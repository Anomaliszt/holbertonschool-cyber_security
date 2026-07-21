Goal: Evaluate real-world TLS configurations using SSL Labs, produce a remediation plan for MedDefense's patient portal, and write a hardened TLS configuration.

Context: Finding 005 from your vulnerability assessment (1x02) identified that the patient portal still supports TLS 1.0 alongside TLS 1.2. That finding has been sitting on the remediation list for 3 weeks. Now you have the knowledge to fix it. But before you write the configuration, you need to understand what a good TLS configuration looks like and what a bad one looks like, using real data from real websites.

---

## PART 1: SSL LABS ANALYSIS REFERENCE

### A+ Grade Website Example: Cloudflare.com

**SSL Labs Grade:** A+

**Protocol Support (Best Practice):**
- TLS 1.3: ✅ Enabled (only modern protocol supported)
- TLS 1.2: ✅ Enabled (for legacy client support)
- TLS 1.1: ❌ Disabled
- TLS 1.0: ❌ Disabled
- SSL 3.0 and earlier: ❌ Disabled

**Key Exchange Strength:**
- Supported: ECDHE with P-256, P-384
- Rating: Excellent (forward secrecy enabled; ephemeral keys)
- No support for DH or static key exchange

**Cipher Suite Strength (Order of Preference):**
1. TLS_AES_256_GCM_SHA384 (TLS 1.3) ← Primary choice
2. TLS_CHACHA20_POLY1305_SHA256 (TLS 1.3)
3. ECDHE-ECDSA-AES256-GCM-SHA384 (TLS 1.2)
4. ECDHE-RSA-AES256-GCM-SHA384 (TLS 1.2)
5. No RC4, no DES, no 3DES, no MD5, no SHA-1

**Certificate Details:**
- Type: OV (Organization Validated) or EV
- Key Algorithm: ECC P-256 or RSA-2048+
- Validity: 1-year (or less)
- Chain: Complete chain provided (no missing intermediates)
- OCSP Stapling: ✅ Enabled

**Security Headers (HSTS, etc.):**
- HSTS: ✅ Enabled, max-age=31536000 (1 year), includeSubDomains
- Content Security Policy: ✅ Present
- X-Frame-Options: ✅ DENY or SAMEORIGIN
- X-Content-Type-Options: ✅ nosniff

**Warnings/Weaknesses:** None significant

**Why A+ Rating:**
- Modern protocols only (TLS 1.3 + TLS 1.2)
- Strong cipher suites with forward secrecy
- Perfect organization of cipher suite precedence
- Complete certificate chain
- Security headers present

---

### B Grade Website Example: Hypothetical Legacy Configuration

**SSL Labs Grade:** B

**Protocol Support (Common Problems):**
- TLS 1.2: ✅ Enabled
- TLS 1.1: ✅ Enabled (WEAKNESS: deprecated protocol still usable)
- TLS 1.0: ✅ Enabled (WEAKNESS: very old protocol with known attacks)
- TLS 1.3: ❌ Not supported

**Key Exchange Strength:**
- Supported: RSA key exchange (static, no forward secrecy) ⚠️
- Some support for ECDHE (good)
- Mix of forward-secure and static exchange

**Cipher Suite Strength (Problems):**
1. ECDHE-RSA-AES128-SHA (weak hash: SHA-1)
2. AES128-SHA (no perfect forward secrecy)
3. RC4-SHA (broken cipher, should not be used)

**Certificate Details:**
- Type: DV (Domain Validated only)
- Key Algorithm: RSA-2048
- Validity: 2 years
- Warnings: Chain might be incomplete

**Security Headers:**
- HSTS: ⚠️ Not configured (or weak max-age)
- CSP: ❌ Not present
- Other headers: ❌ Missing

**Weaknesses Identified:**
- Supports deprecated TLS 1.0/1.1 (vulnerable to downgrade attacks)
- No forward secrecy for all connections
- Weak cipher suites still available
- Missing security headers
- No OCSP Stapling

---

## PART 2: MEDDEFENSE PORTAL ASSESSMENT

### Predicted SSL Labs Grade: D (if publicly tested)

**Finding 005 Issues:**
- ❌ TLS 1.0 supported (BEAST, POODLE, Lucky Thirteen vulnerabilities)
- ✅ TLS 1.2 supported (acceptable, but...TLS 1.3 missing)
- ❌ No indication of TLS 1.3 support
- ❌ Certificate expires in 18 days (Finding 013)

### Issues That Would Reduce Grade

