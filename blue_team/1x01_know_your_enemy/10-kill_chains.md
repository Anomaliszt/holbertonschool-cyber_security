# MedDefense Critical Attack Kill Chains

## Overview

The following kill chains represent the **five highest-risk attack paths** identified from the Vector-to-Asset Matrix (Task 9), Threat Actor Matrix (Task 6), Attack Surface Assessment (Task 7), and Technical Vector Assessment (Task 8). Each chain demonstrates how an attacker progresses from initial access to operational impact and identifies the defensive controls capable of interrupting the attack.

---

# Kill Chain #1: Ransomware Deployment via Internet-Facing Apache Server

**Threat Actor:** Organized Crime (Ransomware-as-a-Service)

**Target Asset:** `ehr-db-01`, Active Directory, Backup NAS

**Expected Impact:**
Enterprise-wide ransomware affecting patient care, resulting in loss of availability, regulatory penalties, financial loss, and reputational damage.

## Step 1 – Initial Access

**Vector:** Vulnerable Software Exploit

**Surface:** External

**Detail:**
The attacker exploits the unpatched Apache 2.4.29 Remote Code Execution vulnerability on `billing-srv-01` to obtain remote code execution.

---

## Step 2 – Establish Foothold

**Action:**
Install a web shell, create persistence, dump local credentials, and establish encrypted command-and-control communications.

**MedDefense Weakness:**
Lack of EDR/SIEM monitoring and delayed patch management.

---

## Step 3 – Lateral Movement / Escalation

**Action:**
Use Mimikatz and PsExec to harvest credentials, compromise Active Directory, and move laterally throughout the flat network.

**MedDefense Weakness:**
Flat network architecture, unrestricted internal database access, and excessive administrative privileges.

---

## Step 4 – Objective Execution

**Action:**
Exfiltrate patient records, destroy NAS backups, and deploy ransomware through Group Policy.

**Data/System Affected:**
EHR database, billing systems, file servers, Active Directory, Backup NAS.

---

## Step 5 – Impact

**Business Impact:**

- Hospital operations disrupted
- Patient care delayed
- HIPAA breach notification
- Multi-million-dollar recovery costs
- Ransom demand and regulatory investigations

**CIA Pillars:**

- **Confidentiality:** Patient data stolen.
- **Integrity:** Files and configurations modified.
- **Availability:** Clinical systems encrypted.

### Gaps Exploited

- G1
- G2
- G3
- G4
- G10

### Break Points

- **Step 1:** Rapid vulnerability management and Internet-facing patching.
- **Step 3:** Network segmentation, EDR, privileged access management, and lateral movement detection.

---

# Kill Chain #2: Credential Phishing Leading to Active Directory Compromise

**Threat Actor:** Organized Crime (RaaS) / Initial Access Broker

**Target Asset:** Active Directory

**Expected Impact:**
Complete enterprise compromise through stolen privileged credentials.

## Step 1 – Initial Access

**Vector:** Phishing / Spear Phishing

**Surface:** Human

**Detail:**
An IT administrator receives a convincing phishing email requesting a Microsoft 365 login.

---

## Step 2 – Establish Foothold

**Action:**
The attacker authenticates using stolen credentials and registers persistence through cloud identity.

**MedDefense Weakness:**
Weak phishing resistance and incomplete MFA protections.

---

## Step 3 – Lateral Movement / Escalation

**Action:**
Synchronize cloud identities with Active Directory, escalate privileges, and enumerate internal systems.

**MedDefense Weakness:**
Weak identity monitoring and flat network architecture.

---

## Step 4 – Objective Execution

**Action:**
Create privileged accounts, disable security tools, and prepare for ransomware deployment or long-term persistence.

**Data/System Affected:**
Domain Controllers, Group Policy, enterprise authentication.

---

## Step 5 – Impact

**Business Impact:**

- Organization-wide identity compromise
- Loss of trust in authentication
- Enterprise-wide ransomware risk
- Regulatory reporting

**CIA Pillars:**

- **Confidentiality:** Enterprise-wide credential exposure.
- **Integrity:** Administrative objects modified.
- **Availability:** Domain services disrupted.

### Gaps Exploited

- G2
- G3
- G6
- G8
- G10

### Break Points

- **Step 1:** Security awareness training and phishing-resistant MFA.
- **Step 3:** Privileged Access Management (PAM), conditional access, and identity monitoring.

---

# Kill Chain #3: Supply Chain Compromise of MedTech Solutions

**Threat Actor:** Organized Crime / Nation-State

**Target Asset:** EHR Database (`ehr-db-01`)

**Expected Impact:**
Unauthorized access to patient records through trusted vendor connectivity.

## Step 1 – Initial Access

**Vector:** Supply Chain Compromise

**Surface:** External

**Detail:**
Attackers compromise MedTech Solutions and steal remote maintenance credentials used for EHR support.

---

## Step 2 – Establish Foothold

