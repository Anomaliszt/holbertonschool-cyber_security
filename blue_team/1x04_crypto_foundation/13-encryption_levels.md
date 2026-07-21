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

---

## SUMMARY: MEDDEFENSE ENCRYPTION LEVEL MAP FOR REQUIRED STORES

### MedDefense Required Store Encryption Mapping

This section maps each of the 7 required MedDefense data stores to a specific encryption level with defensible technical rationale.

| Required Store | Encryption Level | Specific Rationale |
|---|---|---|
| **PostgreSQL Patient Database** | **Level 5 (Database-Level TDE)** | PostgreSQL Transparent Data Encryption encrypts all EHR tables at rest. Key is managed by Vault and kept separate from the database. Acceptable 10-20% query overhead for OLTP workload typical of MedDefense (~500 concurrent connections). If database server is stolen, copied, or accessed offline, patient records remain encrypted. Prevents DBA from reading plaintext EHR data. |
| **MySQL Patient Database** | **Level 5 (Database-Level TDE)** | MySQL InnoDB Transparent Encryption provides same function as PostgreSQL TDE. Use Level 5 for consistency across both database engines at MedDefense. Same Vault key management, overhead, and threat model as PostgreSQL. Both databases may coexist; encryption level is uniform (Level 5). |
| **NAS-01 Backup Storage (Network-Attached Storage)** | **Level 3 (Volume-Level LUKS)** | LUKS encrypts the entire backup volume at the block level, creating a single encryption boundary around all backup files. <3% performance overhead during backup/restore operations. Encryption key is stored in separate Vault infrastructure (not on NAS itself), preventing key leakage if NAS is stolen or physically accessed. If NAS is breached via network or operator error during restore, backup plaintext is protected by volume encryption. |
| **PACS (Picture Archiving and Communication System)** | **Level 5 (Database-Level)** | PACS imaging data is typically stored in a PACS database (Oracle, PostgreSQL, or vendor proprietary). Database-level encryption protects the full PACS dataset at rest. DICOM metadata remains queryable (plaintext in index) so radiologist searches work normally. 10-20% overhead acceptable for radiology workload (typically lower volume than clinical OLTP). Key managed in Vault. Prevents data theft if PACS server is stolen or backup is accessed. |
| **Office 365 (O365: Mailbox, SharePoint, OneDrive)** | **Level 4 (File-Level GPG Encryption)** | O365 provides vendor-managed encryption-in-transit and at-rest (Microsoft encryption keys). For MedDefense-controlled encryption of sensitive patient information sent via O365, apply client-side GPG encryption before uploading/sending. Sensitive attachments and email content are encrypted with GPG symmetric cipher before being sent through O365. MedDefense retains encryption key (separate from O365 key). Overhead is per-message (small, one-time). Prevents O365 from reading patient data if Microsoft key is compromised or subpoenaed. |
| **Clinical Laptops (Physician, Nurse, Admin Devices)** | **Level 1 (Full-Disk Encryption)** | BitLocker (Windows) or FileVault (Mac) mandatory on all clinical devices. Full-disk encryption protects cached EHR sessions, local files, authentication tokens, and temporary patient data on disk. <1% performance overhead on modern systems. If laptop is stolen, attackers cannot read any data from disk without the encryption password. Non-negotiable for HIPAA compliance and MedDefense security baseline. |
| **Device Firmware (Medical Devices: Infusion Pumps, Patient Monitors, Blood Gas Analyzers)** | **Level 1 (Built-in Device Encryption or Physical Security)** | Medical devices: Enable manufacturer-provided encrypted storage if available (most modern FDA-cleared medical devices support firmware/storage encryption). If device supports encryption, enable it (Level 1 equivalent — device manages key internally). If device does not support encryption, device security relies on physical network isolation (separate VLAN, no internet routing, no unauthorized physical access). MedDefense cannot retrofit encryption on legacy devices; vendor responsibility. Device-level encryption (if available) prevents data theft if device is decommissioned or stolen. |

