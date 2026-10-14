///|
test "expert review reaches exact theory and rejects with real counterexamples" {
  let c = context(["both"], ["a", "b"], [[true, true]])
  let session = exploration(c, rule_system(2, []))
  let question = session.next_question().unwrap()
  assert_eq(question.premise, [])
  assert_eq(question.conclusion, [0, 1])
  let revised = session.reject(question, "a-only", [0])
  assert_eq(session.context().object_count(), 1)
  assert_eq(revised.context().object_count(), 2)
  let q = revised.next_question().unwrap()
  assert_eq(q.conclusion, [0])
  let finished = revised.accept(q)
  assert_eq(finished.next_question(), None)
  assert_eq(finished.theory().closure([1]), [0, 1])
}

///|
test "expert review rejects invalid evidence without modifying session" {
  let c = context(["both"], ["a", "b"], [[true, true]])
  let session = exploration(c, rule_system(2, [implication([], [0], 2)]))
  let q = session.next_question().unwrap()
  let mut rejected = 0
  ignore(session.reject(q, "bad", [])) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(session.reject(q, "not-violating", [0, 1])) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(session.next_question(candidate_limit=1)) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  assert_eq(rejected, 3)
  assert_eq(session.context().object_count(), 1)
}
