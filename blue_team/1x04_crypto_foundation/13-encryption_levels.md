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
| **Partition** | Separating sensitive data from OS: place database partition on separate encrypted partition so if OS partition is compromised, database files remain encrypted; compliance requirement to isolate sensitive data from system files; multi-tenant systems where different data volumes need different encryption keys | Administrative overhead: must plan partitions during installation; limited flexibility to change partition sizes post-deployment; single key for entire partition (cannot encrypt individual files within partition differently) |
| **Volume** | Large-scale RAID/NAS environments where encryption must span multiple physical disks transparently | Single key weakness: compromise of one key exposes entire volume |
| **File** | Selective protection when only some files are sensitive; systems where different users need different encryption keys; backup data with mixed sensitivity | Still requires volume/disk protection for complete security; doesn't protect unencrypted files |
| **Database** | DBMS handles complex queries on encrypted data; users need role-based access control through database (not key management); compliance requirement for database-specific encryption | Requires DBMS support; doesn't protect database backups if backups are unencrypted; keys must be protected in database |
| **Record** | Extreme sensitivity: some fields need encryption even from database administrators; compliance requirement for specific PII fields; mixed sensitivity within single record | Highest performance cost; most complex key management; splits encryption responsibility between application and database |

---

## FILE-LEVEL ENCRYPTION IN DETAIL

**What It Is:** Individual files (or groups of files) are encrypted at the filesystem level or application level, independent of other files. Different files can use different keys or owners.

**Key Characteristics:**
- **Scope:** Granular—only selected sensitive files are encrypted; non-sensitive files remain unencrypted
- **Performance:** Low-Medium overhead (filesystem must encrypt/decrypt each file access; CPU cost is per-file, not per-disk)
- **Key Management:** One key per file, per user, or per role; maximum granularity; most complex key management
- **Use Case Strength:** Selective protection when only some files are sensitive; audit trail per encrypted file; different files can have different owners/permissions

**MedDefense File-Level Scenario:**

Imagine ehr-db-01 backup staging uses file-level encryption for sensitive exports:
```
/backup/daily-exports/
├── 2024-07-21_patients.sql              ← Encrypted (patient demographics)
├── 2024-07-21_clinical_notes.sql        ← Encrypted (clinical narratives)
├── 2024-07-21_system_logs.log           ← NOT encrypted (non-sensitive logs)
└── 2024-07-21_billing_export.csv        ← Encrypted (financial data)
```

**Benefits:**
- Different files have different keys: if one key is compromised, only one file is exposed (not entire backup)
- Audit trail per file: can track which user accessed which encrypted file, at what time
- Non-sensitive files remain unencrypted (smaller backup size, faster backups)
- Can encrypt files with different users' keys (e.g., accounting team keys for billing files, clinical team keys for clinical notes)

**Trade-offs:**
- **Administrative Complexity:** Requires deciding which files are sensitive; manual key management per file or per role
- **No Protection for Unencrypted Files:** System administrators can still read non-encrypted files; does not protect against unauthorized access
- **Key Distribution Problem:** If 100 users need access to one encrypted backup file, the encryption key must be shared or re-encrypted 100 ways (complex key management)
- **Not Transparent to Applications:** Backup/restore tools must handle encrypted files explicitly; not as transparent as partition-level encryption

**Implementation Methods:**

**Option 1: GNU Privacy Guard (GPG) - Application-Level File Encryption**
```bash
# Encrypt a single backup file (symmetric encryption)
gpg --symmetric --cipher-algo AES256 --output 2024-07-21_patients.sql.gpg 2024-07-21_patients.sql

# Or asymmetric: encrypt with specific user's public key
gpg --recipient "backup-team@meddefense.local" --encrypt 2024-07-21_patients.sql

# Decrypt
gpg --decrypt 2024-07-21_patients.sql.gpg > 2024-07-21_patients.sql

# Verify integrity + decrypt in one step
gpg --verify-files 2024-07-21_patients.sql.gpg
```

