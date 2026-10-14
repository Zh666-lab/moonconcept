///|
/// Attributes shared by all selected objects. Empty selection yields every attribute.
pub fn Context::intent(
  self : Context,
  objects : Array[Int32],
) -> Array[Int32] raise FcaError {
  let selected = checked_indices(objects, self.object_count())
  let result : Array[Int32] = []
  for a = 0; a < self.attribute_count(); a = a + 1 {
    let mut common = true
    for o in selected {
      if !self.incidence[o][a] {
        common = false
        break
      }
    }
    if common {
      result.push(a)
    }
  }
  result
}

///|
/// Objects having all selected attributes. Empty selection yields every object.
pub fn Context::extent(
  self : Context,
  attributes : Array[Int32],
) -> Array[Int32] raise FcaError {
  let selected = checked_indices(attributes, self.attribute_count())
  let result : Array[Int32] = []
  for o = 0; o < self.object_count(); o = o + 1 {
    let mut matches = true
    for a in selected {
      if !self.incidence[o][a] {
        matches = false
        break
      }
    }
    if matches {
      result.push(o)
    }
  }
  result
}

///|
/// Galois attribute closure B''. Extensivity, monotonicity and idempotence hold.
pub fn Context::closure(
  self : Context,
  attributes : Array[Int32],
) -> Array[Int32] raise FcaError {
  self.intent(self.extent(attributes))
}

///|
pub fn Context::object_closure(
  self : Context,
  objects : Array[Int32],
) -> Array[Int32] raise FcaError {
  self.extent(self.intent(objects))
}

///|
pub fn Context::is_closed(
  self : Context,
  attributes : Array[Int32],
) -> Bool raise FcaError {
  let selected = checked_indices(attributes, self.attribute_count())
  self.closure(selected) == selected
}

///|
/// Relative support is defined as zero for an empty object universe.
pub fn Context::support(
  self : Context,
  attributes : Array[Int32],
) -> Double raise FcaError {
  let count = self.extent(attributes).length()
  if self.object_count() == 0 {
    0.0
  } else {
    count.to_double() / self.object_count().to_double()
  }
}

///|
pub fn Context::attribute_labels(
  self : Context,
  indices : Array[Int32],
) -> Array[String] raise FcaError {
  checked_indices(indices, self.attribute_count()).map(fn(i) {
    self.attribute_names[i]
  })
}

///|
pub fn Context::object_labels(
  self : Context,
  indices : Array[Int32],
) -> Array[String] raise FcaError {
  checked_indices(indices, self.object_count()).map(fn(i) {
    self.object_names[i]
  })
}
