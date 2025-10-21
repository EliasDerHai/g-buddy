import env/world.{type LocationId}
import gleam/int
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import msg.{type Msg}
import state/state.{type State}
import view/texts

pub fn view(model: State) -> Element(Msg) {
  let sidebar_attrs = [attribute.class("bg-neutral-900 w-64 flex flex-col p-8")]

  html.div([attribute.class("flex h-screen w-screen")], [
    html.div(sidebar_attrs, [
      { "Health: " <> model.p.health.v |> int.to_string } |> simple_text,
      { "Job: " <> model.p.job |> texts.job } |> simple_text,
    ]),
    html.div([attribute.class("flex-1")], view_navigation_buttons(model)),
    html.div(sidebar_attrs, [
      { "Cash: $" <> model.p.money.v |> int.to_string } |> simple_text,
      { "Weapon: " <> model.p.weapon |> texts.weapon } |> simple_text,
    ]),
  ])
}

fn view_navigation_buttons(model: State) -> List(Element(Msg)) {
  let location = world.get_location(model.p.location)

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
          attribute.class("flex items-center justify-center h-full w-full p-16"),
        ],
        [html.text("Center Content Area")],
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
      event.on_click(msg.PlayerMove(location_id)),
    ],
    [
      html.div([attribute.class("text-sm")], [html.text(direction)]),
      html.i([], [html.text(label)]),
    ],
  )
}

// utils ----------------------------------------
fn simple_text(t: String) -> Element(a) {
  html.span([], [html.text(t)])
}
