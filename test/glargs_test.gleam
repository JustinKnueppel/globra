import glargs/args
import gleam/list
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn parse_test() {
  let cases = [
    #([], []),
    #(["foo"], [args.Token("foo")]),
    #(["--foo"], [args.Flag(args.B("foo"))]),
    #(["-foo"], [args.Flag(args.B("foo"))]),
    #(["--foo", "bar"], [args.Flag(args.KV("foo", "bar"))]),
    #(["-foo", "bar"], [args.Flag(args.KV("foo", "bar"))]),
    #(["--foo", "bar", "baz"], [
      args.Flag(args.KV("foo", "bar")),
      args.Token("baz"),
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
