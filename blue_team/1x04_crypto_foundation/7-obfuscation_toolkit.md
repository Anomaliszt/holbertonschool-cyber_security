Goal: Distinguish between encryption, hashing and obfuscation techniques, design a tokenization scheme for MedDefense, and evaluate steganography as both a protection tool and a threat vector.

Context: Not every data protection mechanism is encryption. Sec+ 1.4 distinguishes several obfuscation techniques: tokenization (replacing sensitive data with non-sensitive tokens), data masking (hiding parts of data while preserving format) and steganography (hiding data within other data). Each has a specific use case, and confusing them is a common exam mistake and a real-world design error.

---

## PART 1: DATA PROTECTION TECHNIQUE COMPARISON

| Technique | What It Does | Reversible? | Original Recoverable? | Healthcare Use Case |
|---|---|---|---|---|
| **Encryption** | Transforms plaintext into ciphertext using a key; requires the key to reverse | Yes | Yes—with the key | Patient records in transit (TLS for portal); EHR database at rest (AES-256); DICOM images stored on PACS |
| **Hashing** | Transforms data into a fixed-length, deterministic output (one-way function) | No—by design | No—cryptographically infeasible to reverse | Passwords stored in database (bcrypt, Argon2); integrity verification of backup files; HIPAA audit logs |
| **Tokenization** | Replaces sensitive data with a random, non-sensitive token; original data stored in secure vault | Partially—token is reversible only by authorized systems with vault access | Yes—but only by systems with cryptographic keys to access the token vault | Credit card numbers in billing system; PHI in data analytics platforms that should not see real patient names/IDs |
| **Data Masking** | Obscures sensitive data while preserving format and utility (e.g., SSN 987-65-4321 becomes ***-**-4321) | No—masked data is not reversible | No—masking is selective display, not encryption | Displaying patient records to different roles (nurses see full SSN; receptionists see "***-**-XXXX"); development/testing with sanitized production data |
| **Steganography** | Hides data within other data (e.g., embedding text within image metadata or LSBs); data is present but hidden | Possibly—depends on steganography method | Yes—if attacker knows steganography was used; no—if attacker has no reason to look | Unusual use case in healthcare; potential insider threat vector (embedding exfiltrated PHI in DICOM files for covert data theft) |

---

## PART 2: MEDDEFENSE TOKENIZATION DESIGN FOR PAYMENT PROCESSING

### Problem Statement
MedDefense's billing department processes patient payments and insurance claims. They currently store full credit card numbers (PAN: Primary Account Number) in plaintext in the MySQL billing database. This violates PCI-DSS 3.2.1 (never store full PAN unencrypted) and increases breach impact if the database is compromised.

### Tokenization Scheme Design

**Part A: What Data Is Tokenized**

- **Tokenized:** Full credit card number (e.g., "4539-1234-5678-9012")
- **Token Format:** Unique, random 32-character alphanumeric string (e.g., "tok_a7f3e9d2b1c4f8e6a2d9b3f5c1e8a4d7")
- **Non-Sensitive Data Retained:** Last 4 digits (e.g., "9012"), expiration date (e.g., "12/27"), cardholder name
- **Data Flow:**
  1. Patient enters credit card in payment form (HTTPS, encrypted in transit)
  2. Payment gateway (e.g., Stripe, Square) tokenizes the card
  3. Payment gateway returns a token to MedDefense
  4. MedDefense stores token in billing database (not the PAN itself)
  5. When processing payment, MedDefense sends token to payment gateway (not card number)
  6. Payment gateway uses vault to map token back to PAN and processes payment

**Part B: Token Vault Storage and Protection**

- **Vault Location:** Payment gateway's secure, PCI-DSS Level 1 compliant environment (Stripe, Square, etc.)
  - NOT MedDefense's database
  - NOT MedDefense's servers
  - Managed by certified payment processor with higher security standards than MedDefense
- **Vault Encryption:** AES-256 at rest; AES-256 in transit; per-token encryption keys
- **Vault Access Controls:**
  - API authentication: OAuth 2.0 + API keys
  - MedDefense systems authenticate with asymmetric keys (RSA-2048 certificates)
  - Logging: All vault access logged with timestamp, user, action, result
  - Audit: Payment processor provides monthly PCI-DSS audit reports
