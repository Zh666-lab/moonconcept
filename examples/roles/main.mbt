///|
/// Permission analyst pipeline: user incidence -> role concepts -> cover graph -> violated proposal.
/// This never changes permissions or interprets concepts as access-control decisions.
fn role_pipeline() -> (Json, String) raise @fca.FcaError {
  let observed = @fca.context_from_sets(
    ["reader", "contributor", "operator", "reviewer", "admin"],
    ["read", "write", "deploy", "audit"],
    [[0], [0, 1], [0, 2], [0, 3], [0, 1, 2, 3]],
  )
  let proposal = @fca.implication([1], [2], 4)
  let witnesses = observed.counterexample_labels(proposal)
  let graph = observed.lattice()
  let report = Json::object({
    "workflow": Json::string("permission-analysis"),
    "violating_identities": Json::array(
      witnesses.map(fn(s) { Json::string(s) }),
    ),
    "proposal_audit": @fca.rule_system(4, [proposal]).audit(observed),
    "role_lattice": observed.lattice_report(),
  })
  (report, graph.to_dot())
}

///|
fn main {
  let (report, dot) = role_pipeline() catch {
    _ => abort("permission pipeline failed")
  }
  println(report.stringify())
  println(dot)
}
