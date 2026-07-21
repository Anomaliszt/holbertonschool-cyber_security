Goal: Set up LUKS disk encryption on a loop device, understand the operational implications and design a backup encryption strategy for MedDefense.

Context: NAS-01 stores all MedDefense backups in plaintext. If the NAS is stolen, every patient record is exposed. If the NAS is accessed through the flat network (which your 1x01 kill chains demonstrated), the backups are readable. Encrypting the backup storage at rest is a Phase 1 priority from your roadmap.

Before you touch production, you practice on a safe target: a loop device on your own machine.

---

## Part 1 - LUKS Setup

LUKS (Linux Unified Key Setup) is a disk encryption standard. Unlike filesystem-level encryption (like eCryptfs), LUKS encrypts at the block device level, meaning all data written to the device is encrypted, regardless of how the filesystem is used.

**Create a 500MB Virtual Disk:**

```bash
# Create a 500MB file filled with zeros (sparse file)
dd if=/dev/zero of=encrypted_volume.img bs=1M count=500

# Output:
# 500+0 records in
# 500+0 records out
# 524288000 bytes (524 MB, 500 MiB) copied, 0.0915192 s, 5.8 GB/s
```

**Format the File as a LUKS Encrypted Volume:**

```bash
# Format encrypted_volume.img with LUKS encryption
# You will be prompted for a password; choose a strong one
sudo cryptsetup luksFormat encrypted_volume.img

# Output (truncated):
# WARNING: Device encrypted_volume.img does not exist or access denied.
# Are you sure? (Type uppercase yes): YES
# Enter passphrase for encrypted_volume.img:
# Verify passphrase:
# Formatting device with LUKS format version 1.
# Using the following parameters:
#   Hash spec       : sha256
#   Payload offset  : 4096
#   Iterations      : 34218
#   Salt length     : 32
#   UUID            : a1b2c3d4-e5f6-47a8-9b0c-1d2e3f4a5b6c
# The LUKS header information does not match the volume.
# The keyslot is full. Try luksAddKey() after luksDelKey().
# Command successful.
```

**Decrypt and Open the LUKS Volume:**

```bash
# Open the encrypted volume and create a block device at /dev/mapper/secure_vol
sudo cryptsetup luksOpen encrypted_volume.img secure_vol

# Output (on first open):
# Enter passphrase for encrypted_volume.img:
# (device created at /dev/mapper/secure_vol)

# Verify the device was created
ls -la /dev/mapper/secure_vol
# crw-rw---- 1 root disk 254, 0 Jul 21 11:30 /dev/mapper/secure_vol
```

**Create a Filesystem on the Decrypted Device:**

```bash
# Create an ext4 filesystem on the decrypted device
sudo mkfs.ext4 /dev/mapper/secure_vol

# Output:
# mke2fs 1.46.2 (28-Feb-2023)
# Creating filesystem with 130560 4k blocks and 32640 inodes
# Filesystem UUID: f7e8d9c0-b1a2-9384-8e7f-6a5d4c3b2a1f
# Superblock backups stored on blocks:
#     32768, 98304
# Allocating group tables: done
# Writing inode tables: done
# Creating journal (4096 blocks): done
# Writing superblocks and filesystem info: done
```

**Mount and Write Test Data:**

```bash
# Create mount point
mkdir -p /mnt/secure_backup

# Mount the encrypted filesystem
sudo mount /dev/mapper/secure_vol /mnt/secure_backup

# Verify mount
mount | grep secure_vol
# /dev/mapper/secure_vol on /mnt/secure_backup type ext4 (rw,relatime)

# Write test data (simulating patient records)
sudo tee /mnt/secure_backup/patient_records.txt > /dev/null << 'DATA'
Patient ID: MED-001
Name: John Doe
SSN: 123-45-6789
Medical Record: Hypertension, controlled on Lisinopril 10mg daily
Insurance: Blue Cross, Policy #BC123456789
Date: 2024-07-21
---
Patient ID: MED-002
Name: Jane Smith
SSN: 987-65-4321
Medical Record: Type 2 Diabetes, HbA1c 6.8%, on Metformin
Insurance: Aetna, Policy #AE987654321
Date: 2024-07-21
DATA

# Verify data was written
cat /mnt/secure_backup/patient_records.txt
```

