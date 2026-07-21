## CRYPTOGRAPHIC IMPLEMENTATION PLAYBOOK

### EXECUTIVE SUMMARY

MedDefense has 6 CRITICAL cryptographic deficiencies. This playbook provides 5 priority actions to remediate the highest-risk items within 60 days. All actions include step-by-step commands, validation criteria, and rollback procedures.

**Total Estimated Effort:** 120-160 hours IT staff + 60-80 hours planning/testing

---

## PRIORITY 1: EMERGENCY PORTAL CERTIFICATE RENEWAL (BLOCKER)

**Risk:** Portal certificate expired 18 days ago. Any patient accessing the portal sees security warnings. Browsers are starting to refuse connections. This is CRITICAL.

**Timeline:** IMMEDIATE (within 3 days)

### Prerequisites
- Access to DNS for portal.meddefense.local
- Email access to certificate verification account (admin@meddefense.local)
- Apache web server access + restart capability
- 30 minutes of maintenance window (off-peak hours, e.g., 2-4 AM)

### Step 1: Generate Certificate Signing Request (CSR)

```bash
# On web server (portal-srv-01), generate new private key and CSR
cd /etc/ssl/private

# Generate 2048-bit RSA key (or P-256 ECC for future upgrades)
openssl genrsa -out portal.meddefense.local.key 2048

# Alternative: ECC key (smaller, faster)
# openssl ecparam -name prime256v1 -genkey -out portal.meddefense.local.key

# Generate CSR
openssl req -new -key portal.meddefense.local.key \
  -out portal.meddefense.local.csr \
  -subj "/C=US/ST=California/L=San Francisco/O=MedDefense/CN=portal.meddefense.local"

# Verify CSR contents
openssl req -in portal.meddefense.local.csr -noout -text
```

**Expected Output:** CSR with subject C=US, O=MedDefense, CN=portal.meddefense.local

### Step 2: Submit CSR to Certificate Authority

MedDefense is transitioning from Let's Encrypt (90-day, ACME) to **DigiCert OV certificates (1-year)**. Rationale: 800 daily patients cannot afford certificate expiration incidents; manual 1-year renewal is safer than automated 90-day cycles.

```bash
# Option A: If using Let's Encrypt (faster, for emergency renewal)
certbot certonly --manual -d portal.meddefense.local \
  --rsa-key-size 2048 \
  --preferred-challenges dns

# Option B: If using DigiCert (recommended for production)
# 1. Visit DigiCert CertCentral
# 2. Upload portal.meddefense.local.csr
# 3. Select Organization Validated (OV) certificate
# 4. Complete organizational verification (email to admin@meddefense.local)
# 5. Download certificate (usually 1-2 hours)

# Once DigiCert cert is issued, download to /tmp/portal.meddefense.local.crt
```

### Step 3: Deploy Certificate on Apache

```bash
# Copy new certificate and chain to SSL directory
cp /tmp/portal.meddefense.local.crt /etc/ssl/certs/portal.meddefense.local.crt
cp /tmp/DigiCertCA.crt /etc/ssl/certs/DigiCertCA.crt (intermediate certificate)

# Update Apache configuration
nano /etc/apache2/sites-available/portal-ssl.conf

# Ensure SSLCertificateFile points to new certificate
SSLCertificateFile /etc/ssl/certs/portal.meddefense.local.crt
SSLCertificateKeyFile /etc/ssl/private/portal.meddefense.local.key
SSLCertificateChainFile /etc/ssl/certs/DigiCertCA.crt

# Verify Apache configuration syntax
apachectl configtest
# Expected: "Syntax OK"

# Reload Apache (zero-downtime)
systemctl reload apache2

# Verify certificate is deployed
echo | openssl s_client -servername portal.meddefense.local -connect portal.meddefense.local:443 2>/dev/null | openssl x509 -noout -dates
# Expected: notAfter=YYYY-MM-DD (1 year from today)
```

### Step 4: Validation

