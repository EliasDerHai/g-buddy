import env/world.{type LocationId}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import msg.{type Msg}
import state/state.{type State}

pub fn view(model: State) -> Element(Msg) {
  html.div([attribute.class("flex h-screen w-screen")], [
    html.div([attribute.class("bg-neutral-900 w-64")], [
      html.text("Left Sidebar"),
    ]),
    html.div([attribute.class("flex-1")], view_navigation_buttons(model)),
    html.div([attribute.class("bg-neutral-900 w-64")], [
      html.text("Right Sidebar"),
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
  let label = world.label(location_id)
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
    ],
    [
      html.div([attribute.class("text-sm")], [html.text(direction)]),
      html.div([attribute.class("font-bold")], [html.text(label)]),
    ],
  )
}