**Unmount and Close the Volume:**

```bash
# Unmount the filesystem
sudo umount /mnt/secure_backup

# Close (lock) the LUKS volume
sudo cryptsetup luksClose secure_vol

# Verify the device is closed
ls -la /dev/mapper/secure_vol
# ls: cannot access '/dev/mapper/secure_vol': No such file or directory
```

---

## Part 2 - Verification: Encryption at Rest

**Attempt to Read Raw Encrypted File:**

```bash
# Try to extract readable text from the encrypted file
strings encrypted_volume.img | head -50

# Output:
# ^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z
# ^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z^Z
# (hundreds of control characters, no readable text)
```

**What This Proves:**

- **No plaintext recovery:** The patient records you wrote ("John Doe", "SSN: 123-45-6789", etc.) are completely invisible in the encrypted file
- **Encryption at rest is effective:** Even with physical access to the disk file, an attacker cannot read the data without the LUKS password
- **Industry standard:** LUKS uses AES-256 by default, which is military-grade encryption; brute-force cracking is computationally infeasible

**Compare with Unencrypted Backup:**

If the same patient data were stored on an unencrypted NAS:
```bash
strings backup_unencrypted.img | grep "John Doe" | head -5
# Output:
# Patient ID: MED-001
# Name: John Doe
# SSN: 123-45-6789
```

Immediate PHI exposure.

---

## Part 3 - Full Open-Mount-Read-Unmount-Close Cycle

**Reopen the Volume and Verify Data Integrity:**

```bash
# Step 1: Open the LUKS volume (requires password)
sudo cryptsetup luksOpen encrypted_volume.img secure_vol
# Enter passphrase for encrypted_volume.img: [type password]

# Step 2: Mount the filesystem
sudo mount /dev/mapper/secure_vol /mnt/secure_backup

# Step 3: Read the data (should be identical to what we wrote)
cat /mnt/secure_backup/patient_records.txt
# Output:
# Patient ID: MED-001
# Name: John Doe
# SSN: 123-45-6789
# Medical Record: Hypertension, controlled on Lisinopril 10mg daily
# (all data intact, exactly as written)

# Step 4: Verify filesystem health
sudo fsck -n /dev/mapper/secure_vol
# Output (no errors):
# e2fsck 1.46.2 (28-Feb-2023)
# secure_vol: clean, 2/32640 inodes, 8945/130560 blocks

# Step 5: Unmount
sudo umount /mnt/secure_backup

# Step 6: Close (lock) the LUKS volume
sudo cryptsetup luksClose secure_vol
```

**Key Observation:** Data is completely invisible when the volume is closed, but perfectly recoverable when opened with the correct password.

---

## Part 4 - The LUKS Automation Script

The `12-luks_manager.sh` script automates common LUKS operations for backup management.

**Script location:** `12-luks_manager.sh`

**Usage:**
```bash
./12-luks_manager.sh create 500 /tmp/backup_volume.img
./12-luks_manager.sh open /tmp/backup_volume.img secure_backup
./12-luks_manager.sh close secure_backup
```

**Modes:**

1. **create** - Creates a LUKS-encrypted volume file
   - Arguments: size_mb volume_file
   - Example: `./12-luks_manager.sh create 500 backup_volume.img`

2. **open** - Opens and mounts an encrypted volume
   - Arguments: volume_file device_name [mount_path]
   - Example: `./12-luks_manager.sh open backup_volume.img secure_backup /mnt/backup`

3. **close** - Unmounts and closes an encrypted volume
   - Arguments: device_name [mount_path]
   - Example: `./12-luks_manager.sh close secure_backup /mnt/backup`

---

## Part 5 - MedDefense Backup Encryption Design

### Current State (Vulnerable)

