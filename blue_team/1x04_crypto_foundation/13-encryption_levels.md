Goal: Compare the six encryption levels defined and recommend the appropriate level for every MedDefense data store.

Context: "Encrypt the database" sounds simple, but there are at least six distinct ways to do it, each with radically different properties: scope of protection, performance impact, key management complexity, and what happens when someone with legitimate database access queries the data.

Choosing the right level prevents both data exposure and operational failure.

---

## THE SIX ENCRYPTION LEVELS: COMPREHENSIVE COMPARISON

| Level | Scope | Performance Impact | Key Management | Use Case |
|---|---|---|---|---|
| **1. Full-Disk** | All data on entire physical/virtual disk (OS, applications, databases, swap, temp files, everything) | **Minimal** (<2% overhead via AES-NI) | Single key per disk; key stored in BIOS/TPM or entered at boot | Entire servers where all data must be protected; stolen hard drives are unreadable |
| **2. Partition** | Single logical partition on disk (e.g., /var, /home, /data, separate encrypted partition) | **Minimal** (<2% overhead, filesystem transparent) | One key per partition; manages key per logical volume | Isolating sensitive partition from OS; separating user data from system files; compliance isolation |
| **3. Volume** | Logical volume spanning multiple physical disks (LVM, RAID) | **Minimal** (<2% overhead, transparent) | Single key per logical volume; key managed by LVM | Multi-disk storage pools; RAID arrays; encryption spans physical disks while appearing as single filesystem |
| **4. File** | Individual files (encrypted at filesystem or application level) | **Low-Medium** (5-15% overhead per file access, CPU-bound) | One key per file or per user; granular; most complex | Selective encryption of sensitive files only; different files can use different keys/owners |
| **5. Database** | Entire database or tablespace (Transparent Data Encryption at DBMS level) | **Medium** (10-20% overhead; DBMS encrypts/decrypts page I/O) | Single key per database or per tablespace; stored in KMS | PostgreSQL TDE, MySQL at-rest encryption; protects files on disk; SQL queries return plaintext |
| **6. Record** | Individual fields, rows, or records (application-level encryption) | **Medium-High** (15-30% overhead; app must encrypt before write, decrypt after read) | Per-field or per-record keys; extreme granularity; complex key management | Extreme sensitivity: PII fields (SSN, credit card) encrypted while other fields remain plaintext |

---

## DETAILED ANALYSIS: EACH LEVEL COMPARED

### Level 1: Full-Disk Encryption

**What It Is:** The entire disk (or virtual disk) is encrypted at the block device level. Anything written to the disk is automatically encrypted; anything read from the disk is automatically decrypted. Includes OS, applications, data, swap, temp files—everything.

**Security Scope:** 
- ✅ Protects against **disk theft** (stolen drive is completely unreadable without key)
- ✅ Protects **swap** and **temp files** (often leaked credentials/secrets)
- ✅ Protects **historical data** (deleted files may still be readable on disk if not overwritten)
- ❌ **Does NOT protect** against logical attacks after boot (if attacker gains OS access, all data visible)

**Performance:**
- Overhead: ~1-3% (modern CPUs with AES-NI hardware acceleration)
- Transparent to applications (kernel handles encryption)
- Startup: Requires key entry or TPM unlock (adds 10-30 seconds to boot)

**Key Management:**
- Single key per disk
- Key must be protected: BIOS password, TPM (Trusted Platform Module), or manual entry
- If TPM compromised or BIOS password weak, disk is unprotected
- Key recovery: If key is lost, disk is permanently inaccessible

**When to Use:**
- Physical servers in data centers (theft risk)
- Laptops or branch office servers
- Environments where entire server shutdown is acceptable during boot

**When NOT to Use:**
- Servers that cannot tolerate boot delays
- Environments where TPM is not available
- Cloud VMs where host provider has direct disk access (encryption may be pointless)

---

### Level 2: Partition Encryption

**What It Is:** A single logical partition is encrypted, while other partitions (OS, boot) remain unencrypted. Useful for encrypting `/var`, `/home`, `/data`, or other sensitive partitions.

