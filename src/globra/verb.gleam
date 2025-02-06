import globra/action.{type Action}
import globra/noun.{type Noun}
import gleam/option

pub type Verb {
  Verb(
    name: String,
    aliases: List(String),
    action: option.Option(Action),
    nouns: option.Option(List(Noun)),
  )
}

pub fn new_verb(name: String) -> Verb {
  Verb(name: name, aliases: [], action: option.None, nouns: option.None)
}

pub fn verb_with_aliases(verb: Verb, aliases: List(String)) -> Verb {
  Verb(..verb, aliases: aliases)
}

pub fn verb_with_action(verb: Verb, action: Action) -> Verb {
  Verb(..verb, action: option.Some(action))
}

pub fn verb_with_nouns(verb: Verb, nouns: List(Noun)) -> Verb {
  Verb(..verb, nouns: option.Some(nouns))
}
