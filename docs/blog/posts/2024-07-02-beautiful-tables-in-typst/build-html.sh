DOCUMENT=$1
rm -rf demo/$DOCUMENT*
touch _quarto.yml
quarto render examples/$DOCUMENT.qmd -t html -M title:false -M echo:false -M warning:false || exit 1

rm _quarto.yml
mv examples/$DOCUMENT.html examples/${DOCUMENT}_files demo
