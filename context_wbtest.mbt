///|
test "context owns its data and getters do not leak mutation" {
  let names = ["a"]
  let rows = [[true, false]]
  let c = context(names, ["x", "y"], rows)
  names[0] = "changed"
  rows[0][0] = false
  let output = c.rows()
  output[0][0] = false
  assert_eq(c.objects(), ["a"])
  assert_true(c.has(0, 0))
  assert_eq(c.density(), 0.5)
  assert_eq(c.attribute_index("y"), Some(1))
}

///|
test "context rejects duplicate labels and ragged incidence" {
  let mut rejected = 0
  ignore(context(["a", "a"], [], [[], []])) catch {
    _ => rejected = rejected + 1
  }
  ignore(context(["a"], ["x"], [[]])) catch {
    _ => rejected = rejected + 1
  }
  ignore(context([""], [], [[]])) catch {
    _ => rejected = rejected + 1
  }
  assert_eq(rejected, 3)
  let c = context([], ["x"], [])
  assert_eq(c.object_count(), 0)
  assert_eq(c.density(), 0.0)
}
