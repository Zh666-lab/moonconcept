///|
test "canonical base regenerates every closure of the sample" {
  let c = sample()
  let base = c.canonical_basis()
  assert_eq(base.implications().length(), 2)
  for mask = 0; mask < 8; mask = mask + 1 {
    let seed = mask_indices(mask, 3)
    assert_eq(base.closure(seed), c.closure(seed))
  }
  for rule in base.implications() {
    assert_true(c.valid_implication(rule))
  }
}

///|
test "canonical base budgets are explicit and no partial base is returned" {
  let mut rejected = 0
  ignore(sample().canonical_basis(candidate_limit=4)) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(sample().canonical_basis(work_limit=1)) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  let c = context([], [], [])
  assert_eq(c.canonical_basis().implications(), [])
  assert_eq(rejected, 2)
}
