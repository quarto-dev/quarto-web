import pandas as pd
import numpy as np

temps = pd.DataFrame({
  'year': [*range(1920, 1925)],
  'Jan': [40.6, 44.2, 37.5, 41.8, 39.3], 
  'Jun': [58.5, 58.7, 57.8, 52.7, 57.7]
}).set_index('year')

def make_pretty(styler):
    styler.background_gradient(axis=None, vmin=31, vmax=66, cmap="RdYlGn_r")
    return styler

temps.style.pipe(make_pretty)
