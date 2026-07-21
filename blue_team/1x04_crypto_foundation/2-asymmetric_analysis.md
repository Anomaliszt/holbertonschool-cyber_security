Goal: Generate RSA and ECC key pairs, discover the size limitation of asymmetric encryption through experimentation, and understand why the hybrid model exists.

Context: If symmetric encryption is the workhorse, asymmetric encryption is the handshake. It solves the key distribution problem that symmetric encryption alone cannot: how do two parties who have never met agree on a shared secret ? The answer involves key pairs, where one key encrypts and the other decrypts. But this elegance comes at a cost that you are about to measure.

---

## PART 1: RSA KEY GENERATION AND ENCRYPTION

### RSA Key Pair Generation

**Commands executed:**

```bash
openssl genrsa -out rsa_private.pem 2048
openssl rsa -in rsa_private.pem -pubout -out rsa_public.pem
```

**Output:**
```
writing RSA key
-rw------- 1 x x 1.7K rsa_private.pem
-rw-rw-r-- 1 x x  451 rsa_public.pem
```

### Small File Encryption/Decryption

**Command:**
```bash
echo "Patient Record: John Smith, DOB: 1965-03-15, Diagnosis: Hypertension" > patient_record.txt
openssl pkeyutl -encrypt -inkey rsa_public.pem -pubin -in patient_record.txt -out patient_record.enc
openssl pkeyutl -decrypt -inkey rsa_private.pem -in patient_record.enc -out patient_record_decrypted.txt
```

**Result:**
```
Original: Patient Record: John Smith, DOB: 1965-03-15, Diagnosis: Hypertension
Decrypted: Patient Record: John Smith, DOB: 1965-03-15, Diagnosis: Hypertension
Encrypted file size: 256 bytes (RSA-2048 block size)
```

**Success:** ✅ Small file encrypted and decrypted correctly.

### Large File Encryption Attempt

**Command:**
```bash
dd if=/dev/zero of=large_file.bin bs=1M count=100
openssl pkeyutl -encrypt -inkey rsa_public.pem -pubin -in large_file.bin -out large_file.enc
```

**Error Message:**
```
Public Key operation error
40172A88C27D0000:error:0200006E:rsa routines:ossl_rsa_padding_add_PKCS1_type_2_ex:
data too large for key size:../crypto/rsa/rsa_pk1.c:132:
```

### Why RSA Cannot Encrypt Large Files Directly

RSA encryption can only encrypt data smaller than the modulus size (key size). An RSA-2048 key can encrypt at most 245 bytes (2048 bits minus padding overhead). Attempting to encrypt a 100MB file directly produces the error "data too large for key size" because RSA operates on fixed-size blocks. **Real-world usage solves this through the hybrid encryption model: RSA encrypts a symmetric key, then that symmetric key encrypts the bulk data.** This is why TLS and SSH combine asymmetric key exchange with symmetric data encryption—asymmetric algorithms are computationally expensive and size-limited, while symmetric algorithms are fast and can handle any size payload.

---

## PART 2: ECC KEY GENERATION AND COMPARISON

### ECC Key Pair Generation

**Commands executed:**

```bash
openssl ecparam -genkey -name prime256v1 -out ecc_private.pem
openssl ec -in ecc_private.pem -pubout -out ecc_public.pem
```

### Key Size Comparison: RSA vs ECC

| Key Type | File Size | Security Level |
|---|---|---|
| RSA-2048 Private | 1,704 bytes | ~112-bit symmetric equivalent |
| ECC-P256 Private | 302 bytes | ~128-bit symmetric equivalent |
| **Size Ratio (RSA/ECC)** | **5.64× larger** | **ECC: Stronger in smaller key** |
| RSA-2048 Public | 451 bytes | |
| ECC-P256 Public | 178 bytes | 2.5× smaller |

### Why ECC Achieves Equivalent Security with Smaller Keys

ECC (Elliptic Curve Cryptography) uses the discrete logarithm problem on elliptic curves, which has fundamentally different mathematical properties than RSA's integer factorization. The difficulty of breaking ECC grows exponentially with key size, while RSA's difficulty grows sub-exponentially. This means **a 256-bit ECC key provides equivalent security to a 2048-bit RSA key**, yet uses 5.64× less storage and requires far fewer computational cycles. **For constrained environments like MedDefense's BD Alaris infusion pumps and Philips IntelliVue monitors with limited processing power and memory, ECC is far more practical**—the devices can perform authentication and secure communication without exhausting their computational budgets, enabling patient safety systems to operate with cryptographic protection rather than being left unencrypted due to resource constraints.

---

## PART 3: THE HYBRID ENCRYPTION MODEL

### How Hybrid Encryption Works

In hybrid encryption, two asymmetric and symmetric algorithms work in concert:

1. **Asymmetric (Key Exchange Phase):** When a client connects to a server (e.g., patient to MedDefense portal), the server sends its public key (or certificate containing the public key). The client generates a random symmetric key (session key), encrypts it with the server's public key, and transmits the encrypted key over the network. Only the server (which holds the private key) can decrypt and recover the symmetric key.

2. **Symmetric (Data Encryption Phase):** Once both parties possess the same symmetric key, all subsequent communication is encrypted using that key with a fast symmetric algorithm (e.g., AES-256). The bulk patient records, medications, billing data are encrypted with the symmetric key, not the asymmetric key.

