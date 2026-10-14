///|
fn subset_count(dimension : Int32, limit : Int32) -> Int32 raise FcaError {
  if dimension < 0 || dimension > 16 {
    raise Budget("exhaustive algorithms require at most 16 attributes")
  }
  if limit < 1 || limit > 65536 {
    raise Invalid("candidate limit must be 1..65536")
  }
  let count = 1 << dimension
  if count > limit {
    raise Budget("subset candidate budget exceeded")
  }
  count
}

///|
fn mask_indices(mask : Int32, dimension : Int32) -> Array[Int32] {
  let result : Array[Int32] = []
  for i = 0; i < dimension; i = i + 1 {
    if (mask & (1 << i)) != 0 {
      result.push(i)
    }
  }
  result
}

///|
/// Duquenne–Guigues base by the definition of pseudo-intents.
/// Numeric subset order is inclusion-compatible: every strict subset is visited first.
/// This is exact, deliberately bounded, and not a large-scale mining algorithm.
pub fn Context::canonical_basis(
  self : Context,
  candidate_limit~ : Int32 = 65536,
  work_limit~ : Int32 = 1000000,
) -> RuleSystem raise FcaError {
  if work_limit < 1 || work_limit > 10000000 {
    raise Invalid("work limit must be 1..10000000")
  }
  let count = subset_count(self.attribute_count(), candidate_limit)
  let rules : Array[Implication] = []
  let closed_pseudo : Array[Array[Int32]] = []
  let mut work = 0
  for mask = 0; mask < count; mask = mask + 1 {
    work = work + 1
    if work > work_limit {
      raise Budget("pseudo-intent work budget exceeded")
    }
    let candidate = mask_indices(mask, self.attribute_count())
    let closed = self.closure(candidate)
    if candidate != closed {
      let mut pseudo = true
      for i = 0; i < rules.length(); i = i + 1 {
        work = work + 1
        if work > work_limit {
          raise Budget("pseudo-intent work budget exceeded")
        }
        if set_subset(rules[i].premise, candidate) &&
          !set_subset(closed_pseudo[i], candidate) {
          pseudo = false
          break
        }
      }
      if pseudo {
        if rules.length() >= 4096 {
          raise Budget("canonical base exceeds 4096 implications")
        }
        rules.push(implication(candidate, closed, self.attribute_count()))
        closed_pseudo.push(closed)
      }
    }
  }
  rule_system(self.attribute_count(), rules)
}
