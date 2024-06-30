DOCUMENT=$1
rm -rf demo/$DOCUMENT*
touch _quarto.yml
quarto render examples/$DOCUMENT.qmd -t html -M title:false
rm _quarto.yml
mv examples/$DOCUMENT.html examples/${DOCUMENT}_files demo
