import env/weapon
import gleam/list
import gleam/option.{None}
import gleam/set
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import msg.{type Msg}
import state/state.{type State}
import view/generic_view
import view/texts
import view/tooltip

pub fn view_weapons(s: State) -> List(Element(Msg)) {
  [
    "Weapon" |> generic_view.heading,
    s.p.inventory.collected_weapons
      |> set.to_list
      |> list.map(fn(w) { view_weapon(s, w) })
      |> html.div([attribute.class("flex flex-col gap-4 w-80 m-auto")], _),
  ]
}

fn view_weapon(s: State, weapon_id: weapon.WeaponId) -> Element(Msg) {
  let label = weapon_id |> texts.weapon

  generic_view.ButtonConfig(
    label: label,
    on_click: msg.PlayerEquipWeapon(weapon_id),
    disabled_reason: None,
    icon: None,
    style: generic_view.Primary,
    full_width: True,
  )
  |> generic_view.custom_button
  |> tooltip.tooltip_top(
    s.active_tooltip,
    "weapon_picker_" <> weapon_id |> string.inspect,
    // TODO: proper tooltip
    fn() { ["TODO" |> generic_view.simple_text] },
  )
}
