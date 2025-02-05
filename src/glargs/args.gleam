import argv
import gleam/list
import gleam/option

pub type Flag {
  B(name: String)
  KV(name: String, value: String)
}

pub type Argument {
  Token(value: String)
  Flag(flag: Flag)
}

pub type Token {
  RawFlag(name: String)
  RawValue(value: String)
}

pub type Arguments {
  Arguments(tokens: List(String), flags: List(Flag))
}

pub fn raw_args() -> List(String) {
  argv.load().arguments
}

pub fn parsed(args: List(String)) -> List(Argument) {
  parse_args(args, [])
  |> list.reverse()
}

fn parse_args(args: List(String), parsed: List(Argument)) -> List(Argument) {
  case parse_next(args) {
    #(option.None, _) -> parsed
    #(option.Some(arg), []) -> [arg, ..parsed]
    #(option.Some(arg), rest) -> parse_args(rest, [arg, ..parsed])
  }
}

fn parse_next(args: List(String)) -> #(option.Option(Argument), List(String)) {
  case args {
    [] -> #(option.None, [])
    [token] ->
      case parse_token(token) {
        RawFlag(fname) -> #(option.Some(Flag(B(fname))), [])
        RawValue(value) -> #(option.Some(Token(value)), [])
      }
    [t1, t2, ..rest] -> {
      case parse_token(t1), parse_token(t2) {
        RawValue(value), _ -> #(option.Some(Token(value)), [t2, ..rest])
        RawFlag(fname), RawFlag(_) -> #(option.Some(Flag(B(fname))), [
          t2,
          ..rest
        ])
        RawFlag(fname), RawValue(value) -> #(
          option.Some(Flag(KV(fname, value))),
          rest,
        )
      }
    }
  }
}

fn parse_token(token: String) -> Token {
  case token {
    "--" <> fname -> RawFlag(fname)
    "-" <> fname -> RawFlag(fname)
    value -> RawValue(value)
  }
}
