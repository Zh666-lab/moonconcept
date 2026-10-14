///|
test "JSON typed context and theory schemas roundtrip" {
  let c = context(["对象\n\""], ["α", "x"], [[true, false]])
  assert_eq(parse_context_json(c.to_json_string()), c)
  let theory = rule_system(2, [implication([0], [1], 2)])
  assert_true(parse_rules_json(theory.to_json_string()).equivalent(theory))
  assert_eq(
    parse_context_json(context([], [], []).to_json_string()).object_count(),
    0,
  )
}

///|
test "JSON schemas reject unknown fields wrong types versions and noninteger indices" {
  let bad = [
    "{}", "[]", "{\"schema\":\"wrong\",\"objects\":[],\"attributes\":[],\"rows\":[]}",
    "{\"schema\":\"moonconcept-context/v1\",\"objects\":[\"a\"],\"attributes\":[\"x\"],\"rows\":[[1]]}",
    "{\"schema\":\"moonconcept-context/v1\",\"objects\":[],\"attributes\":[],\"rows\":[],\"extra\":0}",
  ]
  let mut rejected = 0
  for text in bad {
    ignore(parse_context_json(text)) catch {
      Invalid(_) => rejected = rejected + 1
      _ => ()
    }
  }
  ignore(
    parse_rules_json(
      "{\"schema\":\"moonconcept-rules/v1\",\"dimension\":2,\"rules\":[{\"premise\":[0.5],\"conclusion\":[1]}]}",
    ),
  ) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  assert_eq(rejected, 6)
}
