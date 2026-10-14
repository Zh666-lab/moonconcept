///|
pub fn Lattice::find_intent(self : Lattice, intent : Array[Int32]) -> Int32? {
  let intent = index_set(intent)
  for i = 0; i < self.size(); i = i + 1 {
    if self.nodes[i].intent == intent {
      return Some(i)
    }
  }
  None
}

///|
pub fn Lattice::find_extent(self : Lattice, extent : Array[Int32]) -> Int32? {
  let extent = index_set(extent)
  for i = 0; i < self.size(); i = i + 1 {
    if self.nodes[i].extent == extent {
      return Some(i)
    }
  }
  None
}

///|
/// Greatest lower bound: intersection of closed extents.
pub fn Lattice::meet(
  self : Lattice,
  left : Int32,
  right : Int32,
) -> Int32 raise FcaError {
  self.check_node(left)
  self.check_node(right)
  match
    self.find_extent(
      set_intersection(self.nodes[left].extent, self.nodes[right].extent),
    ) {
    Some(index) => index
    None => raise Invalid("internal lattice invariant: meet missing")
  }
}

///|
/// Least upper bound: intersection of closed intents (reverse inclusion).
pub fn Lattice::join(
  self : Lattice,
  left : Int32,
  right : Int32,
) -> Int32 raise FcaError {
  self.check_node(left)
  self.check_node(right)
  match
    self.find_intent(
      set_intersection(self.nodes[left].intent, self.nodes[right].intent),
    ) {
    Some(index) => index
    None => raise Invalid("internal lattice invariant: join missing")
  }
}

///|
pub fn Lattice::top(self : Lattice) -> Int32 {
  let mut top = 0
  for i = 1; i < self.size(); i = i + 1 {
    if self.order[top][i] {
      top = i
    }
  }
  top
}

///|
pub fn Lattice::bottom(self : Lattice) -> Int32 {
  let mut bottom = 0
  for i = 1; i < self.size(); i = i + 1 {
    if self.order[i][bottom] {
      bottom = i
    }
  }
  bottom
}

///|
/// Empty meet is the top element.
pub fn Lattice::meet_all(
  self : Lattice,
  nodes : Array[Int32],
) -> Int32 raise FcaError {
  let mut result = self.top()
  for node in nodes {
    result = self.meet(result, node)
  }
  result
}

///|
/// Empty join is the bottom element.
pub fn Lattice::join_all(
  self : Lattice,
  nodes : Array[Int32],
) -> Int32 raise FcaError {
  let mut result = self.bottom()
  for node in nodes {
    result = self.join(result, node)
  }
  result
}

///|
pub fn Lattice::interval(
  self : Lattice,
  lower : Int32,
  upper : Int32,
) -> Array[Int32] raise FcaError {
  if !self.leq(lower, upper) {
    raise Invalid("interval endpoints are not ordered")
  }
  let result : Array[Int32] = []
  for i = 0; i < self.size(); i = i + 1 {
    if self.order[lower][i] && self.order[i][upper] {
      result.push(i)
    }
  }
  result
}
