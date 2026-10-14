///|
/// All inclusion-minimal generators of a closed intent, not only minimum-size generators.
/// Inclusion-compatible enumeration prunes supersets of previously found generators.
pub fn Context::minimal_generators(
  self : Context,
  intent : Array[Int],
  candidate_limit? : Int = 65536,
  result_limit? : Int = 4096,
) -> Array[Array[Int]] raise FcaError {
  let target = checked_indices(intent, self.attribute_count())
  if !self.is_closed(target) {
    raise Invalid("generator target must be a closed intent")
  }
  if result_limit < 1 || result_limit > 65536 {
    raise Invalid("generator result limit must be 1..65536")
  }
  let count = subset_count(target.length(), candidate_limit)
  let result : Array[Array[Int]] = []
  for mask = 0; mask < count; mask = mask + 1 {
    let candidate = mask_indices(mask, target.length()).map(fn(i) { target[i] })
    let mut dominated = false
    for known in result {
      if set_subset(known, candidate) {
        dominated = true
        break
      }
    }
    if !dominated && self.closure(candidate) == target {
      if result.length() >= result_limit {
        raise Budget("generator result budget exceeded")
      }
      result.push(candidate)
    }
  }
  result
}

///|
/// Exact closure rules from minimal generators; this is not the canonical base.
pub fn Context::generator_rules(
  self : Context,
  intent : Array[Int],
  candidate_limit? : Int = 65536,
) -> Array[Implication] raise FcaError {
  let target = checked_indices(intent, self.attribute_count())
  let generators = self.minimal_generators(target, candidate_limit~)
  generators.map(generator => {
    implication(generator, target, self.attribute_count())
  })
}

///|
/// Closed patterns meeting support; budget applies before filtering, not just to survivors.
pub fn Context::frequent_concepts(
  self : Context,
  min_support : Double,
  limit? : Int = 4096,
) -> Array[Concept] raise FcaError {
  if !(min_support >= 0.0 && min_support <= 1.0) {
    raise Invalid("support threshold must be in 0..1")
  }
  let all = self.concepts(limit~)
  let result : Array[Concept] = []
  for concept in all {
    let support = if self.object_count() == 0 {
      0.0
    } else {
      concept.extent.length().to_double() / self.object_count().to_double()
    }
    if support >= min_support {
      result.push(concept)
    }
  }
  result
}
