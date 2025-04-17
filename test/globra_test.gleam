import gleam/list
import gleeunit
import gleeunit/should
import globra/args

pub fn main() {
  gleeunit.main()
}

pub fn parse_test() {
  let cases = [
    #([], []),
    #(["foo"], [args.Command("foo")]),
    #(["--foo"], [args.Flag(args.B(args.Long("foo")))]),
    #(["-foo"], [args.Flag(args.B(args.Short("foo")))]),
    #(["--foo", "bar"], [args.Flag(args.KV(args.Long("foo"), "bar"))]),
    #(["-foo", "bar"], [args.Flag(args.KV(args.Short("foo"), "bar"))]),
    #(["--foo", "bar", "baz"], [
      args.Flag(args.KV(args.Long("foo"), "bar")),
      args.Command("baz"),
    ]),
    #(["--foo", "--bar", "baz"], [
      args.Flag(args.B(args.Long("foo"))),
      args.Flag(args.KV(args.Long("bar"), "baz")),
    ]),
  ]

  list.each(cases, fn(test_case) -> Nil {
    let #(input, expected) = test_case
    should.equal(args.parsed(input), expected)
  })
}

pub fn partition_test() {
  let cases = [
    #([args.Command("foo")], args.PartitionedArguments(["foo"], [])),
    #(
      [args.Flag(args.B(args.Long("foo")))],
      args.PartitionedArguments([], [args.B(args.Long("foo"))]),
    ),
    #(
      [
        args.Command("foo"),
        args.Flag(args.B(args.Long("bar"))),
        args.Command("baz"),
        args.Flag(args.KV(args.Long("my"), "flag")),
      ],
      args.PartitionedArguments(["foo", "baz"], [
        args.B(args.Long("bar")),
        args.KV(args.Long("my"), "flag"),
      ]),
    ),
  ]

  list.each(cases, fn(test_case) {
    let #(input, expected) = test_case
    should.equal(args.partition(input), expected)
  })
}
