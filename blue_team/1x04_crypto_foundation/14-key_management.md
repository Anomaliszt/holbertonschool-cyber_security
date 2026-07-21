Goal: Evaluate TPM, HSM and secure enclave technologies, and design a key management strategy for MedDefense that solves the "where do you keep the keys ?" problem.

Context: Every encryption scheme has a fatal weakness: the key. If you encrypt 50,000 patient records with AES-256 and store the key in a plaintext configuration file on the same server, you have not actually protected anything. You have added a speed bump.

Sec+ 1.4 identifies three hardware security technologies designed to solve this problem: TPM (Trusted Platform Module), HSM (Hardware Security Module) and secure enclaves. Each operates at a different scale and cost, and MedDefense needs to choose which is appropriate for its budget and risk profile.

---

## PART 1: HARDWARE SECURITY TECHNOLOGY COMPARISON

| Technology | What It Is | What It Protects | Typical Cost | Typical Deployment |
|---|---|---|---|---|
| **TPM (Trusted Platform Module)** | Dedicated microchip on motherboard; executes cryptographic operations in isolated secure processor; FIPS 140-2 Level 2 certified | Boot integrity (measured boot), disk encryption keys (BitLocker recovery), local authentication keys | $0-100 (included in enterprise laptops/servers) | Every enterprise laptop (all Windows 10/11 devices have TPM 2.0); physical servers with TPM 2.0 module |
| **HSM (Hardware Security Module)** | Dedicated physical appliance (standalone device or card) with cryptographic processor; stores keys in tamper-resistant hardware; FIPS 140-2 Level 3 certified | High-volume key storage and cryptographic operations; encryption keys for databases, VPN, code signing; protects against logical attacks AND physical tampering | $5,000-50,000+ per device | Central key management servers; compliance-critical systems (certificate authorities, payment processors, healthcare providers); one HSM can manage keys for entire organization |
| **Secure Enclave** | Isolated processor on same die as main CPU (Apple Secure Enclave, Intel SGX, ARM TrustZone); executes code in protected memory area inaccessible to main OS | Application-level secrets (biometric data, payment tokens, encryption keys); isolated from main OS compromise | $0-500 (built into processors; no additional cost) | Mobile devices (iPhone, Android), modern laptops (Apple Silicon Macs), some IoT devices; newer Windows 11 PCs (Pluton) |
| **KMS (Software Key Management System)** | Software service running on secured server (e.g., HashiCorp Vault, AWS KMS, Azure Key Vault); manages keys centrally; NOT a hardware device | Key storage and distribution; audit logging; key rotation policies; integration with applications | $10,000-100,000/year (cloud-based pricing) or on-premises deployment costs | Cloud-based (AWS KMS, Azure Key Vault, Google Cloud KMS) or on-premises (Vault, Thales CipherTrust); central key repository for all organization services |

### When to Use Each Technology

- **TPM:** Protect laptop/desktop keys; BitLocker encryption of employee devices; Windows Hello authentication; cost-effective for distributed endpoints
- **HSM:** Highest security requirement for sensitive keys (database encryption, VPN, certificate signing); compliance mandatory (SOC 2, PCI-DSS, HIPAA); centralized key management for large organizations
- **Secure Enclave:** Mobile and embedded devices; application-specific protection (biometrics, payment tokens); transparent to user
- **KMS (Software):** Centralized key management at scale; cloud-native; compliance-friendly audit trails; easier to rotate keys across many services

---

## PART 2: MEDDEFENSE KEY MANAGEMENT PLAN

### Key Inventory

