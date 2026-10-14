///|
/// Remove tautologies and rules entailed by the remaining current theory.
/// Equivalent and irredundant, not a minimum-cardinality or canonical presentation.
pub fn RuleSystem::irredundant(self : RuleSystem) -> RuleSystem raise FcaError {
  if self.rules.length() > 512 {
    raise Budget("rule reduction supports at most 512 rules")
  }
  let mut rules = self.implications()
  let mut i = 0
  while i < rules.length() {
    let remainder : Array[Implication] = []
    for j = 0; j < rules.length(); j = j + 1 {
      if j != i {
        remainder.push(rules[j])
      }
    }
    let without = rule_system(self.dimension, remainder)
    if without.entails(rules[i]) {
      rules = remainder
    } else {
      i = i + 1
    }
  }
  rule_system(self.dimension, rules)
}

///|
/// Delete premise attributes only when the current theory already entails the stronger rule.
pub fn RuleSystem::reduce_premises(
  self : RuleSystem,
) -> RuleSystem raise FcaError {
  if self.rules.length() > 512 {
    raise Budget("premise reduction supports at most 512 rules")
  }
  let rules = self.implications()
  for i = 0; i < rules.length(); i = i + 1 {
    let mut j = 0
    while j < rules[i].premise.length() {
      let smaller = set_difference(rules[i].premise, [rules[i].premise[j]])
      let candidate = implication(smaller, rules[i].conclusion, self.dimension)
      if rule_system(self.dimension, rules).entails(candidate) {
        rules[i] = candidate
      } else {
        j = j + 1
      }
    }
  }
  rule_system(self.dimension, rules)
}

///|
/// Equivalent singleton-conclusion Horn theory; large expansions fail atomically.
pub fn RuleSystem::split_conclusions(
  self : RuleSystem,
) -> RuleSystem raise FcaError {
  let result : Array[Implication] = []
  for rule in self.rules {
    for attribute in rule.conclusion {
      if result.length() >= 4096 {
        raise Budget("singleton theory exceeds 4096 implications")
      }
      result.push(implication(rule.premise, [attribute], self.dimension))
    }
  }
  rule_system(self.dimension, result)
}

///|
/// Equivalent theory with a new implication, retaining the original system unchanged.
pub fn RuleSystem::with_rule(
  self : RuleSystem,
  rule : Implication,
) -> RuleSystem raise FcaError {
  let rules = self.implications()
  rules.push(check_rule(rule, self.dimension))
  rule_system(self.dimension, rules)
}
