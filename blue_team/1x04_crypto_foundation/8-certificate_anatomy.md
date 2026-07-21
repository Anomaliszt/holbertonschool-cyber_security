Goal: Inspect real X.509 certificates from live websites using OpenSSL, identify every field that matters for security, and diagnose intentionally broken certificates.

Context: Every time a patient opens the MedDefense portal, their browser performs a certificate check in milliseconds: Is this really MedDefense ? Is the certificate still valid ? Was it issued by a trusted authority ? You need to understand exactly what the browser is checking, because in 18 days, MedDefense's certificate expires and you are the person who will replace it.

---

## PART 1: REAL CERTIFICATE INSPECTIONS

### Certificate 1: Let's Encrypt (letsencrypt.org) - DV Certificate

**Certificate Inspection Command:**
```bash
openssl s_client -connect letsencrypt.org:443 -showcerts < /dev/null 2>/dev/null | openssl x509 -text -noout
```

**Key Fields Extracted:**

| Field | Value | Security Significance |
|---|---|---|
| **Subject** | CN=letsencrypt.org | Organization name only; DV (Domain Validated) certificate—no company identity |
| **Issuer** | C=US, O=Let's Encrypt, CN=YE2 | Signed by Let's Encrypt (free, automated CA); YE2 is their intermediate CA |
| **Serial Number** | [Hex value] | Unique identifier; used to revoke via CRL/OCSP if compromised |
| **Signature Algorithm** | ecdsa-with-SHA384 | Modern: ECDSA (not RSA); SHA-384 provides 192-bit security |
| **Not Before** | Jul 6 15:24:34 2026 GMT | Validity start; prevents key reuse from past |
| **Not After** | Oct 4 15:24:33 2026 GMT | 90-day validity period (typical for Let's Encrypt auto-renewal) |
| **Public Key Algorithm** | id-ecPublicKey (256-bit) | ECC P-256; equivalent to RSA-3072; faster than RSA |
| **Subject Alternative Names (SAN)** | DNS:letsencrypt.org, DNS:www.letsencrypt.org, DNS:*.lencr.org, DNS:letsencrypt.com, DNS:www.letsencrypt.com, DNS:cp.letsencrypt.org, DNS:cps.letsencrypt.org | Wildcard + multiple domains; browser accepts any domain in list |
| **Key Usage** | Digital Signature, Key Encipherment | Can be used for TLS handshake authentication |
| **Extended Key Usage** | TLS Web Server Authentication | Restricted to TLS server role (not code signing, email, etc.) |
| **Authority Information Access** | OCSP URL, CA Issuer URL | Allows browser to check revocation status in real-time |

**Interpretation:**
- ✅ **Strong:** Modern ECDSA-SHA384, ECC P-256 key, 90-day rotation discipline
- ✅ **Trusted:** Let's Encrypt is a trusted root CA in all browsers
- ⚠️ **Limitation:** DV only means domain was validated (simple DNS/HTTP validation); no company identity verification
- ✅ **Appropriate For:** Websites, APIs, non-regulatory data (but inadequate for financial/healthcare in some contexts)

---

### Certificate 2: GitHub (github.com) - DV Certificate (Sectigo)

**Certificate Inspection Command:**
```bash
openssl s_client -connect github.com:443 -showcerts < /dev/null 2>/dev/null | openssl x509 -text -noout
```

**Key Fields Extracted:**

| Field | Value | Security Significance |
|---|---|---|
| **Subject** | CN=github.com | Domain validated only; no organization name |
| **Issuer** | C=GB, O=Sectigo Limited, CN=Sectigo Public Server Authentication CA DV E36 | Commercial CA (Sectigo), well-established |
| **Serial Number** | [Hex value] | Unique identifier for revocation |
| **Signature Algorithm** | ecdsa-with-SHA256 | ECDSA-SHA256; strong but slightly weaker than SHA-384 (256-bit vs 384-bit) |
| **Not Before** | Jul 3 00:00:00 2026 GMT | Validity start |
| **Not After** | Sep 30 23:59:59 2026 GMT | ~90-day validity period |
| **Public Key Algorithm** | id-ecPublicKey (256-bit) | ECC P-256; matches Let's Encrypt in strength |
| **Subject Alternative Names (SAN)** | DNS:github.com, DNS:www.github.com | Specific to GitHub domains only; no wildcard |
| **Key Usage** | Digital Signature, Key Encipherment | Standard TLS server certificate usage |
| **Extended Key Usage** | TLS Web Server Authentication | Restricted to TLS server role |

**Comparison to Let's Encrypt:**
- **Issuer:** Sectigo (commercial CA) vs. Let's Encrypt (free, nonprofit)
- **Cost:** GitHub pays for Sectigo cert; letsencrypt.org uses free automation
- **Validation Level:** Both are DV (domain validation only)
- **Algorithm:** Both use ECDSA; GitHub uses SHA-256 vs. Let's Encrypt SHA-384
- **Trust Level:** Both are equally trusted in browsers; same root CA requirements

---

### Certificate 3: BadSSL (expired.badssl.com) - BROKEN/EXPIRED Certificate

**Certificate Inspection Command:**
```bash
openssl s_client -connect expired.badssl.com:443 -showcerts < /dev/null 2>/dev/null | openssl x509 -text -noout
```

**Key Fields Extracted:**

| Field | Value | Security Significance |
|---|---|---|
| **Subject** | OU=Domain Control Validated, OU=PositiveSSL Wildcard, CN=*.badssl.com | Wildcard domain (*.badssl.com) signed years ago |
| **Issuer** | C=GB, ST=Greater Manchester, L=Salford, O=COMODO CA Limited, CN=COMODO RSA Domain Validation Secure Server CA | COMODO CA (now Sectigo); no longer active |
| **Serial Number** | [Hex value] | Certificate identifier |
| **Not Before** | Apr 9 00:00:00 2015 GMT | Issue date: 2015 (10+ years ago) |
| **Not After** | Apr 12 23:59:59 2015 GMT | **EXPIRATION DATE: April 12, 2015 (EXPIRED)** ❌ |
| **Public Key Algorithm** | RSA (2048-bit) | Older than ECC; still acceptable but slower |
| **Signature Algorithm** | sha256WithRSAEncryption | RSA-SHA256; acceptable but shows age of cert |
| **Age** | ~11 years expired | Certificate validity check fails |

**Browser Verification Error:**
```
verify return:1
verify error:num=10:certificate has expired
verify return:1
```

**What Error Users See:**
```
SECURITY ERROR: Your connection is not private
expired.badssl.com has an expired SSL certificate

Error code: SEC_ERROR_EXPIRED_CERTIFICATE (Firefox)
OR
NET::ERR_CERT_DATE_INVALID (Chrome)
```

---

## PART 2: THE BROKEN CERTIFICATE - SECURITY IMPLICATIONS

### What Is Wrong with expired.badssl.com Certificate

**Primary Issue:** Certificate validity period has expired (Valid from Apr 9, 2015 to Apr 12, 2015; current date is 2026).

**Browser Behavior:**
1. Browser downloads certificate from expired.badssl.com
2. Browser extracts "Not After" date: April 12, 2015
3. Browser compares to system clock: Current date (July 2026) > April 12, 2015
4. **Verification fails:** Certificate is expired
5. Browser displays warning and **blocks the connection** (with option to proceed at user's own risk)

**Why This Is a Critical Security Issue:**

| Aspect | Risk |
|---|---|
| **Trust Verification Failed** | If the cert was allowed to be used, it means the domain/server is not being monitored. An attacker could have taken over expired.badssl.com and reissued a new certificate in the real owner's name. |
| **No Revocation Check** | Expired certs are not checked against CRL/OCSP (browser assumes they're invalid). If an expired cert was ever compromised, there's no way to revoke it (it's already considered invalid). |
| **Man-in-the-Middle Window** | If a patient ignores the browser warning and proceeds, an attacker on the network (ISP, compromised router, malicious WiFi) could intercept the connection. The TLS handshake would fail (no valid cert), and the attacker could inject their own certificate. |
| **Liability** | A healthcare provider using an expired certificate shows negligence in security maintenance. Regulators (CMS, OIG, state attorneys general) may view this as failure to implement "appropriate administrative, physical, and technical safeguards" (HIPAA § 164.308). |

### Advice for a Patient

**Would I advise a patient to proceed to a portal displaying this error?**

**❌ Absolutely NOT.**

**Patient Guidance:**
1. **Do not click "Proceed anyway" or "Advanced > Proceed"**
2. **Close the browser tab immediately**
3. **Contact MedDefense support:** "I'm getting a security error on the patient portal. The certificate is expired."
4. **Wait for IT to fix it** before attempting again
5. **If you are asked to bypass the warning,** that is a sign of a serious security problem—escalate to hospital administration or regulatory compliance

**Why This Matters for Healthcare:**
- If the portal cert is expired and not renewed, it indicates IT neglect
- Expired certs often lead to other security gaps (unpatched servers, weak passwords, no monitoring)
- A patient logging in anyway has unknowingly accepted compromise risk
- PHI (medications, diagnosis, SSN) transmitted to a site with an invalid cert could be intercepted

---

## PART 3: IDEAL CERTIFICATE FOR MEDDEFENSE PATIENT PORTAL

### Certificate Type: Organization Validated (OV)

**Recommendation:** **OV (Organization Validated) certificate**

**Reasoning:**
- **DV (Domain Validated):** Only proves domain ownership; CA does not verify organization identity. Modern browsers no longer display organization names prominently in the address bar, so DV certs provide the same visual feedback as OV to patients. However, OV is still preferred because the underlying CA audit trail documents that MedDefense—not an attacker—controls this domain. This matters for:
  - Post-breach incident investigations ("Did attackers ever impersonate MedDefense through a rogue certificate?")
  - Compliance audits (HIPAA expects organizations to verify domain control + organizational legitimacy)
  - CSR/logging requirements (OV issuance requires formal organizational documentation, leaving an audit trail)
- **EV (Extended Validation):** Highest assurance; expensive ($200-1000/year); browsers historically showed green organization name display, but this has been deprecated in modern Chrome/Firefox. Not cost-effective for MedDefense's use case.
- **Healthcare Deployment:** Use OV—adequate for patient portal, maintains audit trail, reasonable cost ($400-800/year).

### Certificate Authority (CA)

**Recommendation:** **DigiCert, Sectigo, or GlobalSign** (trusted, healthcare-aware)

**Reasoning:**
- **Let's Encrypt:** Free DV only; inadequate for healthcare organization
- **DigiCert:** Specializes in OV/EV for healthcare; incident response support; recognized in compliance audits
- **Sectigo:** Reliable, competitive pricing; good support
- **Requirements:** CA must be audited (SOC 2), maintain transparent practices, provide CRL/OCSP (revocation checking)

### Subject Alternative Names (SAN) Entries

**Recommendation:** Specific multi-domain certificate, NOT wildcard

```
CN = portal.meddefense.local
SAN:
  - DNS:portal.meddefense.local
  - DNS:portal.meddefense.com (if public domain)
  - DNS:www.portal.meddefense.local
  - DNS:api.meddefense.local (if API uses same cert)
  - DNS:billing.meddefense.local (if subdomains use same cert)
```

**Reasoning:**
- **Why not wildcard?** If a wildcard cert (*.meddefense.local) is compromised, attacker can create fake subdomains (admin.meddefense.local, phishing.meddefense.local, etc.). Multi-domain limits exposure to only legitimate subdomains.
- **Why specific domains?** List every subdomain patients or staff might access. If new subdomains added (e.g., mobile app), issue new cert.

### Key Algorithm and Size

**Recommendation:** **ECC P-256 (NIST) with ECDSA-SHA256**

**Alternatives:** RSA-2048 with SHA-256 (legacy support)

**Reasoning:**
- **ECC P-256:** Fast, strong (equivalent to RSA-3072), smaller key size (lower bandwidth during TLS handshake), forward-secrecy compatible
- **SHA-256:** Industry standard; SHA-384 is overkill for non-classified data
- **RSA-2048 Fallback:** Some older browsers may not support ECC; maintain RSA cert as backup or dual-cert setup (Server Name Indication)

### Validity Period

**Recommendation:** **1 year** (not 90 days like Let's Encrypt auto-renewal)

**Reasoning:**
- **90-day certs (Let's Encrypt):** Require automation; MedDefense lacks mature auto-renewal processes
- **2-3 year certs:** Over-subscription risk (if cert is compromised in year 2, can't quickly rotate)
- **1-year certs:** Balance between automation effort and key rotation discipline; allows annual security review of certificate chain

### Wildcard vs. Single-Domain

**Recommendation:** **Single-Domain (multiple SAN entries)**

**Example Certificate:**
```
Subject: CN=portal.meddefense.local
Subject Alternative Names: portal.meddefense.local, www.portal.meddefense.local, 
                           api.meddefense.local, billing.meddefense.local
```

**NOT: CN=*.meddefense.local (wildcard)**

**Reasoning:**
- **Single-Domain Advantage:** Compromise of one cert doesn't endanger all subdomains; audit trail is specific
- **Wildcard Risk:** If private key stolen, attacker can impersonate ANY subdomain; harder to detect misuse
- **MedDefense Compromise Scenario:** If wildcard cert compromised, attacker creates phishing.meddefense.local, pharming.meddefense.local, etc. Patients have no way to distinguish legitimate subdomains from attacker's
- **Healthcare Requirement:** HIPAA requires organizations to implement "minimum necessary" principle; wildcard violates this (all subdomains bundled together)

### MedDefense Certificate Profile Summary

| Criterion | Specification | Deployment Rationale |
|---|---|---|
| **Type** | OV (Organization Validated) | CA verifies organizational identity during issuance (audit trail). Modern browsers don't display org name visually, but OV documentation is required for compliance audits and incident response. |
| **CA** | DigiCert or Sectigo | Trusted, reliable; healthcare-friendly; provide CRL/OCSP for revocation checking |
| **Key Algorithm** | RSA-2048 with SHA256 (or ECC P-256 if all client systems support it) | RSA-2048 ensures maximum browser compatibility; ECC P-256 is modern and efficient but requires testing with patient devices |
| **Validity Period** | 1 year | Annual renewal forces security review; shorter than 2-3 years to limit key compromise window |
| **Subject CN** | portal.meddefense.local | Primary hostname patients use to access portal |
| **SAN Entries** | portal.meddefense.local, portal.meddefense.com (if public), www.portal.meddefense.local | Explicit list of domains; do NOT use wildcard (*.meddefense.local) to prevent attacker from creating fake subdomains if key is stolen |
| **Renewal Process** | Manual renewal 30 days before expiry; calendar alert to Sarah Park + IT team | Prevents emergency situation like current (18-day expiry); can use automation later if processes mature |
| **Estimated Annual Cost** | $400-800 | OV certs cost more than free DV (Let's Encrypt) but justified for healthcare organization requiring audit trail |

**Practical Steps for MedDefense:**
1. **IMMEDIATE (this week):** Renew expired/expiring certificate using same CA as current cert (fastest path)
2. **Month 1:** Generate RSA-2048 key pair; create CSR with OV validation fields; submit to DigiCert
3. **Month 2:** Deploy new certificate on portal-srv-01; verify in production with curl/browser testing
4. **Ongoing:** Set yearly calendar reminder 30 days before expiry; assign Sarah Park + 1 backup as responsible parties
5. **Next Year:** Evaluate switching to ECC P-256 if all patient devices support it (smaller handshake, faster)

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 8-certificate_anatomy.md
