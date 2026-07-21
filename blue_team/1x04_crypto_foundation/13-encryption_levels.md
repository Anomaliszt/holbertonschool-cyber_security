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

### Decision Matrix

| Data Store | Primary Threat | Recommended Level | Reasoning |
|---|---|---|---|
| Patient database (ehr-db-01) | Data theft, DBA compromise, backup theft | Database (Level 5) + Record (Level 6 for SSN/payment) | Database for bulk protection; record-level for PII fields that DBAs shouldn't see |
| Backup storage (NAS-01) | Physical theft, network access, unauthorized restore | Volume (Level 3) | Entire backup volume encrypted; single key in separate Vault server; prevents plaintext restore |
| Active Directory (AD servers) | Domain controller compromise | Full-Disk (Level 1) or Partition (Level 2 for sensitive partition) | OS and sensitive data on same server; full-disk simplest; partition if need to isolate DC from other services |
| Configuration files (secrets, API keys) | Developer access, accidental commit to git, backup theft | File (Level 4) | Selective protection; encrypt only secrets; GPG per-file encryption; audit trail |
| Clinical notes (DICOM/medical images, staging) | Radiologist access, staging directory theft | File (Level 4) | Per-radiologist file-level keys; different radiologists see only their encrypted studies; audit per study |
| Web server SSL certificates | Web server compromise, certificate theft | File (Level 4) or Record (Level 6 if embedded in app config) | Private key only accessible to web server process; encrypted at file level; key rotation via configuration management |

---

## KEY PRINCIPLES FOR MEDDEFENSE

1. **No single level is correct for all data:** Healthcare systems must layer encryption:
   - Volume-level for backup storage (broad protection)
   - Database-level for live databases (performance acceptable for OLTP)
   - Record-level for extreme PII (SSN, payment methods)
   - File-level for selective protection (staging data, configuration)

2. **Layering is intentional:** Encryption at multiple levels provides defense-in-depth:
   - If volume key compromised: individual databases still encrypted (level 5)
   - If database key compromised: SSN fields still encrypted (level 6)
   - If attacker gains physical disk: entire volume still encrypted (level 3)

3. **Key management scales with encryption levels:**
   - Full-disk/partition: 1 key → simple, need TPM or boot password
   - Volume: 1-10 keys → manage in KMS
   - Database: 1-20 keys → manage in KMS per database
   - File: 100-1000 keys → manage per user or per role
   - Record: 1000+ keys → application must manage per-field or per-tenant

4. **Performance vs. Security Tradeoff:**
   - Full-disk/partition/volume: <3% overhead, no query impact
   - Database: 10-20% overhead, transparent to queries
   - File: 5-15% overhead, no query impact (files are not queried)
   - Record: 15-30% overhead, severe query impact (cannot search encrypted fields)

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

