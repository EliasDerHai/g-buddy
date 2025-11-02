import env/action
import env/job
import env/shop
import env/story
import env/world.{type LocationId}
import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import msg.{type Msg, PlayerAction, PlayerMove, PlayerShop, PlayerWork, ShopOpen}
import state/check
import state/state.{type State}
import state/toast
import util/list_extension
import view/fight_view
import view/generic_view
import view/icons
import view/setting_view
import view/shop_view
import view/story_view
import view/texts

pub fn view(s: State) -> Element(Msg) {
  html.div([], [
    html.div([attribute.class("flex h-screen w-screen")], [
      html.div(
        [
          attribute.class(
            "bg-neutral-900 w-64 flex flex-col p-8 justify-between",
          ),
        ],
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
      let content = fn() {
        case s.overlay {
          state.NoOverlay -> []
          state.OverlayFight(fight:) -> fight_view.view_fight(s, fight)
          state.OverlayQuests -> todo
          state.OverlaySaveLoad -> setting_view.view_settings(s)
          state.OverlayShop(buyables:) -> shop_view.view_shop(s, buyables)
          state.OverlayStory(chapter_id:, node_id:) ->
            story_view.view_story(chapter_id, node_id)
        }
      }
      let close = case s.overlay {
        state.OverlayFight(_) | state.OverlayStory(_, _) -> None
        _ -> Some(msg.CloseOverlay)
      }

      generic_view.modal(s.overlay != state.NoOverlay, close, content)
    },
    toast.view_toasts(s.toasts),
  ])
}

fn view_left_hud(model: State) -> List(Element(Msg)) {
  [
    html.div(
      [attribute.class("flex flex-col")],
      [
        "Health: " <> model.p.health.v |> int.to_string,
        "Energy: " <> model.p.energy.v |> int.to_string,
        "Job: " <> model.p.job |> texts.job,
      ]
        |> list.map(generic_view.simple_text)
        |> list.append([
          "Items:" |> generic_view.simple_text,
          html.div(
            [attribute.class("flex flex-col gap-2 top-2")],
            model.p.inventory.consumables
              |> dict.to_list
              |> list.map(fn(tuple) {
                let #(consumable_id, amount) = tuple
                let text =
                  consumable_id |> texts.consumable
                  <> " x"
                  <> amount |> int.to_string
                generic_view.button(text, msg.PlayerConsum(consumable_id))
              }),
          ),
        ]),
    ),
    html.div([], [
      generic_view.button_with_icon(
        icons.scroll_text([]),
        "Quests",
        msg.SettingChange(msg.SettingToggleDisplay),
      ),
    ]),
  ]
}

fn view_right_hud(model: State) -> List(Element(Msg)) {
  [
    html.div(
      [attribute.class("flex flex-col")],
      [
        "Day: " <> model.p.day_count |> int.to_string,
        "Cash: $" <> model.p.money.v |> int.to_string,
        "Weapon: " <> model.p.equipped_weapon |> texts.weapon,
        "Strength: " <> model.p.skills.strength |> int.to_string,
        "Dexterity: " <> model.p.skills.dexterity |> int.to_string,
        "Intelligence: " <> model.p.skills.intelligence |> int.to_string,
        "Charm: " <> model.p.skills.charm |> int.to_string,
      ]
        |> list.map(generic_view.simple_text),
    ),
    html.div([], [
      generic_view.button_with_icon(
        icons.settings([]),
        "Settings",
        msg.SettingChange(msg.SettingToggleDisplay),
      ),
    ]),
  ]
}

fn view_navigation_buttons(state: State) -> List(Element(Msg)) {
  let location = world.get_location(state.p.location)
  let buyables = state.p.location |> shop.buyables
  let story_action =
    state.p.story
    |> dict.to_list
    |> list.find_map(fn(t) {
      let chap = t.1 |> story.story_chapter
      case chap.activation {
        story.Active(location:, action_title:) ->
          case state.p.location == location && chap.condition(state.p) {
            True -> Some(#(chap.id, action_title))
            False -> None
          }
        story.Auto(_) -> None
      }
      |> option.to_result(Nil)
    })
    |> option.from_result

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
            generic_view.button_with_icon_disabled(
              icons.briefcase_business([]),
              "Work",
              PlayerWork,
              check.check_work(state.p) |> option.map(texts.disabled_reason),
            ),
          )
          |> list_extension.append_when(
            buyables |> list.is_empty |> bool.negate,
            generic_view.button_with_icon(
              icons.shopping_cart([]),
              "Buy",
              PlayerShop(ShopOpen(buyables)),
            ),
          )
          |> list_extension.append_when(
            story_action |> option.is_some,
            generic_view.button_with_icon(
              icons.scroll_text([]),
              story_action |> option.map(fn(o) { o.1 }) |> option.unwrap(""),
              story_action
                |> option.map(fn(o) { msg.PlayerStory(msg.StoryActivate(o.0)) })
                |> option.unwrap(msg.Noop),
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
