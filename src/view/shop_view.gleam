import lustre/element.{type Element}
import msg.{type Msg}
import state/state
import view/generic_view

pub fn view_shop(s: state.State) -> List(Element(Msg)) {
  ["..." |> generic_view.simple_text]
}
