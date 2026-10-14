///|
test "CXT roundtrip preserves Unicode and whitespace identities" {
  let c = context([" 对象 ", "other"], ["α", " β "], [
    [true, false],
    [false, true],
  ])
  assert_eq(parse_cxt(c.to_cxt()), c)
  assert_eq(parse_cxt(c.to_cxt().replace_all(old="\n", new="\r\n")), c)
  for
    empty in [
      context([], [], []),
      context(["a"], [], [[]]),
      context([], ["x"], []),
    ] {
    assert_eq(parse_cxt(empty.to_cxt()), empty)
  }
}

///|
test "CXT parser rejects malformed headers widths symbols counts and tails" {
  let bad = [
    "", "B\n\n-1\n0\n\n", "B\nname\n0\n0\n\n", "B\n\n1\n1\n\na\nx\nY\n", "B\n\n1\n1\n\na\nx\nXX\n",
    "B\n\n0\n0\n\nextra\n",
  ]
  let mut rejected = 0
  for text in bad {
    ignore(parse_cxt(text)) catch {
      Invalid(_) => rejected = rejected + 1
      _ => ()
    }
  }
  assert_eq(rejected, bad.length())
  let c = context(["a\nb"], [], [[]])
  let mut failed = false
  ignore(c.to_cxt()) catch {
    Invalid(_) => failed = true
    _ => ()
  }
  assert_true(failed)
}
