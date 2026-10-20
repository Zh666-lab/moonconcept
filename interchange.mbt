///|
fn decode_json(text : String) -> Json raise FcaError {
  check_text_size(text)
  let mut depth = 0
  let mut quoted = false
  let mut escaped = false
  for c in text.to_array() {
    if quoted {
      if escaped {
        escaped = false
      } else if c == '\\' {
        escaped = true
      } else if c == '"' {
        quoted = false
      }
    } else if c == '"' {
      quoted = true
    } else if c == '[' || c == '{' {
      depth = depth + 1
      if depth > 16 {
        raise Budget("JSON nesting exceeds 16")
      }
    } else if c == ']' || c == '}' {
      depth = depth - 1
    }
  }
  @json.parse(text[:]) catch {
    _ => raise Invalid("invalid JSON syntax or excessive nesting")
  }
}

///|
fn json_fields(
  value : Json,
  keys : Array[String],
) -> Map[String, Json] raise FcaError {
  match value {
    Object(fields) => {
      if fields.length() != keys.length() {
        raise Invalid("JSON schema has missing or unknown fields")
      }
      for key in keys {
        if !fields.contains(key) {
          raise Invalid("JSON schema is missing a required field")
        }
      }
      fields
    }
    _ => raise Invalid("JSON schema requires an object")
  }
}

///|
fn json_required(
  fields : Map[String, Json],
  key : String,
) -> Json raise FcaError {
  match fields.get(key) {
    Some(value) => value
    None => raise Invalid("JSON required field is missing")
  }
}

///|
fn json_array(value : Json, maximum : Int32) -> Array[Json] raise FcaError {
  match value {
    Array(values) => {
      if values.length() > maximum {
        raise Budget("JSON array exceeds its schema limit")
      }
      values
    }
    _ => raise Invalid("JSON schema requires an array")
  }
}

///|
fn json_integer(value : Json, maximum : Int32) -> Int32 raise FcaError {
  match value {
    Number(n, ..) => {
      if n.is_nan() || n.is_inf() || n < 0.0 || n > maximum.to_double() {
        raise Invalid("JSON integer is outside its supported range")
      }
      let integer = n.to_int()
      if integer.to_double() != n {
        raise Invalid("JSON index or dimension is not an integer")
      }
      integer
    }
    _ => raise Invalid("JSON schema requires an integer")
  }
}

///|
fn json_labels(value : Json, maximum : Int32) -> Array[String] raise FcaError {
  json_array(value, maximum).map(v => {
    match v {
      String(label) => label
      _ => raise Invalid("JSON labels must be strings")
    }
  })
}

///|
fn json_indices(value : Json, dimension : Int32) -> Array[Int32] raise FcaError {
  let indices = json_array(value, 128).map(v => json_integer(v, 127))
  checked_indices(indices, dimension)
}

///|
fn json_schema(
  fields : Map[String, Json],
  expected : String,
) -> Unit raise FcaError {
  match json_required(fields, "schema") {
    String(actual) if actual == expected => ()
    _ => raise Invalid("unsupported JSON schema version")
  }
}

///|
/// Strict typed schema after core JSON parsing. Duplicate object keys follow core's last-wins policy.
/// This data interchange is not a signed/security-policy canonicalization format.
pub fn parse_context_json(text : String) -> Context raise FcaError {
  let fields = json_fields(decode_json(text), [
    "schema", "objects", "attributes", "rows",
  ])
  json_schema(fields, "moonconcept-context/v1")
  let objects = json_labels(json_required(fields, "objects"), 4096)
  let attributes = json_labels(json_required(fields, "attributes"), 128)
  let rows = json_array(json_required(fields, "rows"), 4096).map(row => {
    json_array(row, 128).map(cell => {
      match cell {
        True => true
        False => false
        _ => raise Invalid("JSON incidence cells must be booleans")
      }
    })
  })
  context(objects, attributes, rows)
}

///|
pub fn Context::to_json(self : Context) -> Json {
  Json::object({
    "schema": Json::string("moonconcept-context/v1"),
    "objects": Json::array(self.object_names.map(fn(s) { Json::string(s) })),
    "attributes": Json::array(
      self.attribute_names.map(fn(s) { Json::string(s) }),
    ),
    "rows": Json::array(
      self.incidence.map(fn(row) {
        Json::array(row.map(fn(cell) { Json::boolean(cell) }))
      }),
    ),
  })
}

///|
pub fn Context::to_json_string(self : Context) -> String {
  self.to_json().stringify()
}

///|
/// Preserve numeric tokens in a shadow tree. Core still owns JSON grammar,
/// escaped keys and duplicate-key resolution, so overwritten values are ignored.
fn rule_json_lexemes(text : String) -> Json raise FcaError {
  let chars = text.to_array()
  let out = StringBuilder()
  let mut quoted = false
  let mut escaped = false
  let mut i = 0
  while i < chars.length() {
    let c = chars[i]
    if quoted {
      out.write_char(c)
      if escaped {
        escaped = false
      } else if c == '\\' {
        escaped = true
      } else if c == '"' {
        quoted = false
      }
      i = i + 1
    } else if c == '"' {
      quoted = true
      out.write_char(c)
      i = i + 1
    } else if c == '-' || (c >= '0' && c <= '9') {
      out.write_char('"')
      while i < chars.length() {
        let d = chars[i]
        if (d >= '0' && d <= '9') ||
          d == '-' ||
          d == '+' ||
          d == '.' ||
          d == 'e' ||
          d == 'E' {
          out.write_char(d)
          i = i + 1
        } else {
          break
        }
      }
      out.write_char('"')
    } else {
      out.write_char(c)
      i = i + 1
    }
  }
  // The original input has already passed syntax, size and depth validation.
  @json.parse(out.to_string()[:]) catch {
    _ => raise Invalid("invalid numeric JSON representation")
  }
}

