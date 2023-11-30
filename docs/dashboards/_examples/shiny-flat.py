
import seaborn as sns
from shiny import ui, reactive, render
penguins = sns.load_dataset("penguins")

@reactive.Calc
def filtered_penguins():
   data = penguins[penguins["species"].isin(input.species())]
   data = data[data["island"].isin(input.islands())]
   return data

ui.page(orientation = "columns")

ui.navigation(title = "Palmer Penguins")

with ui.sidebar():

   ui.markdown("![](images/penguins.png){width=80%}")

   species = list(penguins["species"].value_counts().index)
   ui.input_checkbox_group(
      "species", "Species:", 
      species, selected = species
   )

   islands = list(penguins["island"].value_counts().index)
   ui.input_checkbox_group(
      "islands", "Islands:", 
      islands, selected = islands
   )

   ui.markdown("***")

   ui.input_select("dist", "Distribution:", choices=["kde", "hist"])
   ui.input_checkbox("rug", "Show rug marks", value = False)

   ui.markdown(
   """
   ***
   [Learn more](https://pypi.org/project/palmerpenguins/) about
   the Palmer Penguins dataset."
   """)


with ui.column():

   with ui.row(height = "65%"):

      @render.plot
      def depth():
         return sns.displot(
            filtered_penguins(), x = "bill_depth_mm", 
            hue = "species", kind = input.dist(), 
            fill = True, rug=input.rug()
         )

      @render.plot
      def length():
         return sns.displot(
            filtered_penguins(), x = "bill_length_mm", 
            hue = "species", kind = input.dist(), 
            fill = True, rug=input.rug()
      )
      
   with ui.row(height = "35%"):

      @render.data_frame
      def dataview():
         return render.DataGrid(filtered_penguins())

