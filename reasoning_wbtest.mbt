///|
test "forward chaining records new facts and handles cycles" {
  let rules = [
    implication([1], [2], 3),
    implication([0], [1], 3),
    implication([2], [0], 3),
  ]
  let system = rule_system(3, rules)
  let trace = system.trace([0])
  assert_eq(trace.result, [0, 1, 2])
  assert_eq(trace.steps.map(fn(s) { s.rule_index }), [1, 0])
  assert_true(system.entails(implication([0], [2], 3)))
  assert_true(system.is_model([]))
  assert_true(!system.is_model([0]))
  rules[0].conclusion.clear()
  assert_eq(system.closure([0]), [0, 1, 2])
  let copied = system.implications()
  copied[0].conclusion.clear()
  assert_eq(system.closure([0]), [0, 1, 2])
}

///|
test "empty premises and semantic equivalence" {
  let a = rule_system(3, [implication([], [0], 3), implication([0], [1], 3)])
  let b = rule_system(3, [implication([], [0, 1], 3)])
  assert_true(a.equivalent(b))
  assert_eq(a.closure([]), [0, 1])
  assert_true(!a.equivalent(rule_system(2, [])))
}
