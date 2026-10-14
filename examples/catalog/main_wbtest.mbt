///|
test "configuration merge aligns attribute names and survives three formats" {
  match catalog_pipeline() {
    Object(fields) => {
      assert_eq(fields.get("merged_objects"), Some(Json::number(4.0)))
      assert_eq(fields.get("cxt_roundtrip_equal"), Some(Json::boolean(true)))
    }
    _ => abort("not a catalog report")
  }
}
