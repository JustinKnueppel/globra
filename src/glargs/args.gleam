//// args is used for initial parsing of command line arguments.

import argv
import gleam/list
import gleam/option

/// Flags can either be key-value pairs or stand alone boolean toggles.
pub type Flag {
  B(name: String)
  KV(name: String, value: String)
}

/// An argument is either a flag or a component of a command.
pub type Argument {
  Command(value: String)
  Flag(flag: Flag)
}

type RawToken {
  RawFlag(name: String)
  RawValue(value: String)
}

/// Return the command line arguments as given.
pub fn raw_args() -> List(String) {
  argv.load().arguments
}

/// Parse the given list into typed tokens.
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
        RawValue(value) -> #(option.Some(Command(value)), [])
      }
    [t1, t2, ..rest] -> {
      case parse_token(t1), parse_token(t2) {
        RawValue(value), _ -> #(option.Some(Command(value)), [t2, ..rest])
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

fn parse_token(token: String) -> RawToken {
  case token {
    "--" <> fname -> RawFlag(fname)
    "-" <> fname -> RawFlag(fname)
    value -> RawValue(value)
  }
}
