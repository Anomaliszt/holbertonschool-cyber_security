# MedDefense Comprehensive Threat Scenarios

---

# Scenario 1 — "BlackReef Hospital Lockdown"

## Threat Actor:
Organized Crime / Ransomware-as-a-Service (BlackReef affiliate)  
**Profile Reference:** T6 — Ransomware Groups (Organized Crime / RaaS)

## Motivation:
Financial gain through double extortion:
- Cryptocurrency ransom payment.
- Sale or public release of stolen patient records.
- Operational pressure against healthcare services.

## Initial Vector:
**Phishing / Spear Phishing → Credential compromise → Flat network exploitation**

## Attack Surface Exploited:
**External + Human**

The attacker targets an external email pathway and exploits an IT employee with privileged access.

---

# Attack Sequence

## Step 1: Spear Phishing Against IT Leadership  
**ATT&CK Tactic: Initial Access**

BlackReef sends Sarah Park, MedDefense's IT Director, a fake Fortinet security advisory email claiming that an emergency FortiGate firmware patch is required. The email links to a counterfeit vendor portal hosting a malicious document.

Sarah opens the document, allowing a PowerShell payload to execute and establish a reverse shell.

**Exploited Weakness:**
- Limited email security controls.
- High-value employee targeted through authority-based social engineering.

---

## Step 2: Establish Persistent Remote Access  
**ATT&CK Tactic: Execution / Persistence**

The attacker creates a scheduled task disguised as a Windows update process. The task reconnects to the attacker's command-and-control server every 30 minutes.

The attacker now maintains access to Sarah's workstation without needing to repeat the phishing attack.

**Exploited Weakness:**
- No EDR monitoring.
- Insufficient endpoint behavior detection.

---

## Step 3: Internal Discovery and Network Mapping  
**ATT&CK Tactic: Discovery**

The attacker executes Active Directory discovery commands and maps the internal environment.

Because MedDefense operates a flat network, the compromised workstation can reach:

- `ad-dc-01`
- `ehr-srv-01`
- `ehr-db-01`
- `billing-srv-01`
- `NAS-01`

**Exploited Weakness:**
- No internal segmentation.
- Excessive network visibility.

---

## Step 4: Credential Theft and Domain Compromise  
**ATT&CK Tactic: Credential Access / Privilege Escalation**

The attacker executes Mimikatz and discovers cached credentials belonging to the `svc_backup` domain administrator account.

Using pass-the-hash techniques, the attacker authenticates directly to Active Directory and obtains Domain Admin privileges.

**Exploited Weakness:**
- Privileged credentials reused across systems.
- Weak privileged account controls.
- No MFA for administrative access.

---

## Step 5: Data Theft and Ransomware Deployment  
**ATT&CK Tactics: Collection / Exfiltration / Impact**

The attacker:

1. Exports approximately 35 GB of patient records from PostgreSQL (`ehr-db-01`).
2. Copies financial and HR documents.
3. Deletes NAS backups.
4. Removes Windows shadow copies.
5. Deploys BlackReef ransomware through Group Policy.

Systems become encrypted and unavailable.

---

# STRIDE Categories Triggered

| STRIDE | Threat Activated |
|---|---|
| Spoofing | Attacker impersonates IT vendor and later legitimate domain accounts |
| Tampering | Ransomware modifies/encrypts system data |
| Information Disclosure | Patient records stolen before encryption |
| Denial of Service | EHR and operational systems become unavailable |
| Elevation of Privilege | Domain Admin compromise |

---

# MedDefense Assets Impacted

- `ehr-db-01` — Patient database
- `ehr-srv-01` — EHR application server
- Active Directory (`ad-dc-01`)
- `billing-srv-01`
- `NAS-01` backup infrastructure
- File servers

---

# Business Impact

**Clinical**
- EHR downtime prevents normal patient care.
- Delayed access to medical records.

**Financial**
- Ransom payment demand.
- Incident response costs.
- Lost operational revenue.

**Regulatory**
- HIPAA breach notification requirements.
- Potential regulatory penalties.

**Reputational**
- Loss of patient confidence.

---

# Gaps Exploited

| Gap | Exploitation |
|---|---|
| G1: Unpatched public-facing systems | Provides external attack opportunities |
| G2: Flat network architecture | Enables unrestricted lateral movement |
| G3: No SIEM/EDR monitoring | Allows persistence and credential theft to continue |
| G4: Poor backup isolation | Allows ransomware recovery capability to be destroyed |
| G6: Weak identity controls | Enables privileged account takeover |

---

# Detection Opportunities

| Step | Required Control |
|---|---|
| Step 1 | Secure email gateway, phishing detection, attachment sandboxing |
| Step 2 | EDR detecting scheduled task persistence |
| Step 3 | Network monitoring detecting unusual discovery commands |
| Step 4 | Privileged account monitoring and MFA alerts |
| Step 5 | SIEM alerts for mass file encryption and backup deletion |

---

---

# Scenario 2 — "The Quiet Billing Department Theft"

## Threat Actor:
Malicious Insider — Billing Department Employee  
**Profile Reference:** T6 — Insider (Malicious)

## Motivation:
Financial gain through theft and resale of protected health information.

## Initial Vector:
**Legitimate Access Abuse**

## Attack Surface Exploited:
**Internal + Human**

---

# Attack Sequence

## Step 1: Insider Uses Existing Permissions  
**ATT&CK Tactic: Initial Access**

A billing employee with legitimate access to billing systems and read-only EHR permissions decides to steal patient records before leaving the organization.

The employee does not need to bypass authentication because access is already authorized.

---

## Step 2: Identify Valuable Patient Data  
**ATT&CK Tactic: Discovery**

