import globra/args
import globra/flag

pub type Command {
  Command(name: String, action: fn(List(args.RawFlag)) -> Result(Nil, String))
}

pub fn execute_root(command: Command(e)) -> Result(Nil, String) {
  case args.raw_args() |> args.parsed() |> args.partition() {
    args.PartitionedArguments(commands, flags) -> Ok(Nil)
  }
}

/// execute finds the correct command to execute.
fn execute(command: Command, args: List(args.RawFlag)) -> Result(Nil, String) {
  todo
}
