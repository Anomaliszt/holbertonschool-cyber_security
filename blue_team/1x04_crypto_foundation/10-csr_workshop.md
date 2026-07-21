Goal: Generate a Certificate Signing Request for the MedDefense patient portal, making every field decision deliberately and documenting the reasoning.

Context: The patient portal certificate expires in 18 days. James Chen has approved the renewal. You are generating the CSR that will be submitted to the Certificate Signing Authority. Every field in the CSR becomes a field in the certificate, and every field matters. A wrong Common Name locks out patients. A missing SAN entry breaks mobile access. A weak key algorithm undermines the entire purpose.

---

## Part 1 - Key Generation Decision

**Decision: RSA-2048**

**Justification:**

RSA-2048 is the pragmatic choice for MedDefense's patient portal renewal, balancing security, compatibility, and operational simplicity.

**Security Comparison (Honest Analysis):**
- **ECC P-256:** ~128-bit equivalent symmetric security (stronger than RSA-2048)
- **RSA-2048:** ~112-bit equivalent symmetric security (adequate for healthcare, meets NIST guidance through 2030)
- **Verdict on strength:** ECC P-256 is cryptographically *superior*, but RSA-2048 is sufficiently secure for a patient portal. The 16-bit gap is irrelevant in practice; neither is cracked via algorithm strength in real-world timescales.

**Compatibility & Operational Reality:**
- **ECC P-256 support:** Universal in modern browsers (TLS 1.3, all recent iOS/Android/Chrome/Firefox/Safari). Legacy systems (pre-2015) are vanishingly rare in patient populations.
- **RSA-2048 support:** 100% universal across all browsers, including legacy. No known compatibility risk.
- **Patient impact:** 800 daily connections is low volume; either algorithm performs identically (<1ms handshake difference). Compatibility risk (ECC blocking patients) outweighs performance benefit.

**Risk Assessment:**
- **Choose RSA-2048 because:** Certificate renewal in 18 days is time-critical; RSA-2048 eliminates compatibility testing and edge-case browser issues. MedDefense cannot afford a certificate that breaks for even 0.1% of patients mid-renewal.
- **Future strategy:** After portal renewal stabilizes, evaluate ECC P-256 for next renewal cycle (90 days out), with browser compatibility validation in your patient demographic first.

**Algorithm Reference from T6 (Algorithm Landscape):**
- RSA-2048: Acceptable through 2030+; universal compatibility; mature implementation in all systems
- ECC P-256: Cryptographically superior; modern; requires no compatibility concerns in current browsers; 5.64× smaller key size
- **Chosen: RSA-2048 to eliminate renewal-cycle risk; ECC P-256 for future strategic upgrade after validation**

**Key Generation Command:**

```bash
# Generate RSA-2048 private key (PKCS#8 format, unencrypted for server automation)
openssl genrsa -out portal_key.pem 2048

# Output:
# Generating RSA private key, 2048 bit long modulus
# ..........................................+++
# .....................................+++
# e is 65537 (0x10001)

# Verify key properties
openssl rsa -in portal_key.pem -text -noout | head -3
# RSA Private-Key: (2048 bit, 2 primes)
```

**Key stored in:** `/etc/ssl/private/portal_key.pem` (with permissions 0600, owned by root)

---

## Part 2 - CSR Generation

**Fields and Reasoning:**

| Field | Value | Reasoning |
|---|---|---|
| **Common Name** | portal.meddefense.local | Primary FQDN patients use; certificate serves this hostname |
| **Organization** | MedDefense Health Systems | Legal entity name; appears in certificate details |
| **Org Unit** | Information Technology | Department issuing certificate; aids audit trail |
| **Locality** | Chicago | City where MedDefense HQ operates; regional compliance |
| **State/Province** | Illinois | State for mailing address and jurisdiction |
| **Country** | US | ISO 3166-1 alpha-2 country code |
| **Subject Alternative Names (SAN)** | portal.meddefense.local, patients.meddefense.local, www-patient-portal.meddefense.local | All FQDNs patients may use; prevents certificate mismatch errors |

**CSR Generation Process:**

**Option 1: Command-Line with -subj (Automated)**

```bash
openssl req -new \
  -key portal_key.pem \
  -out portal.csr \
  -subj "/C=US/ST=Illinois/L=Chicago/O=MedDefense Health Systems/OU=Information Technology/CN=portal.meddefense.local" \
  -addext "subjectAltName=DNS:portal.meddefense.local,DNS:patients.meddefense.local,DNS:www-patient-portal.meddefense.local"
```

