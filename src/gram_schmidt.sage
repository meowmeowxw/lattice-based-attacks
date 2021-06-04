#!/usr/bin/env sage

import itertools as it
import tempfile
import os
from sage.modules.misc import gram_schmidt

v = [
    vector([4, 1]),
    vector([2, 3])
]
u, mu = gram_schmidt(v)
print(u)

pts = []
for i, j in it.product([-4 + i for i in range(10)], [-4 + i for i in range(10)]):
    pts.append((i, j))

p =  plot(v[0], color="blue", legend_label="v1", legend_color="blue", width=4, thickness=10)
p += plot(v[1], color="blue", legend_label="v2", legend_color="blue", width=4, thickness=10)
p += plot(u[0], color="red", legend_label="u1", legend_color="red", thickness=0.4)
p += plot(u[1], color="green", legend_label="u2", legend_color="green", thickness=0.4)
p += plot(points(pts, color="black"))

f = os.path.join(os.getcwd(), "../img/gram_schmidt.png")
print(f"saving in {f}")
save(p, f, axes=True, aspect_ratio=True)
os.system(f"display {f} &")

"""
G, mu = gram_schmidt(B)
for x, y in it.permutations(G, 2):
    print(f"{x} * {y} = {x * y}")
print(G)
print(mu)

"""