///|
/// The original tree has already checked the field's numeric type. Validate its
/// exact decimal value, not the Double rounded by the standard JSON parser.
fn check_rule_json_number(value : Json) -> Unit raise FcaError {
  let token = match value {
    String(token) => token
    _ => raise Invalid("JSON numeric field has no decimal token")
  }
  let chars = token.to_array()
  let negative = chars[0] == '-'
  let mut i = if negative { 1 } else { 0 }
  let start = i
  let mut digit_count = 0
  let mut integer_digits = 0
  let mut first_nonzero = -1
  let mut last_nonzero = -1
  let mut fraction = false
  while i < chars.length() {
    let digit = chars[i]
    if digit >= '0' && digit <= '9' {
      if digit != '0' {
        if first_nonzero < 0 {
          first_nonzero = digit_count
        }
        last_nonzero = digit_count
      }
      digit_count = digit_count + 1
      if !fraction {
        integer_digits = integer_digits + 1
      }
    } else if digit == '.' {
      fraction = true
    } else {
      break
    }
    i = i + 1
  }
  let end = i
  let mut exponent = 0
  if i < chars.length() {
    i = i + 1
    let mut exponent_negative = false
    if chars[i] == '+' || chars[i] == '-' {
      exponent_negative = chars[i] == '-'
      i = i + 1
    }
    // Exponents beyond the token length cannot change acceptance. Saturation
    // avoids integer overflow even for adversarial exponent strings.
    let cap = chars.length() + 1
    while i < chars.length() {
      if exponent < cap {
        exponent = exponent * 10 + chars[i].to_int() - '0'.to_int()
        if exponent > cap {
          exponent = cap
        }
      }
      i = i + 1
    }
    if exponent_negative {
      exponent = -exponent
    }
  }
  if first_nonzero >= 0 {
    let point = integer_digits + exponent
    if negative || last_nonzero >= point || point - first_nonzero > 3 {
      raise Invalid("JSON numeric field must be an exact integer in 0..128")
    }
    let mut position = 0
    let mut exact = 0
    for j = start; j < end; j = j + 1 {
      if chars[j] != '.' {
        if position >= first_nonzero && position < point {
          exact = exact * 10 + chars[j].to_int() - '0'.to_int()
        }
        position = position + 1
      }
    }
    while position < point {
      exact = exact * 10
      position = position + 1
    }
    if exact > 128 {
      raise Invalid("JSON numeric field must be an exact integer in 0..128")
    }
  }
}

///|
fn check_rule_json_numbers(text : String) -> Unit raise FcaError {
  let fields = json_fields(rule_json_lexemes(text), [
    "schema", "dimension", "rules",
  ])
  check_rule_json_number(json_required(fields, "dimension"))
  for rule in json_array(json_required(fields, "rules"), 4096) {
    let fields = json_fields(rule, ["premise", "conclusion"])
    for key in ["premise", "conclusion"] {
      for index in json_array(json_required(fields, key), 128) {
        check_rule_json_number(index)
      }
    }
  }
}

///|
pub fn parse_rules_json(text : String) -> RuleSystem raise FcaError {
  let value = decode_json(text)
  let fields = json_fields(value, ["schema", "dimension", "rules"])
  json_schema(fields, "moonconcept-rules/v1")
  let dimension = json_integer(json_required(fields, "dimension"), 128)
  let rules = json_array(json_required(fields, "rules"), 4096).map(value => {
    let fields = json_fields(value, ["premise", "conclusion"])
    implication(
      json_indices(json_required(fields, "premise"), dimension),
      json_indices(json_required(fields, "conclusion"), dimension),
      dimension,
    )
  })
  let result = rule_system(dimension, rules)
  check_rule_json_numbers(text)
  result
}

///|
fn implication_json(rule : Implication) -> Json {
  Json::object({
    "premise": Json::array(
      rule.premise.map(fn(i) { Json::number(i.to_double()) }),
    ),
    "conclusion": Json::array(
      rule.conclusion.map(fn(i) { Json::number(i.to_double()) }),
    ),
  })
}

///|
pub fn RuleSystem::to_json(self : RuleSystem) -> Json {
  Json::object({
    "schema": Json::string("moonconcept-rules/v1"),
    "dimension": Json::number(self.attribute_count().to_double()),
    "rules": Json::array(
      self.implications().map(fn(rule) { implication_json(rule) }),
    ),
  })
}

///|
pub fn RuleSystem::to_json_string(self : RuleSystem) -> String {
  self.to_json().stringify()
}
