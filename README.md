# Introduction to Lattice-based Attacks

In this report I analyzed various attacks on RSA and ECDSA based on lattices.

The attacks implemented in sagemath were the following

| Script | Description|
| --- | --- |
| [attack_rsa](./src/attack_rsa.sage) | Decrypt ciphertext with small RSA key with e=3 and known padding |
| [attack_rsa_big](./src/attack_rsa_big.sage) | Decrypt ciphertext with RSA-1024 key with e=3 and known padding |
| [attack_rsa_msb](./src/attack_rsa_msb.sage) | Factor RSA-1024 modulus when known MSB of p |
| [attack_rsa_roca](./src/attack_rsa_roca.sage) | Implement ROCA attack against RSA-512 |
| [attack_ecdsa](./src/attack_ecdsa.sage) | Implement ECDSA attacks when the nonces are small |
| [attack_ecdsa_msb](./src/attack_ecdsa_msb.sage) | Recover ECDSA nonces when MSB bits of nonces are known against secp256r1 |

During the writing of the report I also created some scripts to plot lattices and
reduction algorithms that can be found in [src](./src)