```bash
# Test 1: Certificate validity
curl https://portal.meddefense.local 2>&1 | grep "HTTP"
# Expected: HTTP/2 200 (no SSL errors)

# Test 2: Certificate chain
openssl s_client -connect portal.meddefense.local:443 -showcerts < /dev/null 2>&1 | grep "subject="
# Expected: 3 certificates in chain (leaf, intermediate, root)

# Test 3: Expiration date
echo | openssl s_client -servername portal.meddefense.local -connect portal.meddefense.local:443 2>/dev/null | openssl x509 -noout -dates
# Expected: notBefore/notAfter showing 1 year validity

# Test 4: Browser test
# Open https://portal.meddefense.local in browser
# Expected: Green lock icon, no security warnings
```

### Rollback Procedure

```bash
# If new certificate deployment causes issues:
# Restore old certificate (if still valid, use self-signed temporary)

# Step 1: Restore old Apache config
cp /etc/apache2/sites-available/portal-ssl.conf.bak /etc/apache2/sites-available/portal-ssl.conf

# Step 2: Reload Apache
systemctl reload apache2

# Step 3: Verify restoration
curl https://portal.meddefense.local 2>&1 | grep "HTTP"
```

### Communication Plan

**Before Maintenance (24 hours prior):**
Send email to all patients/staff:
```
Subject: Scheduled Portal Maintenance - 2:00-2:30 AM

Dear Patients,

Portal will be offline for 30 minutes on [DATE] from 2:00-2:30 AM PST for a security certificate update. During this time, you cannot access medical records or schedule appointments.

MedDefense IT Team
```

**During Maintenance:**
- Monitor Apache error logs for certificate errors
- Have rollback procedure ready

**After Maintenance (30 minutes after):**
Confirm portal is accessible and certificate is valid.

---

## PRIORITY 2: DATABASE CONNECTION ENCRYPTION

**Risk:** Unencrypted connections allow database sniffing; all patient queries readable on the network.

**Timeline:** 2-3 weeks

### Prerequisites
- PostgreSQL database admin access
- Ability to modify pg_hba.conf and restart database
- Network connectivity testing between ehr-srv-01 and ehr-db-01
- 2-hour maintenance window

### Step 1: Generate Database Server Certificate

```bash
# On database server (ehr-db-01)
cd /var/lib/postgresql/

# Generate certificate signing request
sudo -u postgres openssl req -new -keyout server.key -out server.csr \
  -subj "/C=US/ST=CA/O=MedDefense/CN=ehr-db-01.meddefense.local"

# Self-sign certificate (for internal use) or obtain from CA
sudo -u postgres openssl x509 -req -in server.csr \
  -signkey server.key -out server.crt \
  -days 365

# Restrict permissions
sudo -u postgres chmod 600 server.key server.crt
sudo -u postgres chmod 644 server.crt
```

### Step 2: Configure PostgreSQL for TLS

```bash
# Edit postgresql.conf
sudo nano /etc/postgresql/14/main/postgresql.conf

# Find and enable SSL
ssl = on
ssl_cert_file = '/var/lib/postgresql/server.crt'
ssl_key_file = '/var/lib/postgresql/server.key'

# Save and restart PostgreSQL
sudo systemctl restart postgresql

# Verify SSL is enabled
sudo -u postgres psql -c "SHOW ssl;"
# Expected: on
```

### Step 3: Enforce SSL Connections in pg_hba.conf

```bash
# Edit pg_hba.conf
sudo nano /etc/postgresql/14/main/pg_hba.conf

# Replace:
#   hostnossl  meddefense  all  10.10.0.0/16  md5
# With:
#   hostssl    meddefense  all  10.10.0.0/16  md5

# This REQUIRES SSL connections from 10.10.0.0/16 (application servers)
# Remove all "hostnossl" lines—require encryption

# Save and reload
sudo -u postgres psql -c "SELECT pg_reload_conf();"
```

### Step 4: Update Application Connection String

```bash
# On ehr-srv-01, update application configuration
nano /opt/meddefense_ehr/config/database.yml

# Update connection string:
# FROM: host=ehr-db-01 user=meddefense password=XXXX dbname=meddefense
# TO:   host=ehr-db-01 user=meddefense password=XXXX dbname=meddefense sslmode=require

# Restart application
sudo systemctl restart meddefense-ehr
```

### Step 5: Validation

