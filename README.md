# Introduction to Lattice-based Attacks

In the [essay](./lattice_based_attacks.pdf) different attacks on RSA and ECDSA based on lattice reduction algorithms are discussed.

The attacks implemented in SageMath are:

| Script | Description|
| --- | --- |
| [attack_rsa](./src/attack_rsa.sage) | Decrypt ciphertext with small RSA key with e=3 and known padding |
| [attack_rsa_big](./src/attack_rsa_big.sage) | Decrypt ciphertext with RSA-1024 key with e=3 and known padding |
| [attack_rsa_msb](./src/attack_rsa_msb.sage) | Factor RSA-1024 modulus when MSB of p are known |
| [attack_rsa_roca](./src/attack_rsa_roca.sage) | Implement ROCA attack against RSA-512 |
| [attack_ecdsa](./src/attack_ecdsa.sage) | Implement ECDSA attacks when the nonces are small |
| [attack_ecdsa_msb](./src/attack_ecdsa_msb.sage) | Recover ECDSA nonces when MSB bits of nonces are known against secp256r1 |

I also created some scripts to plot lattices and reduction algorithms that can be found in [src](./src).