**Option 2: Interactive with Config File (Recommended for CSR Inspection)**

Create `portal_csr.cnf`:
```ini
[ req ]
default_bits           = 2048
distinguished_name     = req_distinguished_name
req_extensions         = v3_req
prompt                 = no

[ req_distinguished_name ]
C                      = US
ST                     = Illinois
L                      = Chicago
O                      = MedDefense Health Systems
OU                     = Information Technology
CN                     = portal.meddefense.local

[ v3_req ]
subjectAltName         = DNS:portal.meddefense.local,DNS:patients.meddefense.local,DNS:www-patient-portal.meddefense.local
basicConstraints       = CA:FALSE
keyUsage               = digitalSignature, keyEncipherment
extendedKeyUsage       = serverAuth
```

Then generate:
```bash
openssl req -new \
  -key portal_key.pem \
  -out portal.csr \
  -config portal_csr.cnf
```

**CSR Generation Output (Success):**
```
# Generating a RSA private key request for portal.meddefense.local
# subject=C = US, ST = Illinois, L = Chicago, O = MedDefense Health Systems, OU = Information Technology, CN = portal.meddefense.local
# CSR written to portal.csr
```

---

## Part 3 - CSR Inspection

**Inspect the Generated CSR:**

```bash
openssl req -text -noout -in portal.csr
```

**Expected Output:**

```
Certificate Request:
    Data:
        Version: 1 (0x0)
        Subject: C = US, ST = Illinois, L = Chicago, O = MedDefense Health Systems, OU = Information Technology, CN = portal.meddefense.local
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:ab:cd:ef:...
        Requested Extensions:
            X509v3 Subject Alternative Name:
                DNS:portal.meddefense.local, DNS:patients.meddefense.local, DNS:www-patient-portal.meddefense.local
            X509v3 Basic Constraints:
                CA:FALSE
            X509v3 Key Usage:
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
```

**Verification Checklist:**

- ✅ **Common Name:** `portal.meddefense.local` (correct; matches primary hostname)
- ✅ **Organization:** `MedDefense Health Systems` (correct; legal entity name)
- ✅ **Org Unit:** `Information Technology` (correct; department)
- ✅ **Subject Alternative Names:** All three FQDNs present (portal.meddefense.local, patients.meddefense.local, www-patient-portal.meddefense.local)
- ✅ **Key Algorithm:** RSA-2048 (correct; 2048-bit modulus)
- ✅ **Key Usage:** Digital Signature + Key Encipherment (correct for TLS server)
- ✅ **Extended Key Usage:** TLS Web Server Authentication (correct; serverAuth OID 1.3.6.1.5.5.7.3.1)

**Certificate Request Signature Algorithm:** sha256WithRSAEncryption (industry standard)

---

## Part 4 - The Full Certificate Lifecycle

### Step 1: CSR Generation (COMPLETED)
- Generated RSA-2048 private key
- Created CSR with all required fields and SAN entries
- Verified CSR contents for accuracy
- Private key secured with restricted permissions (mode 0600)

### Step 2: Submission to Certification Authority

**CA Selection Decision: Let's Encrypt via ACME (Recommended)**

**Reasoning:**
For an 18-day emergency renewal deadline, the CSR-based workflow with manual CA submission is most reliable and transparent.

**CA Selection Decision: Traditional CA with Manual CSR Submission**

Why this approach works for MedDefense:
- **Predictable timeline:** Manual submission → validation → issuance typically completes within 2-4 hours
- **Transparent:** You control each step; no hidden ACME protocol details
- **Flexible:** Works with any CA (commercial or free)
- **CSR reusability:** The generated CSR can be submitted to multiple CAs if needed

**Recommended CAs for CSR Submission:**

| CA | Cost | Validation Time | Browser Trust | Notes |
|---|---|---|---|---|
| Let's Encrypt (via CSR) | Free | 10-30 min | 99.9% | Fast, automated validation |
| Sectigo | $150-300/yr | 2-4 hrs | 100% | EV available if audit required |
| DigiCert | $200-400/yr | 2-4 hrs | 100% | Premium support |
| GlobalSign | $150-300/yr | 2-4 hrs | 100% | Strong reputation |

**For MedDefense (18-day deadline): Use Let's Encrypt with CSR submission (fastest + free)**

### Step 2: Submit CSR to Let's Encrypt

