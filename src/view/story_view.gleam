import env/story
import gleam/dict
import gleam/list
import gleam/option.{Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import msg.{type Msg, PlayerStory, StoryChapterComplete, StoryOptionPick}
import view/generic_view

pub fn view_story(chap_id, node_id) -> List(Element(Msg)) {
  let chap = story.story_chapter(chap_id)
  let assert Some(node) =
    chap.nodes
    |> list.index_map(fn(el, i) { #(i, el) })
    |> dict.from_list
    |> dict.get(node_id)
    |> option.from_result

  let next_node_idx = node_id + 1
  let last_node_idx = list.length(chap.nodes) - 1
  let msg = case next_node_idx > last_node_idx {
    True -> PlayerStory(StoryChapterComplete(chap_id))
    False -> PlayerStory(StoryOptionPick(chap_id, next_node_idx))
  }

  [
    "Story" |> generic_view.heading,
    html.div([attribute.class("flex flex-col gap-4 w-80 m-auto")], [
      node.text |> generic_view.simple_text,
      node.option |> generic_view.button(msg),
    ]),
  ]
}
