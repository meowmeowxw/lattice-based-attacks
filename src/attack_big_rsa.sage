#!/usr/bin/env sage

from pprint import pprint

def print_f(f):
    fl = f.list()
    if fl[-1] != 1:
        print(f"{hex(fl[-1])}x^{len(fl) - 1}", end=" + ")
    else:
        print(f"x^{len(fl) - 1}", end=" + ")
    for i, x in enumerate(fl[1:-1][::-1]):
        print(f"{hex(x)}x^{len(fl) -2 - i}", end=" + ")
    print(f"{hex(f[0])}", end="\n")

while True:
    p = random_prime(2^512 - 1, false, 2^511)
    q = random_prime(2^512 - 1, false, 2^511)
    phi = (p - 1) * (q - 1)
    e = 3
    if gcd(e, phi) == 1:
        break

n =  p * q
N = Zmod(n)
m = b"lattice_key"
lm = len(m)
m = int.from_bytes(m, "big")
pad = int.from_bytes(b"\x01" * (len(hex(n)[2:]) // 2 - lm - 1), "big")
z = (pad << (lm * 8)) | m
c = N(z) ^ e
a = (pad << (lm * 8))
X = 2 ^ (lm * 8)

print(f"n:    {hex(n)}\ne:    {hex(e)}\npad:  {hex(pad)}\nc:    {hex(c)}\na:    {hex(a)}\nX:    {hex(X)}")
print(f"n bit_length: {int(n).bit_length()}")
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
        print(f"\n[*] found: {bytes.fromhex(hex(r[0])[2:])}")
        break
else:
    print("[!] failed")
