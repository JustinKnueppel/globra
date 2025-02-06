pub type Action {
  Action(run: fn() -> Nil)
}

pub fn new_action(f: fn() -> Nil) -> Action {
  Action(run: f)
}
