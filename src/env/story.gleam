import env/world.{type LocationId}
import gleam/option.{type Option, None, Some}
import state/state.{type Player, type StoryChapterId, type StoryLineId, Player}

// types

pub type StoryChapter {
  StoryChapter(
    id: StoryChapterId,
    line_id: StoryLineId,
    condition: fn(Player) -> Bool,
    mission_desc: fn(Player) -> String,
    activation: StoryChapterActivation,
    effect: fn(Player) -> Player,
    effect_toast_msg: Option(String),
    nodes: List(StoryNode),
    next_chapter: StoryChapterId,
  )
}

pub type StoryChapterActivation {
  Auto(location: LocationId)
  Active(location: LocationId, action_title: String)
}

pub type StoryNode {
  StoryNode(text: String, option: String)
}

// fns

pub fn story_chapter(chapter: StoryChapterId) -> StoryChapter {
  let noop = fn(p) { p }

  case chapter {
    state.Main01 ->
      StoryChapter(
        id: chapter,
        line_id: state.Main,
        condition: True |> as_p_fn,
        mission_desc: "" |> as_p_fn,
        activation: Auto(location: world.Apartment),
        effect: noop,
        effect_toast_msg: None,
        nodes: [
          StoryNode(text: "text-01", option: "option-01"),
          StoryNode(text: "text-02", option: "option-02"),
        ],
        next_chapter: state.Main02,
      )

    state.Main02 ->
      StoryChapter(
        id: chapter,
        line_id: state.Main,
        condition: True |> as_p_fn,
        mission_desc: "Get a job" |> as_p_fn,
        activation: Active(
          location: world.DrugCorner,
          action_title: "Greet gang",
        ),
        effect: fn(p) { Player(..p, job: state.Lookout) },
        effect_toast_msg: Some("New job 'lookout'"),
        nodes: [
          StoryNode(text: "text-01", option: "option-01"),
          StoryNode(text: "text-02", option: "option-02"),
        ],
        next_chapter: state.Placeholder,
      )

    // just acts as a placeholder during development
    state.Placeholder ->
      StoryChapter(
        id: chapter,
        line_id: state.Main,
        condition: False |> as_p_fn,
        mission_desc: "TBD..." |> as_p_fn,
        activation: Auto(location: world.NoLocation),
        effect: fn(p) { p },
        effect_toast_msg: None,
        nodes: [],
        next_chapter: state.Placeholder,
      )
  }
}

fn as_p_fn(out: o) -> fn(p) -> o {
  fn(_) { out }
}