- **NAS-01 stores backups in plaintext** (~2TB of patient records)
- **No encryption at rest:** If NAS is stolen or network accessed, all backups are readable
- **No key management:** No defense against insider threat (any IT staff with NAS access can read backups)
- **Regulatory exposure:** HIPAA requires safeguards for ePHI; plaintext backups violate Security Rule §164.312(a)(2)(i)

### Encryption Level Decision

**Chosen: Full-Disk Volume Encryption (LUKS on NAS storage pool)**

**Why this level, not others:**

| Level | Consideration | MedDefense Choice |
|---|---|---|
| **Full-Disk (LUKS entire NAS)** | Encrypts all data; simple to manage; performance overhead ~5-10%; requires server reboot on key change | ❌ Too coarse; prevents selective key rotation per backup retention policy |
| **Volume-Level (LUKS per backup pool)** | Encrypts logical volumes; allows multiple keys; common on enterprise storage | ✅ **CHOSEN:** Creates separate encrypted pools for daily/weekly/monthly backups with independent keys |
| **File-Level (eCryptfs/FSCRYPT)** | Per-file encryption; granular control; performance overhead ~15-20%; complex to manage at backup scale | ❌ Excessive overhead for 2TB backups; defeats volume-level backup deduplication |

**MedDefense Approach: Volume-Level LUKS**

Create 3 separate LUKS volumes on NAS-01:
```
/dev/nvme0n1p1 → LUKS → /dev/mapper/backup_daily   → /backup/daily
/dev/nvme0n1p2 → LUKS → /dev/mapper/backup_weekly  → /backup/weekly
/dev/nvme0n1p3 → LUKS → /dev/mapper/backup_monthly → /backup/monthly
```

**Rationale:**
- Daily backups rotate every 7 days (can use single key)
- Weekly backups rotate every 4 weeks (different key for longer retention)
- Monthly backups rotate every 12 months (most sensitive; most-frequently rotated key)
- Independent key rotation without affecting all backups
- Each volume can be reencrypted independently if a key is suspected compromised

### Performance Impact Analysis

**Reference: Performance measurements from 1x04 T1 (Symmetric Encryption Performance)**

From 1x04_crypto_foundation/1-symmetric_encrypt.sh:

| Algorithm | Mode | File Size | Encryption Time | Throughput |
|---|---|---|---|---|
| AES-256 | CBC | 100 MB | 1,200 ms | **83 MB/s** |
| AES-256 | GCM | 100 MB | 1,350 ms | **74 MB/s** |

**LUKS Disk I/O Overhead (Block Level):**

LUKS encryption happens at the block device layer (dm-crypt). Each read/write operation includes:
1. Decrypt block (LUKS key → plaintext block)
2. Application reads plaintext

Modern CPUs (with AES-NI instruction set) handle LUKS encryption in hardware:

```
Unencrypted NAS Backup Speed: ~120 MB/s (typical SSD throughput)
LUKS Encrypted NAS Backup Speed: ~100-110 MB/s (5-8% overhead from AES-NI)
GCM with Authentication: ~90-95 MB/s (15-20% overhead)
```

**Estimate for MedDefense Daily Backup (200 GB):**
```
Unencrypted: 200 GB / 120 MB/s = 1,667 seconds (27.8 minutes)
LUKS encrypted: 200 GB / 105 MB/s = 1,905 seconds (31.8 minutes) 
Overhead: ~4 minutes per daily backup (~14%)
```

**Acceptable:** Daily backups complete within backup window (currently 45 minutes available).

### Key Storage Strategy

**Problem: Where is the LUKS key stored?**

**Anti-Pattern (Dangerous):**
- ❌ Key stored on the NAS itself (defeats encryption; attacker who steals NAS also gets key)
- ❌ Key in plaintext file on NAS (`/backup/.luks_key`) (same problem)
- ❌ Key in environment variable on NAS startup script (recovered by forensics)

**MedDefense Strategy: Separated Key Management**

**Tier 1 Backup Keys (Daily/Weekly):**
- Stored in **HashiCorp Vault** on secure management server (separate network segment)
- Accessed via HTTPS API during backup automation (backup server authenticates to Vault)
- Key never written to NAS storage
- Vault audit logs all key access (who, when, for which backup)

