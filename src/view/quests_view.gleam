import env/story
import gleam/dict
import gleam/list
import lustre/element.{type Element}
import lustre/element/html
import msg.{type Msg}
import state/state.{type State}
import view/generic_view

pub fn view_quests(state: State) -> List(Element(Msg)) {
  [
    "Active Quests" |> generic_view.heading,
    ..state.p.story
    |> dict.values
    |> list.map(fn(id) {
      let desc = state.p |> { id |> story.story_chapter }.mission_desc
      html.li([], [generic_view.simple_text(desc)])
    })
  ]
}
