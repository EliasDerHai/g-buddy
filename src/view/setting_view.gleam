import lustre/element.{type Element}
import msg.{type Msg}
import state/state.{type State}
import view/generic_view

pub fn view_settings(s: State) -> List(Element(Msg)) {
  [generic_view.simple_text("...")]
}
