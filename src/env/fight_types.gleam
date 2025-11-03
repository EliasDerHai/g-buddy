import gleam/float

pub type Dmg {
  Dmg(v: Int)
}

pub type Def {
  Def(v: Int)
}

pub type Crit {
  Crit(v: Float)
}

pub fn add_dmg(left: Dmg, right: Dmg) -> Dmg {
  Dmg(left.v + right.v)
}

pub fn add_def(left: Def, right: Def) -> Def {
  Def(left.v + right.v)
}

pub fn add_crit(left: Crit, right: Crit) -> Crit {
  left.v +. right.v
  |> float.min(1.0)
  |> Crit
}
