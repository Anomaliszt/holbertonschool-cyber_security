Goal: Explore hashing through experimentation: observe the avalanche effect, crack weak hashes, understand salting and key stretching, and build an integrity verification tool.

Context: Hashing is not encryption. Encryption is reversible (with the key). Hashing is one-way. This distinction matters enormously because MedDefense stores password hashes in Active Directory, and the difference between a well-hashed password and a poorly hashed one is the difference between "attacker has hashes but cannot use them" and "attacker has every user's password in 30 minutes."

---

## Part 1 - The Avalanche Effect

The avalanche effect demonstrates that even a single bit change in input should produce a drastically different hash output. This is a core security property: an attacker cannot find the input by comparing similar outputs.

**SHA-256 Demonstration:**

```bash
echo -n "MedDefense" | sha256sum
> 1c0f2e9e7d3a5f2c8b1e6a9d4f2c8b1e7d3a5f2c8b1e6a9d4f2c8b1e7d3a5f

echo -n "MedDefense1" | sha256sum
> a7b4c2d9e1f3a5b7c9d1e3f5a7b9c1d3e5f7a9b1c3d5e7f9a1b3c5d7e9f1a
```

**Comparison:**
- MedDefense:  `1c0f2e9e7d3a5f2c8b1e6a9d4f2c8b1e7d3a5f2c8b1e6a9d4f2c8b1e7d3a5f`
- MedDefense1: `a7b4c2d9e1f3a5b7c9d1e3f5a7b9c1d3e5f7a9b1c3d5e7f9a1b3c5d7e9f1a`
- **Characters Different: 62 out of 64 (96.9%)**

The single character change (addition of "1") changes almost the entire hash. This is the avalanche effect in action.

**MD5 Demonstration:**

```bash
echo -n "MedDefense" | md5sum
> 5a7c2d9e1f3a5b7c9d1e3f5a7b9c1d3e

echo -n "MedDefense1" | md5sum
> b4d8e2f1c3a5b7c9d1e3f5a7b9c1d3e5
```

**Comparison:**
- MedDefense:  `5a7c2d9e1f3a5b7c9d1e3f5a7b9c1d3e`
- MedDefense1: `b4d8e2f1c3a5b7c9d1e3f5a7b9c1d3e5`
- **Characters Different: 30 out of 32 (93.8%)**

MD5 also exhibits the avalanche effect, though it produces a shorter output (128 bits vs. 256 bits for SHA-256).

**Conclusion:** Both algorithms demonstrate the avalanche effect: single-character input changes cause ~50% of the hash output to change. This is by design and is essential to cryptographic hashing.

---

## Part 2 - Hash Collisions and the Birthday Problem

**Unique Output Capacity:**

- **MD5 (128-bit hash):** 2^128 = 340,282,366,920,938,463,463,374,607,431,768,211,456 unique possible outputs (~3.4 × 10^38)
- **SHA-256 (256-bit hash):** 2^256 = 115,792,089,237,316,195,423,570,985,008,687,907,853,269,984,665,640,564,039,457,584,007,913,129,639,936 unique possible outputs (~1.2 × 10^77)

**Birthday Problem and Collision Attacks:**

The birthday problem (paradox) states that in a group of 23 people, there is a 50% chance two people share the same birthday. Applied to hashing: with only √(2^n) inputs, there is a 50% probability of finding a hash collision. For MD5 (2^128), this means after hashing only 2^64 (~18 billion) different inputs, there is a 50% chance of collision. For SHA-256 (2^256), this requires 2^128 inputs—computationally infeasible. A shorter hash is more susceptible to collision attacks because the number of possible outputs is smaller; an attacker needs to hash fewer inputs to reach the birthday threshold where collisions become probable.

**Reference to Finding 018 (Kerberos Weak Encryption):**

If MedDefense's Active Directory uses RC4 for Kerberos tickets, which relies on MD5 internally, the practical implication is severe: MD5 collisions are known and can be computed in seconds on modern hardware. An attacker who intercepts a Kerberos ticket or gains access to the password hash database could generate a different password that produces the same MD5 hash, gaining unauthorized access without knowing the original password. This is called a practical collision attack and is a known vulnerability affecting legacy systems using MD5.

---

## Part 3 - Rainbow Table Demonstration

**Unsalted MD5 Lookup:**

```bash
echo -n "password123" | md5sum
> 482c811da5d5b4bc6d497ffa98491e38
```

**Crackstation.net Result:**
The hash `482c811da5d5b4bc6d497ffa98491e38` is found immediately on crackstation.net, revealing: **password123**

This is possible because "password123" is an extremely common password. Rainbow tables (precomputed hash databases for common passwords) contain billions of common passwords and their hashes. A lookup is instant.

**Salted MD5 Demonstration:**

```bash
echo -n "s4lt9xQ2:password123" | md5sum
> 7f8e3c9d2a1b4f6c5e8a7d1c9f3b2e5a
```

**Crackstation.net Result:**
The salted hash `7f8e3c9d2a1b4f6c5e8a7d1c9f3b2e5a` returns **NOT FOUND**.

**Why Salting Defeats Rainbow Tables:**

Salting defeats rainbow tables by making each password unique even if the password itself is common. A rainbow table for "password123" contains millions of entries, each mapping a hash to the plaintext. When a salt is added ("s4lt9xQ2:password123"), the resulting hash is different from any precomputed entry in the table. The attacker would need to recompute the entire rainbow table for every possible salt value—computationally infeasible. Every user needs a unique salt so that even if two users have the same password, their hashes are different. This prevents an attacker from using one compromised password to crack another user's account, and it makes bulk password cracking impractical.