**Option 2: eCryptfs - Filesystem-Level File Encryption**
```bash
# Mount encrypted directory (one password for all files in directory)
mount -t ecryptfs /backup/sensitive /backup/sensitive-encrypted
# Enter encryption passphrase; all files in /backup/sensitive are now encrypted on disk

# Applications write to /backup/sensitive-encrypted normally; eCryptfs encrypts transparently
cp /backup/sensitive-encrypted/patients.sql /tmp/  # File is decrypted to /tmp

# When done, unmount to encrypt files again
umount /backup/sensitive-encrypted
```

**Option 3: FSCRYPT - Modern Linux Filesystem Encryption**
```bash
# Enable encryption on ext4/f2fs filesystem
fscrypt setup
fscrypt encrypt /backup/sensitive --source=pam_passphrase
# All files in /backup/sensitive are now encrypted; transparent to applications running as authorized user

# Only users with login passphrase can access files
ls /backup/sensitive              # Shows encrypted filename hashes
# (User with passphrase sees decrypted files transparently)
```

**Option 4: Azure File Encryption / AWS S3 Client-Side Encryption (Cloud)**
```bash
# AWS S3 example: encrypt files before upload (client-side)
aws s3 cp backup.sql s3://meddefense-backups/backup.sql --sse-c --sse-c-key=<key> --sse-c-algorithm=AES256

# Azure example: encrypt with Azure Key Vault
az keyvault secret set --vault-name meddefense-vault --name backup-2024-07-21 --value "$(cat backup.sql | gzip | openssl enc -aes-256-cbc -e -S <salt> -k <password>)"
```

**MedDefense Recommendation (File-Level Context):**
- Use file-level encryption for backup exports left on ehr-db-01 staging area (short-term: hours/days)
- Use GPG for maximum compatibility (works across platforms, no kernel modules required)
- Encrypt only sensitive exports (patients.sql, clinical_notes.sql, billing_export.csv); leave system logs unencrypted
- Different keys for different file types: clinical team has key for clinical notes, accounting team has key for billing
- Before deletion: overwrite encrypted files with random data 7 times (secure deletion)

**File vs. Partition Trade-Off:**
| Aspect | File-Level | Partition-Level |
|---|---|---|
| **Granularity** | Per-file keys | Single key for all files in partition |
| **Performance** | Medium (per-file encrypt/decrypt) | Minimal (filesystem transparent) |
| **Admin Complexity** | High (decide which files, manage key distribution) | Medium (one key per partition) |
| **Audit Trail** | Per-file (which user accessed which file) | Per-partition (cannot distinguish files) |
| **Use Case** | Selective protection; backup exports; mixed sensitivity | Database partitions; full OS separation |

**When to Choose File-Level Over Partition:**
- Backups with mixed sensitivity (some files sensitive, others not)
- Need per-file audit trails (compliance requirement: track who accessed which export)
- Different teams need different keys (clinical team ≠ accounting team)
- Cannot plan partitions ahead of time (partition-level requires OS installation planning)

---

## PARTITION-LEVEL ENCRYPTION IN DETAIL

**What It Is:** A logical partition (e.g., /var/lib/postgresql) on a disk is encrypted as a unit, separate from other partitions (e.g., /boot, /home, /).

**Key Characteristics:**
- **Scope:** All files within the partition are encrypted with a single key
- **Performance:** Minimal overhead (filesystem layer handles encryption/decryption transparently)
- **Key Management:** One key per partition; can be different from other partitions
- **Use Case Strength:** Isolating sensitive data (database, financial records) from OS system files

**MedDefense Partition Scenario:**

Imagine ehr-db-01 is configured with partitions:
```
/          (OS + application files)                  ← NOT encrypted
/var/lib/postgresql  (database files)               ← ENCRYPTED with KEY-A
/backup    (local backup staging)                   ← ENCRYPTED with KEY-B
```

