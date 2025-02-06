import globra/action.{type Action}
import gleam/option

pub type Noun {
  Noun(name: String, aliases: List(String), action: option.Option(Action))
}

pub fn new_noun(name: String) -> Noun {
  Noun(name: name, aliases: [], action: option.None)
}

pub fn noun_with_aliases(noun: Noun, aliases: List(String)) -> Noun {
  Noun(..noun, aliases: aliases)
}

pub fn noun_with_action(noun: Noun, action: Action) -> Noun {
  Noun(..noun, action: option.Some(action))
}
