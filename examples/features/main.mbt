///|
/// Analyst pipeline: categorical incidence -> closed patterns -> generators -> exact dependencies.
fn feature_pipeline() -> Json raise @fca.FcaError {
  let data = @fca.parse_csv(
    "object,touch,portable,radio,keyboard\nphone,1,1,1,0\ntablet,1,1,0,0\nwatch,1,1,1,0\ndesktop,0,0,0,1\nlaptop,0,1,1,1\nworkstation,0,0,1,1\n",
  )
  let patterns = data.frequent_concepts(0.5)
  let target = data.closure([data.attribute_index("touch").unwrap()])
  let generators = data.minimal_generators(target)
  let basis = data.canonical_basis()
  Json::object({
    "workflow": Json::string("feature-analysis"),
    "objects": Json::number(data.object_count().to_double()),
    "frequent_patterns": Json::number(patterns.length().to_double()),
    "touch_closure": Json::array(
      data.attribute_labels(target).map(fn(s) { Json::string(s) }),
    ),
    "minimal_generators": Json::array(
      generators.map(generator => {
        Json::array(
          data.attribute_labels(generator).map(fn(s) { Json::string(s) }),
        )
      }),
    ),
    "exact_basis": basis.to_json(),
    "catalog": data.concept_report(),
  })
}

///|
fn main {
  let report = feature_pipeline() catch {
    _ => abort("feature pipeline failed")
  }
  println(report.stringify())
}
