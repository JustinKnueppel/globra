import globra/args
import gleam/io

pub fn main() {
  io.debug(args.raw_args())
  io.debug(args.raw_args() |> args.parsed())
}
