Goal: Build the definitive reference table of cryptographic algorithms, mapped against MedDefense's current and recommended usage, identifying every deprecated algorithm still in production.

Context: The Security+ exam expects you to know which algorithms are current, which are deprecated and which are broken. More importantly, it expects you to know WHY certain algorithms are inappropriate for certain uses. This task builds the reference you will carry into the exam and into your career.

Every algorithm in the table connects to something you have already seen in MedDefense.

---

## COMPREHENSIVE ALGORITHM REFERENCE TABLE

### SYMMETRIC ENCRYPTION ALGORITHMS

| Algorithm | Key Size | Block Size | Primary Use | Status | Why Deprecated/Broken | MedDefense Current Usage | MedDefense Recommended |
|---|---|---|---|---|---|---|---|
| **AES-128** | 128 bits | 128 bits | General data encryption; fast and secure | ✅ CURRENT | N/A—Still approved | ❌ NOT IMPLEMENTED (except VPN) | ✅ Deploy for database encryption (PostgreSQL, MySQL) |
| **AES-192** | 192 bits | 128 bits | Enhanced security requirement | ✅ CURRENT | N/A—Approved | ❌ NOT IMPLEMENTED | ⚠️ Optional for top-secret data; not required for HIPAA |
| **AES-256** | 256 bits | 128 bits | Top-secret data, long-term protection | ✅ CURRENT | N/A—Approved by NSA Suite B | ✅ VPN tunnels use AES-256 | ✅ Extend to databases, backups, DICOM storage |
| **3DES (Triple DES)** | 168 bits (3 × 56) | 64 bits | Legacy systems | ⚠️ DEPRECATED (2017) | Small block size (64-bit) allows birthday attacks; slow (3× DES); only ~112-bit effective security | ❌ NOT CURRENTLY USED | ⚠️ Migrate any legacy systems to AES-256 |
| **DES (Data Encryption Standard)** | 56 bits | 64 bits | Obsolete encryption | ❌ BROKEN | Trivially broken with modern hardware (2^56 brute force feasible in hours) | ❌ NOT DIRECTLY USED | ❌ MUST REPLACE if found |
| **RC4** | 40-256 bits | N/A (stream cipher) | Obsolete | ❌ BROKEN | IETF RFC 7465 prohibits use; multiple cryptographic breaks (biased key schedule, weak initial bytes) | ✅ ENABLED in Kerberos (legacy compatibility) | ❌ DISABLE immediately; migrate to AES |
| **ChaCha20-Poly1305** | 256 bits | N/A (stream cipher) | Modern authenticated encryption; IoT/mobile | ✅ CURRENT | N/A—Modern, IETF approved (RFC 7539) | ❌ NOT IMPLEMENTED | ✅ Consider for BD Alaris/Philips monitors (resource-constrained devices) |
| **Blowfish** | 32-448 bits | 64 bits | Legacy / password storage | ⚠️ DEPRECATED | 64-bit block size; BCrypt derivative better | ❌ NOT USED in data encryption | ⚠️ Use Bcrypt instead if legacy password hashing needed |

### ASYMMETRIC ENCRYPTION / KEY EXCHANGE ALGORITHMS