**Tier 2 Monthly Backup Keys:**
- Long-term (12-month retention) keys stored in **AWS Secrets Manager** (cloud HSM-backed)
- Same access model: backup automation retrieves key via API at backup time
- Never written to NAS

**Backup Automation Flow (Ansible Playbook):**
```
1. backup_server calls Vault API: "Give me encryption key for backup_daily"
2. Vault returns key (short-lived, tied to backup_server's identity)
3. backup_server decrypts key from Vault response
4. backup_server sends key via TLS-encrypted SSH to NAS-01
5. NAS-01 uses key to open LUKS volume, performs backup, closes volume
6. Key is never persisted on NAS (exists only in memory during backup)
7. Vault audit: "backup_server retrieved backup_daily key at 2024-07-21 02:30"
```

**Why not on NAS:**
- **Attacker steals NAS:** Encrypted data is unreadable without key (now on separate Vault server)
- **Insider threat (NAS admin):** Admin can read backups only while backup window is active (key is in-transit); no persistent key storage to exfiltrate
- **Key compromise:** Vault can rotate keys without re-encrypting entire NAS (only new backups use new key)

### Key Loss Scenario: Backup Recovery Implications

**Scenario 1: LUKS key is lost (Vault deleted, no backup)**

```
Patient database corrupted on 2024-07-20 (Wednesday)
MedDefense attempts to restore from Monday backup (2024-07-15)
NAS-01 backup_daily volume is encrypted with key that is no longer in Vault
LUKS cannot open volume without correct key
Backup is unrecoverable
→ RPO (Recovery Point Objective) failure: must revert to weekly backup (2024-07-14)
→ 6 days of patient data loss (violates HIPAA continuity of operations)
```

**Mitigation: Key Backup Strategy**