| Issue | Impact | Grade Reduction |
|---|---|---|
| **TLS 1.0 Support** | Critical - Outdated protocol with known breaks | A → C |
| **No TLS 1.3** | High - Missing modern protocol standard since 2018 | C → D |
| **Certificate Expiration (18 days)** | Critical - Certificate will be invalid | Any grade → F (check failure) |
| **Missing HSTS Header** | Medium - No browser pinning to HTTPS | - |
| **Certificate Self-Signed/DV Only** | Medium - Cannot verify organization identity | A → B |
| **Weak Cipher Suites** (if enabled) | High - Cryptanalysis attacks possible | Depends on suites |
| **No OCSP Stapling** | Low - Revocation checking slower | - |
| **No CAA Records** | Low - Domain not protected against rogue CA issuance | - |

### Remediation Priority

**Immediate (24 hours):**
1. Renew certificate before expiration (Finding 013)
2. Disable TLS 1.0 (Finding 005)
3. Enable TLS 1.3

**Short-term (1 week):**
4. Configure HSTS header
5. Select strong cipher suites (AES-256-GCM + ChaCha20)
6. Enable OCSP Stapling

**Medium-term (30 days):**
7. Issue new OV certificate (better than current DV)
8. Set up CAA DNS records
9. Implement security headers (CSP, X-Frame-Options, etc.)

---

## PART 3: HARDENED TLS CONFIGURATION (Apache)

### Apache 2.4 Hardened Configuration

```apache
# /etc/apache2/mods-enabled/ssl-hardened.conf

# ============================================================================
# TLS/SSL Security Configuration for MedDefense Patient Portal
# ============================================================================

# Enable TLS 1.2 and TLS 1.3 ONLY; disable older protocols
SSLProtocol             -all +TLSv1.2 +TLSv1.3

# Set strong cipher suites in order of preference
# TLS 1.3 cipher suites (first)
SSLCipherSuite          TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256
# TLS 1.2 cipher suites (fallback)
SSLCipherSuite          ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305

# Prioritize server cipher selection; prevent client from choosing weak ciphers
SSLHonorCipherOrder     on

# Disable SSL/TLS renegotiation (prevent downgrade attacks)
SSLInsecureRenegotiation off

# Set strong ECDH curves only (P-256, P-384)
SSLOpenSSLConfCmd       Curves P-256:P-384

# Enable session tickets for performance (cryptographically secure)
SSLSessionTickets       on

# Session ticket encryption keys (rotate daily in production)
SSLSessionTicketKeyFile /etc/apache2/ssl/session_key.bin

# Enable OCSP Stapling (fast revocation checking)
SSLStaplingCache        "shmcb:logs/stapling_cache(512000)"
SSLUseStapling          on

# ============================================================================
# HSTS - Force browsers to use HTTPS only
# ============================================================================

Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
# max-age=31536000 = 1 year; tells browser NEVER use HTTP for this domain
# includeSubDomains = apply policy to all subdomains
# preload = allow domain in browser HSTS preload list (prevents MITM even on first visit)

# ============================================================================
# Additional Security Headers
# ============================================================================

Header always set X-Content-Type-Options "nosniff"
# Prevents browsers from MIME-sniffing content types; enforces Content-Type

Header always set X-Frame-Options "DENY"
# Prevents clickjacking; disallow framing from other domains

Header always set Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'"
# Restrict scripts/styles to origin only; prevent XSS attacks

Header always set Referrer-Policy "strict-origin-when-cross-origin"
# Limit referrer information leaked to other domains

# ============================================================================
# Certificate Configuration
# ============================================================================

# Server certificate (OV certificate from DigiCert or Sectigo)
SSLCertificateFile      /etc/apache2/ssl/portal_meddefense_ov.crt

# Private key (protected with restricted permissions: chmod 400)
SSLCertificateKeyFile   /etc/apache2/ssl/portal_meddefense_ov.key

# Intermediate CA certificate chain
SSLCertificateChainFile /etc/apache2/ssl/DigiCert_chain.crt

# ============================================================================
# Logging
# ============================================================================

LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" \"%{SSL_PROTOCOL}x\" \"%{SSL_CIPHER}x\"" ssl_combined

CustomLog ${APACHE_LOG_DIR}/ssl_access.log ssl_combined
ErrorLog  ${APACHE_LOG_DIR}/ssl_error.log
```

### Configuration Explanations