```bash
# Test 1: Verify SSL connection
psql -h ehr-db-01 -U meddefense -d meddefense -c "SELECT ssl_is_used();"
# Expected: returns "t" (true)

# Test 2: Capture network traffic (must see encrypted handshake, not plaintext queries)
sudo tcpdump -i eth0 -n "port 5432" -A | head -50
# Expected: Binary/encrypted data, NOT plaintext SQL queries

# Test 3: Attempt non-SSL connection (should fail)
psql -h ehr-db-01 -U meddefense -d meddefense sslmode=disable -c "SELECT 1;"
# Expected: FATAL: no pg_hba.conf entry for host "10.10.X.X"
```

### Rollback

```bash
# Restore pg_hba.conf to allow hostnossl if needed
cp /etc/postgresql/14/main/pg_hba.conf.bak /etc/postgresql/14/main/pg_hba.conf
sudo -u postgres psql -c "SELECT pg_reload_conf();"
```

---

## PRIORITY 3: PATIENT DATABASE ENCRYPTION AT REST

**Risk:** Patient records stored unencrypted on ext4; if database files are copied, attacker reads all patient data.

**Timeline:** 6-8 weeks (complex, requires maintenance window)

### Prerequisites
- Database downtime authorization (must schedule during off-hours)
- 8-hour maintenance window (e.g., Sunday 10 PM - Monday 6 AM)
- Backup of database before encryption (in case of failure)
- External key storage (Vault or HSM) provisioned and tested

### Step 1: Back Up Current Database

```bash
# Create full backup before encryption
sudo -u postgres pg_dump -Fc meddefense > /backup/meddefense_pre_encryption_$(date +%Y%m%d).dump

# Verify backup size and integrity
ls -lh /backup/meddefense_pre_encryption_*.dump
sudo -u postgres pg_restore -d test_restore /backup/meddefense_pre_encryption_*.dump
```

### Step 2: Enable PostgreSQL Transparent Data Encryption (TDE)

PostgreSQL 13+ supports encrypted storage via **pgcrypto** or **Transparent Data Encryption (TDE)** extension.

```bash
# Connect to PostgreSQL as superuser
sudo -u postgres psql meddefense

-- Enable pgcrypto extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create encryption key (or reference external HSM)
-- For now, generate a test key
\! openssl rand -base64 32 > /var/lib/postgresql/encryption.key
-- This key must be stored in Vault or HSM for production
```

**Alternative: Use PostgreSQL 13+ Built-in Encryption (if available in your version):**

```bash
# PostgreSQL 13 and later support encrypted WAL
# Edit postgresql.conf:
wal_encryption = 'on'
wal_encryption_cipher = 'AES256'

# Restart PostgreSQL
sudo systemctl restart postgresql

# Verify encryption is enabled
sudo -u postgres psql -c "SHOW wal_encryption;"
# Expected: on
```

### Step 3: Store Encryption Key in External Vault

```bash
# Assuming HashiCorp Vault is running
vault kv put secret/meddefense/db-encryption-key \
  key="$(cat /var/lib/postgresql/encryption.key)"

# Update PostgreSQL configuration to reference Vault
# (This is database-dependent; consult PostgreSQL + Vault integration docs)

# Verify key is accessible
vault kv get secret/meddefense/db-encryption-key
```

### Step 4: Validate Encryption

```bash
# Verify database files are encrypted (not plaintext readable)
# This is more difficult to verify without attempting decryption

# Test 1: Check that database files exist and are large (encryption overhead)
ls -lh /var/lib/postgresql/14/main/base/

# Test 2: Attempt to read database file as plaintext (should fail)
strings /var/lib/postgresql/14/main/base/16384/16385 | grep -i "patient" | head -5
# Expected: No recognizable patient names/SSNs visible

# Test 3: Query database to confirm data is intact
sudo -u postgres psql meddefense -c "SELECT COUNT(*) FROM patient_records;"
# Expected: Returns correct count (e.g., 180000)
```

### Rollback

```bash
# If encryption causes issues, restore from backup
sudo -u postgres pg_restore -Fc -d meddefense /backup/meddefense_pre_encryption_$(date +%Y%m%d).dump

# Disable encryption in postgresql.conf
# Edit: wal_encryption = off
sudo systemctl restart postgresql
```

---

## PRIORITY 4: BACKUP ENCRYPTION + EXTERNAL KEY STORAGE