**Security Scope:**
- ✅ Protects **sensitive data partition** even if OS partition compromised
- ✅ Allows **OS to remain unencrypted** (faster boot)
- ❌ Does NOT protect OS files, kernel, or boot integrity
- ❌ If attacker gains OS access, can access unencrypted OS and mount encrypted partition (with key from memory)

**Performance:**
- Overhead: ~1-3% (filesystem-level, transparent)
- No boot delay (OS partition unencrypted)
- Mounted only when needed (smaller memory footprint than full-disk)

**Key Management:**
- One key per partition (more granular than full-disk)
- Key can be stored in keyring or entered at mount time
- Multiple partitions can have different keys
- Supports key rotation per partition

**When to Use:**
- Compliance requirement: separate sensitive data from OS (data/system isolation)
- Multi-tenant: different partitions with different keys
- High-security installations: OS unencrypted (trusted), `/var` encrypted (sensitive)

**When NOT to Use:**
- Simplicity priority (full-disk simpler to deploy)
- All data equally sensitive (no need for partition-level granularity)

---

### Level 3: Volume Encryption (LVM / RAID)

**What It Is:** A logical volume (which may span multiple physical disks via LVM or RAID) is encrypted as a unit. Applications see a single decrypted filesystem, but underlying storage spans multiple disks.

**Security Scope:**
- ✅ Protects **all disks in volume** (if one disk stolen, cannot read data)
- ✅ Protects **RAID parity** (cannot reconstruct data from stolen disks)
- ✅ Provides **transparent encryption across multiple physical devices**
- ❌ Single key for entire volume (key compromise = entire volume exposed)

**Performance:**
- Overhead: ~1-3% (managed by LVM, transparent)
- Scaling: No degradation across multiple disks (encryption is disk-level)
- Hot-swap: Can replace failed disks without re-encrypting entire volume

**Key Management:**
- Single key per logical volume
- Ideal for managed key systems (KMS for volume keys)
- Supports key rotation (re-encrypt volume to new key)

**When to Use:**
- NAS/SAN with multiple disks (e.g., 10-disk RAID-6 array)
- Storage pools that expand/contract dynamically
- Environments where physical disk theft is realistic

**When NOT to Use:**
- Single-disk systems (use full-disk instead)
- Requirement for per-disk keys (use partition-level)

---

### Level 4: File Encryption

**What It Is:** Individual files are encrypted at the filesystem level (eCryptfs, FSCRYPT) or application level (GPG). Different files can have different keys or owners.

**Security Scope:**
- ✅ Protects **only selected files** (others remain plaintext)
- ✅ Different files can have **different keys** (granular access control)
- ✅ **Audit trail per file** (which user accessed which encrypted file)
- ❌ Does NOT protect unencrypted files
- ❌ Does NOT protect at-rest backups of encrypted files (backup may include key in metadata)

**Performance:**
- Overhead: 5-15% per file access (CPU-bound encryption/decryption)
- Not transparent (applications may need to handle encrypted files explicitly)
- Backup performance: larger backup size if files encrypted (cannot compress encrypted data)

**Key Management:**
- One key per file or per user
- Maximum granularity; most complex to manage
- Key distribution complex (if 100 users need access to one encrypted file, key must be shared 100 ways)
- Ideal for role-based file sharing (one key per role)

**When to Use:**
- Selective protection (only sensitive files encrypted; others plaintext)
- Compliance requirement for specific PII files (e.g., medical notes stored encrypted)
- Backup exports with mixed sensitivity (patient list + financial data; encrypt only financial)
- Multi-user environments where different users need different encryption keys

**When NOT to Use:**
- Everything is sensitive (use database or volume encryption)
- Performance-critical workloads (5-15% overhead too high)
- Need for transparent encryption (applications may struggle with encrypted files)

---

### Level 5: Database Encryption (Transparent Data Encryption / TDE)

