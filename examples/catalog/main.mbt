///|
/// Configuration maintainer: independent catalog populations -> aligned merge -> theory audit.
fn catalog_pipeline() -> Json raise @fca.FcaError {
  let existing = @fca.parse_csv(
    "object,flash,boot,wifi,touch\nboard-pro,1,1,1,1\nboard-lite,1,1,1,0\nboard-basic,0,1,0,0\n",
  )
  let incoming = @fca.context_from_sets(
    ["board-mini"],
    ["touch", "boot", "flash", "wifi"],
    [[1, 2]],
  )
  let merged = existing.subposition(incoming)
  let saved = @fca.parse_context_json(merged.to_json_string())
  let theory = @fca.rule_system(4, [
    @fca.implication([0], [1], 4),
    @fca.implication([2], [3], 4),
  ])
  let theory = @fca.parse_rules_json(theory.to_json_string())
  let known = @fca.rule_system(4, [@fca.implication([0], [1], 4)])
  let review = @fca.exploration(saved, known)
  let question = match review.next_question() {
    Some(q) =>
      Json::object({
        "premise": Json::array(
          q.premise.map(fn(i) { Json::number(i.to_double()) }),
        ),
        "conclusion": Json::array(
          q.conclusion.map(fn(i) { Json::number(i.to_double()) }),
        ),
      })
    None => Json::null()
  }
  Json::object({
    "workflow": Json::string("configuration-catalog"),
    "merged_objects": Json::number(saved.object_count().to_double()),
    "rule_audit": theory.audit(saved),
    "inference": known.inference_report([0]),
    "next_expert_question": question,
    "cxt_roundtrip_equal": Json::boolean(
      @fca.parse_cxt(saved.to_cxt()) == saved,
    ),
  })
}

///|
fn main {
  let report = catalog_pipeline() catch {
    _ => abort("catalog pipeline failed")
  }
  println(report.stringify())
}
