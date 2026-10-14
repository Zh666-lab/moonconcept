///|
/// One formal concept: extent' = intent and intent' = extent.
pub struct Concept {
  extent : Array[Int32]
  intent : Array[Int32]
} derive(Eq, Debug)

///|
pub extend Concept with Eq::{equal, not_equal}

///|
pub extend Concept with Debug::{to_repr}

///|
pub fn Context::concept_for(
  self : Context,
  attributes : Array[Int32],
) -> Concept raise FcaError {
  let extent = self.extent(attributes)
  { extent, intent: self.intent(extent), }
}

///|
pub fn Context::valid_concept(
  self : Context,
  concept : Concept,
) -> Bool raise FcaError {
  let a = checked_indices(concept.extent, self.object_count())
  let b = checked_indices(concept.intent, self.attribute_count())
  self.intent(a) == b && self.extent(b) == a
}

///|
/// NextClosure in the input attribute order. The supplied intent must already be closed.
pub fn Context::next_intent(
  self : Context,
  current : Array[Int32],
) -> Array[Int32]? raise FcaError {
  let current = checked_indices(current, self.attribute_count())
  if !self.is_closed(current) {
    raise Invalid("NextClosure requires a closed intent")
  }
  for i = self.attribute_count() - 1; i >= 0; i = i - 1 {
    if !current.contains(i) {
      let seed : Array[Int32] = []
      for j in current {
        if j < i {
          seed.push(j)
        }
      }
      seed.push(i)
      let candidate = self.closure(seed)
      let mut canonical = true
      for j = 0; j < i; j = j + 1 {
        if candidate.contains(j) && !current.contains(j) {
          canonical = false
          break
        }
      }
      if canonical {
        return Some(candidate)
      }
    }
  }
  None
}

///|
/// Enumerate in lectic order; budget failure never returns a silently truncated result.
pub fn Context::concepts(
  self : Context,
  limit~ : Int32 = 4096,
) -> Array[Concept] raise FcaError {
  if limit < 1 || limit > 65536 {
    raise Invalid("concept limit must be 1..65536")
  }
  let result : Array[Concept] = []
  let mut current = self.closure([])
  while true {
    if result.length() >= limit {
      raise Budget("concept enumeration limit reached")
    }
    result.push({ extent: self.extent(current), intent: current.copy(), })
    match self.next_intent(current) {
      Some(next) => current = next
      None => break
    }
  }
  result
}
