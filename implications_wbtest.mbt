///|
test "implications canonicalize and expose observed counterexamples" {
  let c = sample()
  let rule = implication([1, 1], [0, 1, 2], 3)
  assert_eq(rule.premise, [1])
  assert_eq(rule.conclusion, [0, 2])
  assert_eq(c.counterexamples(rule), [0])
  assert_eq(c.counterexample_labels(rule), ["alice"])
  assert_true(!c.valid_implication(rule))
  assert_true(c.valid_implication(c.implication_for([2])))
  assert_true(model_respects([0], rule, 3))
  assert_true(!model_respects([1], rule, 3))
}

///|
test "empty support does not change implication truth semantics" {
  let c = context(["a"], ["x", "y"], [[false, false]])
  assert_true(c.valid_implication(implication([0], [1], 2)))
  let r = implication([], [0], 2)
  r.conclusion.push(9)
  let mut rejected = false
  ignore(c.valid_implication(r)) catch {
    Invalid(_) => rejected = true
    _ => ()
  }
  assert_true(rejected)
}