| System | Key Type | Current State | Purpose |
|---|---|---|---|
| Patient Database (ehr-db-01) | PostgreSQL TDE Key | NOT YET IMPLEMENTED | Encrypt all patient medical records at rest on disk |
| Backup Data (NAS-01) | Volume Encryption Key | NOT YET IMPLEMENTED | Encrypt RAID volume containing all backups |
| Portal TLS (portal.meddefense.local) | TLS Private Key (ECC P-256) | Exists, not protected | Server certificate for patient portal HTTPS |
| VPN Tunnel (Central ↔ Westside) | IPSec IKE Pre-shared Key | Exists, not rotated | IKEv2 Diffie-Hellman shared secret |
| VPN Tunnel (Central ↔ HQ) | IPSec IKE Pre-shared Key | Exists, not rotated | IKEv2 Diffie-Hellman shared secret |
| Email (O365) | Microsoft-managed key | O365 provider | Per-mailbox encryption |

### Storage Locations

**For Patient Database Encryption Key (PostgreSQL TDE):**
- **Primary:** HashiCorp Vault on secure on-premises server with PostgreSQL AppRole access
- **Backup:** Daily backup to offline USB HSM in physical vault
- **Why external?** If database server compromised, attacker cannot extract key

**For Backup Volume Encryption Key (NAS Encryption):**
- **Primary:** External HSM in physical vault (off-site), brought online only during backup window
- **Why external?** If NAS is ransomware-encrypted, key cannot be encrypted
- **Backup:** Paper backup of HSM recovery codes in bank safety deposit box

**For Portal TLS Private Key:**
- **Primary:** Hardware security module (Luna HSM) in data center
- **Backup:** Encrypted USB backup in vault (encrypted with separate key)
- **Why HSM?** Web server compromise cannot extract key

**For VPN Pre-shared Keys:**
- **Primary:** Encrypted FortiGate configuration files
- **Master Key:** Built-in FortiGate HSM or separate HSM
- **Backup:** Encrypted configuration backup

---

## PART 3: FINANCIAL AND RISK JUSTIFICATION FOR HSM DEPLOYMENT

### Risk Analysis: Key Compromise Impact

**Scenario 1: PostgreSQL TDE Key Compromised (Vault-Only, No HSM)**

| Impact Factor | Consequence | Annual Likelihood | Impact per Incident |
|---|---|---|---|
| **Attacker reads entire database** | 180,000 patient records exposed; HIPAA breach notification mandated | 15% (database vulnerability exists; no physical key protection) | $4.5M breach costs (180K records × $25/record HIPAA penalty minimum) |
| **Regulatory fines** | HIPAA fine range $100-$50K per patient per violation | N/A | $500K-$900M (worst case) but typical $4.5M |
| **Operational downtime** | Re-encryption required; database offline 4-8 hours | Per incident | $8K-12K (clinical staff downtime, lost revenue) |
| **Class action lawsuits** | Patients sue for identity theft, credit monitoring | Probable if breach confirmed | $500K-$2M settlement |
| **Incident response + forensics** | Breach investigation, legal, regulatory notifications | Per incident | $150K-$300K |
| **Reputation damage** | Loss of patient trust; migration to competitors | Per incident | 5-10% patient loss = $200K-$400K annual revenue impact |
| **Total per incident** | Comprehensive impact | - | **$5.4M - $7.2M** |

**Annual Loss Expectation (ALE) without HSM:**
```
ALE = Likelihood × Impact
ALE = 15% × $6.3M (midpoint) = $945,000/year
```

**Scenario 2: PostgreSQL TDE Key Compromised (With HSM Protection)**

| Impact Factor | Consequence | Annual Likelihood | Impact per Incident |
|---|---|---|---|
| **Attacker cannot extract key from HSM** | Attack fails; no database compromise | 1% (HSM makes extraction impractical; attacker needs physical device theft + sophisticated tampering) | $0 (no data breach) |
| **HSM itself is stolen/compromised** | Unlikely; HSM is physical device in locked data center; FIPS 140-3 hardware zeroizes keys on tamper detection | 0.5% (very rare; requires physical theft) | $6.3M if successful |
| **Alternative: Logical attack on Vault** | Attacker compromises Vault software (not HSM hardware); still cannot extract key without HSM hardware cooperation | 5% (Vault breach more likely than HSM compromise) | $6.3M if successful |
| **Total vulnerability surface** | Reduced from "logical compromise = game over" to "physical theft + tampering required" | - | - |

