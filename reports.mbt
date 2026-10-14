///|
fn indices_json(values : Array[Int]) -> Json {
  Json::array(values.map(fn(i) { Json::number(i.to_double()) }))
}

///|
fn optional_number(value : Double?) -> Json {
  match value {
    Some(n) => Json::number(n)
    None => Json::null()
  }
}

///|
fn metrics_json(metrics : RuleMetrics) -> Json {
  Json::object({
    "objects": Json::number(metrics.object_count.to_double()),
    "premise_count": Json::number(metrics.premise_count.to_double()),
    "conclusion_count": Json::number(metrics.conclusion_count.to_double()),
    "joint_count": Json::number(metrics.joint_count.to_double()),
    "counterexamples": Json::number(metrics.counterexample_count.to_double()),
    "support": Json::number(metrics.support),
    "confidence": optional_number(metrics.confidence),
    "lift": optional_number(metrics.lift),
    "leverage": Json::number(metrics.leverage),
  })
}

///|
/// Indexed output keeps vocabularies once rather than repeating potentially large labels.
pub fn Context::concept_report(
  self : Context,
  limit? : Int = 4096,
) -> Json raise FcaError {
  let nodes = self
    .concepts(limit~)
    .map(concept => {
      Json::object({
        "extent": indices_json(concept.extent),
        "intent": indices_json(concept.intent),
        "support": Json::number(self.support(concept.intent)),
      })
    })
  Json::object({
    "schema": Json::string("moonconcept-concepts/v1"),
    "context": self.to_json(),
    "concepts": Json::array(nodes),
  })
}

///|
pub fn Context::lattice_report(
  self : Context,
  limit? : Int = 256,
) -> Json raise FcaError {
  let lattice = self.lattice(limit~)
  let nodes : Array[Json] = []
  for i = 0; i < lattice.size(); i = i + 1 {
    let concept = lattice.concept(i)
    nodes.push(
      Json::object({
        "id": Json::number(i.to_double()),
        "extent": indices_json(concept.extent),
        "intent": indices_json(concept.intent),
      }),
    )
  }
  let covers = lattice
    .covers()
    .map(fn(edge) {
      Json::array([
        Json::number(edge.lower.to_double()),
        Json::number(edge.upper.to_double()),
      ])
    })
  Json::object({
    "schema": Json::string("moonconcept-lattice/v1"),
    "order": Json::string("extent-subset"),
    "context": self.to_json(),
    "nodes": Json::array(nodes),
    "covers": Json::array(covers),
  })
}

///|
/// Safe numeric DOT labels, directed bottom -> top in extent inclusion order.
/// Human label vocabulary remains in the companion lattice_report, never interpolated into DOT.
pub fn Lattice::to_dot(self : Lattice) -> String {
  let lines = ["digraph ConceptLattice {", "  rankdir=BT;"]
  for i = 0; i < self.nodes.length(); i = i + 1 {
    let node = self.nodes[i]
    let intent = node.intent.map(fn(a) { a.to_string() }).join(",")
    lines.push(
      "  n\{i} [label=\"#\{i} | extent=\{node.extent.length()} | intent={\{intent}}\"];",
    )
  }
  for edge in self.edges {
    lines.push("  n\{edge.lower} -> n\{edge.upper};")
  }
  lines.push("}")
  lines.join("\n") + "\n"
}

///|
/// Every supplied rule is audited, including vacuously valid rules with undefined confidence.
pub fn RuleSystem::audit(
  self : RuleSystem,
  observed : Context,
) -> Json raise FcaError {
  if self.attribute_count() != observed.attribute_count() {
    raise Invalid("audit vocabulary dimensions differ")
  }
  let entries = self
    .implications()
    .map(rule => {
      Json::object({
        "rule": implication_json(rule),
        "valid": Json::boolean(observed.valid_implication(rule)),
        "witnesses": indices_json(observed.counterexamples(rule)),
        "metrics": metrics_json(observed.rule_metrics(rule)),
      })
    })
  Json::object({
    "schema": Json::string("moonconcept-rule-audit/v1"),
    "context": observed.to_json(),
    "rules": Json::array(entries),
  })
}

///|
/// Explanations identify source rule indices and only newly inferred attributes.
pub fn RuleSystem::inference_report(
  self : RuleSystem,
  seed : Array[Int],
) -> Json raise FcaError {
  let seed = checked_indices(seed, self.attribute_count())
  let trace = self.trace(seed)
  let steps = trace.steps.map(fn(step) {
    Json::object({
      "rule_index": Json::number(step.rule_index.to_double()),
      "added": indices_json(step.added),
    })
  })
  Json::object({
    "schema": Json::string("moonconcept-inference/v1"),
    "theory": self.to_json(),
    "seed": indices_json(seed),
    "result": indices_json(trace.result),
    "steps": Json::array(steps),
  })
}
