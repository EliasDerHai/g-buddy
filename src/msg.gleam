import env/action.{type Action}
import env/attack.{type AttackMove}
import env/shop.{type Buyable, type ConsumableId}
import env/world.{type LocationId}
import plinth/browser/event.{type Event, type UIEvent}
import state/state.{type StoryChapterId, type StoryLineId}
import state/toast.{type Toast}

pub type KeyboardEvent =
  Event(UIEvent(event.KeyboardEvent))

pub type Msg {
  PlayerMove(LocationId)
  PlayerWork
  PlayerFightMove(FightMove)
  PlayerAction(Action)
  PlayerShop(PlayerShopMsg)
  PlayerConsum(ConsumableId)
  PlayerStory(StoryMsg)
  KeyDown(KeyboardEvent)
  SettingChange(SettingMsg)
  ToastChange(ToastMsg)
  TooltipChange(TooltipMsg)
  Noop
}

pub type FightMove {
  FightAttack(AttackMove)
  FightRegenStamina
  FightFlee
  FightEnd
}

pub type PlayerShopMsg {
  ShopOpen(options: List(Buyable))
  ShopClose
  ShopBuy(item: Buyable)
}

pub type StoryMsg {
  StoryActivate(chap: StoryChapterId)
  StoryOptionPick(chap: StoryChapterId, node_id: Int)
  StoryChapterComplete(next_chap: StoryChapterId, for_line: StoryLineId)
}

pub type SettingMsg {
  SettingToggleDisplay
  SettingToggleAutoload
  SettingToggleAutosave
  SettingReset
}

pub type ToastMsg {
  ToastAdd(Toast)
  ToastRemove(id: Int)
}

pub type TooltipMsg {
  TooltipShow(id: String)
  TooltipHide
}
