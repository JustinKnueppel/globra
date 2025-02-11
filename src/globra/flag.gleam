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
    parser: fn(List(FlagCore)) -> a,
    opts: FlagOpts,
  )
}

pub fn get_value(flags: List(FlagCore), flag: Flag(a)) -> a {
  flag.parser(flags)
}

fn by_name(flags: List(FlagCore), flag: Flag(a)) -> List(FlagCore) {
  use f <- list.filter(flags)
  case f {
    B(name) -> list.contains([flag.name, ..flag.aliases], name)
    KV(name, _) -> list.contains([flag.name, ..flag.aliases], name)
  }
}

fn b_parser(flags: List(FlagCore), flag: Flag(a)) -> Result(Bool, Nil) {
  let results = flags |> by_name(flag)
  case list.length(results), flag.opts {
    0, FlagOpts(required: True) -> 
  }
  Error(Nil)
}