**Action:**
Authenticate using trusted vendor accounts and establish persistent remote access.

**MedDefense Weakness:**
Broad vendor privileges and insufficient vendor monitoring.

---

## Step 3 – Lateral Movement / Escalation

**Action:**
Move from the maintenance server into Active Directory and adjacent clinical systems.

**MedDefense Weakness:**
Flat network and unrestricted vendor connectivity.

---

## Step 4 – Objective Execution

**Action:**
Export patient records and install persistence for future access.

**Data/System Affected:**
EHR database and supporting application servers.

---

## Step 5 – Impact

**Business Impact:**

- PHI breach
- HIPAA violations
- Loss of patient trust
- Regulatory investigations

**CIA Pillars:**

- **Confidentiality:** Patient records stolen.
- **Integrity:** Possible unauthorized changes.
- **Availability:** Potential service interruption.

### Gaps Exploited

- G2
- G5
- G6

### Break Points

- **Step 1:** Vendor risk assessments and MFA for vendor access.
- **Step 3:** Vendor network segmentation and continuous monitoring.

---

# Kill Chain #4: Malicious Insider Sabotages Critical Infrastructure

**Threat Actor:** Malicious Insider

**Target Asset:** Backup NAS and Active Directory

**Expected Impact:**
Intentional operational disruption and data destruction.

## Step 1 – Initial Access

**Vector:** Insider (Malicious)

**Surface:** Internal

**Detail:**
A privileged IT administrator abuses legitimate access following a disciplinary action.

---

## Step 2 – Establish Foothold

**Action:**
Create hidden administrator accounts and disable automated backups.

**MedDefense Weakness:**
Weak privileged access monitoring and ineffective offboarding.

---

## Step 3 – Lateral Movement / Escalation

**Action:**
Leverage Domain Admin privileges to modify enterprise systems.

**MedDefense Weakness:**
Excessive privileges and insufficient administrative oversight.

---

## Step 4 – Objective Execution

**Action:**
Delete production databases and encrypt or erase backups.

**Data/System Affected:**
Backup NAS, Active Directory, production databases.

---

## Step 5 – Impact

**Business Impact:**

- Major operational outage
- Clinical disruption
- Data recovery costs
- Internal investigation

**CIA Pillars:**

- **Confidentiality:** Limited impact.
- **Integrity:** Critical databases modified or deleted.
- **Availability:** Essential systems unavailable.

### Gaps Exploited

- G4
- G9
- G10

### Break Points

- **Step 2:** Privileged session monitoring and separation of duties.
- **Step 4:** Immutable backups and administrative change approval processes.

---

# Kill Chain #5: Default Credentials Compromise Medical IoT Environment

**Threat Actor:** Unskilled / Opportunistic Attacker

**Target Asset:** Medical IoT Devices

**Expected Impact:**
Compromise of connected medical devices with potential impact on clinical services.

## Step 1 – Initial Access

**Vector:** Default / Shared Credentials

**Surface:** Internal

**Detail:**
An attacker gains network access and discovers default credentials on PACS systems or BD Alaris pump management interfaces.

---

## Step 2 – Establish Foothold

**Action:**
Authenticate using vendor-default credentials and maintain administrator access.

**MedDefense Weakness:**
Default passwords and shared accounts remain unchanged.

---

## Step 3 – Lateral Movement / Escalation

**Action:**
Move between IoT devices and connected clinical systems across the flat network.

**MedDefense Weakness:**
No network segmentation separating medical devices from enterprise systems.

---

## Step 4 – Objective Execution

**Action:**
Modify device configurations, deploy malware, or use IoT systems as pivot points.

**Data/System Affected:**
Medical IoT devices, PACS, connected clinical workstations.

---

## Step 5 – Impact

**Business Impact:**

- Medical equipment disruption
- Patient safety concerns
- Clinical service delays
- Incident response costs

**CIA Pillars:**

- **Confidentiality:** Possible patient data exposure.
- **Integrity:** Device configurations altered.
- **Availability:** Medical devices become unavailable or unreliable.

### Gaps Exploited

- G2
- G7
- G11
- G14

### Break Points

- **Step 1:** Eliminate default credentials and implement unique administrator passwords.
- **Step 3:** Segment medical devices from enterprise networks and continuously monitor IoT communications.

---

# Overall Assessment

Across all five kill chains, the same weaknesses repeatedly enable successful attacks: **unpatched Internet-facing systems (G1), a flat internal network (G2), insufficient monitoring (G3), weak identity and privileged access controls (G6, G10, G11), inadequate backup protection (G4), and excessive third-party access (G5).** The most effective defensive investments for MedDefense are **network segmentation, phishing-resistant MFA, comprehensive EDR/SIEM monitoring, privileged access management (PAM), rapid vulnerability management, immutable backups, and stronger vendor access controls**, as these controls interrupt multiple kill chains at their earliest stages and significantly reduce enterprise-wide risk.