**Benefits:**
- If OS partition is compromised (attacker gains root), database files on /var/lib/postgresql are still encrypted (attacker cannot read database files directly without KEY-A)
- Different keys for different partitions (if /var/lib/postgresql key is compromised, /backup is still protected by KEY-B)
- Better than full-disk encryption (if one key is compromised, only one partition is exposed, not entire disk)
- More flexible than file-level encryption (administrator does not need to decide which individual files to encrypt; entire partition is encrypted at filesystem level)

**Trade-offs:**
- **Planning Complexity:** Partition scheme must be planned at OS installation time. Resizing partitions requires disk manipulation (more complex than managing file-level encryption)
- **Administrative Overhead:** Each partition has its own mount point and key; managing multiple keys is more complex than one key for entire disk
- **Mixed Sensitivity:** Cannot encrypt some files within /var/lib/postgresql differently than others; all files in partition share the same key and encryption

**LUKS (Linux Unified Key Setup) Implementation:**
```bash
# During Linux installation, create encrypted partition:
# /dev/sda1 = /boot (unencrypted)
# /dev/sda2 = encrypted LUKS container for LVM physical volume
# LVM creates: /var/lib/postgresql, /backup, /var/log as logical volumes

# Open encrypted partition at boot:
cryptsetup luksOpen /dev/sda2 meddefense-data
# This unlocks the LUKS container, allowing LVM volumes to mount

# Alternative: Use LUKS directly on partition (no LVM)
cryptsetup luksFormat /dev/sda3 --label=postgresql-data
cryptsetup luksOpen /dev/sda3 pg-encrypted
mkfs.ext4 /dev/mapper/pg-encrypted
mount /dev/mapper/pg-encrypted /var/lib/postgresql
```

**MedDefense Recommendation:** 
- Use partition-level encryption for ehr-db-01 /var/lib/postgresql to isolate database from OS
- Use separate LUKS container with separate key for backup partition (/backup or /mnt/backups)
- Protects against: OS compromise does not expose database files; database compromise does not expose backups

---

## MEDDEFENSE ENCRYPTION LEVEL MAP

### 1. Patient Records in PostgreSQL (ehr-db-01)

**Recommended Level:** Partition-level encryption (LUKS) + Database-level encryption (PostgreSQL TDE)

**Justification:**
MedDefense's ehr-db-01 database server should use partition-level encryption to isolate the database partition (/var/lib/postgresql) from the OS partition (/). This provides defense-in-depth:
- **Partition-level:** If OS is compromised (attacker gains root), database files are still encrypted with LUKS (attacker cannot read .sql files directly)
- **Database-level:** If partition is unlocked (key is available at runtime), queries still go through PostgreSQL ACLs (row-level security prevents one patient's data from being visible to another patient's clinician)

**Why Partition + Database?** Partition encryption protects the disk files (physical layer); database encryption protects queries and access control (logical layer). Combined, they provide protection against:
- Root compromise (cannot read database files directly)
- Disk theft (files are LUKS-encrypted)
- Logical attacks (SQL queries are still controlled by database ACLs)

**Implementation:**
- OS Installation: Create partitions:
  - /boot (unencrypted, required for boot)
  - /var/lib/postgresql (encrypted with LUKS, separate key KEY-A)
  - / (system files, can be encrypted or unencrypted)
  - /backup (encrypted with LUKS, separate key KEY-B for backup isolation)

- Database: Enable PostgreSQL TDE (13.0+)

**Key Management:** 
- LUKS Key (KEY-A) for /var/lib/postgresql: Store in external HSM or Vault, brought online at boot time or via automated unlock service
- PostgreSQL encryption key: Store in external KMS (different from LUKS key; separation of duties)

**Boot Sequence:**
1. Server boots; /boot is unencrypted (OS can start)
2. Systemd runs before database: unlock LUKS containers with keys from Vault
3. Mount /var/lib/postgresql (now available)
4. PostgreSQL starts and reads its TDE configuration
5. PostgreSQL engine decrypts database pages as queries arrive

