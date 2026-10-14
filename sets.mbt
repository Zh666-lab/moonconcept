///|
/// Canonical sorted finite integer set. The input is never modified.
pub fn index_set(values : Array[Int]) -> Array[Int] {
  let sorted = values.copy()
  sorted.sort()
  let result : Array[Int] = []
  for value in sorted {
    if result.is_empty() || result[result.length() - 1] != value {
      result.push(value)
    }
  }
  result
}

///|
/// Validate a subset of a dimension; duplicate indices are canonicalized.
pub fn checked_indices(
  values : Array[Int],
  dimension : Int,
) -> Array[Int] raise FcaError {
  if dimension < 0 {
    raise Invalid("negative dimension")
  }
  for value in values {
    if value < 0 || value >= dimension {
      raise Invalid("set index out of range")
    }
  }
  index_set(values)
}

///|
pub fn set_subset(left : Array[Int], right : Array[Int]) -> Bool {
  for value in left {
    if !right.contains(value) {
      return false
    }
  }
  true
}

///|
pub fn set_union(left : Array[Int], right : Array[Int]) -> Array[Int] {
  let values = left.copy()
  for value in right {
    values.push(value)
  }
  index_set(values)
}

///|
pub fn set_intersection(left : Array[Int], right : Array[Int]) -> Array[Int] {
  let result : Array[Int] = []
  for value in left {
    if right.contains(value) {
      result.push(value)
    }
  }
  index_set(result)
}

///|
pub fn set_difference(left : Array[Int], right : Array[Int]) -> Array[Int] {
  let result : Array[Int] = []
  for value in left {
    if !right.contains(value) {
      result.push(value)
    }
  }
  index_set(result)
}

///|
pub fn set_equal(left : Array[Int], right : Array[Int]) -> Bool {
  set_subset(left, right) && set_subset(right, left)
}

///|
pub fn universe(size : Int) -> Array[Int] raise FcaError {
  if size < 0 {
    raise Invalid("negative universe")
  }
  if size > 65536 {
    raise Budget("universe exceeds 65536")
  }
  let result : Array[Int] = []
  for i = 0; i < size; i = i + 1 {
    result.push(i)
  }
  result
}
