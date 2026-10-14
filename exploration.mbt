///|
/// Immutable, bounded expert-review assistant; not a claim of canonical exploration order.
/// Observations and accepted theory are kept consistent at every transition.
pub struct Exploration {
  priv observed : Context
  priv accepted : RuleSystem
} derive(Debug)

///|
pub extend Exploration with Debug::{to_repr}

///|
pub fn exploration(
  observed : Context,
  accepted : RuleSystem,
) -> Exploration raise FcaError {
  if observed.attribute_count() != accepted.attribute_count() {
    raise Invalid("exploration vocabulary dimensions differ")
  }
  for rule in accepted.implications() {
    if !observed.valid_implication(rule) {
      raise Invalid("accepted theory contradicts an observed object")
    }
  }
  { observed, accepted, }
}

///|
pub fn Exploration::context(self : Exploration) -> Context {
  self.observed
}

///|
pub fn Exploration::theory(self : Exploration) -> RuleSystem {
  self.accepted
}

///|
/// None proves equality of theory closure and observed closure for this finite vocabulary.
/// Budget exhaustion raises rather than incorrectly signaling completion.
pub fn Exploration::next_question(
  self : Exploration,
  candidate_limit~ : Int32 = 65536,
) -> Implication? raise FcaError {
  let dimension = self.observed.attribute_count()
  let total = subset_count(dimension, candidate_limit)
  if candidate_limit < 1 || candidate_limit > 65536 || total > candidate_limit {
    raise Budget("exploration requires a complete bounded subset scan")
  }
  for mask = 0; mask < total; mask = mask + 1 {
    let premise = mask_indices(mask, dimension)
    let rule = self.observed.implication_for(premise)
    if !self.accepted.entails(rule) {
      return Some(rule)
    }
  }
  None
}

///|
/// Expert acceptance is meaningful only for a non-entailed implication valid in observations.
pub fn Exploration::accept(
  self : Exploration,
  question : Implication,
) -> Exploration raise FcaError {
  let rule = check_rule(question, self.observed.attribute_count())
  if self.accepted.entails(rule) || !self.observed.valid_implication(rule) {
    raise Invalid("accept requires a new observation-valid implication")
  }
  let rules = self.accepted.implications()
  rules.push(rule)
  exploration(
    self.observed,
    rule_system(self.observed.attribute_count(), rules),
  )
}

///|
/// Reject using a genuinely violating new complete object that respects all accepted rules.
/// No transition is made on inconsistent/duplicate evidence.
pub fn Exploration::reject(
  self : Exploration,
  question : Implication,
  object_name : String,
  attributes : Array[Int32],
) -> Exploration raise FcaError {
  let dimension = self.observed.attribute_count()
  let rule = check_rule(question, dimension)
  let attributes = checked_indices(attributes, dimension)
  if self.accepted.entails(rule) || !self.observed.valid_implication(rule) {
    raise Invalid("reject requires a new observation-valid implication")
  }
  if model_respects(attributes, rule, dimension) {
    raise Invalid("counterexample does not violate the question")
  }
  if !self.accepted.is_model(attributes) {
    raise Invalid("counterexample contradicts accepted theory")
  }
  exploration(self.observed.with_object(object_name, attributes), self.accepted)
}
