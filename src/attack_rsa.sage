#!/usr/bin/env sage

from pprint import pprint

def print_f(f):
    fl = f.list()
    if fl[-1] != 1:
        print(f"{hex(fl[-1])}x^{len(fl) - 1}", end=" + ")
    else:
        print(f"x^{len(fl) - 1}", end=" + ")
    for i, x in enumerate(fl[1:-1][::-1]):
        print(f"{hex(x)}x^{i+1}", end=" + ")
    print(f"{hex(f[0])}", end="\n")


n =  0xf046522fb555a90bdc558fc93
N = Zmod(n)
e = 3
pad = int.from_bytes(b"this key:", "big")
m = 0x6162
z = (pad << 16) | m
c = N(z) ^ e
a = pad << 16
X = pow(2, 16)

print(f"n:    {hex(n)}\ne:    {hex(e)}\npad:  {hex(pad)}\nc:    {hex(c)}\na:    {hex(a)}\nX:    {hex(X)}")
P.<x> = PolynomialRing(N)
f = (a + x)^e - c
print(f"f:   ", end=" ")
print_f(f)
fi = list(map(int, f.list()))

B = matrix([
    [X^3, fi[2]*X^2, fi[1]*X, fi[0]],
    [0,   n*X^2,     0,       0],
    [0,   0,         n*X,     0],
    [0,   0,         0,       n],
])
det = B.det()
print("\nB:   ")
pprint(B)
print(f"det:  {det}")

print("\n[!] Apply LLL")
L = B.LLL()
print("\nL:   ")
pprint(L)

v = L[0]

print("v:    ", end="")
for element in v:
    print(hex(element), end="  ")
print("")

assert v in span(B)

P.<x> = PolynomialRing(ZZ)
w = []
for i, l in enumerate(v):
    w.append(l // X^(3 - i))
g = w[0]*x^3 + w[1]*x^2 + w[2]*x + w[3]
print("\ng(x): ", end=" ")
print_f(g)

for r in g.roots():
    if r[0] == m:
        print(f"\n[*] found: {hex(r[0])}")
        break
else:
    print("[!] failed")