- **Key Storage:** Payment processor's HSM (Hardware Security Module) with secure key wrapping
- **Compliance:** PCI-DSS Level 1 certification; SOC 2 Type II audit; zero-knowledge tokenization (payment processor cannot see MedDefense's patient data)

**Part C: Compromise Scenario—If Token Vault Is Breached**

If the payment gateway's vault is compromised:
- **Best Case:** Attacker has tokens but not the keys to decrypt them. Tokens are worthless without the decryption key stored in the HSM. Payment processor revokes all tokens and issues new ones (MedDefense updates token references).
- **Worst Case:** Attacker obtains HSM keys. They can decrypt tokens to recover PAN. MedDefense is notified; incident response triggers: notify affected patients, provide credit monitoring, file breach notification with regulators.
- **MedDefense's Mitigation:** This is why using a reputable payment processor (Stripe, Square, Adyen) is critical. Their vault is more secure than MedDefense's servers would be. Breach risk is transferred to the processor, who has insurance and incident response resources.

**Part D: Tokenization vs. Encryption—Comparison**

| Aspect | Tokenization | Encryption |
|---|---|---|
| **Reversibility** | Asymmetric—only payment processor can reverse | Symmetric—anyone with key can decrypt |
| **Key Management** | Processor manages vault keys in HSM | MedDefense must manage encryption keys |
| **Complexity** | Simple—MedDefense stores token strings | Complex—MedDefense must manage encryption keys, key rotation, secure storage |
| **Risk if Database Compromised** | Low—tokens are cryptographically useless without processor's HSM key | Medium-High—if encryption keys are stored in database or accessible locally, attacker could decrypt |
| **Compliance** | PCI-DSS preferred; outsources security to certified processor | Acceptable but requires rigorous key management; MedDefense liable for key security |
| **Performance** | Faster—token lookup; no local decryption overhead | Slower—decrypt-on-demand; crypto operations per query |
| **Audit Trail** | Processor maintains authoritative audit log; MedDefense audits processor | MedDefense maintains encryption/decryption logs; requires internal log integrity controls |

**MedDefense Recommendation:** **Tokenization via reputable payment processor (Stripe/Square) is superior** because:
1. **Outsources key management** to certified PCI-DSS Level 1 provider
2. **Reduces liability** if tokens are stolen (processor's vault keys are not compromised)
3. **Simplifies compliance** (no encryption key rotation burden)
4. **Enables analytics** without exposing PAN (process tokens, count transactions, retain non-sensitive data)

---

## PART 3: DATA MASKING EXAMPLES FOR ROLE-BASED ACCESS

### Masking Rules by Role

| Data Field | Full Value | Nurse (Clinical) | Billing Clerk | Reception | Justification |
|---|---|---|---|---|---|
| **SSN** | 987-65-4321 | 987-65-4321 | ***-**-4321 | ***-**-*** | Nurse needs full SSN for clinical reconciliation (medication allergies tied to patient ID); Billing needs last 4 for verification; Reception needs minimal (last digit obscures) |
| **Patient Name** | Maria Gonzalez | Maria Gonzalez | Maria G. | *** | Nurse needs full name for clinical care; Billing sees first name + initial for communication without full PII; Reception sees placeholder (they call out patient names but don't need to process individually) |
| **Diagnosis** | Type 2 Diabetes | Type 2 Diabetes | Diabetes (no type) | Not displayed | Nurse needs full diagnosis for clinical decisions (Type 2 vs. Type 1 affects treatment); Billing sees disease category for insurance coding; Reception has no need—scheduling only |
| **Insurance Policy Number** | POL-987654321-A1 | POL-****321-A1 | POL-987654321-A1 | POL-****321 | Nurse needs partial (verify it exists); Billing needs full (process claims); Reception sees partial (verify account) |
| **Medication List** | Metformin 500mg, Lisinopril 10mg | Metformin 500mg, Lisinopril 10mg | *** (count: 2) | Not displayed | Nurse needs full medication list for clinical decisions; Billing sees count for drug cost estimation; Reception sees nothing (HIPAA: medication details are PHI) |

### Masking Justification Rules

**Clinical Staff (Nurses, Physicians):**
- Full data access needed for patient safety
- Treatment decisions depend on complete information
- Bound by clinical confidentiality oath
- **Masking:** Minimal to none; apply principle of "clinical necessity"

**Administrative Staff (Billing, Insurance):**
- Limited data for billing/claims processing
- Need to identify patient but not all clinical details
- Bound by administrative confidentiality agreements
- **Masking:** Full names truncated to first+initial; full SSN masked to last 4 digits; clinical details sanitized to ICD-10 codes only

**Reception/Scheduling:**
- Need to verify patient identity and schedule appointments
- No clinical or financial data necessary
- Highest turnover = highest breach risk
- **Masking:** Aggressive masking; patient ID, last 4 SSN only; no clinical or financial data

---

## PART 4: STEGANOGRAPHY AS DATA LOSS PREVENTION THREAT VECTOR

### Steganography Risk to MedDefense

Steganography represents a critical insider threat to MedDefense's data loss prevention controls because DICOM medical images are large binary files (typically 2-10MB each) that routinely flow between the central radiology department, remote clinics, and external specialists. A malicious insider with access to DICOM files could embed exfiltrated PHI (patient names, SSNs, medical history) within the image's metadata fields (DICOM Private Tags) or even the least-significant bits (LSBs) of pixel data without visibly altering the image. Traditional DLP solutions that scan for "credit card numbers" or "patient names" in transit would miss this because they monitor text-based data flows, not binary image modifications; the steganographic payload is indistinguishable from legitimate imaging data. **Detection is exceptionally difficult** because:

1. **Capacity:** A single 5MB CT scan can hide 50-100KB of PHI in its LSBs without detectable image quality loss
2. **Appearance:** The modified image passes all radiological validation (DICOM validation tools only check headers and dimensions, not pixel authenticity)
3. **Audit Gap:** Comparing the modified DICOM against the originating system is computationally expensive and rarely done; most facilities assume DICOM files are bit-identical after transmission
4. **Volume:** DICOM files flow continuously between systems as part of normal clinical workflows

**Control from 1x03 Strategy to Detect This:**

The **Data Flow Analysis control (DFA) with cryptographic integrity verification** would help detect steganographic exfiltration:

1. **Cryptographic Hashing:** Calculate and store SHA-256 hashes of all DICOM files at point of creation (PACS server)
2. **Transit Verification:** When DICOM files are transmitted to remote clinics or external specialists, verify SHA-256 hash matches original
3. **Steganography Detection:** If hash mismatches, the DICOM has been modified (either corrupted or steganographically altered); trigger investigation
4. **Continuous Monitoring:** Implement file integrity monitoring (FIM) on DICOM storage with real-time alerting if any DICOM file is modified

**Additional Mitigations:**
- Disable DICOM Private Tags (restrict metadata fields where steganography could hide data)
- Encrypt DICOM files end-to-end (encryption changes file hash, prevents undetected steganographic modification)
- Audit DICOM access logs; alert on high-volume DICOM transfers to external recipients
- Educate staff: emphasize that steganography is detectable via integrity checking

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 7-obfuscation_toolkit.md