**Annual Loss Expectation (ALE) with HSM:**
```
ALE = (1% × $6.3M) + (0.5% × $6.3M) + (5% × $6.3M)
ALE = $63K + $31.5K + $315K = $409,500/year
```

**ALE Reduction:**
```
ALE Savings = $945K - $409.5K = $535,500/year
```

---

### Cost-Benefit Analysis: HSM Investment Justification

**HSM Deployment Costs (Luna HSM or Thales CloudHSM):**

| Cost Category | Amount | Notes |
|---|---|---|
| **Hardware (Luna HSM)** | $15,000 | One-time; supports up to 100,000 keys |
| **Licensing** | $3,000/year | Thales licensing; support + updates |
| **Setup + Integration** | $8,000 | Professional services to integrate with Vault, PostgreSQL, TLS infrastructure |
| **Annual Maintenance** | $2,000 | Support contract, firmware updates, monitoring |
| **Backup HSM (redundancy)** | $15,000 (one-time) | Second HSM for failover (recommended for healthcare) |
| **Network/Facilities** | $2,000 | Dedicated power, network, secure enclosure |
| **Staff Training** | $1,000 | DBA/Security training on HSM operations |
| **Total Year 1** | **$46,000** | Initial investment |
| **Total Year 2+** | **$5,000/year** | Ongoing licensing + maintenance |

**Alternative: Cloud HSM (AWS CloudHSM, Azure Key Vault with HSM)**

| Cost Category | Amount | Notes |
|---|---|---|
| **AWS CloudHSM** | $3,650/month × 2 HSMs (HA) | Managed service; automatic failover |
| **Annual (AWS CloudHSM)** | **$87,600** | High availability, outsourced management |
| **Azure Key Vault Premium** | $1/key/month × 50 keys | Simpler but less control than dedicated HSM |
| **Annual (Azure)** | **$600** | Budget option; sufficient for small deployments |

**MedDefense Recommendation:** On-premises Luna HSM (one-time $46K + $5K/year) provides better economics and control than cloud HSM for healthcare.

**Cost-Benefit Calculation:**

```
Year 1 Payback Analysis:
  ALE Reduction (HSM vs. Vault-only) = $535,500/year
  HSM Deployment Cost (Year 1)       = $46,000
  Net Benefit (Year 1)               = $535,500 - $46,000 = $489,500

  Payback Period:   46,000 / 535,500 = 0.086 years ≈ 31 days

  Year 2+ Benefit:  $535,500 - $5,000 = $530,500/year
```

**Return on Investment (ROI):**
```
ROI Year 1 = (489,500 / 46,000) × 100 = 1,064%
ROI Year 2+ = (530,500 / 5,000) × 100 = 10,610%
```

**Conclusion:** HSM investment is justified by risk reduction alone in **less than one month**. Even if likelihood estimates are off by 50%, HSM still provides $265K+ annual savings.

---

### Comparative Risk Profiles

| Technology | Security Level | Annual Breach Risk | ALE without HSM | ALE with Technology | Cost/Year | Cost-Benefit |
|---|---|---|---|---|---|
| **Vault (Software KMS only)** | Medium | 15% | $945K | $945K (no reduction) | $10K-20K | Baseline (no HSM benefit) |
| **Vault + Luna HSM** | High | 1-5% | $945K | $409.5K | $46K (Y1) + $5K (ongoing) | $535K ALE reduction; 31-day payback |
| **Cloud HSM (AWS)** | High | 1-5% | $945K | $409.5K | $87.6K/year | Same ALE reduction; higher cost |
| **Vault + TPM (laptop/endpoint keys)** | Medium | 10% | $600K (laptop keys only) | $540K | $0 (TPM built-in) | Good for endpoints; inadequate for servers |
| **KMS-only (no HSM, no Vault)** | Low | 30% | $1.9M | $1.9M | $15-30K/year | High risk; not recommended for healthcare |