**Risk:** Backups are unencrypted; if NAS is breached, all historical patient data is readable.

**Timeline:** 3-4 weeks

### Prerequisites
- External HSM or Vault for key storage (already planned in Priority 1)
- Backup policy documentation (retention, rotation, location)
- NAS administrative access

### Step 1: Enable Volume-Level Encryption on Backup NAS

```bash
# If NAS supports LUKS encryption (Linux-based NAS)
# Format backup volume with encryption

# Warning: This DESTROYS all data on the volume; backup first
sudo cryptsetup luksFormat /dev/sdb1 --key-size 256

# Open encrypted volume
sudo cryptsetup luksOpen /dev/sdb1 backup_encrypted

# Create filesystem on encrypted volume
sudo mkfs.ext4 /dev/mapper/backup_encrypted

# Mount encrypted volume
sudo mount /dev/mapper/backup_encrypted /backup

# Verify encryption
mount | grep backup
# Expected: shows "/dev/mapper/backup_encrypted on /backup type ext4"
```

### Step 2: Store Encryption Key in External HSM

```bash
# Generate encryption key outside NAS (on secure workstation)
openssl rand -base64 256 > backup_encryption.key

# Store key in external HSM (e.g., Thales HSM or AWS CloudHSM)
# This requires HSM-specific procedures; example below assumes AWS CloudHSM

aws cloudhsm create-key \
  --key-material file://backup_encryption.key \
  --key-type AES_256

# Verify key is stored (do NOT retrieve key back to NAS)
aws cloudhsm list-keys

# Delete local copy of key file
shred -vfz backup_encryption.key
```

### Step 3: Configure Automated Backup Encryption

```bash
# Create backup script that uses external key
cat > /opt/backup_encrypted.sh << 'BACKUP_SCRIPT'
#!/bin/bash

# Backup script: encrypt database, store on encrypted NAS, validate

# Step 1: Dump database
sudo -u postgres pg_dump -Fc meddefense > /tmp/meddefense_$(date +%Y%m%d).dump

# Step 2: Encrypt backup with external key
openssl enc -aes-256-cbc -salt \
  -in /tmp/meddefense_$(date +%Y%m%d).dump \
  -out /backup/meddefense_$(date +%Y%m%d).dump.enc \
  -K "$(aws cloudhsm get-key --key-id XXXX | jq -r .KeyMaterial)"

# Step 3: Delete unencrypted temp file
shred -vfz /tmp/meddefense_$(date +%Y%m%d).dump

# Step 4: Verify encrypted backup is readable
openssl enc -aes-256-cbc -d \
  -in /backup/meddefense_$(date +%Y%m%d).dump.enc \
  -K "$(aws cloudhsm get-key --key-id XXXX | jq -r .KeyMaterial)" | head -c 100
# Expected: Binary PostgreSQL dump header

echo "Backup encrypted and validated: /backup/meddefense_$(date +%Y%m%d).dump.enc"
BACKUP_SCRIPT

chmod +x /opt/backup_encrypted.sh

# Schedule daily backup at 2 AM
echo "0 2 * * * /opt/backup_encrypted.sh" | sudo crontab -
```

### Step 4: Validation

```bash
# Test 1: Verify backup file is encrypted (not plaintext readable)
strings /backup/meddefense_20250101.dump.enc | grep -i "patient" | head -5
# Expected: No recognizable data (encrypted)

# Test 2: Verify backup can be decrypted and restored
# (Do this in test environment only)
openssl enc -aes-256-cbc -d \
  -in /backup/meddefense_20250101.dump.enc \
  -K "$(aws cloudhsm get-key --key-id XXXX | jq -r .KeyMaterial)" | \
  sudo -u postgres pg_restore -d test_db -
# Expected: Database restored successfully in test environment

# Test 3: Confirm key is NOT stored on NAS
find /backup -name "*key*" -o -name "*secret*" 2>/dev/null
# Expected: No key files found on NAS
```

---

## PRIORITY 5: DICOM TLS ENCRYPTION

**Risk:** DICOM traffic is transmitted in cleartext; medical imaging data is visible to network attackers.

**Timeline:** 2-3 weeks

