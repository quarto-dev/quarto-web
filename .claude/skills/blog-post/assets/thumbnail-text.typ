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

#align(center + horizon)[
  #stack(
    dir: ltr,
    spacing: 26pt,
    align(horizon)[#image("quarto-logo-trademark-light.svg", height: 144pt)],
    align(horizon)[#text(baseline: -13pt, size: 144pt, weight: "bold")[2]],
  )

  #v(32pt)
  #text(size: 90pt, weight: "bold")[Replace this title]

  #v(16pt)
  #text(size: 52pt)[Replace this subtitle (optional)]
]
