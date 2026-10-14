///|
pub struct RuleSystem {
  priv dimension : Int32
  priv rules : Array[Implication]
} derive(Debug)

///|
pub extend RuleSystem with Debug::{to_repr}

///|
pub struct InferenceStep {
  rule_index : Int32
  added : Array[Int32]
} derive(Eq, Debug)

///|
pub extend InferenceStep with Eq::{equal, not_equal}

///|
pub extend InferenceStep with Debug::{to_repr}

///|
pub struct ClosureTrace {
  result : Array[Int32]
  steps : Array[InferenceStep]
} derive(Eq, Debug)

///|
pub extend ClosureTrace with Eq::{equal, not_equal}

///|
pub extend ClosureTrace with Debug::{to_repr}

///|
pub fn rule_system(
  dimension : Int32,
  rules : Array[Implication],
) -> RuleSystem raise FcaError {
  if dimension < 0 || dimension > 128 {
    raise Invalid("rule-system dimension must be 0..128")
  }
  if rules.length() > 4096 {
    raise Budget("rule system exceeds 4096 implications")
  }
  { dimension, rules: rules.map(rule => check_rule(rule, dimension)), }
}

///|
pub fn RuleSystem::attribute_count(self : RuleSystem) -> Int32 {
  self.dimension
}

///|
pub fn RuleSystem::implications(self : RuleSystem) -> Array[Implication] {
  self.rules.map(fn(rule) {
    { premise: rule.premise.copy(), conclusion: rule.conclusion.copy(), }
  })
}

///|
/// Deterministic Armstrong forward chaining. Each recorded step adds at least one attribute.
pub fn RuleSystem::trace(
  self : RuleSystem,
  seed : Array[Int32],
) -> ClosureTrace raise FcaError {
  let mut result = checked_indices(seed, self.dimension)
  let steps : Array[InferenceStep] = []
  let mut changed = true
  while changed {
    changed = false
    for i = 0; i < self.rules.length(); i = i + 1 {
      let rule = self.rules[i]
      if set_subset(rule.premise, result) {
        let added = set_difference(rule.conclusion, result)
        if !added.is_empty() {
          result = set_union(result, added)
          steps.push({ rule_index: i, added, })
          changed = true
        }
      }
    }
  }
  { result, steps, }
}

///|
pub fn RuleSystem::closure(
  self : RuleSystem,
  seed : Array[Int32],
) -> Array[Int32] raise FcaError {
  self.trace(seed).result
}

///|
pub fn RuleSystem::entails(
  self : RuleSystem,
  rule : Implication,
) -> Bool raise FcaError {
  let rule = check_rule(rule, self.dimension)
  set_subset(rule.conclusion, self.closure(rule.premise))
}

///|
pub fn RuleSystem::equivalent(
  self : RuleSystem,
  other : RuleSystem,
) -> Bool raise FcaError {
  if self.dimension != other.dimension {
    return false
  }
  for rule in self.rules {
    if !other.entails(rule) {
      return false
    }
  }
  for rule in other.rules {
    if !self.entails(rule) {
      return false
    }
  }
  true
}

///|
pub fn RuleSystem::is_model(
  self : RuleSystem,
  attributes : Array[Int32],
) -> Bool raise FcaError {
  let attributes = checked_indices(attributes, self.dimension)
  self.closure(attributes) == attributes
}
