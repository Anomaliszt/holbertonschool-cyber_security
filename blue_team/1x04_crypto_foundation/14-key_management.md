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

### Access Control (Role-Based)

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

