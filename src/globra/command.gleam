import globra/args
import globra/flag

pub type Command(e) {
  Command(name: String, action: fn(List(flag.RawFlag)) -> Result(Nil, e))
}

pub fn execute(command: Command(e)) -> Result(Nil, e) {
  case args.raw_args() |> args.parsed() |> args.partition() {
    args.PartitionedArguments(commands, flags) -> Ok(Nil)
  }
}
