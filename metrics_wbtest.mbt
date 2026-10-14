///|
test "association metrics agree with exact contingency counts" {
  let c = sample()
  let rule = implication([1], [2], 3)
  let m = c.rule_metrics(rule)
  assert_eq(m.premise_count, 2)
  assert_eq(m.conclusion_count, 1)
  assert_eq(m.joint_count, 1)
  assert_eq(m.counterexample_count, 1)
  assert_eq(m.confidence, Some(0.5))
  assert_eq(m.lift, Some(1.5))
  assert_eq(c.filter_rules([rule]).length(), 0)
  assert_eq(c.filter_rules([rule], min_confidence=0.5).length(), 1)
}

///|
test "undefined metrics are explicit despite vacuous implication validity" {
  let c = context(["a"], ["x", "y"], [[false, false]])
  let r = implication([0], [1], 2)
  assert_true(c.valid_implication(r))
  assert_eq(c.rule_metrics(r).confidence, None)
  assert_eq(c.rule_metrics(r).lift, None)
  assert_eq(c.filter_rules([r], min_confidence=0.0).length(), 0)
  assert_eq(
    context([], [], []).rule_metrics(implication([], [], 0)).support,
    0.0,
  )
}
