///|
test "dual projection and incremental observations preserve ownership" {
  let c = sample()
  assert_eq(c.dual().dual(), c)
  let p = c.project([2, 0, 0], [2, 0])
  assert_eq(p.objects(), ["alice", "cara"])
  assert_eq(p.rows(), [[true, false], [true, true]])
  let d = c.with_object("dave", [1])
  assert_eq(d.object_count(), 4)
  assert_eq(d.closure([]), [])
  assert_eq(d.without_object(3), c)
  assert_eq(c.object_count(), 3)
  assert_eq(context_from_sets(["a"], ["x", "y"], [[1, 1]]).rows(), [
    [false, true],
  ])
}

///|
test "projection rejects indices and duplicate observation identities" {
  let c = sample()
  let mut rejected = 0
  ignore(c.project([8], [])) catch {
    _ => rejected = rejected + 1
  }
  ignore(c.with_object("alice", [])) catch {
    _ => rejected = rejected + 1
  }
  ignore(c.without_object(-1)) catch {
    _ => rejected = rejected + 1
  }
  assert_eq(rejected, 3)
}