### Prerequisites
- DICOM server administrative access (pacs-srv-01)
- Certificate for PACS (can reuse DigiCert OV cert or create new self-signed for internal)
- Network testing between DICOM clients and PACS server

### Step 1: Generate DICOM Server Certificate

```bash
# On PACS server
cd /opt/dcmtk/etc

# Generate self-signed certificate (acceptable for internal DICOM)
openssl req -x509 -newkey rsa:2048 -keyout dicom-key.pem \
  -out dicom-cert.pem -days 365 \
  -subj "/C=US/ST=CA/O=MedDefense/CN=pacs-srv-01.meddefense.local"

# Verify certificate
openssl x509 -in dicom-cert.pem -noout -text
```

### Step 2: Enable TLS on DICOM Server

```bash
# Edit DICOM configuration (example using dcmtk storescp)
# The exact configuration depends on your DICOM software

# Example: DCMTK storescp with TLS
storescp --tls-require \
  --tls-cert /opt/dcmtk/etc/dicom-cert.pem \
  --tls-key /opt/dcmtk/etc/dicom-key.pem \
  4242

# Alternative: If using other DICOM software (Orthanc, DCMJS, etc.)
# Update configuration file to enable TLS:
# dicom.tls.enabled = true
# dicom.tls.certificate = /opt/dcmtk/etc/dicom-cert.pem
# dicom.tls.key = /opt/dcmtk/etc/dicom-key.pem
```

### Step 3: Configure DICOM Clients to Use TLS

```bash
# On modalities (CT, MRI, Ultrasound) and DICOM clients
# Enable TLS connection to PACS

# Example: DCMTK storescu (DICOM send client)
storescu --tls-profile-bcp195 -c 4242 pacs-srv-01.meddefense.local study.dcm

# Update any application configurations to enforce DICOM TLS
```

### Step 4: Validation

```bash
# Test 1: Verify TLS handshake succeeds
echo "test" | openssl s_client -connect pacs-srv-01:4242 2>&1 | grep "SSL handshake"
# Expected: SSL handshake successful

# Test 2: Capture DICOM traffic (should see encrypted handshake, not plaintext DICOM)
sudo tcpdump -i eth0 -n "port 4242" -A | head -50
# Expected: Binary/encrypted data, NOT plaintext DICOM tags

# Test 3: Send test DICOM image
# (Use DICOM client to send test study to PACS)
# Expected: PACS receives image; no errors; client shows encrypted connection

# Test 4: Verify non-TLS connection is rejected
echo "test" | openssl s_client -connect pacs-srv-01:4242 -no_tls1_3 2>&1 | grep -i "error"
# Expected: Connection error or protocol negotiation failure
```

---

## IMPLEMENTATION SCHEDULE

| Week | Action | Owner | Resource Hours | Status |
|---|---|---|---|---|
| **THIS WEEK** | P1: Emergency portal cert renewal | Sarah Park | 4 | 🔴 URGENT |
| Week 2 | P2: Database connection encryption (pg_hba.conf + TLS) | DBA | 20 | 📋 Planned |
| Week 2-3 | P4: Backup volume encryption setup | IT Ops | 16 | 📋 Planned |
| Week 3 | P5: DICOM TLS configuration | Biomedical | 12 | 📋 Planned |
| Week 4-8 | P3: Database encryption at rest (major task) | DBA + IT Ops | 80 | 📋 Planned |
| Ongoing | Monitoring: Certificate alerts, encryption status | IT Ops | 4 hours/week | 🔄 Ongoing |

**Total Effort:** ~132 hours IT staff

**Total Estimated Cost:** $8,000-12,000 (staff time + tools + HSM/Vault licensing)

---

## SUCCESS CRITERIA

After completing all 5 priorities, MedDefense should have:

- ✅ Portal certificate renewed + valid for 1 year
- ✅ Database connections encrypted (TLS 1.2+)
- ✅ Patient database encrypted at rest (PostgreSQL TDE or LUKS)
- ✅ Backups encrypted + keys stored externally
- ✅ DICOM traffic encrypted (TLS)
- ✅ Certificate monitoring alerts configured
- ✅ Key management documented and tested
- ✅ HIPAA encryption requirements substantially addressed (Compliance Score: 80%+)

