if [ ! -d env ]; then
   /usr/local/bin/python3 -m venv env
fi
source env/bin/activate
pip install wheel
pip uninstall --yes htmltools shiny 
pip install -r requirements.txt
