import lustre/attribute.{type Attribute, attribute}
import lustre/element/svg

pub fn x(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([attribute("d", "M18 6 6 18")]),
      svg.path([attribute("d", "m6 6 12 12")]),
    ],
  )
}

pub fn sword(attributes: List(Attribute(a))) {
  svg.svg(
    [
      attribute("stroke-linejoin", "round"),
      attribute("stroke-linecap", "round"),
      attribute("stroke-width", "2"),
      attribute("stroke", "currentColor"),
      attribute("fill", "none"),
      attribute("viewBox", "0 0 24 24"),
      attribute("height", "24"),
      attribute("width", "24"),
      ..attributes
    ],
    [
      svg.path([attribute("d", "m11 19-6-6")]),
      svg.path([attribute("d", "m5 21-2-2")]),
      svg.path([attribute("d", "m8 16-4 4")]),
      svg.path([attribute("d", "M9.5 17.5 21 6V3h-3L6.5 14.5")]),
    ],
  )
}