**MedDefense Recommendation:**
- **PostgreSQL TDE Key & Backup Keys:** Luna HSM (on-premises, dedicated)
- **Portal TLS Private Key:** Luna HSM (same device)
- **VPN Pre-shared Keys:** FortiGate with built-in HSM or separate HSM
- **Laptop/Endpoint Keys:** TPM 2.0 (cost-free, built-in)
- **Supporting infrastructure:** HashiCorp Vault for centralized key management + audit logging

---

| Role | Keys Can Access | How | Approval |
|---|---|---|---|
| **Database Administrator** | PostgreSQL TDE Key (indirect) | AppRole from PostgreSQL server | ✅ Automatic via authenticated credentials |
| **Senior DBA / Vault Admin** | All keys (through Vault) | Vault console with MFA | ✅ Dual control (2 people) for emergency access |
| **Network Administrator** | VPN Pre-shared Keys | FortiGate admin account | ✅ Ticket approval + logging |
| **IT Security Lead** | All keys (audit/emergency) | Direct HSM access (3-person escrow split) | ✅ 2-of-3 escrow officer approval + documentation |
| **Backup Administrator** | NAS Encryption Key | Physical HSM possession | ✅ Authorized backup window only, logged |
| **Clinical Staff** | NO KEYS | No access | N/A—data transparent to users |
| **External Auditors** | No active access | Read-only audit logs from Vault | ✅ Reviewed during compliance audits |

**Principle of Least Privilege:** Each role has access only to keys needed for their job.

**Dual Control:** Database encryption key and HSM access require two different people to authorize (prevents single insider threat).

### Key Rotation Schedule

| Key | Rotation Frequency | Trigger | Procedure |
|---|---|---|---|
| **PostgreSQL TDE Key** | Every 1 year or on compromise | Calendar date (Jan 1) or security incident | 1. Generate new key in Vault; 2. Re-encrypt database; 3. Archive old key for 7 years |
| **NAS Volume Key** | Every 1 year or replacement | Calendar date or NAS replacement | 1. Bring old volume online; 2. Create new volume with new key; 3. Migrate backups |
| **TLS Private Key** | Every 1 year (per cert expiration) | Certificate renewal cycle | 1. Generate new ECC P-256 key; 2. Submit CSR to CA; 3. Deploy new cert+key; 4. Archive old key |
| **VPN PSK** | Annually (upgrade from 3-year) | Network change or annual review | 1. Generate new key; 2. Update both endpoints simultaneously; 3. Test tunnel; 4. Document in Vault |

### Compromise Response Procedures

**PostgreSQL TDE Key Compromised:**
1. **Hour 0:** Shut down ehr-db-01; disable remote access; notify CMO
2. **Hour 0-4:** Re-encrypt entire database with new key (AES-256); time estimate: 4-8 hours depending on size
3. **Day 1:** Audit access logs; forensic investigation; implement corrective actions
4. **Compliance:** Report to Compliance Officer; HIPAA breach notification if data exfiltrated

**VPN PSK Compromised:**
1. **Hour 0:** Verify tunnel integrity; generate new PSK on FortiGate; update both endpoints
2. **Hour 1:** Test tunnel with new key; verify connectivity
3. **Analysis:** Check logs for suspicious traffic; verify no patient data accessed

### Emergency Access Procedure (Break Glass)

**Scenario:** Database down, keys inaccessible, patients waiting for treatment.

1. **Two escrow officers unlock key retrieval** with MFA video call
2. **IT Security Lead retrieves emergency key** from Vault
3. **Database restarts** using emergency key
4. **Post-recovery:** Mandatory audit of emergency key access

**Maximum acceptable downtime before emergency override:** 30 minutes. After 30 minutes without database, patient safety compromised; emergency authorized.

