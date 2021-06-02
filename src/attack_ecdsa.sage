#!/usr/bin/env sage

from pprint import pprint
from hashlib import sha256
from sage.misc.prandom import randrange

print("[*] Test ECDSA\n")
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

print("\n[*] Attack ECDSA with small k\n")
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
print("L = ")
print(L)
for v in L:
    k1_, k2_ = v[0], v[1]
    if abs(k1_) == k1 and abs(k2_) == k2:
        print("\n[*] found k1, k2")
        d_ = N(abs(k1_)*s1 - h1) / r1
        print(f"k1: {hex(abs(k1_))}, k2: {hex(abs(k2_))}, d: {hex(d_)}")


print("\n--------------------------------------------------------------------")
print("[*] Attack many signatures with small k\n")
p = 0xffffffffffffd21f
E = EllipticCurve(GF(p), [0, 3])
G = E([14716423389447796975, 5382751491675231482])
n = G.order()
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

m = 20
messages = [f"message {i}".encode() for i in range(m)]

K = 2^50
keys = [randrange(1, K) for _ in range(m)]
h = [int.from_bytes(sha256(m).digest()[:nl//8], "big") for m in messages]
a_known = [k & 3 for k in keys]

print(f"k[0]: {bin(abs(int(keys[0])))[2:].zfill(32)} {hex(keys[0])}")
print(f"k[1]: {bin(abs(int(keys[1])))[2:].zfill(32)} {hex(keys[1])}")

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

print(f"t: {t}")

u = []
for i in range(m - 1):
    u.append(int((1/s[i]) * r[i] * h[m - 1] * (1/r[m - 1]) - ((1/s[i]) * h[i])))
u.extend([0, K])
u = vector(ZZ, u)
print(f"u: {u}")

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
    if all([x == k for x, k in zip(map(abs, v), keys)]):
        print(f"[*] found {i}th row")
        print(f"original: {keys}")
        print(f"found:    {list(map(abs, v[:-1]))}")


print("\n--------------------------------------------------------------------")
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
bits_known = 10
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
