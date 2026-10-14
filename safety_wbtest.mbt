///|
test "owned context theory lattice and clarification resist caller mutation" {
  let names = ["a", "b"]
  let rows = [[true, true], [false, false]]
  let c = context(names, ["x", "y"], rows)
  names[0] = "changed"
  rows[0][0] = false
  let exposed = c.rows()
  exposed[0][1] = false
  assert_eq(c.objects(), ["a", "b"])
  assert_eq(c.rows(), [[true, true], [false, false]])
  let rule = implication([0], [1], 2)
  let theory = rule_system(2, [rule])
  rule.conclusion.clear()
  let returned = theory.implications()
  returned[0].premise.push(99)
  assert_eq(theory.closure([0]), [0, 1])
  let graph = c.lattice()
  let node = graph.concept(0)
  node.intent.push(99)
  assert_true(!graph.concept(0).intent.contains(99))
  let clarified = c.clarify()
  let groups = clarified.attribute_classes()
  groups[0][0] = 99
  assert_eq(clarified.expand_intent([0]), [0, 1])
}

///|
test "exact budgets fail atomically rather than returning truncated results" {
  let c = context(["a", "b"], ["x", "y"], [[true, false], [false, true]])
  assert_eq(c.concepts(limit=4).length(), 4)
  let mut rejected = 0
  ignore(c.concepts(limit=3)) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(c.lattice(limit=3)) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(c.canonical_basis(candidate_limit=3)) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(c.canonical_basis(work_limit=1)) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  let twins = context(["a", "b"], ["x", "y"], [[true, true], [false, false]])
  assert_eq(twins.minimal_generators([0, 1]).length(), 2)
  ignore(twins.minimal_generators([0, 1], result_limit=1)) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  assert_eq(rejected, 5)
}

///|
test "consumer validation rejects corrupted public implication results" {
  let c = context(["a"], ["x"], [[true]])
  let corrupted = implication([], [0], 1)
  corrupted.conclusion.push(99)
  let mut rejected = 0
  ignore(c.valid_implication(corrupted)) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(c.rule_metrics(corrupted)) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(rule_system(1, [corrupted])) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(c.closure([-1])) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(c.has(1, 0)) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(c.lattice().meet(0, 99)) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  assert_eq(rejected, 6)
}

///|
test "format limits and JSON lexical nesting guard are enforced" {
  let long_label = Array::make(4097, "a").join("")
  let mut rejected = 0
  ignore(parse_csv("object\n" + long_label)) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(parse_cxt("B\n\n4097\n0\n\n")) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  let deep = Array::make(17, "[").join("") + "0" + Array::make(17, "]").join("")
  ignore(parse_context_json(deep)) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(
    parse_rules_json(
      "{\"schema\":\"moonconcept-rules/v1\",\"dimension\":1e999,\"rules\":[]}",
    ),
  ) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  assert_eq(rejected, 4)
  let c = context(["{[\\\"}]"], ["x"], [[true]])
  assert_eq(parse_context_json(c.to_json_string()), c)
}

///|
test "core JSON duplicate field last-wins behavior is explicitly documented and tested" {
  let text = "{\"schema\":\"obsolete\",\"schema\":\"moonconcept-context/v1\",\"objects\":[],\"attributes\":[],\"rows\":[]}"
  assert_eq(parse_context_json(text), context([], [], []))
}

///|
test "bounded deterministic malformed text inventory never escapes as a runtime panic" {
  let alphabet = ["B", "\n", "\r", ",", "\"", "[", "]", "{", "}", "0", "X", "."]
  for seed = 0; seed < 1000; seed = seed + 1 {
    let chars : Array[String] = []
    let mut state = seed
    for i = 0; i < 8; i = i + 1 {
      chars.push(alphabet[state % alphabet.length()])
      state = (state * 17 + i + 3) % 997
    }
    let text = chars.join("")
    ignore(parse_csv(text)) catch {
      _ => ()
    }
    ignore(parse_cxt(text)) catch {
      _ => ()
    }
    ignore(parse_context_json(text)) catch {
      _ => ()
    }
  }
}
