Goal: Explore hashing through experimentation: observe the avalanche effect, crack weak hashes, understand salting and key stretching, and build an integrity verification tool.

Context: Hashing is not encryption. Encryption is reversible (with the key). Hashing is one-way. This distinction matters enormously because MedDefense stores password hashes in Active Directory, and the difference between a well-hashed password and a poorly hashed one is the difference between "attacker has hashes but cannot use them" and "attacker has every user's password in 30 minutes."

Instructions:

Part 1 - The Avalanche Effect

Hash the string "MedDefense" with SHA-256:

echo -n "MedDefense" | sha256sum
Now hash "MedDefense1" (one character added). Compare the two hashes. How many characters of the hex output differ ? This is the avalanche effect: a single bit of input change should change approximately 50% of the output. Repeat with MD5. Document all four hashes.

Part 2 - Hash Collisions and the Birthday Problem

MD5 produces a 128-bit hash. SHA-256 produces a 256-bit hash. Calculate: how many possible unique outputs does each produce ? (Express as a power of 2.)

Explain in 3-4 sentences why a shorter hash is more susceptible to collision attacks and what a birthday attack exploits. Reference Finding 018 from 1x02 (Kerberos weak encryption): if MedDefense's AD uses RC4 for Kerberos tickets, which relies on MD5 internally, what is the practical implication for password security ?

Part 3 - Rainbow Table Demonstration

Hash the password "password123" with MD5:

echo -n "password123" | md5sum
Go to crackstation.net and look up the resulting hash. Document what you find.

Now hash "password123" with a salt:

echo -n "s4lt9xQ2:password123" | md5sum
Look up this salted hash on crackstation.net. Document the result. Explain in 3-4 sentences why salting defeats rainbow tables and why every user needs a unique salt.

Part 4 - Key Stretching

Research bcrypt, PBKDF2 and Argon2. For each, explain in 2-3 sentences: what it does differently from a simple hash, why it is more resistant to brute-force and what the "cost factor" or "iteration count" parameter controls.

Which would you recommend for MedDefense's application password storage, and why ? Which is used by Active Directory by default (research this) and is it adequate ?

Part 5 - The Integrity Verification Script

Write a script 3-hash_verify.sh that:

Takes two arguments: a file path and an expected SHA-256 hash

Computes the SHA-256 hash of the file

Compares it to the expected hash

Outputs "INTEGRITY OK" if they match, "INTEGRITY FAILED - expected [hash] got [hash]" if they do not

Returns exit code 0 on success, 1 on failure

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 3-hash_verify.sh, 3-hash_analysis.md