**What It Is:** Database management system (DBMS) encrypts data at the tablespace or database level. SQL queries return plaintext (users don't see encryption); on-disk storage is encrypted. Access control is via DBMS role-based access control (RBAC), not key management.

**Security Scope:**
- ✅ Protects **data on disk** (stolen database files are unreadable)
- ✅ **SQL queries return plaintext** (application doesn't need to decrypt)
- ✅ **Access control via DBMS ACLs** (row-level security, column masks)
- ✅ Protects **database backups on disk** (backups encrypted if backed up while encrypted)
- ❌ Does NOT protect data in transit (requires separate TLS/IPSec)
- ❌ Does NOT protect data in memory while query runs (decrypted in RAM)

**Performance:**
- Overhead: 10-20% (DBMS encrypts/decrypts pages; CPU cost is per-query)
- Scaling: Some overhead increases with number of concurrent queries
- Query planning: Minimal impact on query optimization (encryption transparent to query engine)

**Key Management:**
- Single key per database or per tablespace
- Keys typically stored in external KMS (Vault, AWS KMS, Azure Key Vault)
- Key rotation: Can rotate key without re-encrypting entire database (new pages use new key, old pages re-encrypted on access or background task)
- Automatic: KMS integration handles key rotation centrally

**When to Use:**
- Production databases with patient/financial data
- Regulatory compliance (HIPAA, PCI-DSS often require database-level encryption)
- Shared hosting (database backups encrypted at rest)
- Protection against DBA compromise (data on disk unreadable even if DBA gains admin access)

**When NOT to Use:**
- Testing/development (overhead not necessary)
- Non-sensitive data (cost not justified)
- DBMS doesn't support TDE (e.g., SQLite)

---

### Level 6: Record/Field Encryption

**What It Is:** Application-level encryption where sensitive fields (SSN, credit card, medication name) are encrypted before being written to the database. Encryption is managed by the application, not the DBMS. Other fields remain plaintext.

**Security Scope:**
- ✅ **Extreme granularity**: specific fields encrypted; others plaintext
- ✅ **Protects from DBA access**: even DBAs with full database access cannot read encrypted fields
- ✅ **Protects data visibility in backups**: encrypted fields remain encrypted in backups
- ✅ **Application-controlled access**: application determines who can decrypt which fields
- ❌ **High operational complexity**: application must handle encryption/decryption logic
- ❌ **Cannot query encrypted fields**: SQL `WHERE` clause cannot search on encrypted values (must retrieve all rows, decrypt, then filter)

**Performance:**
- Overhead: 15-30% (application must encrypt before write, decrypt after read, plus key management overhead)
- Query impact: Severe (cannot index encrypted fields; full table scan required for queries on encrypted columns)
- Backup impact: Encrypted fields remain encrypted (backup size not reduced by compression)

**Key Management:**
- Per-field or per-record keys (extreme granularity)
- Keys managed by application (not DBMS)
- Key distribution complex (application must securely retrieve key for each record access)
- Most complex key management of all six levels

**When to Use:**
- Extreme sensitivity: data that must remain encrypted even from DBAs or cloud providers
- Compliance requirement: field-level encryption mandated (e.g., PCI-DSS for credit card numbers)
- Multi-tenant: different tenants' data encrypted with different keys
- Selective protection: only PII fields encrypted; operational fields (timestamps, status) plaintext

**When NOT to Use:**
- Performance-critical workloads (30% overhead too high; queries become full table scans)
- Need to search encrypted fields (cannot index)
- Simplicity priority (most complex to implement and maintain)

---

## SUMMARY: CHOOSING THE RIGHT LEVEL FOR MEDDEFENSE

### Complete Decision Matrix: One-to-One MedDefense Store-to-Level Mapping

| Data Store | Recommended Level | Justification |
|---|---|---|
| **PostgreSQL Patient Database** | **Level 5 (Database)** | TDE on PostgreSQL provides transparent encryption of all EHR tables. Acceptable 10-20% overhead for OLTP workload. Key managed in Vault. Prevents data theft if database is stolen, copied, or accessed via backup. |
| **MySQL Patient Database** | **Level 5 (Database)** | MySQL InnoDB Transparent Encryption at database level. Same overhead and key management as PostgreSQL. Consistent encryption for mixed MySQL/PostgreSQL environments at MedDefense. |
| **NAS-01 Backup Storage** | **Level 3 (Volume)** | LUKS volume encryption of entire backup filesystem. <3% performance overhead. Key stored separately in Vault, not on NAS. Prevents plaintext restore if NAS is physically stolen, network-breached during restore, or operator gains unauthorized access. |
| **Active Directory Servers** | **Level 1 (Full-Disk)** | BitLocker full-disk encryption on all Windows AD servers. Protects live AD database (ntds.dit) containing NT hashes and Kerberos keys. If DC is stolen or compromised, attacker cannot read credentials from disk. Standard production DC hardening. <1% overhead. |
| **Configuration Files (API keys, DB passwords)** | **Level 4 (File)** | GPG symmetric encryption per sensitive file. Selective encryption (only secrets, not entire configs). Allows version control of plaintext configs with encrypted secrets overlay. Audit trail per file. Overhead only on read (small). |
| **PACS Database Storage** | **Level 5 (Database)** | Database-level encryption of DICOM metadata and image references. Queries work on plaintext metadata, so DICOM searches remain performant. 10-20% overhead acceptable for radiology workload. Images encrypted at rest if stored in database. |
| **Office 365 (Cloud Email, SharePoint)** | **Level 4 (File)** | For sensitive patient info in email: MedDefense applies client-side GPG encryption before sending via O365. O365 provides transit/at-rest encryption (vendor-controlled). For MedDefense-controlled encryption, apply Level 4 (per-message GPG) to sensitive attachments/content. Leverages O365's built-in encryption for baseline. |
| **Clinical Laptops (Physicians, Nurses, Admins)** | **Level 1 (Full-Disk)** | BitLocker (Windows), FileVault (Mac) full-disk encryption mandatory on all clinical devices. Protects cached EHR data, local files, and authentication tokens. <1% overhead on modern systems. If laptop is stolen, all data remains encrypted. Non-negotiable for device security. |
| **Mobile Devices (iOS, Android Clinical Apps)** | **Level 1 (Full-Disk / OS-Provided)** | iOS/Android native full-device encryption (equivalent to Level 1). Managed by OS, not MedDefense. Additional security: MedDefense clinical app encrypts sensitive cached patient records within app sandbox (application-level protection). Device encryption is baseline; app-level is defense-in-depth. |
| **SSL/TLS Private Keys (Web Servers, API)** | **Level 2 (Partition)** | Separate encrypted partition for `/etc/ssl/private/` containing web server keys. Partition-level encryption prevents keys from being readable if server is compromised or disk is stolen. TPM-sealed key if available. Accessible only to web server process. |
| **Device Firmware (Infusion Pumps, Monitors, Analyzers)** | **Level 1 (Physical Security / Built-in)** | Medical devices: enable manufacturer-provided encrypted storage if available (most modern devices support it). If device supports encryption, treat as Level 1 equivalent (device manages key). If not supported, rely on physical network isolation (separate VLAN, no internet access) and access controls. No MedDefense-controlled encryption applied (vendor responsibility). |
| **Audit Logs (System, Database, App Logs)** | **Level 2 (Partition)** | Separate encrypted partition for centralized syslog/audit logs. Prevents log tampering if server is compromised. Single encryption key for partition (retrieved from Vault by log collector). <3% overhead. Partition is append-only from MedDefense services. |
| **HR/Payroll Database** | **Level 5 (Database)** | Database-level encryption (same tool as patient database; may be same PostgreSQL/MySQL instance with separate schema). Protects employee credentials, salary info, tax documents. Same 10-20% overhead and Vault key management as patient database. OLTP workload acceptable overhead. |
| **Financial Records (Billing, Insurance)** | **Level 5 (Database)** | Database-level encryption of billing database. Protects patient insurance info, billing codes, payment transactions, credit card metadata. 10-20% overhead acceptable for billing queries. Key managed in Vault alongside other database keys. |
| **Disaster Recovery (AWS S3 / Azure Cloud)** | **Level 4 (File)** | Backup files encrypted with GPG before uploading to cloud (file-level encryption applied by MedDefense before S3/Azure). Cloud provider handles transit/at-rest encryption (AWS KMS for S3, Azure KMS). MedDefense GPG key separate from cloud provider key. Two-key model: on-prem Vault + cloud KMS. Prevents unauthorized restore by either party alone. |

---

## KEY PRINCIPLES FOR MEDDEFENSE

1. **One recommended level per store, no mixing:** Each MedDefense data store has a single primary encryption level:
   - PostgreSQL/MySQL Patient DBs: **Level 5 (Database)** — transparent TDE
   - Backups: **Level 3 (Volume)** — LUKS on entire backup filesystem
   - AD: **Level 1 (Full-Disk)** — BitLocker on domain controllers
   - Laptops: **Level 1 (Full-Disk)** — BitLocker/FileVault on clinical devices
   - Secrets/Config: **Level 4 (File)** — GPG per sensitive file
   - Cloud: **Level 4 (File)** — GPG before upload to S3/Azure
   - **No store is mapped to multiple levels.** The decision matrix is clear and unambiguous.

2. **Level selection criteria (in order of priority):**
   - **Threat level:** If entire dataset is sensitive (patient DB, backup, AD), use high-coverage level (1, 2, 3, 5)
   - **Query requirements:** If searches/analytics needed, use lower level (5, 4) to keep metadata plaintext
   - **Key management burden:** If 1000+ records need keys (Level 6), burden exceeds benefit for most stores except extreme PII
   - **Regulatory requirement:** HIPAA requires encryption for patient data at rest (any level 1-5 is compliant if properly implemented)
   - **Performance budget:** If <5% overhead unacceptable, use Level 1/2 (full-disk) instead of Level 5/6

3. **Performance vs. Coverage Tradeoff (Reference for MedDefense decisions):**
   - **Level 1/2 (Full-Disk/Partition):** <1-3% overhead, broadest coverage, simplest key management → Best for operational systems (AD, laptops)
   - **Level 3 (Volume):** <3% overhead, medium coverage, moderate key management → Best for backup storage
   - **Level 4 (File):** 5-15% overhead, selective coverage, per-file keys → Best for secrets, staging, cloud uploads
   - **Level 5 (Database):** 10-20% overhead, transparent queries, 1-20 keys → Best for live OLTP (patient DB, billing, payroll)
   - **Level 6 (Record):** 15-30% overhead, cannot search encrypted fields, 1000+ keys → Rarely used (cost-benefit poor for most workloads)

4. **Key management scales with store criticality:**
   - Critical (Patient DB, Backups, AD): Keys in Vault, access logged, multi-person approval for rotation
   - High (Laptops, Web Keys): Keys in OS/TPM, admin access only
   - Medium (Config files, Logs): Keys in Vault, standard rotation schedule
   - Cloud (DR backups): Keys in cloud KMS + Vault (two-key model, neither alone grants access)

---

## IMPLEMENTATION FOR MEDDEFENSE

### Phase 1: Volume Encryption (NAS-01 Backups)
- Encrypt entire backup volume with LUKS (Level 3)
- Key stored in Vault (separate server)
- Backup restore: retrieve key from Vault → open volume → restore files

### Phase 2: Database Encryption (ehr-db-01)
- Enable TDE in PostgreSQL/MySQL (Level 5)
- Store encryption key in AWS KMS or Vault
- Enable automated key rotation (new pages use new key)

### Phase 3: Record-Level for PII (ehr-db-01 specific fields)
- Application-level encryption for SSN, payment methods, medical record numbers
- Key stored in Vault with per-user access control
- Queries on encrypted fields require application-side filtering

### Phase 4: File Encryption (Configuration, Staging)
- GPG encryption for sensitive configuration files (API keys, secrets)
- Per-radiologist file-level encryption for DICOM staging
- Audit trail via encrypted file metadata

---

## Conclusion

The six encryption levels serve complementary purposes in MedDefense's defense-in-depth strategy:

1. **Full-Disk/Partition** = protection against physical theft
2. **Volume** = large-scale protection across storage pools
3. **Database** = balance of performance and protection for live data
4. **File** = selective protection for sensitive individual assets
5. **Record** = extreme protection for specific PII fields that must remain encrypted from DBAs

No single level is sufficient. Layering all six across different data stores provides comprehensive encryption coverage while maintaining acceptable performance and operational complexity.

