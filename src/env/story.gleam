import env/world.{type LocationId}
import state/state.{type Player, type StoryChapterId, type StoryLineId}

// types

pub type StoryChapter {
  StoryChapter(
    id: StoryChapterId,
    line_id: StoryLineId,
    condition: fn(Player) -> Bool,
    mission_desc: fn(Player) -> String,
    activation: StoryChapterActivation,
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
  case chapter {
    state.Main01 ->
      StoryChapter(
        id: chapter,
        line_id: state.Main,
        condition: True |> as_p_fn,
        mission_desc: "Go to your workplace" |> as_p_fn,
        activation: Active(
          location: world.SlingerCorner,
          action_title: "Greet gang",
        ),
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
        nodes: [],
        next_chapter: state.Placeholder,
      )
  }
}

fn as_p_fn(out: o) -> fn(p) -> o {
  fn(_) { out }
}
