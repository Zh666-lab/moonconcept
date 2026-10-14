///|
test "NextClosure enumerates each concept exactly once" {
  let c = sample()
  let concepts = c.concepts()
  assert_eq(concepts.length(), 3)
  assert_eq(concepts.map(fn(x) { x.intent }), [[0], [0, 1], [0, 1, 2]])
  for x in concepts {
    assert_true(c.valid_concept(x))
  }
  assert_eq(c.concept_for([2]).extent, [2])
  assert_eq(c.next_intent([0, 1, 2]), None)
}

///|
test "concept budget fails rather than truncating" {
  let c = sample()
  let mut rejected = 0
  ignore(c.concepts(limit=2)) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(c.next_intent([])) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  assert_eq(rejected, 2)
  assert_eq(context([], [], []).concepts().length(), 1)
}
