import gleam/list
import gleam/option
import gleam/result

/// Basic flags can either be key-value pairs or stand alone boolean toggles.
pub type FlagCore {
  B(name: String)
  KV(name: String, value: String)
}

type FlagOpts {
  FlagOpts(required: Bool)
}

pub opaque type Flag(a) {
  Flag(
    name: String,
    aliases: List(String),
    opts: FlagOpts,
    default: option.Option(a),
  )
}

// pub fn get_value(flags: List(FlagCore), flag: Flag(a)) -> a {
//   flag.parser(flags)
// }

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
  let default = option.unwrap(flag.default, False)
  case results, flag.opts {
    [], _ -> Ok(option.unwrap(flag.default, False))
    [B(..)], _ -> Ok(True)
    [KV(_, "true")], _ -> Ok(True)
    [KV(_, "false")], _ -> Ok(False)
    [KV(_, _)], _ -> Error(WrongType)
    _, _ -> Error(ProvidedTooManyTimes)
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
// fn i_parser(flags: List(FlagCore), flag: Flag(Int)) -> Result(Int, ParseError) {
//   let results = flags |> by_name(flag)
//   case results, flag.opts {
//     [], 
//   }
// }
