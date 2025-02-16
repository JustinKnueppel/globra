import gleam/int
import gleam/list
import gleam/option
import gleam/result
import globra/args.{B, Flag as RawFlag, KV}

pub opaque type FlagOpts(a) {
  FlagOpts(name: String, aliases: List(String), default: option.Option(a))
}

pub opaque type Flag(a) {
  Flag(
    opts: FlagOpts(a),
    parser: fn(List(RawFlag), FlagOpts(a)) -> Result(a, ParseError),
  )
}

fn named_flag(name: String) -> FlagOpts(a) {
  FlagOpts(name: name, aliases: [], default: option.None)
}

/// Create a boolean flag with the given name.
pub fn b(name: String) -> Flag(Bool) {
  Flag(opts: named_flag(name), parser: b_parser)
}

/// Create a boolean list flag with the given name.
pub fn b_list(name: String) -> Flag(List(Bool)) {
  Flag(opts: named_flag(name), parser: lb_parser)
}

/// Create an integer flag with the given name.
pub fn i(name: String) -> Flag(Int) {
  Flag(opts: named_flag(name), parser: i_parser)
}

/// Create an integer list flag with the given name.
pub fn i_list(name: String) -> Flag(List(Int)) {
  Flag(opts: named_flag(name), parser: li_parser)
}

/// Create a string flag with the given name.
pub fn s(name: String) -> Flag(String) {
  Flag(opts: named_flag(name), parser: s_parser)
}

/// Create a string list flag with the given name.
pub fn s_list(name: String) -> Flag(List(String)) {
  Flag(opts: named_flag(name), parser: ls_parser)
}

/// Set the default value of the flag.
pub fn with_default(flag: Flag(a), default: a) -> Flag(a) {
  Flag(
    opts: FlagOpts(..flag.opts, default: option.Some(default)),
    parser: flag.parser,
  )
}

/// Set the aliases for the flag.
pub fn with_aliases(flag: Flag(a), aliases: List(String)) -> Flag(a) {
  Flag(opts: FlagOpts(..flag.opts, aliases: aliases), parser: flag.parser)
}

fn by_name(flags: List(RawFlag), flag: FlagOpts(a)) -> List(RawFlag) {
  use f <- list.filter(flags)
  case f {
    B(name) -> list.contains([flag.name, ..flag.aliases], name)
    KV(name, _) -> list.contains([flag.name, ..flag.aliases], name)
  }
}

type ParseError {
  RequiredNotFound
  WrongType
  ProvidedTooManyTimes
}

fn b_parser(
  flags: List(RawFlag),
  flag: FlagOpts(Bool),
) -> Result(Bool, ParseError) {
  let results = flags |> by_name(flag)
  case results {
    [] -> Ok(option.unwrap(flag.default, False))
    [B(..)] -> Ok(True)
    [KV(_, "true")] -> Ok(True)
    [KV(_, "false")] -> Ok(False)
    [KV(_, _)] -> Error(WrongType)
    _ -> Error(ProvidedTooManyTimes)
  }
}

fn lb_parser(
  flags: List(RawFlag),
  flag: FlagOpts(List(Bool)),
) -> Result(List(Bool), ParseError) {
  flags
  |> by_name(flag)
  |> list.filter_map(fn(f) {
    case f {
      B(..) -> Ok(True)
      KV(_, "true") -> Ok(True)
      KV(_, "false") -> Ok(False)
      KV(_, _) -> Error(Nil)
    }
  })
  |> Ok
}

fn i_parser(
  flags: List(RawFlag),
  flag: FlagOpts(Int),
) -> Result(Int, ParseError) {
  let results = flags |> by_name(flag)
  case results {
    [] -> option.to_result(flag.default, RequiredNotFound)
    [B(..)] -> Error(WrongType)
    [KV(_, v)] -> int.parse(v) |> result.map_error(fn(_) { WrongType })
    _ -> Error(ProvidedTooManyTimes)
  }
}

fn li_parser(
  flags: List(RawFlag),
  flag: FlagOpts(List(Int)),
) -> Result(List(Int), ParseError) {
  flags
  |> by_name(flag)
  |> list.filter_map(fn(f) {
    case f {
      B(..) -> Error(Nil)
      KV(_, v) -> int.parse(v)
    }
  })
  |> Ok
}

fn s_parser(
  flags: List(RawFlag),
  flag: FlagOpts(String),
) -> Result(String, ParseError) {
  let results = flags |> by_name(flag)
  case results {
    [] -> option.to_result(flag.default, RequiredNotFound)
    [B(..)] -> Error(WrongType)
    [KV(_, v)] -> Ok(v)
    _ -> Error(ProvidedTooManyTimes)
  }
}

fn ls_parser(
  flags: List(RawFlag),
  flag: FlagOpts(List(String)),
) -> Result(List(String), ParseError) {
  flags
  |> by_name(flag)
  |> list.filter_map(fn(f) {
    case f {
      B(..) -> Error(Nil)
      KV(_, v) -> Ok(v)
    }
  })
  |> Ok
}
