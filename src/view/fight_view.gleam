import gleam/int
import gleam/option.{None}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import msg.{type Msg, Attack, End, Flee, PlayerFightMove}
import state/state.{
  type Fight, type Player, EnemyTurn, EnemyWon, PlayerFled, PlayerTurn,
  PlayerWon,
}
import util/list_extension
import view/generic_view
import view/texts

pub fn view_fight(p: Player, fight: Fight) -> List(Element(Msg)) {
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
    html.div([attribute.class("flex gap-4 justify-center")], case fight.phase {
      PlayerTurn -> [
        generic_view.simple_button("Attack", PlayerFightMove(Attack), None),
        generic_view.simple_button("Flee", PlayerFightMove(Flee), None),
      ]
      PlayerWon | EnemyWon | PlayerFled -> [
        generic_view.simple_button("Close", PlayerFightMove(End), None),
      ]
      EnemyTurn ->
        panic as "Illegal state - EnemyTurn has to be processed before view"
    }),
  ]
}
