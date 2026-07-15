# Web Application Security & Exposure Analysis
## MedDefense Health Systems – Internet-Facing vs. Internal Risk Assessment

---

## Executive Summary

MedDefense hosts web applications across **three distinct threat environments:**

1. **web-srv-01** (patient portal): **Internet-facing**, publicly accessible, direct attacker access possible
2. **ehr-srv-01** (EHR system): **Internal but flat network**, accessible to any hospital staff + vendors
3. **backup-srv-01** (NAS management): **Internal only**, limited access but web-based management interface

**A vulnerability on an internet-facing system is orders of magnitude more dangerous than the identical vulnerability on an internal-only system.** For internet-facing systems, the attacker does not need credentials, network access, or physical proximity—the vulnerability is accessible to the entire internet.

**Key Finding:** Finding 017 (Tomcat version disclosure) directly led to discovery of Finding 031 (Ghostcat RCE, CVSS 9.8 Critical). This demonstrates that "informational" findings can be reconnaissance vectors for critical vulnerabilities.

---

## Host 1: web-srv-01 (Patient Portal - 10.10.2.10)

### Exposure Classification: **INTERNET-FACING**

The patient portal is explicitly designed for external access:
- **Public DNS:** Likely `portal.meddefense-health.com` or similar
- **Accessibility:** Reachable from any internet-connected device globally
- **Attacker Barrier to Entry:** **None** (no VPN, no firewall, no IP restriction—it's the patient portal)
- **User Base:** Patients, external stakeholders, potentially adversaries

### Web-Related Findings on web-srv-01

#### **Finding 012: TLS 1.0 and TLS 1.1 Enabled**
- **CVSS:** 6.5 (Medium)
- **Category:** Cryptographic
- **Description:** Web server supports deprecated TLS 1.0 (RFC 2246, 1999) and TLS 1.1 (RFC 4346, 2006)
- **Current Date:** Jul 2026 (25+ years after TLS 1.0; 20+ years after TLS 1.1)
- **Security Status:** Both protocols have known practical attacks (BEAST, Poodle); modern browsers warn users; should be disabled
- **Modern Standard:** TLS 1.3 (RFC 8446, 2018) is now standard; TLS 1.2 (2008) is minimum acceptable
- **Patient Portal Implication:** Patients accessing portal from public WiFi, coffee shops, hotels are vulnerable to downgrade attacks if browser/client accepts TLS 1.0
- **CVSS Breakdown:**
  - Confidentiality impact: Medium (patient data in transit could be decrypted)
  - Integrity impact: Medium (downgrade attacks could modify transmitted data)
  - Availability impact: None
  - Attack complexity: High (requires MITM + client support for old TLS)

#### **Finding 013: Missing HTTP Security Headers**
- **CVSS:** 5.4 (Medium)
- **Category:** Misconfiguration (Web)
- **Description:** Missing headers include:
  - `X-Frame-Options` (prevents clickjacking)
  - `Content-Security-Policy` (prevents XSS)
  - `X-Content-Type-Options` (prevents MIME sniffing)
  - `Strict-Transport-Security` (HSTS, enforces HTTPS)
  - `X-XSS-Protection` (browser XSS filter)
- **Real-World Impact:** Enables various client-side attacks against portal users
- **Specific Risk:** Patient could be tricked into visiting malicious portal URL (via email) that injects JavaScript to steal session cookies
- **Severity on Patient Portal:** **HIGHER than on internal system** because:
  - Portal handles sensitive patient data (medical history, insurance, appointments)
  - Attackers specifically target patient portals for credential harvesting
  - Patient users may not recognize phishing/MITM attacks

#### **Finding 014: HTTP TRACE Method Enabled**
- **CVSS:** 5.7 (Medium)
- **Category:** Web-based
- **Description:** HTTP TRACE method is enabled on web server; allows cross-site tracing (XST) attacks
- **Attack Vector:** Attacker can use TRACE to bypass `HttpOnly` cookie restrictions and extract session cookies from MITM position
- **Real-World Scenario:** Patient on public WiFi; attacker intercepts traffic; uses TRACE method to extract session cookie; hijacks patient session
- **Severity on Patient Portal:** **HIGH** because patient medical data and insurance information are in the session

#### **Finding 021: SSL Certificate Expired**
- **CVSS:** 5.9 (Medium)
- **Category:** Cryptographic
- **Description:** SSL/TLS certificate for patient portal domain has expired
- **Real-World Impact:** 
  - Browsers show security warning to patients ("Your connection is not secure")
  - Patients may ignore warning and proceed (training users to bypass security)
  - Certificate authority (CA) verification fails
  - MITM attack becomes trivial (attacker can present any certificate)
- **Patient Trust Impact:** Expired certificate damages patient confidence in security of portal
- **Compliance Impact:** HIPAA requires valid certificates for HTTPS-protected patient data

#### **Finding 028: Missing Content-Security-Policy (CSP)**
- **CVSS:** 5.3 (Medium)
- **Category:** Web-based
- **Description:** CSP header not configured or overly permissive
- **Attack Vector:** Attacker injects malicious JavaScript into portal (via stored XSS, database compromise, or MITM)
- **Impact:** JavaScript can:
  - Steal session cookies
  - Redirect patient to phishing site
  - Modify portal display to trick patient into entering credentials
  - Exfiltrate patient medical data
- **Risk on Portal:** **CRITICAL when combined with other findings**
  - If attacker can inject JavaScript (via XSS) AND CSP is missing, data theft is trivial
  - If CSP is properly configured, injected JavaScript is blocked

### Combined Risk Assessment: web-srv-01

**Individual vulnerabilities are concerning; combined they create multiple attack chains:**

#### **Attack Chain 1: Session Hijacking via TRACE + Expired Certificate**
1. **Precondition:** Patient accesses portal from public WiFi
2. **Step 1:** Attacker performs MITM attack (ARP spoofing or WiFi SSID clone)
3. **Step 2:** Patient browser attempts HTTPS connection to portal
4. **Step 3:** Expired certificate causes security warning; patient clicks "Proceed Anyway" (trained to ignore warnings)
5. **Step 4:** Attacker presents malicious certificate (MITM succeeds)
6. **Step 5:** Attacker uses HTTP TRACE to extract session cookie from patient traffic
7. **Result:** Attacker hijacks patient session; accesses medical history, insurance info, appointment data

#### **Attack Chain 2: XSS → Data Theft via Missing CSP**
1. **Precondition:** Portal has stored XSS vulnerability (not in this scan, but common in web apps)
2. **Step 1:** Attacker injects malicious JavaScript into portal (e.g., in patient comment field)
3. **Step 2:** Other patients access portal; JavaScript executes in their browser
4. **Step 3:** CSP missing; JavaScript executes unrestricted
5. **Step 4:** JavaScript steals session cookies and exfiltrates medical data
6. **Result:** Multiple patients' data compromised

#### **Attack Chain 3: Downgrade Attack via TLS 1.0/1.1**
1. **Precondition:** Patient browser supports TLS 1.0/1.1 (older devices, legacy configurations)
2. **Step 1:** Attacker performs MITM attack
3. **Step 2:** Attacker forces TLS downgrade to 1.0
4. **Step 3:** Attacker exploits BEAST or Poodle vulnerability to decrypt TLS traffic
5. **Result:** Attacker reads all patient data in transit (medical history, insurance)

### Priority for web-srv-01: **CRITICAL - Patch within 24-48 hours**

**Rationale:**
- **Internet-facing:** Attackers can access directly; no network barrier
- **Patient data:** Medical records, insurance info, appointment data
- **Multiple attack chains:** Findings chain together for complete compromise
- **Regulatory deadline:** HIPAA requires timely security remediation; days of delay attract regulatory scrutiny

**Remediation Approach:**
1. **Immediate (2 hours):**
   - Renew and deploy SSL certificate
   - Test certificate is valid in browsers
   
2. **Short-term (4-8 hours):**
   - Disable TLS 1.0 and TLS 1.1
   - Enable TLS 1.3 and 1.2 only
   - Test compatibility with common browsers
   
3. **Short-term (8-16 hours):**
   - Disable HTTP TRACE method
   - Add security headers: CSP, X-Frame-Options, X-Content-Type-Options, HSTS
   - Test with security header validation tools
   
4. **Validation (1 hour):**
   - SSL Labs scan to verify TLS configuration
   - OWASP security headers checklist validation

**Total remediation time:** 12-24 hours (most can be parallelized)

---

## Host 2: ehr-srv-01 (EHR System - 10.10.2.13)

### Exposure Classification: **INTERNAL but FLAT NETWORK**

The EHR server is intended for internal use only:
- **Access:** Hospital network only (no VPN, direct internal access)
- **User Base:** Hospital staff, physicians, clinicians, administrative staff
- **Attacker Barrier to Entry:** **Initial compromise required** (must be on hospital network or compromised employee device)
- **But:** Hospital network is flat (no micro-segmentation); any compromised workstation on hospital network can access EHR server
- **Threat Vector:** Compromised employee laptop, compromised contractor device, compromised WiFi guest access point

### Web-Related Findings on ehr-srv-01

#### **Finding 017: Tomcat Version Information Disclosure (Apache Tomcat/8.5.78)**
- **CVSS:** 4.3 (Low to Medium, depending on severity rating)
- **Category:** Information Disclosure (Web)
- **Description:** Tomcat version visible in HTTP response headers and error pages
- **Example Header:**
  ```
  Server: Apache-Coyote/1.1
  X-Powered-By: Servlet/3.1 JSP/2.3 (Apache Tomcat/8.5.78)
  ```
- **Real-World Impact:**
  - **Reconnaissance:** Attacker knows exact Tomcat version
  - **Vulnerability Mapping:** Attacker looks up CVEs affecting Tomcat 8.5.78 specifically
  - **Exploit Selection:** Attacker knows which exploits are relevant

#### **Finding 031: Ghostcat (CVE-2020-1938 - Apache Tomcat AJP Deserialization RCE)**
- **CVSS:** 9.8 (Critical)
- **Category:** Application (Web)
- **Description:** Apache Tomcat 8.5.78 is vulnerable to Ghostcat RCE via AJP (Apache JServ Protocol) port 8009
- **Vulnerability Details:**
  - AJP protocol allows unauthenticated RCE
  - Attacker can call arbitrary JSP files or upload malicious code
  - No authentication required; AJP port is often internal-only but traversable from flat network
- **Attack Scenario:**
  - Attacker on hospital network scans for AJP port 8009
  - Finds ehr-srv-01 with AJP open
  - Exploits Ghostcat to upload malicious JSP file
  - JSP executes with Tomcat privileges
  - Attacker has RCE on EHR server; accesses patient records database

### Combined Risk Assessment: ehr-srv-01

**Finding 017 + Finding 031 = Perfect Attack Chain:**

1. **Reconnaissance (Finding 017):** Attacker sees Tomcat 8.5.78 in response headers
2. **Vulnerability Research:** Attacker searches for CVEs affecting Tomcat 8.5.78
3. **Discovery (Finding 031):** Attacker finds Ghostcat (CVE-2020-1938, published 2020, still unpatched in 2026)
4. **Exploitation:** Attacker exploits Ghostcat to achieve RCE
5. **Impact:** Attacker accesses all patient medical records, lab results, medications stored in EHR database

**Why This Is Different from web-srv-01:**
- ehr-srv-01 is **internal-only**, but
- Attacker only needs to compromise one hospital device (e.g., employee laptop infected with malware, or vendor laptop with weak credentials) to gain network access
- Flat network means no firewall between compromised device and EHR server
- Ghostcat is CVSS 9.8 Critical; once AJP port 8009 is reachable, RCE is trivial

### Priority for ehr-srv-01: **CRITICAL - Patch within 24-48 hours**

**Rationale:**
- **CVSS 9.8 Critical:** Ghostcat is a critical vulnerability
- **Trivial exploitation:** Public exploits available; requires single command to trigger
- **Patient data exposure:** EHR system contains complete medical records for all patients treated at hospital
- **Compliance deadline:** HIPAA requires timely remediation of critical vulnerabilities

**Remediation Approach:**
1. **Immediate (2 hours):** Upgrade Apache Tomcat to 8.5.86+ or apply Ghostcat patch
   - Patch available; requires restart of EHR application
   - Plan maintenance window or use blue-green deployment

2. **Short-term (1 hour after upgrade):**
   - Disable AJP port 8009 if not required by external integrations
   - Restrict AJP access via firewall to specific IPs if required
   - Hide Tomcat version in response headers (minimal security value but good practice)

3. **Validation (1 hour):**
   - Test EHR application functionality after Tomcat upgrade
   - Verify AJP port 8009 is not accessible from flat network

**Total remediation time:** 4-8 hours (includes application restart maintenance window)

---

## Comparative Risk Analysis: web-srv-01 vs. ehr-srv-01

| Factor | web-srv-01 (Portal) | ehr-srv-01 (EHR) |
|--------|-------------------|-----------------|
| **Exposure** | Internet-facing | Internal only |
| **Attacker Barrier** | None | Network compromise required |
| **CVSS Max** | 6.5 (Header missing) | 9.8 (Ghostcat) |
| **Data Sensitivity** | Medium (patient self-entered) | **CRITICAL (medical records)** |
| **Exploit Ease** | Medium (MITM/downgrade) | High (trivial Ghostcat exploit) |
| **Time to First Compromise** | Hours (internet-wide scanning) | Days/weeks (requires internal access) |
| **User Impact** | Hundreds/thousands (all portal users) | Tens of thousands (all patients) |
| **Remediation Effort** | 12-24 hours | 4-8 hours |

### Remediation Priority Ranking

**1. web-srv-01 (Patient Portal) - IMMEDIATE (0-24 hours)**
- Internet-facing; exposed to global attacker pool
- Multiple attack chains; findings compound
- Patient data + user confidence at stake
- Regulatory deadline urgent

**2. ehr-srv-01 (EHR System) - IMMEDIATE (0-24 hours, but slightly lower priority due to internal-only)**
- CVSS 9.8 Critical vulnerability
- Trivial exploitation for anyone with network access
- Complete patient medical records at stake
- However: Requires internal network access (slightly harder for attacker)

**Practical Recommendation:** Patch both within same 24-hour window if possible (parallelized efforts). If only one can be patched first, patch **web-srv-01** due to internet-facing exposure, but schedule ehr-srv-01 remediation for same day.

---

## Critical Insight: Finding 017 → Finding 031 Analysis

### What Does This Tell Us About Medium-Severity Information Disclosure?

**Finding 017 (Version Disclosure) is often rated as "Low" or "Medium" severity** because version information alone does not cause compromise. However, **this finding directly enabled discovery of Finding 031 (CVSS 9.8 Critical).**

**The Chain:**
1. Scanner sees Tomcat version in response headers → Finding 017 (Medium, Information Disclosure)
2. Scanner maps Tomcat 8.5.78 → Known CVE (Ghostcat, CVE-2020-1938)
3. Scanner probes for Ghostcat vulnerability → Finding 031 (CVSS 9.8 Critical)

**Lesson for Vulnerability Assessment:**

**Information disclosure findings should not be dismissed or deprioritized.** They are **reconnaissance vectors** that enable attackers to:
- Identify specific versions
- Map to known CVEs
- Select appropriate exploits
- Tailor attack campaigns

**Best Practice:**
- **Treat information disclosure as "gateway to critical vulnerabilities"**
- When analyzing Medium-severity findings, **manually investigate if they reveal version numbers**
- For version-disclosing findings, **proactively search NVD for CVEs affecting that specific version**
- If critical CVEs exist for disclosed versions, **escalate the information disclosure finding** from Medium to Critical (because it enables critical vulnerability)

**CVSS v3.1 Refinement:**
The CVSS base score for Finding 017 (version disclosure) is appropriately Medium/Low—it causes no direct impact. However, **CVSS Environmental Score** (context-specific multiplier) should be increased when:
- Version disclosure + **known critical CVE** for that version exists
- Disclosed component **is publicly accessible** (internet-facing)
- Component is **commonly targeted** (Tomcat, Apache, IIS are frequent targets)

**In MedDefense's case:** Finding 017 should have been **escalated from Medium to Critical** once Finding 031 (Ghostcat) was discovered, because the information disclosure directly enables the critical vulnerability.

---

## NAS Management Interface (backup-srv-01) - Web-Based Access

### Finding 015: NAS Management Accessible Network-Wide
- **CVSS:** 6.5 (Medium)
- **Category:** Misconfiguration
- **Description:** NAS management interface (typically port 8080 or similar) accessible from all hospital network segments
- **Exposure:** Internal only, but accessible from any hospital workstation + WiFi guests
- **Risk:** If NAS is accessed with default or weak credentials, attacker can access backup data
- **Note:** Not as critical as web-srv-01 or ehr-srv-01 (not internet-facing, no patient-critical data in transit), but still represents significant risk for backup system compromise

### Consolidated Remediation Priorities

**TIER 1 (0-24 hours):**
- web-srv-01: Patch TLS, headers, certificate
- ehr-srv-01: Patch Ghostcat

**TIER 2 (1-7 days):**
- backup-srv-01: Restrict NAS management access via firewall; enforce strong credentials

**TIER 3 (1-4 weeks):**
- Review and update all web-based management interfaces across hospital network
- Implement WAF (Web Application Firewall) for internet-facing web-srv-01
- Implement network segmentation to isolate internal systems (ehr-srv-01, backup-srv-01)

---

## Conclusion

**Internet-facing vulnerabilities require immediate remediation; internal vulnerabilities require context-aware assessment.**

- **web-srv-01 (internet-facing):** Global attacker pool; compromise possible within hours
- **ehr-srv-01 (internal but flat network):** Attacker must compromise internal device first, but trivial once inside
- **backup-srv-01 (internal, limited access):** Lower priority but still requires remediation

**Both web-srv-01 and ehr-srv-01 should be remediated within 24 hours.** The internet-facing exposure of web-srv-01 is slightly higher priority, but the CVSS 9.8 Ghostcat vulnerability on ehr-srv-01 is equally critical and easier to exploit (once internal access is gained).

**Key takeaway:** Information disclosure findings (Finding 017) should be investigated for associated critical vulnerabilities (Finding 031). A Medium-severity finding that reveals version information for a component with critical CVEs should be escalated in priority.
