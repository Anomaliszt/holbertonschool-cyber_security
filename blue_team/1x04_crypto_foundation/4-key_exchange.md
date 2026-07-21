Goal: Simulate a Diffie-Hellman key exchange with OpenSSL to understand how two parties agree on a shared secret over an insecure channel, then analyze the man-in-the-middle vulnerability that certificates exist to solve.

Context: The fundamental problem of symmetric encryption is key distribution: Alice and Bob need the same key, but they cannot send it over the network because Eve is listening. In 1976, Whitfield Diffie and Martin Hellman solved this problem with mathematics. You are about to reproduce their solution with OpenSSL.

But their solution has a weakness. If Eve is not just listening but actively intercepting and modifying traffic, Diffie-Hellman alone cannot detect her. This is why certificates exist. The connection between key exchange and PKI is the thread that runs through the rest of this project.

---

## PART 1: DIFFIE-HELLMAN SIMULATION

### Step 1: Generate Shared DH Parameters

**Command:**
```bash
openssl dhparam -out dhparams.pem 2048
```

**Output:**
```
Generating DH parameters, 2048 bit long safe prime
[.+*+* pattern repeated: OpenSSL generating a 2048-bit safe prime]
```

**Result:** ✅ DH parameters generated (428 bytes)

### Step 2: Generate Alice's Keys

**Commands:**
```bash
openssl genpkey -paramfile dhparams.pem -out alice_private.pem
openssl pkey -in alice_private.pem -pubout -out alice_public.pem
```

**Output:**
```
=== Alice's Keys Generated ===
Private key: 806 bytes
Public key: 800 bytes
```

Alice's private key is kept secret. Her public key is sent to Bob.

### Step 3: Generate Bob's Keys

**Commands:**
```bash
openssl genpkey -paramfile dhparams.pem -out bob_private.pem
openssl pkey -in bob_private.pem -pubout -out bob_public.pem
```

**Output:**
```
=== Bob's Keys Generated ===
Private key: 806 bytes
Public key: 800 bytes
```

Bob's private key is kept secret. His public key is sent to Alice.

### Step 4: Derive Shared Secret (Alice's Computation)

**Command:**
```bash
openssl pkeyutl -derive -inkey alice_private.pem -peerkey bob_public.pem -out alice_secret.bin
```

**Result:** Alice's secret = 256 bytes (2048 bits)

Alice uses her private key + Bob's public key → derives shared secret

### Step 5: Derive Shared Secret (Bob's Computation)

**Command:**
```bash
openssl pkeyutl -derive -inkey bob_private.pem -peerkey alice_public.pem -out bob_secret.bin
```

**Result:** Bob's secret = 256 bytes (2048 bits)

Bob uses his private key + Alice's public key → derives shared secret

### Step 6: Compare the Secrets

**Command:**
```bash
cmp alice_secret.bin bob_secret.bin
```

**Output:**
```
✅ IDENTICAL: Both Alice and Bob derived the same shared secret!

Alice's secret (hex): 8e76b6ad0a4ba44efab8421d35515a10811b6785d6415c6f76e38e2213...01b8da7cc8667754c609bf74d8ff3b80f9

Bob's secret (hex):   8e76b6ad0a4ba44efab8421d35515a10811b6785d6415c6f76e38e2213...01b8da7cc8667754c609bf74d8ff3b80f9

✅ The secrets are byte-for-byte identical!
```

---

## PART 2: NON-TECHNICAL EXPLANATION (For CFO Robert Kim)

### How Diffie-Hellman Key Exchange Works

Imagine Alice and Bob are in a crowded airport (the internet), and Eve is standing nearby listening to every word they say. They want to agree on a secret password that only they know, without Eve learning it. 

