Goal: Capture and verify a complete certificate chain, understand how trust propagates from root to leaf, and analyze what happens when the chain breaks.

Context: A certificate is only as trustworthy as the chain behind it. The patient's browser trusts the portal's certificate because it trusts the intermediate CA that signed it, which it trusts because it trusts the root CA in its trust store. If any link in this chain is invalid, expired, revoked or untrusted, the entire connection fails.

---

## PART 1: FULL CERTIFICATE CHAIN CAPTURE (GitHub.com)

### Chain Extraction Command

```bash
openssl s_client -connect github.com:443 -showcerts -servername github.com < /dev/null 2>&1 | \
awk 'BEGIN{count=0} /-----BEGIN CERTIFICATE-----/{count++; file="github_chain_cert_"count".pem"} \
/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/{print > file}'
```

### Chain Structure

**Total Certificates in Chain:** 3 (Leaf + 1 Intermediate + Root*)

*Note: The root CA is typically already in the system's trust store, so browsers may not download it; here we capture what the server sends.*

### Certificate Hierarchy Analysis

```
Trust Store Root
    ↓ (signed by)
Certificate 3: USERTrust ECC Certification Authority (Root CA)
    ↓ (signed by)
Certificate 2: Sectigo Public Server Authentication Root E46 (Intermediate Root)
    ↓ (signed by)
Certificate 1: github.com (Leaf Certificate)
```

### Detailed Chain Information

