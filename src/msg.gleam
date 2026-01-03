import env/action.{type Action}
import env/attack.{type AttackMove}
import env/shop.{type Buyable, type ConsumableId}
import env/weapon.{type WeaponId}
import env/world.{type LocationId}
import plinth/browser/event.{type Event, type UIEvent}
import state/state.{type Overlay, type StoryChapterId}
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
  PlayerEquipWeapon(WeaponId)
  OpenOverlay(Overlay)
  CloseOverlay
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
  ShopBuy(item: Buyable)
}

pub type StoryMsg {
  StoryActivate(chap: StoryChapterId)
  StoryOptionPick(chap: StoryChapterId, node_id: Int)
  StoryChapterComplete(chap: StoryChapterId)
}

pub type SettingMsg {
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
