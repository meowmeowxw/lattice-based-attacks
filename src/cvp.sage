#!/usr/bin/env sage

import itertools as it
import os
from sage.modules.free_module_integer import IntegerLattice
from sage.plot.point import Point

v1 = vector([0, 1])
v2 = vector([2, 0])
target = vector([2.3, 2.4])
B = IntegerLattice([v1, v2])
t = [2.3, 2.1]
w = B.closest_vector(t)
print(w)

pts = []
for i, j in it.product([-2 + i for i in range(6)], [-2 + i for i in range(6)]):
    pt = i*v1 + j*v2
    x,y = pt[0], pt[1]
    if x < -2 or x > 6 or y < -2 or y > 6:
        continue
    pts.append(pt)

p =  plot(v1, color="blue", legend_label="v1", legend_color="blue")
p += plot(v2, color="purple", legend_label="v2", legend_color="purple")
p += plot(w, color="green", legend_label="w", legend_color="green")
p += plot(points(t, color="red", legend_label="t", legend_color="red", size=20))
p += plot(points(pts, color="grey"))

f = os.path.join(os.getcwd(), "../img/cvp.png")
print(f"saving in {f}")
save(p, f, axes=True, aspect_ratio=True)
os.system(f"display {f} &")

