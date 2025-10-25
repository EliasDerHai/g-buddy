import gleam/option.{None}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import msg.{type Msg}
import state/state.{type State}
import view/generic_view

pub fn view_settings(s: State) -> List(Element(Msg)) {
  [
    html.h2([attribute.class("text-2xl font-bold mb-6")], [
      html.text("Settings"),
    ]),
    html.div([attribute.class("flex flex-col gap-4")], [
      setting_toggle(
        "Autosave",
        "Automatically save your progress",
        generic_view.toggle_button(
          s.settings.autosave,
          msg.SettingChange(msg.SettingToggleAutosave),
        ),
      ),
      setting_toggle(
        "Autoload",
        "Automatically load your last save on startup",
        generic_view.toggle_button(
          s.settings.autoload,
          msg.SettingChange(msg.SettingToggleAutoload),
        ),
      ),
      setting_toggle(
        "Reset",
        "Reset the storage deleting all saves & settings",
        generic_view.simple_warn_button(
          "Reset",
          msg.SettingChange(msg.SettingReset),
          None,
        ),
      ),
    ]),
  ]
}

fn setting_toggle(
  label: String,
  description: String,
  right: Element(Msg),
) -> Element(Msg) {
  html.div(
    [
      attribute.class("flex items-center justify-between"),
    ],
    [
      html.div([attribute.class("flex flex-col")], [
        html.span([attribute.class("font-medium text-white")], [
          html.text(label),
        ]),
        html.span([attribute.class("text-sm text-gray-400")], [
          html.text(description),
        ]),
      ]),
      right,
    ],
  )
}
