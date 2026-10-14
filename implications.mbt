///|
/// Positive Horn implication. Conclusion is canonicalized to exclude the premise.
pub struct Implication {
  premise : Array[Int32]
  conclusion : Array[Int32]
} derive(Eq, Debug)

///|
pub extend Implication with Eq::{equal, not_equal}

///|
pub extend Implication with Debug::{to_repr}

///|
pub fn implication(
  premise : Array[Int32],
  conclusion : Array[Int32],
  dimension : Int32,
) -> Implication raise FcaError {
  if dimension < 0 || dimension > 128 {
    raise Invalid("implication dimension must be 0..128")
  }
  let premise = checked_indices(premise, dimension)
  let conclusion = checked_indices(conclusion, dimension)
  { premise, conclusion: set_difference(conclusion, premise), }
}

///|
/// All public consumers revalidate the mutable result arrays of an implication.
fn check_rule(
  rule : Implication,
  dimension : Int32,
) -> Implication raise FcaError {
  implication(rule.premise, rule.conclusion, dimension)
}

///|
pub fn model_respects(
  model : Array[Int32],
  rule : Implication,
  dimension : Int32,
) -> Bool raise FcaError {
  let model = checked_indices(model, dimension)
  let rule = check_rule(rule, dimension)
  !set_subset(rule.premise, model) || set_subset(rule.conclusion, model)
}

///|
/// Return exactly the observed objects satisfying the premise but missing a conclusion attribute.
pub fn Context::counterexamples(
  self : Context,
  rule : Implication,
) -> Array[Int32] raise FcaError {
  let rule = check_rule(rule, self.attribute_count())
  let result : Array[Int32] = []
  for o in self.extent(rule.premise) {
    let mut satisfies = true
    for a in rule.conclusion {
      if !self.incidence[o][a] {
        satisfies = false
        break
      }
    }
    if !satisfies {
      result.push(o)
    }
  }
  result
}

///|
/// An implication with no observed premise examples is vacuously valid.
pub fn Context::valid_implication(
  self : Context,
  rule : Implication,
) -> Bool raise FcaError {
  self.counterexamples(rule).is_empty()
}

///|
pub fn Context::implication_for(
  self : Context,
  premise : Array[Int32],
) -> Implication raise FcaError {
  let premise = checked_indices(premise, self.attribute_count())
  implication(premise, self.closure(premise), self.attribute_count())
}

///|
/// Violating objects retain their original identities; this is descriptive, not policy enforcement.
pub fn Context::counterexample_labels(
  self : Context,
  rule : Implication,
) -> Array[String] raise FcaError {
  self.object_labels(self.counterexamples(rule))
}
