///|
test "redundancy removal and premise reduction preserve all closures" {
  let s = rule_system(3, [
    implication([0], [1], 3),
    implication([1], [2], 3),
    implication([0], [2], 3),
    implication([0, 1], [2], 3),
    implication([2], [2], 3),
  ])
  let reduced = s.reduce_premises().irredundant()
  assert_true(reduced.equivalent(s))
  assert_eq(reduced.implications().length(), 2)
  for mask = 0; mask < 8; mask = mask + 1 {
    let seed = mask_indices(mask, 3)
    assert_eq(s.closure(seed), reduced.closure(seed))
  }
}

///|
test "singleton expansion and extension keep rule-system value semantics" {
  let s = rule_system(3, [implication([0], [1, 2], 3)])
  let split = s.split_conclusions()
  assert_eq(split.implications().length(), 2)
  assert_true(split.equivalent(s))
  assert_eq(s.with_rule(implication([], [0], 3)).closure([]), [0, 1, 2])
  assert_eq(s.closure([]), [])
}
