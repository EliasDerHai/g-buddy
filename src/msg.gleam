import env/world.{type LocationId}

pub type FightMove {
  Attack
  Flee
}

pub type Msg {
  PlayerMove(LocationId)
  PlayerWork
  PlayerFightMove(FightMove)
}
