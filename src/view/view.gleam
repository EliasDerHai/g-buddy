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
    html.div([attribute.class("flex-1")], [
      html.text("Center Content"),
    ]),
    html.div([attribute.class("bg-neutral-900 w-64")], [
      html.text("Right Sidebar"),
    ]),
  ])
}
