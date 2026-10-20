///|
test "rule JSON rejects exact nonintegers even when Double rounds to an integer" {
  for
    token in [
      "0.999999999999999999999", "1e-999", "128.00000000000000000001", "-1e-999",
    ] {
    let text = "{\"schema\":\"moonconcept-rules/v1\",\"dimension\":" +
      token +
      ",\"rules\":[]}"
    let rejected = try {
      ignore(parse_rules_json(text))
      false
    } catch {
      Invalid(_) => true
      _ => false
    }
    assert_true(rejected)
    let indexed = "{\"schema\":\"moonconcept-rules/v1\",\"dimension\":128,\"rules\":[{\"premise\":[" +
      token +
      "],\"conclusion\":[]}]}"
    let rejected_index = try {
      ignore(parse_rules_json(indexed))
      false
    } catch {
      Invalid(_) => true
      _ => false
    }
    assert_true(rejected_index)
  }
}

///|
test "rule JSON retains exact integer decimal and exponent spellings" {
  for
    token in [
      "1", "1.0000000000000000000000", "0.01e2", "100e-2", "1e+0", "0.000e-999999999999",
      "-0",
    ] {
    let text = "{\"schema\":\"moonconcept-rules/v1\",\"dimension\":" +
      token +
      ",\"rules\":[]}"
    let rules = parse_rules_json(text)
    assert_true(rules.attribute_count() == 0 || rules.attribute_count() == 1)
  }
  let upper = parse_rules_json(
    "{\"schema\":\"moonconcept-rules/v1\",\"dimension\":1.28e2,\"rules\":[{\"premise\":[127.000],\"conclusion\":[0e999999999999999999999]}]}",
  )
  assert_eq(upper.attribute_count(), 128)
  let cases = [
    "{\"schema\":\"moonconcept-rules/v1\",\"dimension\":0.999999999999999999999,\"dimension\":1,\"rules\":[]}",
    "{\"schema\":1e-999,\"schema\":\"moonconcept-rules/v1\",\"dimension\":1,\"rules\":[128.00000000000000000001],\"rules\":[]}",
    "{\"schema\":\"moonconcept-rules/v1\",\"dimension\":1e-999,\"\\u0064imension\":1,\"rules\":[{\"premise\":[0.999999999999999999999],\"premise\":[0],\"conclusion\":[]}]}",
  ]
  for text in cases {
    assert_eq(parse_rules_json(text).attribute_count(), 1)
  }
}