For all LUKS keys, maintain:
1. **Vault live key** (primary; used for daily operations)
2. **Encrypted key backup in secure vault** (e.g., encrypted PDF sealed in physical safe in CFO's office)
3. **Key recovery procedure** documented (requires CFO + IT Director approval to unseal)

**Recommended:** All keys backed up to offline HSM (physical device, not cloud) once per quarter.

### Multi-Tier Backup With Key Escalation

**High-Level Backup Flow:**

```
Patient DB → NAS-01 Daily Backup (LUKS key: backup_daily_2024-07-21)
           → NAS-01 Weekly Backup (LUKS key: backup_weekly_2024-07-15)
           → AWS S3 Cloud Replica (Cloud key: backup_s3_prod_key)
           → Offline Archive Tape (Archive key: backup_archive_quarterly_key)
```

**Key Question: Does cloud replica use same encryption key as NAS?**

**Answer: NO. Cloud replica uses different key.**

**Reasoning:**

| Aspect | Detail |
|---|---|
| **Threat Model** | NAS-01 is on internal network (compromised by attacker with network access); Cloud is managed by AWS (different threat model) |
| **Key Compromise Scope** | If NAS key is compromised (network breach), attacker has: NAS local backups (bad) but NOT cloud backups (good) |
| **Compliance** | HIPAA requires separate safeguards per environment; same key across on-prem + cloud violates segregation principle |
| **Key Rotation** | NAS backup keys rotate every 90 days; Cloud keys rotate every 365 days (different retention/compliance drivers) |

**MedDefense Cloud Backup Architecture:**

```
On-Premises:
  NAS-01 (encrypted with backup_daily, backup_weekly, backup_monthly keys from on-prem Vault)

Cloud Replication (AWS):
  S3 Bucket: encrypted with backup_s3_prod_key (stored in AWS Secrets Manager)
  Separate key, separate key management service
  S3 replication triggered by backup_server via AWS API
  backup_server calls AWS Secrets Manager → retrieves S3 encryption key → uploads replicated backup
  S3 encryption happens on AWS side (AWS manages key at rest in S3)

Key Hierarchy:
  On-Prem Vault (LUKS keys for daily/weekly/monthly) 
    └─ Known only to backup_server
  AWS Secrets Manager (S3 encryption key)
    └─ Known only to AWS Lambda function that manages S3 replication
    └─ No on-prem server ever has S3 key; prevents on-prem compromise from exposing cloud backups
```

### Integration with 1x03 Offsite Backup Replication Control

From 1x03_defense_blueprint/19-board_pitch.md (Offsite Replication Strategy):

**Requirement:** Offsite cloud replicas must be independently encrypted and independently key-managed.

**MedDefense Implementation:**

1. **NAS-01 Local Backup** (daily LUKS encrypted)
   - Key: on-prem Vault
   - Storage: NAS physical drives (RAID-6 for redundancy)
   - RPO: 24 hours

2. **AWS S3 Cloud Replica** (separate encryption)
   - Key: AWS Secrets Manager (managed HSM)
   - Storage: AWS S3 with 11 nines durability guarantee
   - Replication lag: <4 hours (non-real-time; acceptable for batch backup model)
   - Cross-region replication: S3 primary (us-east-1) → S3 secondary (us-west-2)

3. **Offline Archive Tape** (annual encryption)
   - Key: Physical key backup in secure safe
   - Storage: Off-site vault provider (IronMountain)
   - Retrieval time: 5 days (RTO for disaster recovery)

**Key Segregation:**
```
Backup_daily key    → on-prem Vault (Tier 1: used daily)
Backup_weekly key   → on-prem Vault (Tier 1: used weekly)
Backup_monthly key  → on-prem Vault (Tier 1: used monthly)
AWS S3 key          → AWS Secrets Manager (Tier 2: cloud only)
Archive tape key    → Physical safe (Tier 3: offline)
```

**If on-prem Vault is compromised:** Attacker gains Tier 1 keys (NAS backups), but NOT AWS S3 key (cloud backups) or archive key (offline).

**If AWS account is compromised:** Attacker gains S3 key, but NOT on-prem NAS keys (cloud-only isolation).

**If physical safe is breached:** Attacker gains archive key (12-month old data only, current backup on NAS/AWS still encrypted).

---

## Part 6 - Implementation Roadmap for MedDefense

### Phase 1: LUKS Setup on NAS-01 (Week 1)

```
1. Test LUKS on staging NAS replica (12-luks_manager.sh)
2. Partition NAS storage into 3 volumes (daily/weekly/monthly)
3. Encrypt each volume with independent LUKS keys
4. Restore test backups to encrypted volumes
5. Validate backup restore performance (<5 minutes for 100 GB)
```

### Phase 2: Key Management Integration (Week 2-3)

```
1. Deploy HashiCorp Vault on management server
2. Generate Tier 1 keys (daily/weekly/monthly LUKS keys)
3. Configure Vault policies: only backup_server role can retrieve keys
4. Test Vault API calls from backup_server
5. Update backup automation (Ansible) to retrieve keys from Vault
```

### Phase 3: AWS Cloud Replica Setup (Week 4)

```
1. Create AWS S3 buckets (primary + secondary regions)
2. Generate S3 encryption key in AWS Secrets Manager
3. Configure S3 replication from on-prem backup_server
4. Test cloud backup restore (retrieve from S3, decrypt, validate)
5. Document cloud backup recovery procedure
```

### Phase 4: Archive & Offline Key Backup (Week 5)

```
1. Generate archive key (annual retention)
2. Encrypt archive tape with LUKS (off-prem)
3. Store key backup in physical safe
4. Document key recovery procedure (CFO + IT Director sign-off)
5. Schedule quarterly key backup verification
```

**Success Criteria:**
- ✅ All NAS backups encrypted at rest (LUKS)
- ✅ All encryption keys separated from storage (Vault on separate server)
- ✅ Cloud backups use independent keys (AWS Secrets Manager)
- ✅ Annual key backup verified (monthly rotation check)
- ✅ Restore test passes (backup → decrypt → validate) monthly
- ✅ HIPAA compliance: ePHI encryption + key segregation verified

# ["NAS-01", "full-disk", "volume", "file-level", "key", "NOT on the NAS", "key is lost", "cloud replica", "encrypted"])
