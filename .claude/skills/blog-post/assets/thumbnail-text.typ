#set page(
  width: 1200pt,
  height: 630pt,
  margin: 50pt,
  fill: rgb("#447099"),
)

#set text(
  fill: white,
  font: ("Helvetica Neue", "Helvetica", "Arial", "Liberation Sans", "DejaVu Sans"),
)

#align(center + horizon)[
  #stack(
    dir: ltr,
    spacing: 16pt,
    align(horizon)[#image("quarto-logo-trademark-light.svg", height: 90pt)],
    align(horizon)[#text(baseline: -8pt, size: 90pt, weight: "bold")[2]],
  )

  #v(20pt)
  #text(size: 56pt, weight: "bold")[Replace this title]

  #v(10pt)
  #text(size: 32pt)[Replace this subtitle (optional)]
]
