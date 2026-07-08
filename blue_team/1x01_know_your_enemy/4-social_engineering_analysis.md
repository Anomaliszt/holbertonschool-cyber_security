# Social Engineering Threat Analysis — MedDefense

## Scenario 1: Fake FortiGate Support Firmware Patch

**Vector Type:** Phishing

**Target:** Sarah Park — IT Director  
Sarah is vulnerable because IT leadership is responsible for maintaining security infrastructure and is accustomed to handling urgent vendor notifications and vulnerability remediation requests.

**Psychological Lever:** Urgency + Authority

**Red Flags:**
1. The sender domain is `fortinet-support.net` rather than the legitimate Fortinet vendor domain.
2. The email creates artificial urgency by threatening service termination within 24 hours.
3. The patch is provided through an unsolicited download link instead of a verified vendor support portal.

**Technical Control:**  
Deploy secure email gateways with domain spoofing detection, URL reputation filtering, and attachment/link sandboxing.

**Administrative Control:**  
Require all security patches and vendor updates to be verified through approved vendor channels before installation.

---

# Scenario 2: Fake CEO Wire Transfer Request

**Vector Type:** Business Email Compromise (BEC)

**Target:** Robert Kim — CFO  
The CFO is vulnerable because financial executives have authority to approve payments and are high-value targets for attackers seeking fraudulent transfers.

**Psychological Lever:** Authority + Fear

**Red Flags:**
1. The sender address contains a subtle variation from the legitimate CEO email address.
2. The request demands secrecy and bypasses normal financial approval processes.
3. The CEO claims to be unavailable and requires email-only communication.

**Technical Control:**  
Implement SPF, DKIM, and DMARC email authentication with executive impersonation detection.

**Administrative Control:**  
Require dual approval and out-of-band verification for wire transfers above a defined threshold.

---

# Scenario 3: Fake IT Support Password Request

**Vector Type:** Vishing

**Target:** Clinical Nurse Staff  
Nurses are vulnerable because they work under time pressure, depend on IT systems for patient care, and are culturally encouraged to help coworkers resolve urgent issues.

**Psychological Lever:** Helpfulness + Authority + Urgency

**Red Flags:**
1. Legitimate IT personnel should never request passwords.
2. The caller uses an emergency scenario to pressure the employee.
3. The caller cannot provide verifiable identification, ticket information, or follow official support procedures.

**Technical Control:**  
Implement IT support identity verification procedures using ticket numbers, employee IDs, or callback verification.

**Administrative Control:**  
Maintain a strict policy prohibiting password sharing with anyone, including IT personnel.

---

# Scenario 4: Fake Parking Permit Renewal SMS

**Vector Type:** Smishing

**Target:** All MedDefense Employees  
Employees are vulnerable because workplace administrative messages are common and the threat of losing parking access creates pressure to act quickly.

**Psychological Lever:** Fear + Urgency

**Red Flags:**
1. The SMS contains an unexpected login link.
2. The message threatens immediate consequences such as towing.
3. The URL does not match the official MedDefense HR or facilities portal.

**Technical Control:**  
Deploy mobile threat protection and SMS filtering to block malicious links.

**Administrative Control:**  
Establish a policy that HR and facilities departments will never request credentials through SMS messages.

---

# Scenario 5: Compromised Healthcare Association Website

**Vector Type:** Watering Hole Attack

**Target:** MedDefense Physicians  
Physicians are vulnerable because they regularly access trusted healthcare websites for CME credits, research, and professional resources.

**Psychological Lever:** Familiarity + Trust

**Red Flags:**
1. A normally trusted healthcare website behaves unexpectedly.
2. The website redirects users without normal navigation.
3. The site requests unusual downloads, browser extensions, or permissions.

**Technical Control:**  
Deploy endpoint detection and response (EDR) with browser exploit protection.

**Administrative Control:**  
Require secure browsing practices and restrict unauthorized software downloads.

---

# Scenario 6: Fake MedDefense Patient Portal

**Vector Type:** Brand Impersonation / Typosquatting

**Target:** Patients and MedDefense Portal Users  
Users are vulnerable because they trust familiar branding and may not notice small domain differences when searching online.

**Psychological Lever:** Familiarity + Trust

**Red Flags:**
1. The domain uses a similar but incorrect spelling (`meddefence-portal.com`).
2. The fake portal appears through a sponsored search advertisement.
3. The site requests credentials but is not accessed through the official portal address.

**Technical Control:**  
Implement external attack surface monitoring and domain takedown services.

**Administrative Control:**  
Educate users to bookmark the official portal URL rather than accessing it through search engines.

---

# Scenario 7: Unauthorized Person Tailgating into IT Department

**Vector Type:** Impersonation

**Target:** MedDefense Employees with Physical Access  
Employees are vulnerable because healthcare culture emphasizes cooperation and helping others, making staff less likely to challenge someone who appears to belong.

**Psychological Lever:** Helpfulness + Familiarity

**Red Flags:**
1. The individual does not display a valid visible badge.
2. The visitor badge is expired or intentionally concealed.
3. The person requests access to a restricted area without proper authorization.

**Technical Control:**  
Deploy stronger physical access controls such as monitored badge systems, access logs, and security cameras.

**Administrative Control:**  
Enforce anti-tailgating policies requiring employees to challenge unknown individuals entering restricted areas.

---

# Social Engineering Risk Ranking — MedDefense

| Rank | Scenario | Vector Type | Risk Level | Primary Concern |
|---|---|---|---|---|
| 1 | Scenario 2 | Business Email Compromise | Critical | Financial fraud through executive impersonation |
| 2 | Scenario 3 | Vishing | Critical | Credential theft enabling EHR compromise |
| 3 | Scenario 4 | Smishing | High | Enterprise credential harvesting |
| 4 | Scenario 6 | Brand Impersonation / Typosquatting | High | Patient portal compromise |
| 5 | Scenario 1 | Phishing | High | IT infrastructure compromise |
| 6 | Scenario 7 | Impersonation | Medium–High | Physical security breach |
| 7 | Scenario 5 | Watering Hole Attack | Medium | Malware delivery through trusted websites |

---

# Overall Assessment

MedDefense’s greatest social engineering risks come from attacks exploiting trusted relationships:

- IT authority
- Executive authority
- Healthcare branding
- Patient trust
- Staff willingness to help

Technical controls reduce exposure, but effective defense requires:

- Strong verification procedures
- Security awareness training
- Clear reporting channels
- Policies that empower employees to challenge suspicious requests
- A culture where security checks are viewed as protecting patient care rather than delaying it
