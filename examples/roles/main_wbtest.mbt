///|
test "role report identifies an actual counterexample and renders the cover graph" {
  let (report, dot) = role_pipeline()
  match report {
    Object(fields) =>
      assert_eq(
        fields.get("violating_identities"),
        Some(Json::array([Json::string("contributor")])),
      )
    _ => abort("not a role report")
  }
  assert_true(dot.length() > 100)
}
