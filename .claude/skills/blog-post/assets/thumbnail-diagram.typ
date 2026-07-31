#import "@preview/cetz:0.3.4"

#set page(
  width: 1920pt,
  height: 1080pt,
  margin: 80pt,
  fill: rgb("#447099"),
)

#set text(
  fill: white,
  font: ("Helvetica Neue", "Helvetica", "Arial", "Liberation Sans", "DejaVu Sans"),
)

#align(center)[
  #stack(
    dir: ltr,
    spacing: 26pt,
    align(horizon)[#image("quarto-logo-trademark-light.svg", height: 144pt)],
    align(horizon)[#text(baseline: -13pt, size: 144pt, weight: "bold")[2]],
  )

  #v(16pt)
  #text(size: 90pt, weight: "bold")[Replace this title]

  #v(16pt)

  #cetz.canvas(length: 72pt, {
    import cetz.draw: *

    // Ellipse node — white fill, dark blue label.
    let node(pos, label, name) = {
      let (x, y) = pos
      circle(
        (x, y),
        radius: (1.4, 0.55),
        fill: white,
        stroke: white,
        name: name,
      )
      content((x, y), text(fill: rgb("#1f3a52"), weight: "bold", size: 32pt)[#label])
    }

    // Edge — white line connecting two named nodes.
    let edge(a, b) = {
      line(a, b, stroke: (paint: white, thickness: 2.5pt))
    }

    // Replace the placeholder graph below with your own nodes + edges.
    node((4, 2), "Root", "root")
    node((1, 0), "A", "a")
    node((7, 0), "B", "b")
    edge("root", "a")
    edge("root", "b")
  })
]
