import env/world.{type LocationId}

pub type Msg {
  PlayerMove(LocationId)
  PlayerWork
  PlayerFightMove(FightMove)
}

pub type FightMove {
  Attack
  Flee
  End
}
