#!/usr/bin/env sage

from pprint import pprint
from hashlib import sha256
from sage.misc.prandom import randrange


print("[*] Attack many signatures when MSB bits known of each k\n")
p = 0xffffffffffffd21f
p = 0xffffffff00000001000000000000000000000000ffffffffffffffffffffffff
a = p - 3
b = 0x5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b
E = EllipticCurve(GF(p), [a, b])
G = E([
    0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296,
    0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5
])
n = 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551
E.set_order(n)
d = randrange(1, n-1)
Q = d * G
N = Zmod(n)
nl = int(n).bit_length()
print(E)
print(f"p: {p} {hex(p)}")
print(f"n: {n} {hex(n)}")
print(f"d: {d} {hex(d)}")
print(f"G: ({hex(G[0])}, {hex(G[1])})")
print(f"Q: ({hex(Q[0])}, {hex(Q[1])})")

m = 100
messages = [f"message {i}".encode() for i in range(m)]

exp = 256
# It works with 7 bits too most of the time
bits_known = 8
keys = [randrange(1, n) for _ in range(m)]
h = [int.from_bytes(sha256(msg).digest()[:nl//8], "big") for msg in messages]
a = [k & (sum(2^(exp - i) for i in range(bits_known))) for k in keys]
K = 2^(exp - bits_known)

print(f"k[0]: {hex(keys[0])}")
print(f"k[1]: {hex(keys[1])}")

print(f"h[0]: {hex(h[0])}")
print(f"h[1]: {hex(h[1])}")

Points = [int(keys[i]) * G for i in range(m)]
xs = [P[0] for P in Points]
r = [N(x) for x in xs]
s =  [(h[i] + d*r[i]) / N(keys[i]) for i in range(m)]

print(f"P[0]: {Points[0]}")
print(f"P[1]: {Points[1]}")

print(f"(r[0], s[0]): ({hex(r[0])}, {hex(s[0])})")
print(f"(r[1], s[1]): ({hex(r[1])}, {hex(s[1])})")

t = []
for i in range(m - 1):
    t.append(int((-1/s[i]) * s[m-1] * r[i] * (1/r[m - 1])))
t.extend([1, 0])
t = vector(ZZ, t)

print(f"t[:3]: {t[:3]}")
print(f"a[:3]: {a[:3]}")

u = []
for i in range(m - 1):
    u.append(int((1/s[i]) * r[i] * h[m - 1] * (1/r[m - 1]) - ((1/s[i]) * h[i])))
for i in range(m - 1):
    # u[i] = int(N(2^(exp - 4))*(a[i] + t[i]*a[m-1] + u[i]))
    # bi = keys[i] & (2^(exp - 9) - 1)
    # print(f"{bin(keys[i])[2:].zfill(exp)}, ki = {keys[i]}")
    # print(f"{bin(bi)[2:].zfill(exp)}, {bi}")
    # print(f"{bin(a[i])[2:].zfill(exp)}, {a[i]}")
    # print(f"bi + ai = {bi + a[i]}")
    # bm = keys[m-1] & (2^(exp - 9) - 1)
    # z = (a[i] + bi) + t[i]*(a[m-1] + bm) + u[i]
    # print(f"z mod n {z % n}")
    u[i] = int(N(u[i] + a[i] + t[i]*a[m-1]))
u.extend([0, K])
u = vector(ZZ, u)
print(f"u[:3]: {u[:3]}")

B = matrix(ZZ, m, m + 1)
for i in range(m - 1):
    B[i, i] = n
B = B.insert_row(m, t)
B = B.insert_row(m + 1, u)
# print(B)

L = B.LLL()
print("\n[!] reduced")
# print(L)
for i, v in enumerate(L):
    w = []
    for i, x in enumerate(map(abs, v[:-1])):
        w.append(x + a[i])
    if all([x == k for x, k in zip(w, keys)]):
        print(f"[*] found {i}th row")
        print(f"original[:3]: {keys[:3]}")
        print(f"found[:3]:    {w[:3]}")
