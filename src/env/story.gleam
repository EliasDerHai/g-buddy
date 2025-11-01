import env/world.{type LocationId}
import state/state.{type Player, type StoryChapterId}

// types

pub type StoryChapter {
  StoryChapter(
    id: StoryChapterId,
    condition: fn(Player) -> Bool,
    mission_desc: fn(Player) -> String,
    activation: StoryChapterActivation,
    nodes: List(StoryNode),
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
      )
  }
}

fn as_p_fn(out: o) -> fn(p) -> o {
  fn(_) { out }
}
