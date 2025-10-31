import gleam/bool
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import msg.{type Msg}
import view/icons

pub type ButtonStyle {
  Primary
  Warning
  Secondary
}

pub type ButtonConfig {
  ButtonConfig(
    label: String,
    on_click: Msg,
    disabled_reason: Option(String),
    icon: Option(Element(Msg)),
    style: ButtonStyle,
    full_width: Bool,
  )
}

pub fn default_config(label: String, on_click: Msg) -> ButtonConfig {
  ButtonConfig(
    label: label,
    on_click: on_click,
    disabled_reason: None,
    icon: None,
    style: Primary,
    full_width: False,
  )
}

/// Basic button with primary styling
pub fn button(label: String, on_click: Msg) -> Element(Msg) {
  default_config(label, on_click)
  |> custom_button
}

/// Button with icon
pub fn button_with_icon(
  icon: Element(Msg),
  label: String,
  on_click: Msg,
) -> Element(Msg) {
  ButtonConfig(..default_config(label, on_click), icon: Some(icon))
  |> custom_button
}

/// Warning/danger button (red)
pub fn warning_button(label: String, on_click: Msg) -> Element(Msg) {
  ButtonConfig(..default_config(label, on_click), style: Warning)
  |> custom_button
}

/// Full width button
pub fn full_width_button(label: String, on_click: Msg) -> Element(Msg) {
  ButtonConfig(..default_config(label, on_click), full_width: True)
  |> custom_button
}

/// Full width button with icon
pub fn full_width_icon_button(
  icon: Element(Msg),
  label: String,
  on_click: Msg,
) -> Element(Msg) {
  ButtonConfig(
    ..default_config(label, on_click),
    icon: Some(icon),
    full_width: True,
  )
  |> custom_button
}

pub fn simple_button(
  t: String,
  msg: Msg,
  disabled_reason: Option(String),
) -> Element(Msg) {
  ButtonConfig(..default_config(t, msg), disabled_reason: disabled_reason)
  |> custom_button
}

/// Fully customizable button - use this for 1% cases that need full control
pub fn custom_button(config: ButtonConfig) -> Element(Msg) {
  let ButtonConfig(
    label:,
    on_click:,
    disabled_reason:,
    icon:,
    style:,
    full_width:,
  ) = config

  let is_disabled = disabled_reason |> option.is_some

  let base_classes =
    "px-6 py-3 rounded-lg font-medium transition-colors "
    <> case icon {
      Some(_) -> "flex gap-2 items-center justify-center "
      None -> ""
    }
    <> case full_width {
      True -> "w-full "
      False -> ""
    }

  let state_classes = case is_disabled, style {
    True, _ -> "bg-gray-700 text-gray-500 cursor-not-allowed"
    False, Primary -> "bg-blue-600 text-white hover:bg-blue-700 cursor-pointer"
    False, Warning -> "bg-red-400 text-white hover:bg-red-600 cursor-pointer"
    False, Secondary ->
      "bg-gray-600 text-white hover:bg-gray-700 cursor-pointer"
  }

  let button_element =
    html.button(
      [
        attribute.class(base_classes <> state_classes),
        attribute.disabled(is_disabled),
        event.on_click(on_click),
      ],
      case icon {
        Some(icon_el) -> [
          icon_el,
          html.span([attribute.class("text-sm")], [html.text(label)]),
        ]
        None -> [html.span([attribute.class("text-sm")], [html.text(label)])]
      },
    )

  // Only wrap in span with title if disabled
  case disabled_reason {
    None -> button_element
    Some(reason) -> html.span([attribute.title(reason)], [button_element])
  }
}

// OTHER UI COMPONENTS ---------------------------------------------------------

pub fn simple_text(t: String) -> Element(a) {
  html.span([], [html.text(t)])
}

pub fn heading(t: String) {
  html.h2([attribute.class("text-2xl font-bold mb-4")], [html.text(t)])
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
  // TODO: make content a fn () -> List(Element(Msg))
  content: List(Element(Msg)),
) -> Element(Msg) {
  use <- bool.guard(!is_open, html.div([], []))

  html.div([], [
    // Backdrop
    html.div(
      [
        attribute.class("fixed inset-0 bg-black/60 z-10"),
        event.on_click(case closeable {
          None -> msg.Noop
          Some(msg) -> msg
        })
          |> event.stop_propagation,
      ],
      [],
    ),
    // Modal
    html.div(
      [
        attribute.class(
          "fixed inset-0 grid z-20 place-items-center pointer-events-none",
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
