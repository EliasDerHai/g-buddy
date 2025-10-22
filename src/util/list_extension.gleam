import gleam/list

pub fn of_one(a) -> List(a) {
  [a]
}

pub fn append_when(l: List(a), cond: Bool, item) -> List(a) {
  case cond {
    False -> l
    True -> l |> list.append(item |> of_one)
  }
}
