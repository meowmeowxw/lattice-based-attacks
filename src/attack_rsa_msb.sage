#!/usr/bin/env sage

from pprint import pprint

bound = 2^512
while True:
    p = random_prime(bound - 1, false, bound >> 1)
    q = random_prime(bound - 1, false, bound >> 1)
    phi = (p - 1) * (q - 1)
    e = 3
    if gcd(e, phi) == 1:
        break

n = int(p * q)
l = 160
a = (p >> l) << l
p_cuberoot = int(p^(1/3))
N = Zmod(n)
X = 2^l
print(f"n:       {hex(n)}")
print(f"a:       {hex(a)}")
print(f"p^(1/3): {hex(p_cuberoot)}")
print(f"X:       {hex(X)}")
B = matrix(ZZ, [
    [X^2, X*a, 0],
    [0,   X,   a],
    [0,   0,   n]
])
L = B.LLL()
v = L[0]
w = []
for i, x in enumerate(v):
    w.append(x // X^(2 - i))

P.<x> = PolynomialRing(ZZ)
g = w[0]*x^2 + w[1]*x + w[2]
for r in g.roots():
    p_ = a + r[0]
    print(f"r:       {hex(abs(r[0]))}")
    if n % p_ == 0:
        print("\n[*] found\n")
        q_ = n // p_
        print(f"p:       {hex(p_)}\nq:       {hex(q_)}")
        assert p_ * q_ == n
    else:
        print("[!] failed")

