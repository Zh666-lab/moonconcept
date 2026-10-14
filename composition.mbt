///|
/// Apposition aligns objects by identity and concatenates disjoint attribute vocabularies.
pub fn Context::apposition(
  self : Context,
  other : Context,
) -> Context raise FcaError {
  if self.object_count() != other.object_count() {
    raise Invalid("apposition requires the same object identities")
  }
  let alignment : Array[Int] = []
  for name in self.object_names {
    match other.object_index(name) {
      Some(index) => alignment.push(index)
      None => raise Invalid("apposition object identity is missing")
    }
  }
  let names = self.attributes()
  for name in other.attribute_names {
    if names.contains(name) {
      raise Invalid("apposition attribute identities must be disjoint")
    }
    names.push(name)
  }
  let rows : Array[Array[Bool]] = []
  for o = 0; o < self.object_count(); o = o + 1 {
    let row = self.incidence[o].copy()
    for value in other.incidence[alignment[o]] {
      row.push(value)
    }
    rows.push(row)
  }
  context(self.objects(), names, rows)
}

///|
/// Subposition aligns attributes by identity and concatenates disjoint object populations.
pub fn Context::subposition(
  self : Context,
  other : Context,
) -> Context raise FcaError {
  if self.attribute_count() != other.attribute_count() {
    raise Invalid("subposition requires the same attribute identities")
  }
  let alignment : Array[Int] = []
  for name in self.attribute_names {
    match other.attribute_index(name) {
      Some(index) => alignment.push(index)
      None => raise Invalid("subposition attribute identity is missing")
    }
  }
  let names = self.objects()
  let rows = self.rows()
  for o = 0; o < other.object_count(); o = o + 1 {
    let name = other.object_names[o]
    if names.contains(name) {
      raise Invalid("subposition object identities must be disjoint")
    }
    names.push(name)
    rows.push(alignment.map(fn(a) { other.incidence[o][a] }))
  }
  context(names, self.attributes(), rows)
}