| Position | Certificate | Role | Subject | Issuer | Validity | Purpose |
|---|---|---|---|---|---|---|
| **1 (Leaf)** | github.com | Server Certificate (End-Entity) | CN=github.com | C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication CA DV E36 | Not After: Sep 30, 2026 | Used by server to prove identity; signed by Sectigo intermediate CA |
| **2 (Intermediate)** | Sectigo Public Server Authentication CA DV E36 | Intermediate CA | C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication CA DV E36 | C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication Root E46 | Not After: Mar 21, 2036 | Signs server certificates; bridges trust from root CA to leaf certs |
| **3 (Root)** | Sectigo Public Server Authentication Root E46 | Root CA | C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication Root E46 | C=US, ST=New Jersey, L=Jersey City, O=The USERTRUST Network, CN=USERTrust ECC Certification Authority | Not After: Jan 18, 2038 | Ultimate trust anchor; self-signed (Issuer ≠ Subject indicates it's issued by a higher root, USERTrust) |

### Subject-Issuer Chain Verification

**Certificate 1 (Leaf) Subject** matches **Certificate 2 Issuer?**
```
Cert 1 Issuer: C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication CA DV E36
Cert 2 Subject: C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication CA DV E36
✅ MATCH: Certificate 1 was signed by the holder of Certificate 2
```

**Certificate 2 (Intermediate) Subject** matches **Certificate 3 Issuer?**
```
Cert 2 Issuer: C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication Root E46
Cert 3 Subject: C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication Root E46
✅ MATCH: Certificate 2 was signed by the holder of Certificate 3
```

**Certificate 3 (Root) Subject** matches **Certificate 3 Issuer?**
```
Cert 3 Subject: CN=Sectigo Public Server Authentication Root E46
Cert 3 Issuer: CN=USERTrust ECC Certification Authority
⚠️ NO MATCH: This indicates there's likely a 4th root above this
```

**How Trust Propagates:**

1. Browser downloads Certificate 1 (github.com leaf cert)
2. Browser extracts Certificate 1's Issuer: "Sectigo Public Server Authentication CA DV E36"
3. Server sends Certificate 2 (the intermediate CA that issued it)
4. Browser verifies: Cert 1 Issuer = Cert 2 Subject ✅
5. Browser verifies Cert 2's signature using Cert 2's public key
6. Browser extracts Certificate 2's Issuer: "Sectigo Public Server Authentication Root E46"
7. Server sends Certificate 3 (the root CA)
8. Browser verifies: Cert 2 Issuer = Cert 3 Subject ✅
9. Browser verifies Cert 3's signature using Cert 3's public key
10. Browser checks if Cert 3's Subject is in the system trust store ✅ (USERTrust root is trusted)
11. **Chain is valid; connection proceeds**

---

## PART 2: MANUAL CHAIN VERIFICATION

### Verification With Full Chain

**Command:**
```bash
cat github_chain_cert_2.pem github_chain_cert_3.pem > github_chain_file.pem
openssl verify -CAfile github_chain_file.pem github_chain_cert_1.pem
```

**Output:**
```
github_chain_cert_1.pem: OK
```

**Interpretation:** ✅ Certificate chain is valid from leaf (github.com) through intermediates to root.

### Verification Without Intermediate (Missing Link)

**Command:**
```bash
openssl verify github_chain_cert_1.pem
```

**Output:**
```
error 20 at 0 depth lookup: unable to get local issuer certificate
error github_chain_cert_1.pem: verification failed
```

**Interpretation:** ❌ Verification fails because the issuer of Certificate 1 (Sectigo intermediate) is not available. The browser cannot complete the chain.

### Why Servers Must Send the Full Chain

**Explanation:**

When a client (browser) receives a certificate from a server, it must verify the entire chain of trust from the leaf certificate back to a known root CA in its trust store. If the server sends **only the leaf certificate** (Certificate 1), the client must search for the intermediate CA in its own trust store or via OCSP/CRL lookups. **This is slow and often fails** because:

1. **Intermediate CAs are not usually pre-installed** in browsers (only root CAs are); the client doesn't have Certificate 2 locally
2. **Downloading intermediates on-demand is expensive** (requires additional DNS/HTTP queries during TLS handshake, adding 100-500ms latency)
3. **Some networks block OCSP requests**, leaving the client unable to verify the chain

**Best practice:** The server sends the full chain (Certificates 1 + 2 + 3) during the TLS handshake. The client immediately has all pieces needed to verify, dramatically improving connection speed and reliability.

---

## PART 3: REVOCATION MECHANISMS

### CRL (Certificate Revocation List)

**What It Is:**
A CRL is a digitally signed document issued by a Certificate Authority listing all certificates that have been revoked before their expiration date. It contains:
- Serial numbers of revoked certificates
- Revocation date and reason (e.g., keyCompromise, cessationOfOperation, certificateHold)
- CRL issuance date and next update date

**How Clients Use It:**
1. Browser downloads the CRL from the URL specified in the certificate's CRL Distribution Points extension
2. Browser extracts the certificate's serial number
3. Browser searches the CRL for that serial number
4. If found: Certificate is revoked → connection blocked
5. If not found: Certificate is not revoked → connection proceeds

**Main Limitations:**
- **Size:** CRLs can be megabytes large (all revoked certs from a CA for months); impractical to download for every TLS connection
- **Freshness:** CRLs are updated periodically (daily, weekly, monthly) but not in real-time; a revoked cert might be usable for hours after revocation before clients download the updated CRL
- **Bandwidth:** Downloading CRLs consumes network bandwidth; not feasible for mobile devices or low-bandwidth environments
- **Cache Complexity:** Clients must manage CRL caching (when to refresh, when to expire)

**Status:** CRLs are **largely deprecated** in favor of OCSP.

### OCSP (Online Certificate Status Protocol)

**What It Is:**
OCSP is a lightweight protocol that allows a client to query the CA's OCSP responder (a server) in real-time to ask: "Is certificate serial number X still valid?"

**Request-Response:**
- Client sends: Certificate serial number + timestamp
- OCSP responder responds: "good", "revoked", or "unknown"
- Response is small (typically <1KB) and cryptographically signed by the CA

**Improvements over CRL:**
- **Real-time:** Revocation is effective immediately (no waiting for CRL refresh cycle)
- **Compact:** OCSP responses are tiny compared to CRLs; minimal bandwidth
- **On-demand:** Client queries only for the specific certificate in use (not downloading all revoked certs)

**Performance Cost:** OCSP adds latency (10-100ms per connection) because the browser must make an HTTP request to the OCSP responder during TLS handshake.

### OCSP Stapling

**What It Is:**
The server itself queries the OCSP responder (not the client) and includes the OCSP response in the TLS handshake. The server "staples" the response to the certificate.

**Advantages:**
- **Zero Client Latency:** Browser receives OCSP response from server (no additional network request needed)
- **Privacy:** OCSP responder doesn't learn which clients are visiting which sites (server queries instead)
- **Caching:** Server can cache the OCSP response for ~24 hours, amortizing the cost across multiple clients

**How It Works:**
1. Server connects to OCSP responder and fetches current status for its certificate
2. Server includes this response in the TLS Certificate message
3. Browser verifies OCSP response signature and checks certificate status
4. Connection proceeds or fails based on OCSP result

**Current State:** OCSP Stapling is now **standard practice** for high-security sites (most HTTPS sites use it).

---

## PART 4: MEDDEFENSE REVOCATION/REPLACEMENT SCENARIO

### Scenario: Private Key Compromised (Found in Git Repository)

**Day 0 (Discovery):** MedDefense's IT finds the portal's private key accidentally committed to a Git repository and pushed to GitHub.

**Immediate Actions (Hour 0-1):**

1. **Emergency Key Revocation:**
   - Contact Sectigo (the CA) or DigiCert's emergency support line
   - Provide: Certificate serial number, domain (portal.meddefense.local), proof of compromise (Git commit link)
   - Request: IMMEDIATE revocation (expedited process; most CAs have emergency revocation in <2 hours)

2. **OCSP Revocation Takes Effect:**
   - CA issues updated OCSP response: Serial number marked as "revoked"
   - If server uses OCSP Stapling, it must immediately delete the cached OCSP response
   - New TLS connections trigger fresh OCSP staple from server (no stale response sent)
   - Clients querying OCSP responder will get "revoked" status immediately

3. **CRL Update (Secondary):**
   - CA updates CRL and publishes to CRL distribution point
   - CRL typically updated within 24 hours (depends on CA SLA)
   - Clients using CRL will see revocation within 1 day

**Short-term (Hour 1-4):**

4. **Generate New Private Key and CSR:**
   - MedDefense IT generates new ECC P-256 private key on secure, offline system (or HSM)
   - Creates Certificate Signing Request (CSR) with same SAN entries as original cert
   - Submits CSR to CA (DigiCert/Sectigo)

5. **CA Issues New Certificate:**
   - CA validates domain ownership (DNS TXT record, HTTP challenge, or phone call)
   - Issues new OV/EV certificate signed with new private key
   - Validity: Starts immediately; valid for 1 year

**Medium-term (Hour 4-24):**

6. **Deploy New Certificate:**
   - IT installs new certificate on web server (portal.meddefense.local)
   - Tests TLS connection with `openssl s_client`
   - Verifies new certificate in browser (no errors, organization name displayed)
   - Monitoring: Alert if clients see certificate warnings

7. **Monitor Revocation Propagation:**
   - Track OCSP response (should show "revoked" status for old cert serial)
   - Monitor CRL updates
   - Check CT logs (Certificate Transparency) to ensure no rogue certs issued

**Long-term (Day 1+):**

8. **Incident Response:**
   - Investigate how private key ended up in Git (process failure, lack of pre-commit hooks)
   - Audit all backups and archives for the compromised key
   - Implement controls: `.gitignore` for private keys, pre-commit hooks, secrets scanning
   - Notify affected users (if any patient data accessed via compromised cert): "We identified a security issue, took immediate action, and your data was protected"

**Regulatory Notification (if applicable):**
- Check if incident triggers HIPAA breach notification (unlikely if no evidence of actual PHI access)
- Document incident in security incident log for audits

---

## PART 5: TRUST STORE EXPLORATION

### System Trust Store Location

**Linux:**
```bash
/etc/ssl/certs/
```

**Total Root CAs Trusted:** 122 root certificates

**Inspection:**
```bash
ls -1 /etc/ssl/certs/*.pem | wc -l
```

### Sample Root CA Certificate (DigiCert Assured ID Root G2)

**Extraction:**
```bash
openssl x509 -in /etc/ssl/certs/DigiCert_Assured_ID_Root_G2.pem -noout -subject -issuer -dates
```

**Output:**
```
subject=C=US, O=DigiCert Inc, OU=www.digicert.com, CN=DigiCert Assured ID Root G2
issuer=C=US, O=DigiCert Inc, OU=www.digicert.com, CN=DigiCert Assured ID Root G2
notBefore=Aug  1 12:00:00 2013 GMT
notAfter=Jan 15 12:00:00 2038 GMT
```

### Analysis

| Finding | Observation |
|---|---|
| **Subject = Issuer** | ✅ Self-signed root CA (issues its own certificates) |
| **Validity Start** | August 1, 2013 (13 years ago) |
| **Validity End** | January 15, 2038 (14 years in the future) |
| **Total Validity Period** | 25 years |
| **Issuer Still Active?** | ✅ Yes; DigiCert continues issuing certificates |

### Surprising Finding: Long Validity Period

**Expected:** Most certificates are valid for 1-3 years; long certificates increase compromise window.

**Observed:** Root CA is valid for 25 years (Aug 2013 → Jan 2038).

**Why This Is Intentional (Not a Mistake):**
1. **Root CAs are high-security:** Private key stored in HSM (Hardware Security Module) with offline backup; access restricted to <5 people
2. **Root CAs are rarely used directly:** They issue intermediate CAs; intermediates issue end-entity certificates. Compromise of a root would affect millions of devices (making very long validity impractical in reality)
3. **Intermediate CAs have shorter validity:** Intermediate certs typically valid 5-10 years; end-entity certs 1 year
4. **Renewal complexity:** Replacing a root cert requires browsers to update trust stores; very expensive process involving coordination with all major browser vendors
5. **Industry practice:** All major CAs (DigiCert, Sectigo, GlobalSign, etc.) have roots valid 20-30 years

**Key Insight:** The security model is layered. Root CAs are "set and forget" (high security, long validity). Intermediates and leaf certs are actively managed (shorter validity, more frequent rotation). This maximizes both security and operational efficiency.

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 9-chain_of_trust.md
