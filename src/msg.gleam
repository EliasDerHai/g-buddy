import env/action.{type Action}
import env/world.{type LocationId}
import plinth/browser/event.{type Event, type UIEvent}

pub type KeyboardEvent =
  Event(UIEvent(event.KeyboardEvent))

pub type Msg {
  PlayerMove(LocationId)
  PlayerWork
  PlayerFightMove(FightMove)
  PlayerAction(Action)
  KeyDown(event: KeyboardEvent)
  SettingChange(SettingMsg)
  Noop
}

pub type FightMove {
  Attack
  Flee
  End
}

pub type SettingMsg {
  SettingToggleDisplay
  SettingToggleAutoload
  SettingToggleAutosave
  SettingReset
}