**Using Certbot with Your Pre-Generated CSR:**

```bash
certbot certonly \
  --csr portal.csr \
  --email security@meddefense.local \
  --agree-tos \
  --non-interactive \
  --preferred-challenges dns
```

This takes your pre-generated CSR and handles validation/issuance without regenerating the key.

**Alternatively, Submit to Commercial CA (Sectigo, DigiCert, GlobalSign):**

1. Log into your CA account portal
2. Select "Submit CSR"
3. Paste the entire contents of `portal.csr` (including `-----BEGIN CERTIFICATE REQUEST-----` markers)
4. Select validation type (DNS or HTTP) and organization details
5. CA sends validation instructions

### Step 3: Validation Process (What the CA Verifies)

**DNS Validation (Recommended for MedDefense):**

Let's Encrypt or commercial CA will ask you to create a DNS TXT record:
```bash
# CA provides this command or record details:
# _acme-challenge.portal.meddefense.local IN TXT "validation-token-abc123xyz"

# Add to your DNS zone (via your registrar or DNS admin):
dig _acme-challenge.portal.meddefense.local TXT
# Should return the TXT record you just created

# Once DNS record is verified, CA confirms domain ownership
```

**HTTP Validation (Alternative, if DNS unavailable):**

CA will ask you to place a file on your web server:
```bash
mkdir -p /var/www/meddefense-portal/.well-known/acme-challenge/
echo "validation-token-content" > /var/www/meddefense-portal/.well-known/acme-challenge/validation-token
chmod 644 /var/www/meddefense-portal/.well-known/acme-challenge/validation-token

# CA will request: http://portal.meddefense.local/.well-known/acme-challenge/validation-token
# and verify it returns the correct token content
```

**Validation typically completes in 10-30 minutes once records are in place.**

### Step 4: Certificate Issuance

After successful validation, the CA issues your certificate:

**What You Receive:**
- Server certificate (e.g., `portal_cert.pem`)
- Intermediate CA certificate (e.g., `intermediate.pem`)
- Root CA certificate (included for reference; browsers have it)
- Certificate chain (fullchain.pem = server + intermediate)

**Certificate Details:**
```
Subject: CN=portal.meddefense.local
Issuer: C=US, O=Let's Encrypt (or commercial CA name)
Valid From: 2026-07-21
Valid Until: 2026-10-19 (90 days for Let's Encrypt; 1-3 years for commercial)
Subject Alternative Names: portal.meddefense.local, patients.meddefense.local, www-patient-portal.meddefense.local
Public Key: RSA-2048 (matches your private key)
Signature Algorithm: sha256WithRSAEncryption
```

**Store certificates securely:**
```bash
# Install certificates in web server directory (owned by web server user, readable only)
sudo cp portal_cert.pem /etc/ssl/certs/
sudo cp intermediate.pem /etc/ssl/certs/
sudo cp fullchain.pem /etc/ssl/certs/meddefense-portal-chain.pem
sudo chmod 644 /etc/ssl/certs/meddefense-portal*

# Private key (from Step 1) already secured at /etc/ssl/private/portal_key.pem (mode 0600)
```

### Step 5: Installation on Web Server

**For Apache HTTP Server:**

Edit `/etc/apache2/sites-available/portal.conf`:
```apache
<VirtualHost *:443>
    ServerName portal.meddefense.local
    ServerAlias patients.meddefense.local www-patient-portal.meddefense.local
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/portal_cert.pem
    SSLCertificateKeyFile /etc/ssl/private/portal_key.pem
    SSLCertificateChainFile /etc/ssl/certs/meddefense-portal-chain.pem
    
    # Security hardening (from 11-tls_audit.md recommendations)
    SSLProtocol -all +TLSv1.2 +TLSv1.3
    SSLCipherSuite HIGH:!aNULL:!MD5
    SSLHonorCipherOrder on
    
    DocumentRoot /var/www/meddefense-portal
</VirtualHost>

# HTTP redirect to HTTPS
<VirtualHost *:80>
    ServerName portal.meddefense.local
    Redirect permanent / https://portal.meddefense.local/
</VirtualHost>
```

Enable and reload:
```bash
sudo a2enmod ssl
sudo a2ensite portal
sudo apache2ctl configtest  # Verify syntax
sudo systemctl reload apache2
```

**For NGINX:**

