import env/action
import env/job
import env/world.{type LocationId}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import msg.{type Msg, PlayerAction, PlayerMove, PlayerWork}
import state/check
import state/state.{type State}
import util/list_extension
import view/fight_view
import view/generic_view
import view/setting_view
import view/texts

pub fn view(s: State) -> Element(Msg) {
  [
    html.div([attribute.class("flex h-screen w-screen")], [
      html.div(
        [attribute.class("bg-neutral-900 w-64 flex flex-col p-8")],
        view_left_hud(s),
      ),
      html.div([attribute.class("flex-1")], view_navigation_buttons(s)),
      html.div(
        [
          attribute.class(
            "bg-neutral-900 w-64 flex flex-col p-8 justify-between",
          ),
        ],
        view_right_hud(s),
      ),
    ]),
    {
      let is_open = s.fight |> option.is_some
      let content = case s.fight {
        None -> []
        Some(fight) -> fight_view.view_fight(s.p, fight)
      }
      generic_view.modal(is_open, None, content)
    },
    {
      let #(is_open, content) = case s.settings.display {
        state.Hidden -> #(False, [])
        state.SaveLoad -> #(True, setting_view.view_settings(s))
      }
      generic_view.modal(is_open, Some(msg.SettingToggle), content)
    },
  ]
  |> html.div([], _)
}

fn view_left_hud(model: State) -> List(Element(Msg)) {
  [
    { "Health: " <> model.p.health.v |> int.to_string }
      |> generic_view.simple_text,
    { "Energy: " <> model.p.energy.v |> int.to_string }
      |> generic_view.simple_text,
    { "Job: " <> model.p.job |> texts.job } |> generic_view.simple_text,
  ]
}

fn view_right_hud(model: State) -> List(Element(Msg)) {
  [
    html.div([attribute.class("flex flex-col")], [
      { "Day: " <> model.p.day_count |> int.to_string }
        |> generic_view.simple_text,
      { "Cash: $" <> model.p.money.v |> int.to_string }
        |> generic_view.simple_text,
      { "Weapon: " <> model.p.weapon |> texts.weapon }
        |> generic_view.simple_text,
      { "Strength: " <> model.p.skills.strength |> int.to_string }
        |> generic_view.simple_text,
      { "Dexterity: " <> model.p.skills.dexterity |> int.to_string }
        |> generic_view.simple_text,
      { "Intelligence: " <> model.p.skills.intelligence |> int.to_string }
        |> generic_view.simple_text,
      { "Charm: " <> model.p.skills.charm |> int.to_string }
        |> generic_view.simple_text,
    ]),
    html.div([], [
      generic_view.simple_button("Settings", msg.SettingToggle, None),
    ]),
  ]
}

fn view_navigation_buttons(state: State) -> List(Element(Msg)) {
  let location = world.get_location(state.p.location)

  let #(n, e, s, w) = location.connections

  [
    html.div([attribute.class("relative h-full w-full")], [
      // North
      html.div([attribute.class("absolute top-4 left-1/2 -translate-x-1/2")], [
        navigation_button(n, "North"),
      ]),
      // East
      html.div([attribute.class("absolute right-4 top-1/2 -translate-y-1/2")], [
        navigation_button(e, "East"),
      ]),
      // South
      html.div(
        [attribute.class("absolute bottom-4 left-1/2 -translate-x-1/2")],
        [navigation_button(s, "South")],
      ),
      // West
      html.div([attribute.class("absolute left-4 top-1/2 -translate-y-1/2")], [
        navigation_button(w, "West"),
      ]),

      // Center
      html.div(
        [
          attribute.class(
            "flex flex-col gap-4 items-center justify-center h-full w-full p-16",
          ),
        ],
        []
          |> list_extension.append_when(
            { state.p.job |> job.job_stats }.workplace == state.p.location,
            generic_view.simple_button(
              "Work",
              PlayerWork,
              check.check_work(state.p) |> option.map(texts.disabled_reason),
            ),
          )
          |> list.append(view_actions(state)),
      ),
    ]),
  ]
}

fn navigation_button(location_id: LocationId, direction: String) -> Element(Msg) {
  let label = texts.location(location_id)
  let is_disabled = location_id == world.NoLocation

  let base_classes = "px-6 py-3 rounded-lg font-medium transition-colors"
  let state_classes = case is_disabled {
    True -> "bg-gray-700 text-gray-500 cursor-not-allowed"
    False -> "bg-blue-600 text-white hover:bg-blue-700 cursor-pointer"
  }

  html.button(
    [
      attribute.class(base_classes <> " " <> state_classes),
      attribute.disabled(is_disabled),
      event.on_click(PlayerMove(location_id)),
    ],
    [
      html.div([attribute.class("text-sm")], [html.text(direction)]),
      html.i([], [html.text(label)]),
    ],
  )
}

fn view_actions(state: State) -> List(Element(Msg)) {
  action.get_action_by_location(state.p.location)
  |> list.map(fn(a) {
    generic_view.simple_button(
      a.id |> texts.action,
      PlayerAction(a),
      state.p
        |> check.check_action_costs(a.costs)
        |> list.first
        |> option.from_result
        |> option.map(texts.disabled_reason),
    )
  })
}
