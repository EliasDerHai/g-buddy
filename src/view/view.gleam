import env/job
import env/world.{type LocationId}
import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import msg.{type Msg, PlayerMove, PlayerWork}
import state/check
import state/state.{type State}
import util/list_extension
import view/icons
import view/texts

pub fn view(model: State) -> Element(Msg) {
  let sidebar_attrs = [attribute.class("bg-neutral-900 w-64 flex flex-col p-8")]

  html.div([], [
    html.div([attribute.class("flex h-screen w-screen")], [
      html.div(sidebar_attrs, [
        { "Health: " <> model.p.health.v |> int.to_string } |> simple_text,
        { "Energy: " <> model.p.energy.v |> int.to_string } |> simple_text,
        { "Job: " <> model.p.job |> texts.job } |> simple_text,
      ]),
      html.div([attribute.class("flex-1")], view_navigation_buttons(model)),
      html.div(sidebar_attrs, [
        { "Cash: $" <> model.p.money.v |> int.to_string } |> simple_text,
        { "Weapon: " <> model.p.weapon |> texts.weapon } |> simple_text,
      ]),
    ]),
    modal(
      model.fight |> option.is_some,
      Some(PlayerMove(model.p.location)),
      "hello modal" |> simple_text |> list_extension.of_one,
    ),
  ])
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
          attribute.class("flex items-center justify-center h-full w-full p-16"),
        ],
        []
          |> list_extension.append_when(
            { state.p.job |> job.job_stats }.workplace == state.p.location,
            simple_button("Work", PlayerWork, !check.can_work(state.p)),
          ),
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

// utils ----------------------------------------
fn simple_text(t: String) -> Element(a) {
  html.span([], [html.text(t)])
}

fn simple_button(t: String, msg: Msg, is_disabled: Bool) -> Element(Msg) {
  let base_classes = "px-6 py-3 rounded-lg font-medium transition-colors"
  let state_classes = case is_disabled {
    True -> "bg-gray-700 text-gray-500 cursor-not-allowed"
    False -> "bg-blue-600 text-white hover:bg-blue-700 cursor-pointer"
  }

  html.button(
    [
      attribute.class(base_classes <> " " <> state_classes),
      attribute.disabled(is_disabled),
      event.on_click(msg),
    ],
    [
      html.span([attribute.class("text-sm")], [html.text(t)]),
    ],
  )
}

fn modal(
  is_open: Bool,
  closeable: Option(Msg),
  content: List(Element(Msg)),
) -> Element(Msg) {
  use <- bool.guard(!is_open, html.div([], []))

  html.div([], [
    // Backdrop
    case closeable {
      Some(effect) ->
        html.div(
          [
            attribute.class("fixed inset-0 bg-black/50 z-1"),
            event.on_click(effect),
          ],
          [],
        )
      None -> html.div([], [])
    },
    // Modal
    html.div(
      [
        attribute.class(
          "fixed inset-0 grid place-items-center z-2 pointer-events-none",
        ),
      ],
      [
        html.div(
          [
            attribute.class(
              "pointer-events-auto bg-neutral-800 rounded-lg shadow-xl max-w-2xl w-full mx-4 relative",
            ),
          ],
          list.flatten([
            // Close button
            case closeable {
              Some(effect) -> [
                html.button(
                  [
                    attribute.class(
                      "cursor-pointer absolute top-4 right-4 text-gray-400 hover:text-white transition-colors",
                    ),
                    event.on_click(effect),
                  ],
                  [icons.x([])],
                ),
              ]
              None -> []
            },
            // Modal content
            [html.div([attribute.class("p-8")], content)],
          ]),
        ),
      ],
    ),
  ])
}
