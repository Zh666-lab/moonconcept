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
fn json_array(value : Json, maximum : Int) -> Array[Json] raise FcaError {
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
fn json_integer(value : Json, maximum : Int) -> Int raise FcaError {
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
fn json_labels(value : Json, maximum : Int) -> Array[String] raise FcaError {
  json_array(value, maximum).map(v => {
    match v {
      String(label) => label
      _ => raise Invalid("JSON labels must be strings")
    }
  })
}

///|
fn json_indices(value : Json, dimension : Int) -> Array[Int] raise FcaError {
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
pub fn parse_rules_json(text : String) -> RuleSystem raise FcaError {
  let fields = json_fields(decode_json(text), ["schema", "dimension", "rules"])
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
  rule_system(dimension, rules)
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
