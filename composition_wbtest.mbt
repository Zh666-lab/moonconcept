///|
test "composition aligns labels instead of relying on row order" {
  let c = context(["a", "b"], ["x"], [[true], [false]])
  let d = context(["b", "a"], ["y"], [[true], [false]])
  assert_eq(c.apposition(d).rows(), [[true, false], [false, true]])
  let e = context(["c"], ["y", "x"], [[true, false]])
  assert_eq(c.apposition(d).subposition(e).rows(), [
    [true, false],
    [false, true],
    [false, true],
  ])
}

///|
test "composition rejects conflicting identities" {
  let c = context(["a"], ["x"], [[true]])
  let mut rejected = 0
  ignore(c.apposition(c)) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(c.subposition(c)) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(c.apposition(context(["b"], ["y"], [[true]]))) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  assert_eq(rejected, 3)
}