| Algorithm | Key Size | Primary Use | Status | Why Deprecated/Broken | MedDefense Current Usage | MedDefense Recommended |
|---|---|---|---|---|---|---|
| **RSA-2048** | 2048 bits | Key exchange, digital signatures, TLS handshake | ✅ CURRENT (minimum) | N/A | ✅ Patient portal TLS certificate | ✅ Keep for legacy compatibility; sign with SHA-256 |
| **RSA-3072** | 3072 bits | Key exchange, signatures (higher security) | ✅ CURRENT | N/A | ❌ NOT USED | ⚠️ Consider for new certificates (stronger than 2048) |
| **RSA-4096** | 4096 bits | Key exchange, signatures (top-secret data) | ✅ CURRENT | N/A | ❌ NOT USED | ⚠️ Optional for certificate authority root keys; adds minimal security over 3072 |
| **Diffie-Hellman (DH-2048)** | 2048 bits | Key exchange phase of IPSec/TLS | ✅ CURRENT (minimum) | N/A | ✅ VPN tunnels (FortiGate configuration) | ✅ Keep; ensure IKEv2 with DH Group 14+ |
| **Diffie-Hellman (DH-4096+)** | 4096+ bits | Higher-security key exchange | ✅ CURRENT | N/A | ❌ NOT USED (VPN uses 2048) | ✅ Recommend upgrade to DH-3072 or DH-4096 for VPN |
| **ECDHE (Elliptic Curve DH, P-256)** | 256 bits | Forward-secret key exchange (TLS 1.3) | ✅ CURRENT | N/A—Preferred over DHE | ❌ NOT IMPLEMENTED | ✅ Deploy in TLS 1.3 configuration (better than DHE-2048) |
| **ECDHE (P-384)** | 384 bits | Forward-secret key exchange (Suite B) | ✅ CURRENT | N/A | ❌ NOT IMPLEMENTED | ⚠️ Consider for higher security requirement |
| **ECC P-256 (NIST)** | 256 bits | Digital signatures, static encryption | ✅ CURRENT | N/A | ❌ NOT IMPLEMENTED | ✅ Recommended for certificate signing (replaces RSA-2048) |
| **ECC P-384** | 384 bits | Digital signatures (higher security) | ✅ CURRENT | N/A | ❌ NOT IMPLEMENTED | ⚠️ Use for certificate authority keys |

### HASHING ALGORITHMS

| Algorithm | Output Size | Primary Use | Status | Why Deprecated/Broken | MedDefense Current Usage | MedDefense Recommended |
|---|---|---|---|---|---|---|
| **MD5** | 128 bits | Checksums, integrity checks | ❌ BROKEN | Collision attacks possible (2^21 complexity); cannot rely on uniqueness | ❌ NOT USED for crypto | ❌ NEVER use for password hashing or digital signatures |
| **SHA-1** | 160 bits | Legacy digital signatures, TLS certificates | ⚠️ DEPRECATED | Collision attacks demonstrated (2015 SHAttered attack); NIST deprecated in 2011 | ❌ NOT USED | ❌ Remove from any remaining systems |
| **SHA-256** | 256 bits | Digital signatures, password hashing, integrity | ✅ CURRENT | N/A | ✅ VPN HMAC uses SHA-256 | ✅ Standard for all crypto hashing; use with RSA signatures |
| **SHA-512** | 512 bits | Enhanced security, password hashing | ✅ CURRENT | N/A | ❌ NOT IMPLEMENTED | ✅ Use for password hashing (PBKDF2-SHA-512) |
| **SHA-3** | 224, 256, 384, 512 bits | Next-generation hashing | ✅ CURRENT | N/A—NIST standard since 2015 | ❌ NOT IMPLEMENTED | ⚠️ Optional; SHA-256 sufficient for now |

### KEY DERIVATION FUNCTIONS (KDF)

| Algorithm | Input | Output | Primary Use | Status | Why Deprecated/Broken | MedDefense Current Usage | MedDefense Recommended |
|---|---|---|---|---|---|---|---|
| **PBKDF2** | Password + salt | Arbitrary | Password hashing for application logins | ✅ CURRENT | N/A; requires sufficient iterations (100k+) | ❌ NOT IMPLEMENTED (AD uses NTHash) | ✅ Use PBKDF2-SHA-512 for application DB password hashing |
| **Bcrypt** | Password + salt | 192 bits | Password hashing, slow-by-design | ✅ CURRENT | N/A; inherently resistant to GPU attacks | ❌ NOT IMPLEMENTED | ✅ Preferred over PBKDF2 for new systems |
| **Scrypt** | Password + salt | Arbitrary | Password hashing, memory-hard KDF | ✅ CURRENT | N/A; memory-hard increases cost for attackers | ❌ NOT IMPLEMENTED | ✅ Consider for new systems (more resistant than Bcrypt) |
| **Argon2** | Password + salt | Arbitrary | Password hashing, GPU/ASIC resistant | ✅ CURRENT (emerging) | N/A—Winner of Password Hashing Competition (2015) | ❌ NOT IMPLEMENTED | ✅ RECOMMENDED for new systems; best resistance to hardware acceleration |

