///|
test "Hasse reduction is extent ordered and has no transitive edge" {
  let lattice = sample().lattice()
  assert_eq(lattice.size(), 3)
  assert_eq(lattice.covers(), [{ lower: 1, upper: 0, }, { lower: 2, upper: 1, }])
  assert_true(lattice.leq(2, 0))
  assert_true(!lattice.leq(0, 2))
  assert_eq(lattice.upper_covers(2), [1])
  assert_eq(lattice.lower_covers(0), [1])
  let c = lattice.concept(0)
  c.extent.clear()
  assert_eq(lattice.concept(0).extent, [0, 1, 2])
}

///|
test "lattice materialization validates its resource and index bounds" {
  let mut rejected = 0
  ignore(sample().lattice(limit=2)) catch {
    Budget(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(sample().lattice(limit=257)) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  ignore(sample().lattice().leq(-1, 0)) catch {
    Invalid(_) => rejected = rejected + 1
    _ => ()
  }
  assert_eq(rejected, 3)
}