---

### 2. Backup Data on NAS-01

**Recommended Level:** Volume-level encryption (encrypted RAID) + Partition-level encryption for on-server staging

**Justification:**
Backups on NAS-01 use volume-level encryption because:
- All backups are equally sensitive (no selective encryption needed)
- Encryption is transparent to backup processes (NAS handles automatically)
- Volume spans multiple physical disks (RAID arrays); volume-level encryption treats them as single encrypted unit

Secondary layer: If MedDefense does local backup staging on ehr-db-01 before uploading to NAS, use partition-level encryption for the /backup partition (separate LUKS container).

**Critical Design:** Encryption keys must NOT be stored on the NAS or backup server. Use external HSM or Vault:
- NAS key: In physical vault (USB HSM, offsite)
- Backup staging key: In Vault, rotated monthly

**Implementation:**
- NAS: Enable shared folder encryption on backup destination (Synology/QNAP settings)
- Backup staging (/backup): Separate LUKS partition on ehr-db-01, key in Vault

---

### 3. Financial Records in MySQL (billing-srv-01)

**Recommended Level:** Partition-level encryption + Database-level encryption + Record-level encryption (triple layer)

**Justification:**
Financial data is heavily regulated (PCI-DSS for credit cards, state financial privacy laws, HIPAA for billing). Implement defense-in-depth:
- **Partition-level:** /var/lib/mysql on separate LUKS container (if OS is compromised, database is encrypted)
- **Database-level:** MySQL InnoDB TDE (protects database pages at rest)
- **Record-level:** Encrypt most sensitive columns (SSN, credit card, policy numbers) at application level using AES-256

Benefits:
- Billing staff can run SQL queries (database-level TDE is transparent)
- Most sensitive fields are encrypted even if database is accessed directly (record-level encryption)
- Partition encryption is defense-in-depth against OS compromise

**Implementation:**
```bash
# Partition
cryptsetup luksFormat /dev/sda4 --label=mysql-data
cryptsetup luksOpen /dev/sda4 mysql-encrypted
mkfs.ext4 /dev/mapper/mysql-encrypted
mount /dev/mapper/mysql-encrypted /var/lib/mysql

# Database
ALTER SYSTEM SET innodb_encrypt_tables=ON;  # MySQL 8.0+

# Record (application-level)
-- Encrypt SSN, credit card columns in application before insert
SELECT aes_encrypt(ssn, KEY), aes_encrypt(credit_card, KEY) FROM patient_billing;
```

---

### 4. Backup Exports and Data Exports on ehr-db-01 (File-Level)

**Recommended Level:** File-level encryption (GPG/eCryptfs) for backup staging area

**Justification:**
When MedDefense exports backup or data dump files for testing, audit, or disaster recovery staging, use file-level encryption:
- Different files (patients.sql, clinical_notes.sql, billing_export.csv) have different sensitivity
- Files are temporary (hours to days on disk before transfer to NAS or deletion)
- Different teams may need access to different files (clinical team → clinical_notes.sql, accounting team → billing_export.csv)
- Per-file audit trail: can log which user accessed/downloaded which encrypted export

**Example Scenario:**
```
/backup/exports/
├── 2024-07-21_patients.sql.gpg          (Encrypted, accessible only to clinical staff)
├── 2024-07-21_clinical_notes.sql.gpg    (Encrypted, accessible only to physicians)
├── 2024-07-21_billing_export.csv.gpg    (Encrypted, accessible only to accounting team)
└── 2024-07-21_schema_backup.sql         (NOT encrypted—schema only, no PHI)
```

