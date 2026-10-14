///|
fn csv_record(
  records : Array[Array[String]],
  row : Array[String],
) -> Unit raise FcaError {
  if row.length() > 129 || records.length() >= 4097 {
    raise Budget("CSV dimensions exceed 4096 objects or 128 attributes")
  }
  records.push(row.copy())
}

///|
/// State machine: 0 field-start, 1 unquoted, 2 quoted, 3 after closing quote.
/// Commas and CRLF/LF delimit outside quotes; doubled quotes escape inside quotes.
fn csv_table(text : String) -> Array[Array[String]] raise FcaError {
  check_text_size(text)
  if text.length() == 0 {
    raise Invalid("CSV requires a header record")
  }
  let chars = text.to_array()
  let records : Array[Array[String]] = []
  let row : Array[String] = []
  let field = StringBuilder()
  let mut size = 0
  let mut state = 0
  let mut pending = false
  let mut i = 0
  while i < chars.length() {
    let c = chars[i]
    if state == 2 {
      if c == '"' {
        if i + 1 < chars.length() && chars[i + 1] == '"' {
          field.write_char('"')
          size = size + 1
          i = i + 1
        } else {
          state = 3
        }
      } else {
        field.write_char(c)
        size = size + c.utf16_len()
      }
    } else if c == ',' || c == '\n' || c == '\r' {
      row.push(field.to_string())
      if row.length() > 129 {
        raise Budget("CSV row exceeds 129 fields")
      }
      field.reset()
      size = 0
      state = 0
      if c == ',' {
        pending = true
      } else {
        if c == '\r' {
          if i + 1 >= chars.length() || chars[i + 1] != '\n' {
            raise Invalid("CSV bare carriage return outside quotes")
          }
          i = i + 1
        }
        csv_record(records, row)
        row.clear()
        pending = false
      }
    } else if c == '"' {
      if state != 0 {
        raise Invalid("CSV quote is only allowed at the start of a field")
      }
      state = 2
      pending = true
    } else {
      if state == 3 {
        raise Invalid("CSV has content after a closing quote")
      }
      field.write_char(c)
      size = size + c.utf16_len()
      state = 1
      pending = true
    }
    if size > 4096 {
      raise Budget("CSV field exceeds 4096 UTF-16 code units")
    }
    i = i + 1
  }
  if state == 2 {
    raise Invalid("CSV contains an unterminated quoted field")
  }
  if pending {
    row.push(field.to_string())
    csv_record(records, row)
  }
  if records.is_empty() {
    raise Invalid("CSV requires a header record")
  }
  records
}

///|
/// Incidence CSV profile: literal first header 'object', then unique attributes; cells 0/1.
/// Quoted multiline labels are supported; no whitespace trimming or truthy coercion.
pub fn parse_csv(text : String) -> Context raise FcaError {
  let records = csv_table(text)
  let header = records[0]
  if header.is_empty() || header[0] != "object" {
    raise Invalid("CSV first header must be object")
  }
  let attributes : Array[String] = []
  for a = 1; a < header.length(); a = a + 1 {
    attributes.push(header[a])
  }
  let objects : Array[String] = []
  let rows : Array[Array[Bool]] = []
  for o = 1; o < records.length(); o = o + 1 {
    let record = records[o]
    if record.length() != header.length() {
      raise Invalid("CSV contains a ragged record")
    }
    objects.push(record[0])
    let row : Array[Bool] = []
    for a = 1; a < record.length(); a = a + 1 {
      match record[a] {
        "0" => row.push(false)
        "1" => row.push(true)
        _ => raise Invalid("CSV incidence cells must be exactly 0 or 1")
      }
    }
    rows.push(row)
  }
  context(objects, attributes, rows)
}

///|
fn csv_quote(value : String) -> String {
  "\"" + value.replace_all(old="\"", new="\"\"") + "\""
}

///|
/// Dataset export, not spreadsheet-safe sanitization: labels are preserved, including formulas.
pub fn Context::to_csv(self : Context) -> String {
  let header = [csv_quote("object")]
  for name in self.attribute_names {
    header.push(csv_quote(name))
  }
  let records = [header.join(",")]
  for o = 0; o < self.object_count(); o = o + 1 {
    let row = [csv_quote(self.object_names[o])]
    for cell in self.incidence[o] {
      row.push(if cell { "1" } else { "0" })
    }
    records.push(row.join(","))
  }
  records.join("\r\n") + "\r\n"
}