---

## RATIONALE FOR ENCRYPTION LEVEL SELECTION

**Why PostgreSQL and MySQL → Level 5 (Database)?**
- Both are OLTP systems requiring frequent reads and writes on patient data
- Database-level TDE encrypts all tables uniformly (no partial coverage)
- Query performance acceptable (10-20% overhead typical for clinical systems)
- Prevents unauthorized data theft even if database file is stolen, copied, or restored offline
- Key management centralized in Vault (single source of truth for database encryption keys)
- Consistency: Both PostgreSQL and MySQL use same encryption level (Level 5), not mixed levels

**Why NAS Backups → Level 3 (Volume)?**
- Backups are large (2TB+) and infrequently accessed (restore only during disaster recovery)
- Volume-level LUKS encryption is the broadest coverage (encrypt entire backup filesystem)
- Key is NOT stored on NAS itself (critical security requirement) — stored in separate Vault infrastructure
- Prevents plaintext data exposure if:
  - NAS is physically stolen or decommissioned
  - NAS is accessed via network breach (ransomware, unauthorized admin)
  - Backup restore process is compromised
- Performance overhead (<3%) is acceptable for backup operations (not time-critical like OLTP)

**Why PACS → Level 5 (Database)?**
- PACS is database-backed (imaging metadata and references stored in DB; DICOM images may be in separate storage)
- Database-level encryption protects metadata and image references at rest
- DICOM queries on plaintext metadata ensure radiologist search/retrieve performance is unaffected
- 10-20% overhead acceptable for radiology workload (typically lower QPS than clinical notes OLTP)
- Prevents unauthorized access to imaging data if PACS server is stolen or backup is accessed

**Why O365 → Level 4 (File)?**
- O365 provides vendor-supplied encryption-in-transit and at-rest (Microsoft manages encryption keys)
- For MedDefense-controlled encryption of sensitive patient information, apply client-side GPG encryption BEFORE sending via O365
- Level 4 (file-level) is appropriate because: (1) only SENSITIVE patient info needs MedDefense encryption, (2) per-message overhead is small, (3) MedDefense retains encryption key (separate from O365 key)
- Prevents data exposure if Microsoft key is compromised, subpoenaed, or O365 infrastructure is breached
- Allows selective encryption (sensitive attachments encrypted, routine emails plaintext)

**Why Clinical Laptops → Level 1 (Full-Disk)?**
- Laptops must protect ALL data (cached EHR sessions, local files, authentication tokens, temporary patient data)
- Full-disk encryption is mandatory for clinical devices under HIPAA
- <1% performance overhead on modern systems (not a practical constraint)
- Prevents data exposure if laptop is physically stolen
- Non-negotiable baseline for MedDefense device security

**Why Device Firmware → Level 1 (Built-in or Physical Security)?**
- Medical devices are vendor-supplied and MedDefense cannot retrofit encryption
- For devices that support manufacturer-provided encryption, enable it (equivalent to Level 1)
- For devices without encryption support, rely on physical network isolation (separate VLAN, no internet)
- Device encryption (if available) prevents data theft if device is decommissioned or stolen
- No MedDefense-controlled encryption applied (vendor responsibility and device capability dependent)

---

## CONCLUSION: ONE-TO-ONE MAPPING FOR REQUIRED STORES

MedDefense required stores are mapped as follows:

1. **PostgreSQL Patient Database** → Level 5 (Database TDE)
2. **MySQL Patient Database** → Level 5 (Database TDE)
3. **NAS-01 Backup Storage** → Level 3 (Volume LUKS)
4. **PACS** → Level 5 (Database)
5. **Office 365** → Level 4 (File-level GPG)
6. **Clinical Laptops** → Level 1 (Full-Disk BitLocker/FileVault)
7. **Device Firmware** → Level 1 (Built-in or Physical Security)

Each store has a single recommended encryption level with clear technical justification. This one-to-one pairing provides defensible encryption coverage for all required MedDefense data stores.

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

