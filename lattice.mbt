///|
/// Edge direction is lower extent -> upper extent (subset order).
pub struct Cover {
  lower : Int
  upper : Int
} derive(Eq, Debug)

///|
pub extend Cover with Eq::{equal, not_equal}

///|
pub extend Cover with Debug::{to_repr}

///|
pub struct Lattice {
  priv nodes : Array[Concept]
  priv edges : Array[Cover]
  priv order : Array[Array[Bool]]
} derive(Debug)

///|
pub extend Lattice with Debug::{to_repr}

///|
/// Materialize a bounded Hasse diagram; cubic cover reduction is limited to 256 concepts.
pub fn Context::lattice(
  self : Context,
  limit? : Int = 256,
) -> Lattice raise FcaError {
  if limit < 1 || limit > 256 {
    raise Invalid("lattice limit must be 1..256")
  }
  let nodes = self.concepts(limit~)
  let n = nodes.length()
  let order : Array[Array[Bool]] = []
  for i = 0; i < n; i = i + 1 {
    let row : Array[Bool] = []
    for j = 0; j < n; j = j + 1 {
      row.push(set_subset(nodes[i].extent, nodes[j].extent))
    }
    order.push(row)
  }
  let edges : Array[Cover] = []
  for i = 0; i < n; i = i + 1 {
    for j = 0; j < n; j = j + 1 {
      if i != j && order[i][j] {
        let mut direct = true
        for k = 0; k < n; k = k + 1 {
          if k != i && k != j && order[i][k] && order[k][j] {
            direct = false
            break
          }
        }
        if direct {
          edges.push({ lower: i, upper: j, })
        }
      }
    }
  }
  { nodes, edges, order, }
}

///|
fn Lattice::check_node(self : Lattice, node : Int) -> Unit raise FcaError {
  if node < 0 || node >= self.nodes.length() {
    raise Invalid("lattice node out of range")
  }
}

///|
pub fn Lattice::size(self : Lattice) -> Int {
  self.nodes.length()
}

///|
pub fn Lattice::concept(self : Lattice, node : Int) -> Concept raise FcaError {
  self.check_node(node)
  {
    extent: self.nodes[node].extent.copy(),
    intent: self.nodes[node].intent.copy(),
  }
}

///|
pub fn Lattice::covers(self : Lattice) -> Array[Cover] {
  self.edges.copy()
}

///|
pub fn Lattice::leq(
  self : Lattice,
  lower : Int,
  upper : Int,
) -> Bool raise FcaError {
  self.check_node(lower)
  self.check_node(upper)
  self.order[lower][upper]
}

///|
pub fn Lattice::upper_covers(
  self : Lattice,
  node : Int,
) -> Array[Int] raise FcaError {
  self.check_node(node)
  let out : Array[Int] = []
  for edge in self.edges {
    if edge.lower == node {
      out.push(edge.upper)
    }
  }
  out
}

///|
pub fn Lattice::lower_covers(
  self : Lattice,
  node : Int,
) -> Array[Int] raise FcaError {
  self.check_node(node)
  let out : Array[Int] = []
  for edge in self.edges {
    if edge.upper == node {
      out.push(edge.lower)
    }
  }
  out
}
