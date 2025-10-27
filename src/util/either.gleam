import gleam/string

/// similar to a Result, but doesn't imply a success or failure 
/// character of it's variants
pub type Either(left, right) {
  Left(left)
  Right(right)
}

pub fn from_left(left: left) {
  Left(left)
}

pub fn from_right(right: right) {
  Right(right)
}

pub fn is_left(either: Either(left, right)) {
  case either {
    Left(_) -> True
    Right(_) -> False
  }
}

pub fn is_right(either: Either(left, right)) {
  !is_left(either)
}

pub fn left(e: Either(l, r)) {
  case e {
    Left(l) -> l
    Right(_) -> panic as { "Either " <> e |> string.inspect <> " not a left" }
  }
}

pub fn right(e: Either(l, r)) {
  case e {
    Left(_) -> panic as { "Either " <> e |> string.inspect <> " not a right" }
    Right(r) -> r
  }
}