The employee reviews accessible records and identifies valuable information:

- Names
- DOB
- Insurance information
- Diagnoses
- Prescription history

The employee determines which records have the highest resale value.

---

## Step 3: Bulk Export Patient Records  
**ATT&CK Tactic: Collection**

The employee exports approximately 200 patient records daily through the normal EHR export function.

The activity blends with normal workflow because no behavioral analytics monitor unusual access patterns.

---

## Step 4: Remove Data Through USB Device  
**ATT&CK Tactic: Exfiltration**

The employee copies CSV exports onto a personal USB drive.

No technical restriction prevents removable media usage.

---

## Step 5: Maintain Access After Termination  
**ATT&CK Tactic: Persistence**

HR submits an account termination request, but IT processing delays leave VPN credentials active for five additional business days.

The former employee reconnects remotely and extracts additional billing data.

---

# STRIDE Categories Triggered

| STRIDE | Threat Activated |
|---|---|
| Spoofing | Continued use of valid employee credentials |
| Information Disclosure | Patient record theft |
| Repudiation | Limited monitoring prevents accountability |
| Elevation of Privilege | Abuse of excessive permissions |

---

# MedDefense Assets Impacted

- `ehr-db-01`
- EHR application
- `billing-srv-01`
- Patient database
- Employee workstation

---

# Business Impact

**Clinical**
- Exposure of confidential medical information.

**Financial**
- Patient identity theft consequences.
- Legal response costs.

**Regulatory**
- HIPAA privacy violation.

**Reputational**
- Reduced trust in MedDefense data handling.

---

# Gaps Exploited

| Gap | Exploitation |
|---|---|
| G7: Shared/excessive access permissions | Employee accesses more data than required |
| G8: Weak access monitoring | Large exports go unnoticed |
| G9: Poor employee offboarding | Former employee retains access |
| G12: Weak data handling controls | USB transfer allowed |

---

# Detection Opportunities

| Step | Required Control |
|---|---|
| Step 2 | User behavior analytics detecting unusual searches |
| Step 3 | DLP monitoring large exports |
| Step 4 | USB device restrictions |
| Step 5 | Automated HR-to-identity deprovisioning |

---

---

# Scenario 3 — "Vendor Gateway Breach"

## Threat Actor:
External attacker compromising a trusted vendor relationship  
**Profile Reference:** T6 — Organized Crime / External Attacker using Supply Chain Access

## Motivation:
Financial gain through unauthorized access, ransomware deployment, or data theft.

## Initial Vector:
**Vendor access pathway — MedTech Solutions remote maintenance account**

## Attack Surface Exploited:
**Third Party + External**

---

# Attack Sequence

## Step 1: Compromise MedTech Solutions  
**ATT&CK Tactic: Initial Access**

Attackers compromise a MedTech Solutions technician account through phishing or credential theft.

The account has legitimate remote maintenance access to MedDefense EHR infrastructure.

---

## Step 2: Authenticate Through Vendor Access Channel  
**ATT&CK Tactic: Persistence**

The attacker uses stolen vendor credentials to access MedDefense maintenance services.

Because the account is trusted, the connection appears legitimate.

---

## Step 3: Move From Vendor Connection Into Internal Systems  
**ATT&CK Tactic: Lateral Movement**

The attacker accesses:

- EHR application servers.
- Database systems.
- Maintenance interfaces.

The flat network allows movement beyond the original vendor access scope.

---

## Step 4: Access Patient Data  
**ATT&CK Tactic: Collection**

The attacker queries EHR databases and exports patient information.

Sensitive medical records become available for extortion or resale.

---

## Step 5: Deploy Malware or Maintain Access  
**ATT&CK Tactic: Impact / Persistence**

The attacker installs remote tools or ransomware payloads using trusted vendor pathways.

---

# STRIDE Categories Triggered

| STRIDE | Threat Activated |
|---|---|
| Spoofing | Attacker impersonates vendor personnel |
| Information Disclosure | Patient records exposed |
| Tampering | Systems modified through trusted access |
| Elevation of Privilege | Vendor access expanded beyond intended scope |
| Denial of Service | Potential ransomware disruption |

---

# MedDefense Assets Impacted

- `ehr-srv-01`
- `ehr-db-01`
- Active Directory
- Medical applications
- Patient records

---

# Business Impact

**Clinical**
- Possible EHR outage affecting patient treatment.

**Financial**
- Incident response and recovery costs.

**Regulatory**
- Third-party HIPAA breach exposure.

**Reputational**
- Loss of confidence in vendor security management.

---

# Gaps Exploited

| Gap | Exploitation |
|---|---|
| G5: Excessive vendor access | Vendor credentials provide broad reach |
| G2: Flat network architecture | Vendor compromise enables lateral movement |
| G3: Lack of monitoring | Vendor activity appears legitimate |
| G6: Weak identity controls | No MFA or strong vendor authentication |

---

# Detection Opportunities

| Step | Required Control |
|---|---|
| Step 1 | Vendor security assessments and MFA enforcement |
| Step 2 | Vendor access logging and anomaly detection |
| Step 3 | Network segmentation restricting vendor paths |
| Step 4 | Database monitoring and unusual query detection |
| Step 5 | EDR and SIEM detection of malware behavior |

---

# Overall Threat Scenario Assessment

The three scenarios demonstrate that MedDefense faces risk from **external attackers, trusted insiders, and third-party relationships**. The common failure points are identity, visibility, and excessive trust: attackers succeed when legitimate access is abused, privileged access is uncontrolled, and suspicious activity is not detected. The highest-value defensive investments are therefore **strong identity controls (MFA and least privilege), network segmentation, centralized monitoring, and vendor access restrictions**.
