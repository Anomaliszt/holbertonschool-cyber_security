Goal: Compare the six encryption levels defined and recommend the appropriate level for every MedDefense data store.

Context: "Encrypt the database" sounds simple, but there are at least three ways to do it: encrypt the entire disk the database sits on (full-disk), encrypt the database files (file-level), or encrypt individual fields within the database (record-level). Each has radically different properties: scope of protection, performance impact, key management complexity and what happens when someone with legitimate database access queries the data.

Choosing the wrong level either leaves data exposed or creates operational problems that the clinical staff will not tolerate.

---

## ENCRYPTION LEVELS COMPARISON

| Level | Scope | Performance Impact | Key Management | Use Case |
|---|---|---|---|---|
| **Full-Disk** | All data on entire physical/virtual disk (OS, applications, everything) | Minimal (kernel handles transparently) | Single key per disk; key stored in BIOS/TPM or entered at boot | Entire servers with OS, swap, temp files; stolen hard drives cannot be read by attacker; includes non-database files |
| **Partition** | Single logical partition on disk (e.g., /var, /home, separate partition for data) | Minimal (filesystem transparent) | One key per partition; key stored in partition table or bootloader | Isolating critical partition from rest of disk; separating user data from OS; shares key across all files in partition |
| **Volume** | Logical volume that may span multiple physical disks (LVM) | Minimal (transparent to applications) | Single key; managed by logical volume manager | RAID arrays, multi-disk storage pools; provides encryption across multiple physical disks while appearing as single filesystem |
| **File** | Individual files (encrypted at filesystem level) | Low-Medium (filesystem must encrypt/decrypt each file access) | One key per file or shared per user; granular key management | Selective encryption of sensitive files while leaving others unencrypted; different files can have different keys/owners; audit trail per file |
| **Database** | Entire database or tablespace (encryption at DBMS level) | Medium (database engine encrypts/decrypts pages) | Single key per database; key stored in database-specific key manager or external KMS | PostgreSQL Transparent Data Encryption (TDE), MySQL at-rest encryption; protects database files; SQL queries see decrypted data (access control handled by database ACLs) |
| **Record** | Individual fields, rows, or records (application-level encryption) | Medium-High (application must encrypt before storing, decrypt after retrieval) | Key per record or per field; extreme granularity; most complex key management | Protecting specific sensitive fields (SSN, credit card, medication name) while leaving non-sensitive fields unencrypted; record-level access control; encrypted data visible in database backups |

---

## WHEN TO USE EACH LEVEL

| Level | When It's the Best Choice | Trade-offs |
|---|---|---|
| **Full-Disk** | Physical servers in accessible locations (data centers, branch offices) where theft/unauthorized access to hardware is possible; OS security relies on startup authentication | Protects against disk theft but not logical attacks; slow at startup; if attacker gains OS access, all data visible |
| **Partition** | Multi-tenant systems where different tenants' data must be on same server but encrypted separately; compliance requirement to isolate data | Administrative overhead; must plan partitions in advance |
| **Volume** | Large-scale RAID/NAS environments where encryption must span multiple physical disks transparently | Single key weakness: compromise of one key exposes entire volume |
| **File** | Selective protection when only some files are sensitive; systems where different users need different encryption keys; backup data with mixed sensitivity | Still requires volume/disk protection for complete security; doesn't protect unencrypted files |
| **Database** | DBMS handles complex queries on encrypted data; users need role-based access control through database (not key management); compliance requirement for database-specific encryption | Requires DBMS support; doesn't protect database backups if backups are unencrypted; keys must be protected in database |
| **Record** | Extreme sensitivity: some fields need encryption even from database administrators; compliance requirement for specific PII fields; mixed sensitivity within single record | Highest performance cost; most complex key management; splits encryption responsibility between application and database |

---

## MEDDEFENSE ENCRYPTION LEVEL MAP

### 1. Patient Records in PostgreSQL (ehr-db-01)

**Recommended Level:** Database-level encryption (PostgreSQL TDE)

