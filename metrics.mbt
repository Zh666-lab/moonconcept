///|
/// Confidence/lift are undefined (None), not NaN, when their denominators vanish.
pub struct RuleMetrics {
  object_count : Int32
  premise_count : Int32
  conclusion_count : Int32
  joint_count : Int32
  counterexample_count : Int32
  support : Double
  confidence : Double?
  lift : Double?
  leverage : Double
} derive(Eq, Debug)

///|
pub extend RuleMetrics with Eq::{equal, not_equal}

///|
pub extend RuleMetrics with Debug::{to_repr}

///|
pub struct ScoredRule {
  rule : Implication
  metrics : RuleMetrics
} derive(Eq, Debug)

///|
pub extend ScoredRule with Eq::{equal, not_equal}

///|
pub extend ScoredRule with Debug::{to_repr}

///|
/// Evaluate A -> B after removing A from B; no statistical significance is inferred.
pub fn Context::rule_metrics(
  self : Context,
  rule : Implication,
) -> RuleMetrics raise FcaError {
  let rule = check_rule(rule, self.attribute_count())
  let n = self.object_count()
  let a = self.extent(rule.premise).length()
  let b = self.extent(rule.conclusion).length()
  let joint = self.extent(set_union(rule.premise, rule.conclusion)).length()
  let support = if n == 0 { 0.0 } else { joint.to_double() / n.to_double() }
  let confidence = if a == 0 {
    None
  } else {
    Some(joint.to_double() / a.to_double())
  }
  let lift = if a == 0 || b == 0 || n == 0 {
    None
  } else {
    Some(joint.to_double() * n.to_double() / (a.to_double() * b.to_double()))
  }
  let leverage = if n == 0 {
    0.0
  } else {
    support - a.to_double() * b.to_double() / (n.to_double() * n.to_double())
  }
  {
    object_count: n,
    premise_count: a,
    conclusion_count: b,
    joint_count: joint,
    counterexample_count: a - joint,
    support,
    confidence,
    lift,
    leverage,
  }
}

///|
/// Score an explicit candidate inventory. Undefined confidence never passes a threshold.
pub fn Context::filter_rules(
  self : Context,
  rules : Array[Implication],
  min_support~ : Double = 0.0,
  min_confidence~ : Double = 1.0,
) -> Array[ScoredRule] raise FcaError {
  if !(min_support >= 0.0 && min_support <= 1.0) ||
    !(min_confidence >= 0.0 && min_confidence <= 1.0) {
    raise Invalid(
      "support and confidence thresholds must be finite values in 0..1",
    )
  }
  if rules.length() > 4096 {
    raise Budget("candidate rule inventory exceeds 4096")
  }
  let result : Array[ScoredRule] = []
  for rule in rules {
    let rule = check_rule(rule, self.attribute_count())
    let metrics = self.rule_metrics(rule)
    match metrics.confidence {
      Some(confidence) =>
        if metrics.support >= min_support && confidence >= min_confidence {
          result.push({ rule, metrics, })
        }
      None => ()
    }
  }
  result
}