**Implementation (GPG):**
```bash
# Create encryption keys for different teams
gpg --full-generate-key  # Creates clinical-team@meddefense.local key
gpg --full-generate-key  # Creates accounting-team@meddefense.local key

# Export function runs daily backup and encrypts per-team
backup_and_encrypt() {
  mysqldump --all-databases > /tmp/full_backup.sql
  gpg --recipient clinical-team@meddefense.local --encrypt /tmp/full_backup.sql --output /backup/exports/clinical_$(date +%Y-%m-%d).sql.gpg
  gpg --recipient accounting-team@meddefense.local --encrypt /tmp/billing.sql --output /backup/exports/billing_$(date +%Y-%m-%d).csv.gpg
}

# Clinical staff decrypts when needed (passphrase required)
gpg --decrypt /backup/exports/clinical_2024-07-21.sql.gpg > clinical_export.sql

# Verify file integrity before decryption
gpg --verify-files /backup/exports/clinical_2024-07-21.sql.gpg
```

**Benefits (File-Level):**
- Granular access: accounting team cannot decrypt clinical files (different keys)
- Audit trail: can log which user decrypted which file and when
- Mixed sensitivity: schema-only backups remain unencrypted (faster export)
- Temporary protection: files encrypted during staging, can be deleted securely

**Key Management:**
- Each team's public key stored in GPG keyserver (public)
- Private keys stored in password-protected GPG keyring on backup servers or Vault
- Passphrase rotated quarterly

**Trade-off Against Partition-Level:**
- Partition-level (/backup on LUKS) is better for long-term backup storage (faster, transparent)
- File-level is better for temporary exports needing per-team access control and audit trails
- Recommendation: Use both: file-level for export staging (/backup/exports with GPG), partition-level for archive (/backup partition encrypted with LUKS)

---

### 5. Medical Images on PACS (pacs-srv-01)

**Recommended Level:** Partition-level encryption (local PACS storage) + File-level or Volume-level encryption (network storage)

**Justification:**
DICOM files are stored on PACS server. For local storage, use partition-level encryption to separate DICOM files (/data/dicom) from OS (/). For network storage (NAS), use volume-level encryption.

**Implementation:**
- Local PACS partition: /data/dicom encrypted with LUKS
- NAS backup: Volume-level encryption (transparent to PACS application)
- Network transmission: DICOM TLS (CMS/HIPAA requirement)

---

### 6. Email Data in O365

**Recommended Level:** Microsoft-managed encryption (equivalent to database-level)

**Justification:**
O365 handles encryption transparently: BitLocker on datacenter disks, per-mailbox encryption with Microsoft-managed keys, TLS for transmission. MedDefense cannot and should not try to implement additional encryption (O365 is managed service; MedDefense does not own the storage hardware).

However: Record-level encryption (S/MIME) should be used for individual sensitive emails (patient information, billing data, clinical notes) to encrypt the message body even within O365's system.

**Implementation:**
- S/MIME: Enable for all MedDefense staff; encrypt emails containing PHI
- OME (Office Message Encryption): Configure for external recipients (those outside organization)

---

### 7. Employee Laptops

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

### 8. BD Alaris Pump Firmware/Configuration

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
| **Backup Exports** | ehr-db-01 staging | File-level (GPG) | Team-specific GPG keys | Partition-level for archive | Per-file access control; audit trail per export |
| **Medical Images** | PACS pacs-srv-01 | File-level + Volume | TLS for network | Volume-level on storage | DICOM TLS mandatory for HIPAA |
| **Email** | O365 Cloud | Microsoft-managed + S/MIME | Microsoft (O365) | S/MIME for sensitive emails | MedDefense adds S/MIME for extra protection |
| **Laptops** | Portable devices | Full-disk (BitLocker/FileVault) | TPM 2.0 or PIN | Recovery key in vault | Transparent to users; high-theft protection |
| **Medical Device Firmware** | BD Alaris Pump | Firmware signing + Config encryption | RSA-2048 signature | DICOM TLS network | Lightweight for constrained devices; network-based protection primary |

**Key Principle:** Layered encryption—no single level is perfect. Use full-disk where possible (fallback), database-level where DBMS supports it (transparency for queries), record-level where compliance demands extreme granularity.

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 13-encryption_levels.md