**Justification:**
MedDefense needs to encrypt all patient medical records (PHI: medications, diagnoses, procedure notes, clinical observations). Database-level encryption allows clinicians to query records through normal SQL (they see decrypted data based on role-based access control), while the underlying data files are encrypted at rest. If an attacker compromises the server OS and tries to read database files directly (bypassing PostgreSQL ACLs), the files are encrypted and unreadable. This provides protection against:
- Root compromises (attacker cannot read database files directly)
- Physical disk theft (data cannot be read by another system)
- But NOT: SQL injection to see other patients' data (that's handled by row-level security, not encryption)

**Secondary Layers:**
- Full-disk encryption (backup layer): If PostgreSQL TDE fails or is misconfigured, full-disk encryption provides fallback
- Record-level encryption for most sensitive fields: If compliance requires encryption even from DBA, add column-level encryption for patient SSN, credit card numbers

**Implementation:**
```sql
-- PostgreSQL 14+
CREATE EXTENSION pgcrypto;
ALTER SYSTEM SET ssl_key_file = '/secure/path/to/key';
```

**Key Management:** Store PostgreSQL encryption key in external key management system (HashiCorp Vault, AWS KMS); NOT on the same server (if compromised, key is also compromised).

---

### 2. Backup Data on NAS-01

**Recommended Level:** Volume-level encryption (encrypted RAID)

**Justification:**
Backups contain all data: PostgreSQL dumps (plaintext patient records), MySQL dumps (plaintext billing data), DICOM files (plaintext medical images). All backups must be encrypted as a single volume to ensure if the NAS is compromised or stolen, backup data cannot be extracted. Volume-level encryption is appropriate because:
- All backups are equally sensitive (no selective encryption needed)
- Encryption must be transparent to backup processes (NAS handles it automatically)
- Single encryption key for entire backup volume is acceptable (encrypted backups cannot be accessed anyway unless NAS is online)

**Critical Design:** Encryption key must NOT be stored on the NAS. If NAS is ransomware-encrypted and key is on NAS, both backups AND key are lost (defeating recovery capability). External key storage is mandatory.

**Implementation:**
- Enable Synology NAS shared folder encryption on backup destination
- Key: Store in external location (HashiCorp Vault, USB HSM in vault, offline secure storage)
- Backup process: Restore key to NAS during backup window only, then remove

---

### 3. Financial Records in MySQL (billing-srv-01)

**Recommended Level:** Database-level encryption + Record-level encryption (hybrid)

**Justification:**
Financial data contains: patient names, dates of birth, SSNs, insurance policy numbers, credit card last-4s, 3 years of billing records. Some of this data needs different protection levels:
- Standard medical identifiers (patient name, DOB) = database-level sufficient
- Highly sensitive PII (SSN, credit card, policy numbers) = record-level encryption needed

Hybrid approach: Use MySQL at-rest encryption for database files (database-level), then add application-level encryption for the most sensitive columns (SSN, credit card fragments) using AES-256 in the application tier.

**Benefit:** Billing staff can run SQL queries to find "all charges for patient ID 12345" (database-level encryption handles this transparently), but cannot see the patient's SSN even if they manually query the database (application-level encryption requires decryption key held by billing system, not DBA).

**Implementation:**
- Database: MySQL InnoDB TDE
- Application: Encrypt SSN, Credit card (last 4), Insurance policy in application before storing

---

### 4. Medical Images on PACS (pacs-srv-01)

**Recommended Level:** File-level encryption + Volume-level backup encryption

**Justification:**
DICOM files are large (typically 2-10MB per image). Encrypting at file level is appropriate because:
- Each DICOM file is independent and can be encrypted/decrypted individually
- PACS system manages file access (radiologists request specific studies); file-level encryption aligns with this access model
- File-level encryption allows audit trails per file (which radiologist accessed which study)

For storage:
- If PACS files are on dedicated storage (NAS or SAN), add volume-level encryption as secondary protection
- DICOM files should be encrypted at both levels: file-level (application handles DICOM TLS or application encryption) and volume-level (storage device encrypts at rest)

**Implementation:**
- PACS application: Enable DICOM TLS for network transmission (CMS/HIPAA requirement)
- Storage: Volume-level encryption on PACS storage appliance (NAS, SAN, or dedicated PACS server disk)

---

### 5. Email Data in O365

