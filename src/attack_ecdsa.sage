#!/usr/bin/env sage

from pprint import pprint
from hashlib import sha256
from sage.misc.prandom import randrange

print("[*] Test\n")
p = 0xffffffffffffd21f
E = EllipticCurve(GF(p), [0, 3])
# G = E.gen(0)
G = E([14716423389447796975, 5382751491675231482])
n = G.order()
# d = randrange(1, n-1)
d = 17297868438860976900
Q = d * G
N = Zmod(n)
nl = int(n).bit_length()
print(E)
print(f"p: {p} {hex(p)}")
print(f"n: {n} {hex(n)}")
print(f"d: {d} {hex(d)}")
print(f"G: ({hex(G[0])}, {hex(G[1])})")
print(f"Q: ({hex(Q[0])}, {hex(Q[1])})")

m1 = b"message 1"
m2 = b"message 2"
print(f"m1: {m1}")
print(f"m2: {m2}")

#  k1 = N(randrange(1, 2^32))
#  k2 = N(randrange(1, 2^32))
k1 = 0x50a65330
k2 = 0x1f5b977a
print(f"k1: {bin(abs(int(k1)))[2:].zfill(32)} {hex(k1)}")
print(f"k2: {bin(abs(int(k2)))[2:].zfill(32)} {hex(k2)}")

h1 = int.from_bytes(sha256(m1).digest()[:nl//8], "big")
h2 = int.from_bytes(sha256(m2).digest()[:nl//8], "big")

print(f"h1: {hex(h1)}")
print(f"h2: {hex(h2)}")

P1 = int(k1)*G
x1 = P1[0]
r1 = N(x1)
s1 = (h1 + d*r1) / k1
P2 = int(k2)*G
x2 = P2[0]
r2 = N(x2)
s2 = (h2 + d*r2) / k2

print(f"P1: {P1}")
print(f"P2: {P2}")

print(f"(r1, s1): ({hex(r1)}, {hex(s1)})")
print(f"(r2, s2): ({hex(r2)}, {hex(s2)})")

u11 = h1 / s1
u12 = r1 / s1
if N(r1) == N((int(u11) * G + int(u12) * Q)[0]):
    print("valid")

u21 = h2 / s2
u22 = r2 / s2
if N(r2) == N((int(u21) * G + int(u22) * Q)[0]):
    print("valid")

print("\n\n[*] Attack\n")
t = (-1/s1) * s2 * r1 * (1/r2)
u = (1/s1) * r1 * h2 * (1/r2) - ((1/s1) * h1)
K = 2^32
B = matrix(ZZ, [[n, 0, 0],
                [t, 1, 0],
                [u, 0, K]])
det = B.det()
assert det == n * K
print(f"sqrt(n): {isqrt(n)}")
print(f"K:       {K}")

L = B.LLL()
print(L)
for v in L:
    k1_, k2_ = v[0], v[1]
    if abs(k1_) == k1 and abs(k2_) == k2:
        print("[!] FOUND k1, k2")
        print(hex(abs(k1_)), hex(abs(k2_)))