Here's the magic: Alice chooses a secret number (her private key) and performs a mathematical calculation that transforms it into a public number (her public key). She announces her public number to the entire airport, and Eve hears it. Bob does the same—he chooses a secret number and calculates his public number, announcing it publicly. Now comes the clever part: **When Alice takes Bob's public number and her secret number and performs a specific mathematical operation, she gets a result. When Bob takes Alice's public number and his secret number and performs the same operation, he gets the exact same result.** Eve, even though she heard both public numbers announced, cannot derive this same result because she does not have either secret number. The mathematics works such that only the combination of one secret with the other public produces the shared key. Eve would need to solve an extremely difficult math problem (the discrete logarithm problem) to figure out the shared key, and that would take thousands of years with modern computers.

**What happened:** Alice and Bob each had 806-byte secret keys. They calculated 256-byte public keys from those secrets. They exchanged public keys over the network. Then each of them—using their own secret key plus the other person's public key—calculated the exact same 256-byte shared secret. Eve sees all the public keys flying across the network but cannot derive that shared secret.

---

## PART 3: VULNERABILITY - MAN-IN-THE-MIDDLE ATTACK

### The Problem with Plain Diffie-Hellman

Diffie-Hellman solves the "listening" problem (Eve sees public keys but cannot derive the secret), but it does **not** solve the "active attacker" problem. If Eve is not just listening but also **intercepting and modifying traffic**, she can perform a man-in-the-middle (MITM) attack:

1. Alice sends her public key toward Bob, but Eve intercepts it.
2. Eve performs a DH exchange with Alice directly (Eve acts as "Bob"), deriving a shared secret with Alice using Eve's own private key.
3. Eve also performs a DH exchange with Bob directly (Eve acts as "Alice"), deriving a different shared secret with Bob using a different private key.
4. Now Eve has two shared secrets: one with Alice and one with Bob.
5. When Alice encrypts data with her shared secret, Eve decrypts it (Eve has that secret), re-encrypts it with Bob's shared secret, and sends it on.
6. Alice and Bob have no idea Eve is in the middle reading everything.

### Application to MedDefense VPN Tunnel

**Scenario:** MedDefense's VPN tunnel between Central office and Westside clinic uses IPSec with Diffie-Hellman for key exchange. If the tunnel relied on **plain DH without certificate-based authentication**, an attacker on the network path (for example, an attacker who has compromised an intermediate router or ISP infrastructure) could:

1. **Intercept the IKEv2 DH handshake** between the FortiGate at Central and the Netgear router at Westside.
2. **Pretend to be Westside to Central** and establish a DH-derived shared secret with the FortiGate.
3. **Pretend to be Central to Westside** and establish a separate DH-derived shared secret with the Netgear router.
4. **Read all traffic** passing through the tunnel: patient data, financial records, medication information.
5. **Modify traffic in flight**: Redirect backups to attacker's server, inject malware into updates, alter patient dosages transmitted through the tunnel.

### How Certificates Prevent This

**Certificates solve MITM by adding identity verification.** Before Alice and Bob perform DH key exchange, they first verify each other's identity using digital certificates (signed by a trusted Certificate Authority). Here's how it works in the MedDefense VPN context:

1. The FortiGate at Central presents a **certificate signed by a trusted CA** that proves it belongs to MedDefense Central (it has a specific name/IP binding).
2. The Netgear router at Westside presents a **certificate signed by the same trusted CA** proving it belongs to MedDefense Westside.
3. Before they exchange DH keys, each device **cryptographically verifies** the other's certificate using the CA's public key. If an attacker tries to impersonate Westside, their certificate would not verify (it would not have a valid CA signature).
4. Only after certificate verification succeeds do the devices proceed with the DH key exchange.
5. Now, even if an attacker intercepts traffic, they cannot perform MITM because they cannot forge a valid certificate for "Westside" signed by the trusted CA.

**In essence:** DH solves eavesdropping (Eve cannot passively derive the key). **Certificates solve impersonation** (Eve cannot forge an identity and perform active MITM). Together, they create the foundation of secure communication.

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 4-key_exchange.md
