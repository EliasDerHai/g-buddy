import env/action.{type ActionId}
import env/world.{type LocationId}

pub type Msg {
  PlayerMove(LocationId)
  PlayerWork
  PlayerFightMove(FightMove)
  PlayerAction(ActionId)
}

pub type FightMove {
  Attack
  Flee
  End
}