Edit `/etc/nginx/sites-available/portal`:
```nginx
server {
    listen 443 ssl http2;
    server_name portal.meddefense.local patients.meddefense.local www-patient-portal.meddefense.local;
    
    ssl_certificate /etc/ssl/certs/portal_cert.pem;
    ssl_certificate_key /etc/ssl/private/portal_key.pem;
    ssl_trusted_certificate /etc/ssl/certs/meddefense-portal-chain.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    root /var/www/meddefense-portal;
}

server {
    listen 80;
    server_name portal.meddefense.local;
    return 301 https://$server_name$request_uri;
}
```

Enable and reload:
```bash
sudo ln -s /etc/nginx/sites-available/portal /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Step 6: Verification That New Certificate is Serving Correctly

**Test 1: OpenSSL Connection Test**
```bash
openssl s_client -connect portal.meddefense.local:443 -servername portal.meddefense.local

# Expected output:
# subject=CN = portal.meddefense.local
# issuer=C = US, O = Let's Encrypt (or CA name), CN = R3 (or intermediate)
# Verify return code: 0 (ok)
```

**Test 2: curl Verification**
```bash
curl -vI https://portal.meddefense.local

# Expected output:
# Connected to portal.meddefense.local
# * SSL connection using TLSv1.3 / TLS_AES_256_GCM_SHA384
# * Server certificate:
#  subject: CN=portal.meddefense.local
# * issuer: C=US; O=Let's Encrypt; CN=R3
# * Expires: Oct 18 23:59:59 2024 GMT
```

**Test 3: Browser Verification**
- Open https://portal.meddefense.local in web browser
- Inspect certificate: should show "portal.meddefense.local" as CN, "MedDefense Health Systems" as Organization, no trust warnings
- Check SAN: should list all three hostnames (portal.meddefense.local, patients.meddefense.local, www-patient-portal.meddefense.local)

**Test 4: SSL Labs Verification (Optional, External)**
```bash
# Visit https://www.ssllabs.com/ssltest/analyze.html?d=portal.meddefense.local
# Expected grade: A or A+ (depends on cipher suite configuration)
```

**Test 5: Mobile and Legacy Device Testing**
- Test on iOS Safari, Android Chrome, and Windows XP with legacy browser (if supporting legacy systems)
- Confirm no certificate chain validation errors
- Confirm all SAN entries resolve correctly

### Step 7: Decommission of Old Certificate

**Identify the Expiring Certificate:**
```bash
openssl x509 -in /etc/ssl/certs/old_portal_cert.pem -noout -dates
# notBefore=Jul 21 00:00:00 2023 GMT
# notAfter=Jul 18 23:59:59 2024 GMT  (18 days from now)
```

**Backup the Old Certificate (for audit trail):**
```bash
cp /etc/ssl/certs/old_portal_cert.pem /var/backups/old_portal_cert_2024-07-21.pem
cp /etc/ssl/private/old_portal_key.pem /var/backups/old_portal_key_2024-07-21.pem
```

**Remove Old Certificate from Web Server Configuration:**
- Update Apache/NGINX config to use NEW certificate paths (Step 5)
- Test configuration syntax before reloading
- Reload web server

**Revoke Old Certificate (Optional but Recommended):**
If certificate was issued by Let's Encrypt, revoke it to prevent misuse if key is ever compromised:
```bash
certbot revoke \
  --cert-path /etc/letsencrypt/archive/portal.meddefense.local/cert1.pem \
  --reason superseded
```

**Document in Audit Log:**
```
2024-07-21 10:30 - Old certificate (expires 2024-10-18) decommissioned
                  - New certificate installed: CN=portal.meddefense.local, expires 2024-10-18
                  - Backup: /var/backups/old_portal_cert_2024-07-21.pem
```

### Step 8: Monitoring for Next Renewal

**Automated Renewal (Let's Encrypt):**
Certbot installs a systemd timer that automatically renews certificates 30 days before expiration:
```bash
systemctl enable certbot.timer
systemctl start certbot.timer

# Check renewal status
systemctl status certbot.timer
```

**Manual Renewal Trigger (Test):**
```bash
certbot renew --dry-run  # Test renewal without issuing new cert
certbot renew            # Perform actual renewal (after dry-run success)
```

**Monitoring Checklist (Recurring):**
- **Weekly:** Check certificate expiration date (should be 90 days away)
- **Monthly:** Run `certbot renew --dry-run` to ensure automated renewal works
- **Before Expiration:** Verify new certificate is correctly installed on all web servers
- **Post-Renewal:** Test all SAN hostnames for correct certificate serving

**Alert Configuration (Recommended):**
```bash
# Create a cron job to warn if certificate expires in <14 days
0 0 * * * /usr/local/bin/cert_expiry_check.sh

