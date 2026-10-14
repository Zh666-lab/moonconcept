///|
test "minimal generators exclude redundant supersets and include empty generators" {
  let c = sample()
  assert_eq(c.minimal_generators([0]), [[]])
  assert_eq(c.minimal_generators([0, 1]), [[1]])
  assert_eq(c.minimal_generators([0, 1, 2]), [[2]])
  for r in c.generator_rules([0, 1, 2]) {
    assert_true(c.valid_implication(r))
  }
  assert_eq(c.frequent_concepts(0.5).length(), 2)
}

///|
test "all alternate minimal generators are returned" {
  let c = context(["a", "b"], ["x", "y"], [[true, true], [false, false]])
  assert_eq(c.minimal_generators([0, 1]), [[0], [1]])
  let mut rejected = 0
  ignore(c.minimal_generators([0])) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(c.minimal_generators([0, 1], result_limit=1)) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  assert_eq(rejected, 2)
}
