///|
/// Errors distinguish invalid data from an explicitly exhausted resource budget.
pub(all) suberror FcaError {
  Invalid(String)
  Budget(String)
} derive(Eq, Debug)

///|
/// Owned binary incidence context. All input arrays and exposed arrays are copied.
pub struct Context {
  priv object_names : Array[String]
  priv attribute_names : Array[String]
  priv incidence : Array[Array[Bool]]
} derive(Eq, Debug)

///|
fn validate_labels(
  labels : Array[String],
  kind : String,
) -> Unit raise FcaError {
  for i = 0; i < labels.length(); i = i + 1 {
    if labels[i].length() == 0 || labels[i].length() > 4096 {
      raise Invalid("\{kind}: label length must be 1..4096")
    }
    for j = 0; j < i; j = j + 1 {
      if labels[i] == labels[j] {
        raise Invalid("\{kind}: duplicate label at index \{i}")
      }
    }
  }
}

///|
/// Up to 4096 objects and 128 attributes; empty dimensions have standard FCA semantics.
pub fn context(
  objects : Array[String],
  attributes : Array[String],
  rows : Array[Array[Bool]],
) -> Context raise FcaError {
  if objects.length() > 4096 || attributes.length() > 128 {
    raise Budget("context dimensions exceed 4096 objects or 128 attributes")
  }
  validate_labels(objects, "objects")
  validate_labels(attributes, "attributes")
  if rows.length() != objects.length() {
    raise Invalid("row count does not match object count")
  }
  let copied : Array[Array[Bool]] = []
  for row in rows {
    if row.length() != attributes.length() {
      raise Invalid("row width does not match attribute count")
    }
    copied.push(row.copy())
  }
  {
    object_names: objects.copy(),
    attribute_names: attributes.copy(),
    incidence: copied,
  }
}

///|
pub fn Context::object_count(self : Context) -> Int32 {
  self.object_names.length()
}

///|
pub fn Context::attribute_count(self : Context) -> Int32 {
  self.attribute_names.length()
}

///|
pub fn Context::objects(self : Context) -> Array[String] {
  self.object_names.copy()
}

///|
pub fn Context::attributes(self : Context) -> Array[String] {
  self.attribute_names.copy()
}

///|
pub fn Context::rows(self : Context) -> Array[Array[Bool]] {
  self.incidence.map(fn(row) { row.copy() })
}

///|
pub fn Context::has(
  self : Context,
  object : Int32,
  attribute : Int32,
) -> Bool raise FcaError {
  if object < 0 || object >= self.object_count() {
    raise Invalid("object index out of range")
  }
  if attribute < 0 || attribute >= self.attribute_count() {
    raise Invalid("attribute index out of range")
  }
  self.incidence[object][attribute]
}

///|
pub fn Context::object_index(self : Context, name : String) -> Int32? {
  for i = 0; i < self.object_count(); i = i + 1 {
    if self.object_names[i] == name {
      return Some(i)
    }
  }
  None
}

///|
pub fn Context::attribute_index(self : Context, name : String) -> Int32? {
  for i = 0; i < self.attribute_count(); i = i + 1 {
    if self.attribute_names[i] == name {
      return Some(i)
    }
  }
  None
}

///|
pub fn Context::density(self : Context) -> Double {
  let cells = self.object_count() * self.attribute_count()
  if cells == 0 {
    return 0.0
  }
  let mut present = 0
  for row in self.incidence {
    for value in row {
      if value {
        present = present + 1
      }
    }
  }
  present.to_double() / cells.to_double()
}

///|
pub extend FcaError with Eq::{equal, not_equal}

///|
pub extend FcaError with Debug::{to_repr}

///|
pub extend Context with Eq::{equal, not_equal}

///|
pub extend Context with Debug::{to_repr}
