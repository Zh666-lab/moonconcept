///|
/// Clarification removes only duplicate incidence rows/columns, not reducible nonduplicates.
/// Groups map each representative back to every original index, so multiplicities are explicit.
pub struct Clarification {
  context : Context
  priv object_groups : Array[Array[Int]]
  priv attribute_groups : Array[Array[Int]]
} derive(Debug)

///|
pub extend Clarification with Debug::{to_repr}

///|
pub fn Context::clarify(self : Context) -> Clarification raise FcaError {
  let object_groups : Array[Array[Int]] = []
  let row_keys : Map[String, Int] = Map([])
  let object_representatives : Array[Int] = []
  for o = 0; o < self.object_count(); o = o + 1 {
    let key = self.incidence[o]
      .map(fn(present) { if present { "1" } else { "0" } })
      .join("")
    match row_keys.get(key) {
      Some(group) => object_groups[group].push(o)
      None => {
        row_keys[key] = object_groups.length()
        object_groups.push([o])
        object_representatives.push(o)
      }
    }
  }
  let attribute_groups : Array[Array[Int]] = []
  let column_keys : Map[String, Int] = Map([])
  let attribute_representatives : Array[Int] = []
  for a = 0; a < self.attribute_count(); a = a + 1 {
    let column : Array[String] = []
    for o = 0; o < self.object_count(); o = o + 1 {
      column.push(if self.incidence[o][a] { "1" } else { "0" })
    }
    let key = column.join("")
    match column_keys.get(key) {
      Some(group) => attribute_groups[group].push(a)
      None => {
        column_keys[key] = attribute_groups.length()
        attribute_groups.push([a])
        attribute_representatives.push(a)
      }
    }
  }
  {
    context: self.project(object_representatives, attribute_representatives),
    object_groups,
    attribute_groups,
  }
}

///|
pub fn Clarification::expand_extent(
  self : Clarification,
  extent : Array[Int],
) -> Array[Int] raise FcaError {
  let selected = checked_indices(extent, self.object_groups.length())
  let result : Array[Int] = []
  for group in selected {
    for value in self.object_groups[group] {
      result.push(value)
    }
  }
  index_set(result)
}

///|
pub fn Clarification::expand_intent(
  self : Clarification,
  intent : Array[Int],
) -> Array[Int] raise FcaError {
  let selected = checked_indices(intent, self.attribute_groups.length())
  let result : Array[Int] = []
  for group in selected {
    for value in self.attribute_groups[group] {
      result.push(value)
    }
  }
  index_set(result)
}

///|
pub fn Clarification::object_classes(self : Clarification) -> Array[Array[Int]] {
  self.object_groups.map(fn(group) { group.copy() })
}

///|
pub fn Clarification::attribute_classes(
  self : Clarification,
) -> Array[Array[Int]] {
  self.attribute_groups.map(fn(group) { group.copy() })
}
