///|
/// Interchange object and attribute universes, preserving their order.
pub fn Context::dual(self : Context) -> Context raise FcaError {
  let rows : Array[Array[Bool]] = []
  for a = 0; a < self.attribute_count(); a = a + 1 {
    let row : Array[Bool] = []
    for o = 0; o < self.object_count(); o = o + 1 {
      row.push(self.incidence[o][a])
    }
    rows.push(row)
  }
  context(self.attribute_names, self.object_names, rows)
}

///|
/// Induced subcontext in original index order; duplicates in either selection are ignored.
pub fn Context::project(
  self : Context,
  objects : Array[Int],
  attributes : Array[Int],
) -> Context raise FcaError {
  let objects = checked_indices(objects, self.object_count())
  let attributes = checked_indices(attributes, self.attribute_count())
  let rows : Array[Array[Bool]] = []
  for o in objects {
    rows.push(attributes.map(fn(a) { self.incidence[o][a] }))
  }
  context(
    objects.map(fn(o) { self.object_names[o] }),
    attributes.map(fn(a) { self.attribute_names[a] }),
    rows,
  )
}

///|
/// Add a named counterexample/observation without mutating the original context.
pub fn Context::with_object(
  self : Context,
  name : String,
  attributes : Array[Int],
) -> Context raise FcaError {
  let attributes = checked_indices(attributes, self.attribute_count())
  let names = self.objects()
  names.push(name)
  let rows = self.rows()
  rows.push(
    Array::makei(self.attribute_count(), fn(a) { attributes.contains(a) }),
  )
  context(names, self.attribute_names, rows)
}

///|
pub fn Context::without_object(
  self : Context,
  object : Int,
) -> Context raise FcaError {
  let selected = checked_indices([object], self.object_count())
  self.project(
    set_difference(universe(self.object_count()), selected),
    universe(self.attribute_count()),
  )
}

///|
/// Construct a context from per-object positive attribute indices; absent attributes are false.
pub fn context_from_sets(
  objects : Array[String],
  attributes : Array[String],
  positives : Array[Array[Int]],
) -> Context raise FcaError {
  if positives.length() != objects.length() {
    raise Invalid("positive-row count mismatch")
  }
  if objects.length() > 4096 || attributes.length() > 128 {
    raise Budget("context dimensions exceeded")
  }
  let rows : Array[Array[Bool]] = []
  for positive in positives {
    let checked = checked_indices(positive, attributes.length())
    rows.push(Array::makei(attributes.length(), fn(a) { checked.contains(a) }))
  }
  context(objects, attributes, rows)
}