---

## MEDDEFENSE CRYPTO GAP ANALYSIS

### Current Usage vs. Recommended Usage

**What MedDefense is doing:**
- ✅ VPN: AES-256 + SHA-256 + IKEv2 (DH-2048)
- ✅ Portal: RSA-2048 certificate with TLS 1.0/1.2 (weak TLS versions)
- ✅ Email: Microsoft-managed TLS 1.2
- ❌ Database: NO ENCRYPTION
- ❌ Backups: NO ENCRYPTION
- ❌ DICOM: NO ENCRYPTION
- ⚠️ Active Directory: DES, RC4 enabled (legacy Kerberos)
- ⚠️ Passwords: NTHash (MD4-based), not a proper KDF

**What MedDefense should be doing:**
- Databases: AES-256-CBC or AES-256-GCM
- Backups: AES-256 with externally stored keys (not on NAS)
- DICOM: DICOM TLS with AES-256
- Active Directory: AES-only, disable DES/RC4
- TLS: TLS 1.2 minimum (1.3 preferred), disable TLS 1.0
- Passwords: Argon2 or Bcrypt (not NTHash)

### Critical Replacement Actions (4+ Cases)

**Case 1: RC4 in Kerberos Authentication** ❌ BROKEN
- **Current:** Active Directory allows Kerberos tickets encrypted with RC4 (legacy)
- **Risk:** Kerberoasting attacks; offline ticket cracking with modern hardware
- **Replacement:** AES-256 only; disable RC4 and DES
- **Action:** `adsi.msc` → Domain Controllers → Edit Kerberos encryption types to AES-only
- **Timeline:** 30 days (coordinate with application testing)

**Case 2: No Database Encryption (PostgreSQL + MySQL)** ❌ ABSENT
- **Current:** Patient records and billing data stored in plaintext on unencrypted ext4
- **Risk:** Any root compromise or physical disk theft exposes all data
- **Replacement:** PostgreSQL TDE (Transparent Data Encryption) or LUKS + AES-256
- **Action:** Enable LUKS encryption on ehr-db-01 and billing-srv-01 filesystems
- **Timeline:** 2 weeks (coordinate with backup windows)

**Case 3: No DICOM Encryption (Medical Images)** ❌ ABSENT
- **Current:** DICOM images transmitted in cleartext over ports 4242/11112
- **Risk:** Medical images with embedded PHI (name, DOB, MRN, diagnosis) accessible to network sniffing
- **Replacement:** DICOM TLS (DICOM PS3.15) with AES-256
- **Action:** Configure DICOM TLS on PACS and all radiology workstations
- **Timeline:** 3 weeks (requires biomedical engineering coordination)

**Case 4: Unencrypted Backups on NAS** ❌ ABSENT
- **Current:** All backups stored unencrypted on Synology NAS (RAID-5)
- **Risk:** Ransomware can encrypt backups; no recovery option
- **Replacement:** AES-256 encryption with keys stored externally (not on NAS)
- **Action:** Enable Synology shared folder encryption + store keys in HashiCorp Vault
- **Timeline:** 4 weeks (requires external key management setup)

**Case 5: TLS 1.0 Still Enabled on Patient Portal** ⚠️ WEAK
- **Current:** Portal supports TLS 1.0 and TLS 1.2; no TLS 1.3
- **Risk:** BEAST, POODLE, Lucky Thirteen attacks against TLS 1.0
- **Replacement:** TLS 1.2 minimum (TLS 1.3 preferred); disable TLS 1.0/1.1
- **Action:** Apache SSL configuration; update mod_ssl directives
- **Timeline:** 1 week (no service impact; tested in lab first)

**Case 6: No Email Encryption for PHI** ⚠️ WEAK
- **Current:** Physicians email PHI in plaintext (audit notes: "I've told them not to. They do it anyway.")
- **Risk:** HIPAA violation; data breach if email intercepted
- **Replacement:** S/MIME or Office Message Encryption (OME) for all O365 mailboxes
- **Action:** Enable OME by default; require external password for external recipients
- **Timeline:** 2 weeks (requires user training)

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 6-algorithm_landscape.md