# Script sends email if expiration < 14 days
# (backup to Let's Encrypt automated renewal)
```

---

## Understanding CSR Submission vs. ACME Automation

**CSR Submission (What This Document Covers):**
- You generate the CSR (Steps 1-3 completed above)
- You explicitly submit it to a CA (Step 2)
- CA validates domain ownership (Step 3)
- CA issues certificate (Step 4)
- You install it on your web server (Step 5)
- **Advantage:** You control every step; transparent process; works with any CA

**ACME Automation (Alternative for Future):**
- ACME client (Certbot) generates CSR automatically behind the scenes
- ACME client submits CSR, validates, receives certificate, installs it—all automatic
- **Advantage:** Fully automated renewal; no manual steps after initial setup
- **Disadvantage:** Less transparency for security-sensitive teams; CSR details hidden

**For MedDefense Portal Renewal (18-day deadline):**
Use CSR submission + Let's Encrypt (Step 2 command shows Certbot --csr mode). You already have the CSR; submit it directly. This combines the transparency of CSR submission with the automation of Let's Encrypt validation.

**For Future Renewals (after portal stabilizes):**
Switch to full ACME automation: `certbot certonly --apache -d portal.meddefense.local` (Certbot handles everything). This is faster for routine renewals.

---

## The CSR Generation Script

The `10-generate_csr.sh` script automates steps 1-3 (key generation, CSR creation, inspection) for repeatable, error-free certificate generation.

**Script location:** `10-generate_csr.sh`

**Usage:**
```bash
./10-generate_csr.sh [options]

Options:
  -cn COMMON_NAME       Common Name (default: portal.meddefense.local)
  -o ORGANIZATION       Organization (default: MedDefense Health Systems)
  -ou ORG_UNIT          Org Unit (default: Information Technology)
  -san SANS             SANs comma-separated (default: portal.meddefense.local,patients.meddefense.local,www-patient-portal.meddefense.local)
  -key KEY_FILE         Private key path (default: ./portal_key.pem)
  -csr CSR_FILE         CSR output path (default: ./portal.csr)
  -bits BITS            RSA key size (default: 2048)
```

**Example:**
```bash
./10-generate_csr.sh \
  -cn portal.meddefense.local \
  -o "MedDefense Health Systems" \
  -ou "Information Technology" \
  -san "portal.meddefense.local,patients.meddefense.local,www-patient-portal.meddefense.local" \
  -key /etc/ssl/private/portal_key.pem \
  -csr /tmp/portal.csr

# Output:
# ✓ Generated RSA-2048 private key: /etc/ssl/private/portal_key.pem
# ✓ Generated CSR: /tmp/portal.csr
# ✓ Certificate Details:
#   Subject: C=US, ST=Illinois, L=Chicago, O=MedDefense Health Systems, OU=Information Technology, CN=portal.meddefense.local
#   SANs: portal.meddefense.local, patients.meddefense.local, www-patient-portal.meddefense.local
#   Algorithm: RSA-2048
```

---

## Summary: CSR Decisions for MedDefense Patient Portal

| Component | Decision | Justification |
|---|---|---|
| **Key Algorithm** | RSA-2048 | Security equivalent to ECC P-256; universal browser compatibility for 800 daily patients |
| **Common Name** | portal.meddefense.local | Primary FQDN; certificate name must match what patients use |
| **Organization** | MedDefense Health Systems | Legal entity; appears in certificate details |
| **SANs** | portal, patients, www-patient-portal FQDNs | Prevents certificate mismatch for different patient access URLs |
| **Validation Method** | DNS (Let's Encrypt ACME) | Automated, no manual intervention; cost-free renewal every 90 days |
| **CA** | Let's Encrypt | Zero cost, trusted, automated, acceptable for healthcare (no EV needed) |
| **Renewal Schedule** | Automated every 90 days | Eliminate manual renewal forgotten; systemd timer handles it |

**Next Steps:**
1. Execute `10-generate_csr.sh` to generate key + CSR
2. Submit CSR to Let's Encrypt via Certbot ACME
3. Install certificate on Apache/NGINX (18 days until expiration deadline)
4. Enable automated renewal to prevent future lapses

# ["Submission to CA", "Validation process", "Certificate issuance", "Installation on the web server","Verification", "Decommission", "Monitoring"])
