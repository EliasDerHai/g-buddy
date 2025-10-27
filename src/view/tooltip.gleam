import gleam/option.{type Option}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import msg.{type Msg, TooltipChange, TooltipHide, TooltipShow}

pub fn with_tooltip(
  trigger: Element(Msg),
  state_flag: Option(String),
  tooltip_id: String,
  content: fn() -> List(Element(Msg)),
  position: TooltipPosition,
) -> Element(Msg) {
  let is_active = state_flag == option.Some(tooltip_id)

  html.div(
    [
      attribute.class("tooltip-wrapper relative inline-block"),
      event.on_mouse_enter(TooltipChange(TooltipShow(tooltip_id))),
      event.on_mouse_leave(TooltipChange(TooltipHide)),
    ],
    [
      trigger,
      case is_active {
        True -> render_tooltip(content(), position)
        False -> element.none()
      },
    ],
  )
}

pub type TooltipPosition {
  Top
  Bottom
  Left
  Right
}

fn render_tooltip(
  content: List(Element(Msg)),
  position: TooltipPosition,
) -> Element(Msg) {
  let position_classes = case position {
    Top ->
      "bottom-full left-1/2 -translate-x-1/2 mb-2
      before:content-[''] before:absolute before:top-full before:left-1/2
      before:-translate-x-1/2 before:border-8 before:border-transparent
      before:border-t-neutral-900"
    Bottom ->
      "top-full left-1/2 -translate-x-1/2 mt-2
      before:content-[''] before:absolute before:bottom-full before:left-1/2
      before:-translate-x-1/2 before:border-8 before:border-transparent
      before:border-b-neutral-900"
    Left ->
      "right-full top-1/2 -translate-y-1/2 mr-2
      before:content-[''] before:absolute before:left-full before:top-1/2
      before:-translate-y-1/2 before:border-8 before:border-transparent
      before:border-l-neutral-900"
    Right ->
      "left-full top-1/2 -translate-y-1/2 ml-2
      before:content-[''] before:absolute before:right-full before:top-1/2
      before:-translate-y-1/2 before:border-8 before:border-transparent
      before:border-r-neutral-900"
  }

  html.div(
    [
      attribute.class(
        "absolute z-10 bg-neutral-900 text-white rounded-lg shadow-xl p-4
        min-w-[250px] max-w-[400px]
        animate-in fade-in duration-150 " <> position_classes,
      ),
    ],
    content,
  )
}

// Convenience functions for specific positions

pub fn tooltip_top(
  trigger: Element(Msg),
  state_flag: Option(String),
  id: String,
  content: fn() -> List(Element(Msg)),
) -> Element(Msg) {
  with_tooltip(trigger, state_flag, id, content, Top)
}

pub fn tooltip_bottom(
  trigger: Element(Msg),
  state_flag: Option(String),
  id: String,
  content: fn() -> List(Element(Msg)),
) -> Element(Msg) {
  with_tooltip(trigger, state_flag, id, content, Bottom)
}

pub fn tooltip_left(
  trigger: Element(Msg),
  state_flag: Option(String),
  id: String,
  content: fn() -> List(Element(Msg)),
) -> Element(Msg) {
  with_tooltip(trigger, state_flag, id, content, Left)
}

pub fn tooltip_right(
  trigger: Element(Msg),
  state_flag: Option(String),
  id: String,
  content: fn() -> List(Element(Msg)),
) -> Element(Msg) {
  with_tooltip(trigger, state_flag, id, content, Right)
}
