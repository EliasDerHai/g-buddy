import env/attack.{type AttackMove}
import env/weapon
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import msg.{
  type Msg, FightAttack, FightEnd, FightFlee, FightRegenStamina, PlayerFightMove,
}
import state/state.{
  type Fight, type State, EnemyTurn, EnemyWon, PlayerFled, PlayerTurn, PlayerWon,
}
import util/list_extension
import view/generic_view
import view/icons
import view/texts
import view/tooltip

pub fn view_fight(state: State, fight: Fight) -> List(Element(Msg)) {
  let p = state.p

  [
    html.h2([attribute.class("text-2xl font-bold mb-4")], [
      html.text("Fight!"),
    ]),
    // Stats
    html.div([attribute.class("flex justify-between mb-6")], [
      html.div(
        [],
        [
          html.p([attribute.class("font-bold")], [html.text("You")]),
          html.p([], [
            html.text(
              "HP: "
              <> int.to_string(p.health.v)
              <> "/"
              <> int.to_string(p.health.max),
            ),
          ]),
          html.p([], [
            html.text(
              "Stamina: "
              <> int.to_string(fight.stamina.v)
              <> "/"
              <> int.to_string(fight.stamina.max),
            ),
          ]),
        ]
          |> list_extension.append_when(
            fight.last_player_dmg |> option.is_some(),
            html.p([attribute.class("text-red-100")], [
              html.text(
                "Dmg dealt: "
                <> fight.last_player_dmg |> option.unwrap(0) |> int.to_string,
              ),
            ]),
          ),
      ),
      html.div(
        [],
        [
          html.p([attribute.class("font-bold")], [
            html.text(texts.enemy(fight.enemy.id)),
          ]),
          html.p([], [html.text("HP: " <> int.to_string(fight.enemy.health))]),
        ]
          |> list_extension.append_when(
            fight.last_enemy_dmg |> option.is_some(),
            html.p([attribute.class("text-red-100")], [
              html.text(
                "Dmg dealt: "
                <> fight.last_enemy_dmg |> option.unwrap(0) |> int.to_string,
              ),
            ]),
          ),
      ),
    ]),
    // Phase display
    html.div([attribute.class("mb-6 text-center")], [
      case fight.phase {
        PlayerTurn ->
          html.p([attribute.class("text-blue-400")], [html.text("Your turn")])
        EnemyTurn ->
          html.p([attribute.class("text-red-400")], [html.text("Enemy turn")])
        PlayerWon ->
          html.p([attribute.class("text-green-400")], [html.text("Victory!")])
        EnemyWon ->
          html.p([attribute.class("text-red-400")], [html.text("Defeated!")])
        PlayerFled ->
          html.p([attribute.class("text-yellow-400")], [html.text("Fled!")])
      },
    ]),
    // Actions
    html.div(
      [attribute.class("flex flex-col gap-4 justify-center w-80 m-auto")],
      case fight.phase {
        PlayerTurn ->
          attack.get_attack_options(p, fight)
          |> list.map(fn(attack) { view_attack_button(state, attack) })
          |> list.append([
            generic_view.full_width_icon_button(
              icons.arrow_big_up_dash([]),
              "Regen. Stamina",
              PlayerFightMove(FightRegenStamina),
            ),
            generic_view.full_width_icon_button(
              icons.arrow_big_left_dash([]),
              "Flee",
              PlayerFightMove(FightFlee),
            ),
          ])
        PlayerWon | EnemyWon | PlayerFled -> [
          generic_view.full_width_button("Close", PlayerFightMove(FightEnd)),
        ]
        EnemyTurn ->
          panic as "Illegal state - EnemyTurn has to be processed before view"
      },
    ),
  ]
}

pub fn view_attack_button(state: State, attack: AttackMove) -> Element(Msg) {
  generic_view.full_width_icon_button(
    icons.sword([]),
    attack.id |> texts.attack,
    PlayerFightMove(FightAttack(attack)),
  )
  |> tooltip.tooltip_top(
    state.active_tooltip,
    "attack-" <> attack.id |> string.inspect,
    fn() { tooltip(state, attack) },
  )
}

fn tooltip(state: State, attack: AttackMove) {
  let weapon.WeaponStat(id: _, dmg:, def:, crit:) =
    state.p.weapon |> weapon.weapon_stats

  [
    html.div([attribute.class("space-y-2")], [
      html.h4([attribute.class("font-bold text-lg")], [
        html.text(attack.id |> texts.attack),
      ]),
      html.div([attribute.class("grid grid-cols-2 gap-2 text-sm")], [
        html.div([attribute.class("flex flex-col")], [
          html.span([attribute.class("text-gray-400")], [
            html.text("Stamina Cost:"),
          ]),
          html.text(" " <> int.to_string(attack.stamina_cost)),
        ]),
        html.div([attribute.class("flex flex-col")], [
          html.span([attribute.class("text-gray-400")], [
            html.text("Damage: "),
          ]),
          html.text(" " <> dmg |> int.to_string),
        ]),
        html.div([attribute.class("flex flex-col")], [
          html.span([attribute.class("text-gray-400")], [
            html.text("Crit Chance: "),
          ]),
          html.text(
            " "
            <> { crit |> float.to_precision(2) } *. 100.0 |> float.to_string
            <> "%",
          ),
        ]),
        html.div([attribute.class("flex flex-col")], [
          html.span([attribute.class("text-gray-400")], [
            html.text("Defence: "),
          ]),
          html.text(" " <> def |> int.to_string),
        ]),
      ]),
    ]),
  ]
}
