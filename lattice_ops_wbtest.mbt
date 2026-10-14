///|
test "diamond lattice meet join extrema and absorption" {
  let c = context(["a", "b"], ["x", "y"], [[true, false], [false, true]])
  let l = c.lattice()
  let x = l.find_intent([0]).unwrap()
  let y = l.find_intent([1]).unwrap()
  assert_eq(l.meet(x, y), l.bottom())
  assert_eq(l.join(x, y), l.top())
  assert_eq(l.meet_all([]), l.top())
  assert_eq(l.join_all([]), l.bottom())
  assert_eq(l.interval(l.bottom(), l.top()).length(), 4)
  for a = 0; a < l.size(); a = a + 1 {
    for b = 0; b < l.size(); b = b + 1 {
      assert_eq(l.meet(a, l.join(a, b)), a)
      assert_eq(l.join(a, l.meet(a, b)), a)
      assert_eq(l.join(a, b), l.join(b, a))
      assert_eq(l.meet(a, b), l.meet(b, a))
    }
  }
}
