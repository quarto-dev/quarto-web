#import "@preview/cetz:0.3.4"

#set page(
  width: 1200pt,
  height: 630pt,
  margin: 50pt,
  fill: rgb("#447099"),
)

#set text(fill: white, font: "Helvetica Neue")

#align(center)[
  #stack(
    dir: ltr,
    spacing: 16pt,
    align(horizon)[#image("quarto-logo-trademark-light.svg", height: 90pt)],
    align(horizon)[#text(baseline: -8pt, size: 90pt, weight: "bold")[2]],
  )

  #v(10pt)
  #text(size: 56pt, weight: "bold")[Parsing & Source Maps]

  #v(10pt)

  #cetz.canvas(length: 45pt, {
    import cetz.draw: *

    let node(pos, label, name) = {
      let (x, y) = pos
      circle(
        (x, y),
        radius: (1.4, 0.55),
        fill: white,
        stroke: white,
        name: name,
      )
      content((x, y), text(fill: rgb("#1f3a52"), weight: "bold", size: 20pt)[#label])
    }

    let edge(a, b) = {
      line(a, b, stroke: (paint: white, thickness: 1.5pt))
    }

    node((6, 4), "Doc", "doc")
    node((2, 2), "Header", "header")
    node((10, 2), "Div", "div")

    node((0, 0), "Str", "str1")
    node((4, 0), "Str", "str2")
    node((8, 0), "Para", "para1")
    node((12, 0), "Para", "para2")

    edge("doc", "header")
    edge("doc", "div")
    edge("header", "str1")
    edge("header", "str2")
    edge("div", "para1")
    edge("div", "para2")
  })
]