3. **Why This Combination Is Superior:** Asymmetric encryption solves the "key distribution problem"—two strangers can establish trust without pre-sharing secrets. Symmetric encryption solves the "speed problem"—AES-256 is thousands of times faster than RSA for bulk data. Hybrid encryption gets the best of both: asymmetric for key exchange (secure, no pre-shared secrets), symmetric for data (fast, practical for large files).

4. **MedDefense Patient Portal Example:** When a patient connects to `https://patient-portal.meddefense.local`, the browser and web server perform a TLS handshake:
   - **Asymmetric (Key Exchange):** Client and server use the server's RSA-2048 public key to establish a shared AES-256 session key.
   - **Symmetric (Data Encryption):** All subsequent traffic—patient credentials, medical records, billing information—is encrypted with the AES-256 session key. The asymmetric key is never used for the actual data.

---

## PART 4: KEY LENGTH AND ALGORITHM COMPARISON TABLE

| Algorithm | Type | Approved Key Lengths | Equivalent Security | Current Status | Healthcare Use (HIPAA/NIST) | MedDefense Current Usage |
|---|---|---|---|---|---|---|
| **AES** | Symmetric | 128, 192, 256 bits | 128-bit, 192-bit, 256-bit | ✅ APPROVED | ✅ RECOMMENDED (NIST SP 800-175B) | ❌ NOT IMPLEMENTED (no disk encryption) |
| **RSA** | Asymmetric | 2048, 3072, 4096 bits | 112-bit (2048), 128-bit (3072), 152-bit (4096) | ⚠️ APPROVED but aging | ✅ ACCEPTABLE for signatures; use 2048+ for new systems | ✅ Patient portal uses RSA-2048 certificate |
| **ECC (P-256/NIST)** | Asymmetric | 256, 384, 521 bits | 128-bit (P-256), 192-bit (P-384), 256-bit (P-521) | ✅ APPROVED | ✅ RECOMMENDED (NIST SP 800-175B) | ❌ NOT IMPLEMENTED |
| **ECC (P-384)** | Asymmetric | 384 bits | 192-bit equivalent | ✅ APPROVED | ✅ RECOMMENDED for Suite B / Top Secret data | ❌ NOT IMPLEMENTED |
| **DES** | Symmetric | 56 bits | 56-bit (BROKEN) | ❌ DEPRECATED | ❌ NOT APPROVED (trivially breakable) | ✅ ENABLED in Active Directory (RC4/DES still negotiable) |
| **3DES (Triple DES)** | Symmetric | 112-168 bits | 112-bit effective (due to meet-in-the-middle) | ⚠️ DEPRECATED | ⚠️ ACCEPTABLE (legacy only) | ❌ NOT IMPLEMENTED |
| **RC4** | Symmetric | 40-256 bits | Variable (BROKEN for most sizes) | ❌ BROKEN | ❌ NOT APPROVED | ✅ ENABLED in Kerberos (legacy compatibility) |
| **ChaCha20-Poly1305** | AEAD | 256 bits | 256-bit equivalent | ✅ APPROVED | ✅ RECOMMENDED (IETF RFC 7539, NIST SP 800-38D) | ❌ NOT IMPLEMENTED |

### Algorithm Approval Summary for Healthcare

| Algorithm | Verdict | Reason |
|---|---|---|
| **AES-256** | ✅ APPROVED | NIST FIPS 197; US government approved for TOP SECRET data; HIPAA preferred |
| **RSA-2048+** | ✅ APPROVED | NIST SP 800-56B; acceptable for key exchange and signatures; 2048-bit minimum |
| **ECC-P256+** | ✅ APPROVED | NIST SP 800-186; modern, efficient; preferred over RSA for new systems |
| **ChaCha20-Poly1305** | ✅ APPROVED | IETF RFC 7539; NIST SP 800-38D; modern AEAD construction |
| **3DES** | ⚠️ LEGACY ONLY | NIST deprecated in 2017; only acceptable for legacy system compatibility |
| **DES** | ❌ NOT APPROVED | NIST deprecated in 1999; trivially breakable with modern hardware |
| **RC4** | ❌ NOT APPROVED | IETF RFC 7465 prohibits use; multiple breaks (BEAST, Lucky Thirteen); NOT for healthcare |

### MedDefense Compliance Assessment

**What MedDefense Is Doing Right:**
- ✅ Patient portal uses RSA-2048 certificate (TLS handshake)
- ✅ VPN tunnels use AES-256 with IPSec

**What MedDefense Must Fix:**
- ❌ Database encryption at rest: No AES-256; must implement LUKS or native database encryption
- ❌ Active Directory: DES and RC4 still enabled; must disable legacy encryption types, require AES-only
- ❌ DICOM: No encryption; must implement DICOM TLS with AES-256
- ❌ Backup encryption: NAS shares stored plaintext; must implement AES-256 encryption with off-NAS key storage
- ❌ Email encryption: S/MIME or OME not deployed; must enforce encryption for PHI emails
- ❌ TLS on portal: TLS 1.0 still supported; must mandate TLS 1.3 only or TLS 1.2 minimum with strong ciphers

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 2-asymmetric_analysis.md
