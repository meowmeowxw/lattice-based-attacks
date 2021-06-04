#!/usr/bin/env sage

from sage.misc.prandom import randrange

def coppersmith_howgrave_univariate(pol, modulus, beta, mm, tt, XX):
    """
    Original implementation david wong https://github.com/mimoo/RSA-and-LLL-attacks/blob/master/coppersmith.sage
    Coppersmith revisited by Howgrave-Graham
    
    finds a solution if:
    * b|modulus, b >= modulus^beta , 0 < beta <= 1
    * |x| < XX
    """

    dd = pol.degree()
    nn = dd * mm + tt

    #
    # Coppersmith revisited algo for univariate
    #
    polZ = pol.change_ring(ZZ)
    x = polZ.parent().gen()

    # compute polynomials
    gg = []
    for ii in range(mm):
        for jj in range(dd):
            gg.append((x * XX)**jj * modulus**(mm - ii) * polZ(x * XX)**ii)
    for ii in range(tt):
        gg.append((x * XX)**ii * polZ(x * XX)**mm)
    
    # construct lattice B
    BB = Matrix(ZZ, nn)

    for ii in range(nn):
        for jj in range(ii+1):
            BB[ii, jj] = gg[ii][jj]

    # display basis matrix
    #  if debug:
    #      matrix_overview(BB, modulus^mm)

    # LLL
    BB = BB.LLL()

    # transform shortest vector in polynomial    
    new_pol = 0
    for ii in range(nn):
        new_pol += x**ii * BB[0, ii] / XX**ii

    # factor polynomial
    return new_pol.roots()


def get_fast_prime(e, M):
    while True:
        k = randrange(2^28, 2^29 - 1)
        a = randrange(2^20, 2^62 - 1)
        # parse to int or the return of pow in sage is an integerMod...
        # lost 20 minutes for this error...
        p = k * M + int(pow(e, a, M))
        if is_prime(int(p)):
            # print(f"a: {hex(a)}\nk: {hex(k)}\n")
            return p


M = prod(Primes()[:40])
e = 0x10001
p = get_fast_prime(e, M)
q = get_fast_prime(e, M)
n = p * q
n = 0x5744ef59efbea3c2771a4a8fd1b996dc52d5185f796c98979b3d4de484ba31646c02c20151d1460b3b7af9fcfde12a657b5504cab9ff7705e4f8107b01c25d23
nl = int(n).bit_length()
phi = (p - 1) * (q - 1)

print(f"n bit:       {nl}")
print(f"n:           {hex(n)}")
print(f"e:           {hex(e)}")
print(f"M:           {hex(M)}")

MM = Zmod(M)
N = Zmod(n)
order = MM(e).multiplicative_order()
factors = factor(order)
print(f"order:       {hex(order)}")
print(f"factors:     {factors}")

M1 = 0x1b3e6c9433a7735fa5fc479ffe4027e13bea
MM = Zmod(M1)
m = 5
t = 6
beta = 0.5

c = discrete_log(MM(n), MM(e))
order = MM(e).multiplicative_order()

lower_bound = c // 2 
upper_bound = (c + order) // 2 
lower_bound = 359900

P.<x> = PolynomialRing(N)
epsilon = beta / 7
X = floor(2 * n^beta / M1)

print(f"possible a:  {hex(upper_bound - lower_bound)}")

for a in range(lower_bound, upper_bound):
    f = x + int((N(M1)^(-1)) * int(MM(e)^a))
    roots = coppersmith_howgrave_univariate(f, n, beta, m, t, X)
    for k_, _ in roots:
        p_ = int(k_ * M1) + int(MM(e)^a)
        if n % p_ == 0:
            q_ = n // p_
            print(f"a:           {hex(a)}")
            print(f"p:           {hex(p_)}")
            print(f"q:           {hex(q_)}")
            assert p_ * q_ == n
            exit(0)
