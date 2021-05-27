#!/usr/bin/env sage

import itertools as it
import tempfile
import os

v1 = vector([8, 4])
v2 = vector([7, 5])

pts = []
for i, j in it.product([-10 + i for i in range(27)], [-10 + i for i in range(27)]):
    pt = i*v1 + j*v2
    x, y = pt[0], pt[1]
    if x < -5 or x > 17 or y < -5 or y > 17:
        continue
    pts.append(pt)

p =  plot(v1, color="blue", legend_label="v1", legend_color="blue")
p += plot(v2, color="purple", legend_label="v2", legend_color="purple")
p += plot(points(pts, color="grey"))

while True:
    if v2.norm() < v1.norm():
        v1, v2 = v2, v1
    m = floor(v1.inner_product(v2) / v1.inner_product(v1))
    if m == 0:
        break
    else:
        v2 = v2 - (m * v1)

p += plot(v1, color="red", legend_label="w1", legend_color="red")
p += plot(v2, color="green", legend_label="w2", legend_color="green")

print(v1, v2)
print(v1 *v2)

f = os.path.join(os.getcwd(), "../img/gauss_svp.png")
print(f"saving in {f}")
save(p, f, axes=True, aspect_ratio=True)
os.system(f"display {f} &")
