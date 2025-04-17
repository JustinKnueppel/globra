import gleam/io
import gleam/list
import globra/args

pub fn main() {
  let flags = args.raw_args() |> args.parsed() |> args.partition()
  let cmd =
    Command("foo", [Command("bar", [Command("baz", [])]), Command("hello", [])])
  io.debug(find_command(cmd, flags))
}

pub type Command {
  Command(name: String, subcommands: List(Command))
}

fn find_command(
  root: Command,
  args: args.PartitionedArguments,
) -> Result(Command, String) {
  let args.PartitionedArguments(commands, flags) = args
  case commands {
    [] -> Ok(root)
    [first, ..rest] -> {
      case list.find(root.subcommands, fn(cmd) { cmd.name == first }) {
        Error(_) -> Error("Command not found")
        Ok(cmd) -> find_command(cmd, args.PartitionedArguments(rest, flags))
      }
    }
  }
}
