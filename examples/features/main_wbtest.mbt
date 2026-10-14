///|
test "feature analyst receives closed patterns and exact dependency report" {
  let report = feature_pipeline()
  match report {
    Object(fields) => {
      assert_eq(fields.get("objects"), Some(Json::number(6.0)))
      assert_eq(
        fields.get("touch_closure"),
        Some(Json::array([Json::string("touch"), Json::string("portable")])),
      )
    }
    _ => abort("not a feature report")
  }
}
