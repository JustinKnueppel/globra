import gleam/int
import gleam/list
import gleam/option
import gleam/result

/// Basic flags can either be key-value pairs or stand alone boolean toggles.
pub type FlagCore {
  B(name: String)
  KV(name: String, value: String)
}

pub opaque type Flag(a) {
  Flag(
    name: String,
    aliases: List(String),
    default: option.Option(a),
    parser: fn(List(FlagCore), Flag(a)) -> Result(a, ParseError),
  )
}

pub fn b(name: String) -> Flag(Bool) {
  Flag(name: name, aliases: [], default: option.None, parser: b_parser)
}

pub fn b_list(name: String) -> Flag(List(Bool)) {
  Flag(name: name, aliases: [], default: option.None, parser: lb_parser)
}

pub fn i(name: String) -> Flag(Int) {
  Flag(name: name, aliases: [], default: option.None, parser: i_parser)
}

pub fn i_list(name: String) -> Flag(List(Int)) {
  Flag(name: name, aliases: [], default: option.None, parser: li_parser)
}

pub fn s(name: String) -> Flag(String) {
  Flag(name: name, aliases: [], default: option.None, parser: s_parser)
}

pub fn s_list(name: String) -> Flag(List(String)) {
  Flag(name: name, aliases: [], default: option.None, parser: ls_parser)
}

fn by_name(flags: List(FlagCore), flag: Flag(a)) -> List(FlagCore) {
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

fn b_parser(flags: List(FlagCore), flag: Flag(Bool)) -> Result(Bool, ParseError) {
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
  flags: List(FlagCore),
  flag: Flag(List(Bool)),
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

fn i_parser(flags: List(FlagCore), flag: Flag(Int)) -> Result(Int, ParseError) {
  let results = flags |> by_name(flag)
  case results {
    [] -> option.to_result(flag.default, RequiredNotFound)
    [B(..)] -> Error(WrongType)
    [KV(_, v)] -> int.parse(v) |> result.map_error(fn(_) { WrongType })
    _ -> Error(ProvidedTooManyTimes)
  }
}

fn li_parser(
  flags: List(FlagCore),
  flag: Flag(List(Int)),
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
  flags: List(FlagCore),
  flag: Flag(String),
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
  flags: List(FlagCore),
  flag: Flag(List(String)),
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
