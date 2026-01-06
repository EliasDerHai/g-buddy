import env/attack.{type AttackMove}
import env/fight_types
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
  let weapon.WeaponStat(id: _, dmg: dmg_weap, def: def_weap, crit: crit_weap) =
    p.equipped_weapon |> weapon.weapon_stats
  let #(dmg_skill, def_skill, crit_skill) = p.skills |> state.skill_dmg_def

  let dmg = fight_types.add_dmg(dmg_weap, dmg_skill)
  let def = fight_types.add_def(def_weap, def_skill)
  let crit = fight_types.add_crit(crit_weap, crit_skill)

  [
    "Fight!" |> generic_view.heading,
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
          html.p([], [
            html.text("Dmg: " <> dmg.v |> int.to_string)
            |> tooltip.tooltip_top(state.active_tooltip, "dmg", fn() {
              [
                html.div([attribute.class("space-y-2")], [
                  html.h4([attribute.class("font-bold text-lg")], [
                    html.text("Dmg:"),
                  ]),
                  html.div([attribute.class("grid grid-cols-2 gap-2 text-sm")], [
                    "Body (str):" |> generic_view.simple_text,
                    dmg_skill |> fight_types.dmg_str |> generic_view.simple_text,
                    "Weapon:" |> generic_view.simple_text,
                    dmg_weap |> fight_types.dmg_str |> generic_view.simple_text,
                  ]),
                ]),
              ]
            }),
          ]),
          html.p([], [
            html.text("Def: " <> def.v |> int.to_string)
            |> tooltip.tooltip_top(state.active_tooltip, "def", fn() {
              [
                html.div([attribute.class("space-y-2")], [
                  html.h4([attribute.class("font-bold text-lg")], [
                    html.text("Def:"),
                  ]),
                  html.div([attribute.class("grid grid-cols-2 gap-2 text-sm")], [
                    "Body (str):" |> generic_view.simple_text,
                    def_skill |> fight_types.def_str |> generic_view.simple_text,
                    "Weapon:" |> generic_view.simple_text,
                    def_weap |> fight_types.def_str |> generic_view.simple_text,
                  ]),
                ]),
              ]
            }),
          ]),
          html.p([], [
            html.text(
              "Crit: "
              <> { crit.v |> float.to_precision(2) } *. 100.0 |> float.to_string
              <> "%",
            )
            |> tooltip.tooltip_top(state.active_tooltip, "crit", fn() {
              [
                html.div([attribute.class("space-y-2")], [
                  html.h4([attribute.class("font-bold text-lg")], [
                    html.text("Crit:"),
                  ]),
                  html.div([attribute.class("grid grid-cols-2 gap-2 text-sm")], [
                    "Body (dex):" |> generic_view.simple_text,
                    crit_skill
                      |> fight_types.crit_str
                      |> generic_view.simple_text,
                    "Weapon:" |> generic_view.simple_text,
                    crit_weap
                      |> fight_types.crit_str
                      |> generic_view.simple_text,
                  ]),
                ]),
              ]
            }),
          ]),
        ]
          |> list_extension.append_when(
            fight.last_player_dmg |> option.is_some(),
            html.p([attribute.class("text-red-300")], [
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
          html.p([], [html.text("Hp: " <> int.to_string(fight.enemy.health))]),
          // symmetry with player (no stamina)
          html.br([]),
          html.p([], [
            html.text("Dmg: " <> fight.enemy.dmg |> fight_types.dmg_str),
          ]),
          html.p([], [
            html.text("Def: " <> fight.enemy.def |> fight_types.def_str),
          ]),
          html.p([], [
            html.text("Crit: " <> fight.enemy.crit |> fight_types.crit_str),
          ]),
        ]
          |> list_extension.append_when(
            fight.last_enemy_dmg |> option.is_some(),
            html.p([attribute.class("text-red-300")], [
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
        PlayerWon(reward:) ->
          html.div([], [
            html.p([attribute.class("text-green-400")], [html.text("Victory!")]),
            html.p([], [
              { "Enemy dropped: 💲" <> reward |> int.to_string }
              |> generic_view.simple_text,
            ]),
          ])
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
        PlayerWon(_) | EnemyWon | PlayerFled -> [
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
    fn() { attack_tooltip(attack) },
  )
}

fn attack_tooltip(attack: AttackMove) {
  let attack.AttackMove(
    id: _,
    requirements: _,
    stamina_cost:,
    dmg:,
    crit:,
    weapon: _,
  ) = attack

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
          html.text(stamina_cost |> int.to_string),
        ]),
        html.div([attribute.class("flex flex-col")], [
          html.span([attribute.class("text-gray-400")], [
            html.text("Damage:"),
          ]),
          html.text("+" <> dmg.v |> int.to_string),
        ]),
        html.div([attribute.class("flex flex-col")], [
          html.span([attribute.class("text-gray-400")], [
            html.text("Crit Chance:"),
          ]),
          html.text(
            "+"
            <> { crit.v |> float.to_precision(2) } *. 100.0 |> float.to_string
            <> "%",
          ),
        ]),
      ]),
    ]),
  ]
}
