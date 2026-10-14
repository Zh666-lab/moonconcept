///|
fn check_text_size(text : String) -> Unit raise FcaError {
  if text.length() > 33554432 {
    raise Budget("text input exceeds 32 Mi UTF-16 code units")
  }
}

///|
fn decimal_count(text : String, maximum : Int) -> Int raise FcaError {
  let chars = text.to_array()
  if chars.is_empty() || chars.length() > 5 {
    raise Invalid("expected a bounded unsigned decimal count")
  }
  let mut result = 0
  for c in chars {
    if c < '0' || c > '9' {
      raise Invalid("count contains a nondecimal character")
    }
    result = result * 10 + c.to_int() - '0'.to_int()
    if result > maximum {
      raise Budget("declared dimension exceeds the supported maximum")
    }
  }
  result
}

///|
/// Strict Burmeister binary CXT: B, blank, counts, blank, labels, X/. incidence.
/// LF and CRLF accepted; one optional terminal line ending, no trailing records.
pub fn parse_cxt(text : String) -> Context raise FcaError {
  check_text_size(text)
  let normalized = text.replace_all(old="\r\n", new="\n")
  if normalized.to_array().contains('\r') {
    raise Invalid("CXT contains a bare carriage return")
  }
  let lines = normalized.split("\n").map(fn(s) { s.to_owned() }).to_array()
  if normalized.length() > 0 && lines[lines.length() - 1] == "" {
    ignore(lines.pop())
  }
  if lines.length() < 5 || lines[0] != "B" || lines[1] != "" || lines[4] != "" {
    raise Invalid("invalid binary CXT header")
  }
  let objects = decimal_count(lines[2], 4096)
  let attributes = decimal_count(lines[3], 128)
  if lines.length() != 5 + objects + attributes + objects {
    raise Invalid("CXT record count mismatch or trailing content")
  }
  let object_names = Array::makei(objects, fn(i) { lines[5 + i] })
  let attribute_names = Array::makei(attributes, fn(i) {
    lines[5 + objects + i]
  })
  let rows : Array[Array[Bool]] = []
  for o = 0; o < objects; o = o + 1 {
    let chars = lines[5 + objects + attributes + o].to_array()
    if chars.length() != attributes {
      raise Invalid("CXT incidence row width mismatch")
    }
    let row : Array[Bool] = []
    for c in chars {
      match c {
        'X' => row.push(true)
        '.' => row.push(false)
        _ => raise Invalid("CXT incidence cells must be X or .")
      }
    }
    rows.push(row)
  }
  context(object_names, attribute_names, rows)
}

///|
/// Reject multiline labels because CXT has no quoting mechanism; use CSV/JSON instead.
pub fn Context::to_cxt(self : Context) -> String raise FcaError {
  let lines = [
    "B",
    "",
    self.object_count().to_string(),
    self.attribute_count().to_string(),
    "",
  ]
  for name in self.object_names {
    if name.to_array().contains('\n') || name.to_array().contains('\r') {
      raise Invalid("CXT cannot represent multiline labels")
    }
    lines.push(name)
  }
  for name in self.attribute_names {
    if name.to_array().contains('\n') || name.to_array().contains('\r') {
      raise Invalid("CXT cannot represent multiline labels")
    }
    lines.push(name)
  }
  for row in self.incidence {
    lines.push(row.map(fn(value) { if value { "X" } else { "." } }).join(""))
  }
  lines.join("\n") + "\n"
}
