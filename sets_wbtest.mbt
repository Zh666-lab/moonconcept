///|
test "finite set operations canonicalize without mutating" {
  let a = [3, 1, 1]
  assert_eq(index_set(a), [1, 3])
  assert_eq(a, [3, 1, 1])
  assert_eq(set_union(a, [2]), [1, 2, 3])
  assert_eq(set_intersection(a, [1, 4]), [1])
  assert_eq(set_difference(a, [1]), [3])
  assert_true(set_equal([2, 1], [1, 2, 2]))
  assert_true(set_subset([], []))
  assert_eq(checked_indices([1, 0, 1], 2), [0, 1])
  assert_eq(universe(0), [])
  let mut rejected = false
  ignore(checked_indices([-1], 2)) catch {
    _ => rejected = true
  }
  assert_true(rejected)
}
