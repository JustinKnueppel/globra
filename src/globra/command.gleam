import globra/args
import globra/flag

pub type Command {
  Command(name: String, action: fn(List(args.RawFlag)) -> Result(Nil, String))
}

pub fn execute_root(command: Command(e)) -> Result(Nil, String) {
  case args.raw_args() |> args.parsed() |> args.partition() {
    args.PartitionedArguments(commands, flags) ->
      execute(command, commands, flags)
  }
}

/// execute finds the correct command to execute.
fn execute(
  command: Command,
  commands: List(String),
  args: List(args.RawFlag),
) -> Result(Nil, String) {
  case commands {
    "help" -> generate_help(command)
  }
}

fn generate_help(command: Command) -> Result(Nil, String) {
  io.debug("hello")
}