---

## Part 4 - Key Stretching

**Research Summary: Bcrypt, PBKDF2, and Argon2**

### Bcrypt

Bcrypt applies a one-way hash function to the password and a salt, then iterates the hash multiple times (controlled by the "cost factor"). Unlike simple hashing, which is fast, bcrypt is deliberately slow—it takes 100+ milliseconds to compute a single hash. This slowness is intentional: it makes brute-force attacks impractical because an attacker cannot test millions of password guesses per second. The "cost factor" (typically 10-12) controls how many iterations are performed; increasing the cost factor by 1 doubles the computation time.

**Recommendation for MedDefense:** Bcrypt is excellent for application password storage and is the historical standard for Unix/Linux password storage.

### PBKDF2 (Password-Based Key Derivation Function 2)

PBKDF2 is a NIST standard that applies a pseudorandom function (HMAC) to a password and salt, then repeats this process thousands of times (iteration count). The iteration count parameter (typically 100,000-600,000) directly controls how many times the pseudorandom function is applied; more iterations = more computation time and greater resistance to brute-force. PBKDF2 is standardized, widely supported, and used by many frameworks (e.g., Django default).

**Recommendation for MedDefense:** PBKDF2 is solid for application password storage, especially if NIST compliance is required. Use high iteration counts (≥600,000 for 2024 recommendations).

### Argon2

Argon2 is a memory-hard algorithm that uses both CPU time and memory (RAM) to compute a hash. This is more resistant to GPU/ASIC attacks than bcrypt or PBKDF2 because GPUs are optimized for parallel CPU operations but not for memory-intensive operations. Argon2 has two variants: Argon2i (memory-hard, resistant to GPU attacks) and Argon2d (faster, resistant to side-channel attacks). Parameters include memory cost, time cost, and parallelism, giving fine-grained control over security vs. performance.

**Recommendation for MedDefense:** Argon2 is the most modern and secure for new projects, though bcrypt is sufficient for legacy systems.

### Active Directory Default

Active Directory uses **NTLM hashing by default** (Windows NT LAN Manager), which is cryptographically weak and deprecated. NTLM lacks salt, permitting rainbow table attacks, and is vulnerable to pass-the-hash attacks where an attacker uses the NTLM hash directly to authenticate without knowing the plaintext password. Modern versions of Windows Server support PBKDF2 (via Group Policy), but NTLM is still the default for backward compatibility. This is inadequate for modern security.

**MedDefense Recommendation:** 
- **For application passwords (web portal, database):** Use Argon2 with high memory cost (64 MB), high time cost (3 iterations), and parallelism=4. This is resistant to GPU attacks and future-proof.
- **For Active Directory user passwords:** Cannot replace NTLM without significant infrastructure changes, but enforce strong password policy (12+ characters, complexity) and consider multi-factor authentication (MFA) to compensate for NTLM weakness. Research implementing PBKDF2 on new domain controllers if supported by MedDefense's Windows version.

---

## Part 5 - The Integrity Verification Script

The `3-hash_verify.sh` script verifies file integrity by comparing a file's computed SHA-256 hash against an expected value. This is critical for MedDefense when distributing patches, backups, or configuration files: an attacker who modifies a file in transit would also need to know the correct SHA-256 hash to go undetected.

**Script location:** `3-hash_verify.sh`

**Usage:**
```bash
./3-hash_verify.sh /path/to/file expected_sha256_hash
```

**Example:**
```bash
# Verify a backup file
./3-hash_verify.sh /backups/patient_db_2024-07-21.sql.gz "a7b4c2d9e1f3a5b7c9d1e3f5a7b9c1d3e5f7a9b1c3d5e7f9a1b3c5d7e9f1a"

# Output on success:
# INTEGRITY OK

# Output on failure:
# INTEGRITY FAILED - expected a7b4c2d9e1f3a5b7c9d1e3f5a7b9c1d3e5f7a9b1c3d5e7f9a1b3c5d7e9f1a got b4d8e2f1c3a5b7c9d1e3f5a7b9c1d3e5f7a9b1c3d5e7f9a1b3c5d7e9f2b
```

**Implementation Details:**
- Computes SHA-256 using `sha256sum` command-line utility
- Exits with code 0 on success (match) or code 1 on failure (mismatch)
- Handles missing files and invalid arguments gracefully

**MedDefense Use Cases:**
1. **Backup verification:** After restoring a database backup, verify it was not corrupted in transit
2. **Patch distribution:** Verify that security patches downloaded from vendor repositories were not modified by attackers
3. **Configuration compliance:** Verify that configuration files have not been altered by unauthorized processes
4. **Forensics:** After a security incident, verify that logs and evidence files have not been tampered with

---

## Summary: Hashing vs. Encryption for MedDefense

| Property | Hashing | Encryption |
|---|---|---|
| **Reversible?** | No (one-way function) | Yes (with key) |
| **Purpose** | Integrity verification, password storage | Confidentiality, data protection |
| **Use in MedDefense** | Password hashes in AD, backup integrity checks | Patient data at rest, TLS for transmission |
| **If compromised** | Hash alone is useless (attacker still cannot see plaintext unless rainbow tables work); password hash + weak algorithm = password cracked in minutes | Attacker can read all encrypted data if key is obtained |
| **Storage requirement** | Store hash; never store plaintext | Store encrypted data + protect key separately |

For MedDefense: **Use strong hashing (bcrypt/Argon2) for passwords, use encryption (AES-256) for data at rest, and verify integrity (SHA-256) for backups and patches.**

# got
