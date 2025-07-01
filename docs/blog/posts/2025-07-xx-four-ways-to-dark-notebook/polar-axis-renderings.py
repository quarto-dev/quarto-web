#| renderings: [light, dark]

import numpy as np
import matplotlib.pyplot as plt
from quarto import theme_colors_matplotlib;

r = np.arange(0, 2, 0.01)
theta = 2 * np.pi * r

theme_colors_matplotlib("#ffffff", "#f8f8f8", None)
fig, ax = plt.subplots(subplot_kw={'projection': 'polar'})
ax.plot(theta, r)
ax.set_rticks([0.5, 1, 1.5, 2])
ax.grid(True)
plt.show()

theme_colors_matplotlib("#151515", "#343a40", None)
fig, ax = plt.subplots(subplot_kw={'projection': 'polar'})
ax.plot(theta, r)
ax.set_rticks([0.5, 1, 1.5, 2])
ax.grid(True)
plt.show()
