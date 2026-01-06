import env/action
import env/shop.{type Buyable}
import gleam/int
import gleam/list
import gleam/option.{None}
import gleam/set
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import msg.{type Msg, PlayerShop, ShopBuy}
import state/check.{AlreadyOwned}
import state/state.{type State}
import util/either
import view/generic_view
import view/texts

pub fn view_shop(s: State, buyables: List(Buyable)) -> List(Element(Msg)) {
  [
    "Shop" |> generic_view.heading,
    html.div(
      [attribute.class("flex flex-col gap-4 w-80 m-auto")],
      buyables
        |> list.map(fn(buyable) { view_buyable(s, buyable) }),
    ),
  ]
}

fn view_buyable(s: State, buyable: Buyable) -> Element(Msg) {
  let #(name, saturated) = case buyable.id {
    either.Left(weapon_id) -> #(
      texts.weapon(weapon_id),
      s.p.inventory.collected_weapons |> set.contains(weapon_id),
    )
    either.Right(consumable_id) -> #(texts.consumable(consumable_id), False)
  }

  let can_afford = s.p.money.v >= buyable.price
  let disabled_reason =
    case can_afford {
      True -> None
      False ->
        option.Some(check.Insufficient(action.Money(cost: buyable.price)))
    }
    |> option.or(case saturated {
      False -> None
      True -> option.Some(AlreadyOwned)
    })
    |> option.map(texts.disabled_reason)

  let label = name <> " -💲" <> int.to_string(buyable.price)

  generic_view.ButtonConfig(
    label: label,
    on_click: PlayerShop(ShopBuy(item: buyable)),
    disabled_reason: disabled_reason,
    icon: None,
    style: generic_view.Primary,
    full_width: True,
  )
  |> generic_view.custom_button
}
