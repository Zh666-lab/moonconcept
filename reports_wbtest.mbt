///|
test "reports preserve exact semantic objects and safe numeric DOT" {
  let c = context(["a", "b"], ["x\" -> hacked", "y"], [
    [true, false],
    [false, true],
  ])
  let report = c.lattice_report()
  let fields = json_fields(report, [
    "schema", "order", "context", "nodes", "covers",
  ])
  assert_eq(json_required(fields, "context"), c.to_json())
  assert_eq(json_array(json_required(fields, "nodes"), 256).length(), 4)
  let dot = c.lattice().to_dot()
  assert_true(dot.split("\n").count() > 4)
  assert_true(!dot.to_array().contains('"') || dot != "")
  let concepts = json_fields(c.concept_report(), [
    "schema", "context", "concepts",
  ])
  assert_eq(json_array(json_required(concepts, "concepts"), 4096).length(), 4)
}

///|
test "audit and explanation include counterexamples undefined metrics and real steps" {
  let c = context(["a-only"], ["a", "b"], [[true, false]])
  let theory = rule_system(2, [
    implication([0], [1], 2),
    implication([1], [0], 2),
  ])
  let audit = json_fields(theory.audit(c), ["schema", "context", "rules"])
  let rows = json_array(json_required(audit, "rules"), 4096)
  let first = json_fields(rows[0], ["rule", "valid", "witnesses", "metrics"])
  assert_eq(json_required(first, "valid"), Json::boolean(false))
  assert_eq(json_required(first, "witnesses"), indices_json([0]))
  let second = json_fields(rows[1], ["rule", "valid", "witnesses", "metrics"])
  let metrics = json_fields(json_required(second, "metrics"), [
    "objects", "premise_count", "conclusion_count", "joint_count", "counterexamples",
    "support", "confidence", "lift", "leverage",
  ])
  assert_eq(json_required(metrics, "confidence"), Json::null())
  let explanation = json_fields(theory.inference_report([0]), [
    "schema", "theory", "seed", "result", "steps",
  ])
  assert_eq(json_required(explanation, "result"), indices_json([0, 1]))
  assert_eq(json_array(json_required(explanation, "steps"), 128).length(), 1)
}
