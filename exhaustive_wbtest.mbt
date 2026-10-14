///|
fn oracle_seed(mask : Int, dimension : Int) -> Array[Int] {
  let result : Array[Int] = []
  let mut remaining = mask
  for a = 0; a < dimension; a = a + 1 {
    if remaining % 2 == 1 {
      result.push(a)
    }
    remaining = remaining / 2
  }
  result
}

///|
fn oracle_subset(a : Array[Int], b : Array[Int]) -> Bool {
  let mut result = true
  for value in a {
    if !b.contains(value) {
      result = false
    }
  }
  result
}

///|
/// Separate scalar matrix oracle: no production derivation/set/closure helpers are called.
fn oracle_closure(
  rows : Array[Array[Bool]],
  width : Int,
  seed : Array[Int],
) -> Array[Int] {
  let witnesses : Array[Int] = []
  for o = 0; o < rows.length(); o = o + 1 {
    let mut matches = true
    for a in seed {
      if !rows[o][a] {
        matches = false
      }
    }
    if matches {
      witnesses.push(o)
    }
  }
  let common : Array[Int] = []
  for a = 0; a < width; a = a + 1 {
    let mut shared = true
    for o in witnesses {
      if !rows[o][a] {
        shared = false
      }
    }
    if shared {
      common.push(a)
    }
  }
  common
}

///|
test "exhaustive 689 contexts and 5054 seeds prove closure enumeration basis and generators" {
  let mut contexts = 0
  let mut seeds = 0
  for height = 0; height <= 3; height = height + 1 {
    for width = 0; width <= 3; width = width + 1 {
      for mask = 0; mask < 1 << (height * width); mask = mask + 1 {
        let rows = Array::makei(height, fn(o) {
          Array::makei(width, fn(a) { mask / (1 << (o * width + a)) % 2 == 1 })
        })
        let c = context(
          Array::makei(height, fn(o) { "o\{o}" }),
          Array::makei(width, fn(a) { "a\{a}" }),
          rows,
        )
        contexts = contexts + 1
        let expected : Array[Array[Int]] = []
        let pseudo : Array[Array[Int]] = []
        for bits = 0; bits < 1 << width; bits = bits + 1 {
          let seed = oracle_seed(bits, width)
          let closed = oracle_closure(rows, width, seed)
          assert_eq(c.closure(seed), closed)
          assert_eq(c.closure(closed), closed)
          seeds = seeds + 1
          if seed == closed {
            expected.push(seed)
          } else {
            let mut qualifies = true
            for smaller in pseudo {
              if oracle_subset(smaller, seed) &&
                !oracle_subset(oracle_closure(rows, width, smaller), seed) {
                qualifies = false
              }
            }
            if qualifies {
              pseudo.push(seed)
            }
          }
        }
        let nodes = c.concepts()
        assert_eq(nodes.length(), expected.length())
        for node in nodes {
          assert_true(expected.contains(node.intent))
        }
        for target in expected {
          let actual = c.minimal_generators(target)
          let minimal : Array[Array[Int]] = []
          for bits = 0; bits < 1 << width; bits = bits + 1 {
            let seed = oracle_seed(bits, width)
            if oracle_closure(rows, width, seed) == target {
              let mut is_minimal = true
              for smaller_bits = 0
                  smaller_bits < 1 << width
                  smaller_bits = smaller_bits + 1 {
                let smaller = oracle_seed(smaller_bits, width)
                if smaller != seed &&
                  oracle_subset(smaller, seed) &&
                  oracle_closure(rows, width, smaller) == target {
                  is_minimal = false
                }
              }
              if is_minimal {
                minimal.push(seed)
              }
            }
          }
          assert_eq(actual.length(), minimal.length())
          for generator in actual {
            assert_true(minimal.contains(generator))
          }
        }
        let basis = c.canonical_basis()
        let premises = basis.implications().map(fn(rule) { rule.premise })
        assert_eq(premises, pseudo)
        let reduced = basis.reduce_premises().irredundant()
        let single = basis.split_conclusions()
        for bits = 0; bits < 1 << width; bits = bits + 1 {
          let seed = oracle_seed(bits, width)
          let expected = oracle_closure(rows, width, seed)
          assert_eq(basis.closure(seed), expected)
          assert_eq(reduced.closure(seed), expected)
          assert_eq(single.closure(seed), expected)
        }
      }
    }
  }
  assert_eq(contexts, 689)
  assert_eq(seeds, 5054)
}

///|
test "all 512 three-by-three contexts have exact covers and lattice bounds" {
  for mask = 0; mask < 512; mask = mask + 1 {
    let rows = Array::makei(3, fn(o) {
      Array::makei(3, fn(a) { mask / (1 << (o * 3 + a)) % 2 == 1 })
    })
    let c = context(["a", "b", "c"], ["x", "y", "z"], rows)
    let lattice = c.lattice()
    let edges = lattice.covers()
    for i = 0; i < lattice.size(); i = i + 1 {
      assert_true(lattice.leq(lattice.bottom(), i))
      assert_true(lattice.leq(i, lattice.top()))
      for j = 0; j < lattice.size(); j = j + 1 {
        let left = lattice.concept(i).extent
        let right = lattice.concept(j).extent
        assert_eq(lattice.leq(i, j), oracle_subset(left, right))
        let mut direct = i != j && oracle_subset(left, right)
        for k = 0; k < lattice.size(); k = k + 1 {
          if k != i &&
            k != j &&
            oracle_subset(left, lattice.concept(k).extent) &&
            oracle_subset(lattice.concept(k).extent, right) {
            direct = false
          }
        }
        assert_eq(edges.contains({ lower: i, upper: j, }), direct)
        let meet = lattice.meet(i, j)
        let join = lattice.join(i, j)
        assert_eq(lattice.meet(j, i), meet)
        assert_eq(lattice.join(j, i), join)
        assert_eq(lattice.meet(i, join), i)
        assert_eq(lattice.join(i, meet), i)
        for k = 0; k < lattice.size(); k = k + 1 {
          if lattice.leq(k, i) && lattice.leq(k, j) {
            assert_true(lattice.leq(k, meet))
          }
          if lattice.leq(i, k) && lattice.leq(j, k) {
            assert_true(lattice.leq(join, k))
          }
        }
      }
    }
  }
}