| Parameter | Setting | Reasoning |
|---|---|---|
| **SSLProtocol** | -all +TLSv1.2 +TLSv1.3 | Only modern protocols; disables TLS 1.0/1.1, SSL 3.0 (which are vulnerable to BEAST, POODLE, downgrade attacks) |
| **SSLCipherSuite (TLS 1.3)** | TLS13-AES-256-GCM-SHA384 (primary) | AES-256-GCM provides 256-bit encryption + authentication; NIST FIPS approved; fastest modern cipher |
| **SSLCipherSuite (TLS 1.2)** | ECDHE-ECDSA-AES256-GCM-SHA384 (first) | ECDHE = forward secrecy (if server key compromised, past sessions remain secure); RSA fallback for compatibility |
| **SSLHonorCipherOrder** | on | Forces server to choose strongest cipher from client's list; prevents weak cipher selection by client |
| **SSLInsecureRenegotiation** | off | Prevents attacker from forcing renegotiation to downgrade to weaker protocols |
| **SSLOpenSSLConfCmd Curves** | P-256:P-384 | Only modern ECDH curves; disables weak curves (P-192, P-224); P-256 sufficient for most healthcare use |
| **SSLSessionTickets** | on | Enables stateless session resumption (client can resume session without server session table); improves performance |
| **SSLStaplingCache** | Enabled | Server queries OCSP responder and includes response in handshake; client gets revocation status immediately (no separate OCSP query needed) |
| **HSTS max-age** | 31536000 (1 year) | Browsers will not allow HTTP connections for 1 year; protects against SSLStrip attacks; long duration for healthcare data |
| **X-Content-Type-Options** | nosniff | Browsers enforce Content-Type header; prevents MIME-sniffing attacks (e.g., serving JavaScript as image) |
| **X-Frame-Options** | DENY | Prevents clickjacking; pages cannot be framed in iframes from other domains |
| **Referrer-Policy** | strict-origin-when-cross-origin | Limits referrer data to prevent information leakage to external sites |

---

## PART 4: TLS DOWNGRADE ATTACK

### How TLS Downgrade Attack Works

A TLS downgrade attack occurs when an attacker intercepts the TLS handshake negotiation and forces the client and server to agree on a weaker protocol version than both would normally support. **Here's the mechanism:**

1. **Client connects to portal.meddefense.local over TLS**
2. **Client sends ClientHello:** "I support TLS 1.3, 1.2, 1.0"
3. **Attacker intercepts ClientHello** (man-in-the-middle on network)
4. **Attacker modifies ClientHello:** Removes TLS 1.3 and 1.2 support, leaving only "TLS 1.0"
5. **Server receives ClientHello:** "I support TLS 1.0 only"
6. **Server responds:** "Let's use TLS 1.0" (even though it prefers 1.2)
7. **TLS 1.0 connection established:** Attacker can now break it (BEAST attack, POODLE attack, etc.)

**Why This Works:** During the initial handshake, there's no authentication of the ClientHello message itself—the server simply believes the client's protocol preferences.

### Attack Against MedDefense

**Scenario:** MedDefense portal supports TLS 1.0 + TLS 1.2 (Finding 005).

**Attack Sequence:**
1. Patient connects to portal from a coffee shop WiFi (attacker is on the network)
2. Attacker's tool (e.g., sslstrip, Firesheep, custom proxy) intercepts TLS negotiation
3. Attacker removes TLS 1.2 from ClientHello, leaving only TLS 1.0
4. Connection downgrades to TLS 1.0
5. Attacker uses POODLE or Lucky Thirteen exploit to break TLS 1.0 encryption
6. Attacker captures and decrypts PHI (patient name, SSN, medications, diagnosis)
7. Patient sees "Secure" lock icon in browser; completely unaware connection was downgraded

**Patient Impact:** Full data breach—credentials, medical records, billing information transmitted in plaintext.

### Simplest Prevention: Remove Old Protocols

**Solution:** Disable TLS 1.0, TLS 1.1, and SSL 3.0 entirely on the server.

**Configuration (1 line):**
```apache
SSLProtocol -all +TLSv1.2 +TLSv1.3
```

**Why This Works:**
- Client can no longer request TLS 1.0 (server won't offer it)
- Even if attacker modifies ClientHello to request TLS 1.0, server refuses (connection fails)
- Browser shows "SSL Error" instead of silently accepting downgrade
- Patient is informed: "Something is wrong with this connection; do not proceed"

**Additional Protection:** HSTS Header
```
Strict-Transport-Security: max-age=31536000; includeSubDomains
```
This tells the browser: "For the next 1 year, ALWAYS use HTTPS for this domain, no exceptions." Even if attacker tries SSLStrip (downgrade to HTTP), browser blocks it.

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 11-tls_audit.md
