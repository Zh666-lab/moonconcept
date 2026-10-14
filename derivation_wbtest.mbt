///|
fn sample() -> Context raise FcaError {
  context(["alice", "bob", "cara"], ["read", "write", "admin"], [
    [true, true, false],
    [true, false, false],
    [true, true, true],
  ])
}

///|
test "Galois derivations and vacuous intersection semantics" {
  let c = sample()
  assert_eq(c.intent([]), [0, 1, 2])
  assert_eq(c.extent([]), [0, 1, 2])
  assert_eq(c.closure([]), [0])
  assert_eq(c.closure([2]), [0, 1, 2])
  assert_eq(c.object_closure([0]), [0, 2])
  assert_eq(c.support([2]), 1.0 / 3.0)
  assert_eq(c.attribute_labels([2, 0]), ["read", "admin"])
  assert_eq(c.object_labels([1]), ["bob"])
  assert_true(c.is_closed([0, 1]))
}

///|
test "empty contexts obey Galois laws" {
  let c = context([], ["x", "y"], [])
  assert_eq(c.closure([]), [0, 1])
  assert_eq(c.extent([0]), [])
  assert_eq(c.support([]), 0.0)
  let d = context(["a"], [], [[]])
  assert_eq(d.intent([0]), [])
  assert_eq(d.object_closure([]), [0])
}
