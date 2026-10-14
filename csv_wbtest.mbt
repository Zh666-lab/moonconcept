///|
test "CSV quotes preserve commas quotes multiline Unicode and terminal delimiters" {
  let c = context(["a,\"b\n对象", "=formula"], ["x\r\ny", " z "], [
    [true, false],
    [false, true],
  ])
  assert_eq(parse_csv(c.to_csv()), c)
  for
    empty in [
      context([], [], []),
      context(["a"], [], [[]]),
      context([], ["x"], []),
    ] {
    assert_eq(parse_csv(empty.to_csv()), empty)
  }
  assert_eq(parse_csv("object,x\na,1").rows(), [[true]])
}

///|
test "CSV rejects malformed quoting duplicate labels ragged records and coercion" {
  let bad = [
    "", "object,x\n\"a,1", "object,x\na\"b,1", "object,x\n\"a\"b,1", "object,x\na,yes",
    "object,x\na,1,0", "object,x,x\na,1,1", "object,x\na,1\na,0", "object,x\ra,1",
    "object,x\na,1\n\n",
  ]
  let mut rejected = 0
  for text in bad {
    ignore(parse_csv(text)) catch {
      Invalid(_) => rejected = rejected + 1
      _ => ()
    }
  }
  assert_eq(rejected, bad.length())
}