**Recommended Level:** Microsoft-managed encryption (equivalent to database-level)

**Justification:**
O365 handles encryption transparently: BitLocker on datacenter disks, per-mailbox encryption with Microsoft-managed keys, TLS for transmission. MedDefense cannot and should not try to implement additional encryption (O365 is managed service; MedDefense does not own the storage hardware).

However: Record-level encryption (S/MIME) should be used for individual sensitive emails (patient information, billing data, clinical notes) to encrypt the message body even within O365's system.

**Implementation:**
- S/MIME: Enable for all MedDefense staff; encrypt emails containing PHI
- OME (Office Message Encryption): Configure for external recipients (those outside organization)

---

### 6. Employee Laptops

**Recommended Level:** Full-disk encryption (BitLocker on Windows, FileVault on Mac)

**Justification:**
Laptops are portable, frequently travel, and are high-theft targets. Full-disk encryption ensures if a laptop is stolen, all data (OS, applications, cached patient data, local files) cannot be accessed. Full-disk encryption is appropriate because:
- Encryption is transparent to employees (no performance impact noticed)
- Protects all data indiscriminately (no need to decide which files to encrypt)
- Enforced by OS at boot (attacker cannot bypass by booting alternate OS or removing disk to another machine)

**Implementation:**
- Windows: BitLocker with TPM 2.0 (or PIN+password)
- macOS: FileVault with Recovery Key in secure location
- Mobile: Full-disk encryption mandatory for all phones/tablets

**Key Management:** Recovery keys must be stored in secure location (corporate password manager like Dashlane, NOT in local files on laptop)

---

### 7. BD Alaris Pump Firmware/Configuration

**Recommended Level:** Record-level encryption + Firmware signing (at application level)

**Justification:**
BD Alaris pumps are constrained devices with limited processing power. Full-disk or database-level encryption is impractical. Instead:
- Firmware should be cryptographically signed (not encrypted; signing allows verification without performance cost)
- Configuration data (drug library, dosing parameters, calibration) should use application-level encryption if stored locally on pump
- Network communication should use DICOM TLS or HTTPS

**Important:** Do NOT encrypt firmware on the pump itself (decryption happens at power-on, consuming battery/processing power). Instead, transport firmware in encrypted channels (HTTPS from pump server) and verify signature on-device (lightweight operation).

**Implementation:**
- Firmware: RSA-2048 signature verification on pump at boot (verify firmware integrity)
- Configuration: AES-256 encryption for sensitive parameters (drug concentration, maximum rate limits) in configuration files
- Network: DICOM TLS or HTTPS for all pump-to-server communication

---

## SUMMARY: MEDDEFENSE ENCRYPTION LEVEL MATRIX

| Data Store | Location | Recommended Level | Primary Key | Secondary Layer | Notes |
|---|---|---|---|---|---|
| **Patient Records** | PostgreSQL ehr-db-01 | Database (TDE) | External KMS | Full-disk backup | Clinicians see decrypted data; queries work normally |
| **Backups** | NAS-01 | Volume (encrypted RAID) | External vault | N/A | Key NOT on NAS (ransomware scenario) |
| **Financial Data** | MySQL billing-srv-01 | Database + Record (hybrid) | External KMS | Full-disk backup | Most sensitive fields (SSN, CC) encrypted at application level |
| **Medical Images** | PACS pacs-srv-01 | File-level + Volume | TLS for network | Volume-level on storage | DICOM TLS mandatory for HIPAA |
| **Email** | O365 Cloud | Microsoft-managed + S/MIME | Microsoft (O365) | S/MIME for sensitive emails | MedDefense adds S/MIME for extra protection |
| **Laptops** | Portable devices | Full-disk (BitLocker/FileVault) | TPM 2.0 or PIN | Recovery key in vault | Transparent to users; high-theft protection |
| **Medical Device Firmware** | BD Alaris Pump | Firmware signing + Config encryption | RSA-2048 signature | DICOM TLS network | Lightweight for constrained devices; network-based protection primary |

**Key Principle:** Layered encryption—no single level is perfect. Use full-disk where possible (fallback), database-level where DBMS supports it (transparency for queries), record-level where compliance demands extreme granularity.

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 13-encryption_levels.md
