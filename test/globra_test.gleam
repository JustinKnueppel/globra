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
    #(["--foo"], [args.Flag(args.B("foo"))]),
    #(["-foo"], [args.Flag(args.B("foo"))]),
    #(["--foo", "bar"], [args.Flag(args.KV("foo", "bar"))]),
    #(["-foo", "bar"], [args.Flag(args.KV("foo", "bar"))]),
    #(["--foo", "bar", "baz"], [
      args.Flag(args.KV("foo", "bar")),
      args.Command("baz"),
    ]),
    #(["--foo", "--bar", "baz"], [
      args.Flag(args.B("foo")),
      args.Flag(args.KV("bar", "baz")),
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
      [args.Flag(args.B("foo"))],
      args.PartitionedArguments([], [args.B("foo")]),
    ),
    #(
      [
        args.Command("foo"),
        args.Flag(args.B("bar")),
        args.Command("baz"),
        args.Flag(args.KV("my", "flag")),
      ],
      args.PartitionedArguments(["foo", "baz"], [
        args.B("bar"),
        args.KV("my", "flag"),
      ]),
    ),
  ]

  list.each(cases, fn(test_case) {
    let #(input, expected) = test_case
    should.equal(args.partition(input), expected)
  })
}
