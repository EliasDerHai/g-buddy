import env/action.{type Action, type ActionId}
import env/world.{type LocationId}

pub type Msg {
  PlayerMove(LocationId)
  PlayerWork
  PlayerFightMove(FightMove)
  PlayerAction(Action)
}

pub type FightMove {
  Attack
  Flee
  End
}
