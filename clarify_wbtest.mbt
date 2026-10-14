///|
test "clarification exposes duplicate multiplicities and restores concepts" {
  let c = context(["a", "b", "c"], ["x", "y", "z"], [
    [true, true, false],
    [true, true, false],
    [false, false, true],
  ])
  let reduced = c.clarify()
  assert_eq(reduced.object_groups, [[0, 1], [2]])
  assert_eq(reduced.attribute_groups, [[0, 1], [2]])
  assert_eq(reduced.context.object_count(), 2)
  assert_eq(reduced.context.attribute_count(), 2)
  assert_eq(reduced.context.concepts().length(), c.concepts().length())
  for concept in reduced.context.concepts() {
    assert_true(
      c.valid_concept({
        extent: reduced.expand_extent(concept.extent),
        intent: reduced.expand_intent(concept.intent),
      }),
    )
  }
}

///|
test "empty dimensions have well-defined duplicate equivalence classes" {
  let c = context(["a", "b"], [], [[], []]).clarify()
  assert_eq(c.object_groups, [[0, 1]])
  assert_eq(c.attribute_groups, [])
  let d = context([], ["x", "y"], []).clarify()
  assert_eq(d.attribute_groups, [[0, 1]])
}
