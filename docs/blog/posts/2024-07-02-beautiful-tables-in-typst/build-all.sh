rm images/*.png
rm -rf demo/*
for ex in examples/*.qmd; do
  quarto run $QDOC/tools/snapshot-typst.ts $ex `echo $ex | sed 's:examples:images:' | sed 's:qmd$:png:'` || exit 1
  ./build-html.sh `echo $ex | sed 's:examples/::' | sed 's:\.qmd$::'` || exit 1
  quarto render $ex || exit 1
done