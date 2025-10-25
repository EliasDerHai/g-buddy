import gleam/bool
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import msg.{type Msg}
import view/icons

pub fn simple_text(t: String) -> Element(a) {
  html.span([], [html.text(t)])
}

pub fn simple_button(
  t: String,
  msg: Msg,
  disabled_reason: Option(String),
) -> Element(Msg) {
  let base_classes = "px-6 py-3 rounded-lg font-medium transition-colors"
  let is_disabled = disabled_reason |> option.is_some
  let state_classes = case is_disabled {
    True -> "bg-gray-700 text-gray-500 cursor-not-allowed"
    False -> "bg-blue-600 text-white hover:bg-blue-700 cursor-pointer"
  }

  html.span(
    case disabled_reason {
      None -> []
      Some(disabled_reason) -> [attribute.title(disabled_reason)]
    },
    [
      html.button(
        [
          attribute.class(base_classes <> " " <> state_classes),
          attribute.disabled(is_disabled),
          event.on_click(msg),
        ],
        [
          html.span([attribute.class("text-sm")], [html.text(t)]),
        ],
      ),
    ],
  )
}

pub fn simple_warn_button(
  t: String,
  msg: Msg,
  disabled_reason: Option(String),
) -> Element(Msg) {
  let base_classes = "px-6 py-3 rounded-lg font-medium transition-colors"
  let is_disabled = disabled_reason |> option.is_some
  let state_classes = case is_disabled {
    True -> "bg-gray-700 text-gray-500 cursor-not-allowed"
    False -> "bg-red-400 text-white hover:bg-red-600 cursor-pointer"
  }

  html.span(
    case disabled_reason {
      None -> []
      Some(disabled_reason) -> [attribute.title(disabled_reason)]
    },
    [
      html.button(
        [
          attribute.class(base_classes <> " " <> state_classes),
          attribute.disabled(is_disabled),
          event.on_click(msg),
        ],
        [
          html.span([attribute.class("text-sm")], [html.text(t)]),
        ],
      ),
    ],
  )
}

pub fn toggle_button(active: Bool, on_toggle: Msg) -> Element(Msg) {
  let toggle_bg = case active {
    True -> "bg-blue-600"
    False -> "bg-gray-600"
  }

  let toggle_position = case active {
    True -> "translate-x-5"
    False -> "translate-x-0"
  }
  html.button(
    [
      attribute.class(
        "relative inline-flex h-6 w-11 items-center rounded-full transition-colors "
        <> toggle_bg,
      ),
      event.on_click(on_toggle),
    ],
    [
      html.span(
        [
          attribute.class(
            "inline-block h-4 w-4 transform rounded-full bg-white transition-transform "
            <> toggle_position,
          ),
        ],
        [],
      ),
    ],
  )
}

pub fn modal(
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
