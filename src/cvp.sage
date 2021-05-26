#!/usr/bin/env sage

import itertools as it
import tempfile
import os

v1 = vector([3, 4])
v2 = vector([7, 2])

pts = []
for i, j in it.product([-2 + i for i in range(10)], [-2 + i for i in range(10)]):
    pts.append((i, j))

p =  plot(v1, color="blue", legend_label="v1", legend_color="blue")
p += plot(v2, color="purple", legend_label="v2", legend_color="purple")
p += plot(points(pts, color="grey"))

p += plot(vector([3.4, 1.9]), color="red", width=0.7, arrowsize=5, legend_label="w", legend_color="red")
p += plot(point([3.4, 1.9], color="red"))
p += plot(vector([3, 2]), color="green", width=0.7, arrowsize=5, legend_label="v", legend_color="green")

f = os.path.join(os.getcwd(), "../img/cvp.png")
print(f"saving in {f}")
save(p, f, axes=True, aspect_ratio=True)
os.system(f"display {f} &")

