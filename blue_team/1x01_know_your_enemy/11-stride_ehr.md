# STRIDE Threat Model — MedDefense EHR System

## System Scope

**System Assessed: MedDefense Electronic Health Record (EHR) Environment**

Components included:

- **`ehr-srv-01`** — EHR application server
- **`ehr-db-01`** — PostgreSQL database server
- **Clinical Workstations** — Physician and nursing endpoints accessing EHR applications
- **Network Connections** — Internal communication paths between users, application servers, databases, and supporting systems

The STRIDE model identifies threats across six categories:

- **S — Spoofing:** Impersonating users, systems, or services
- **T — Tampering:** Unauthorized modification of data or systems
- **R — Repudiation:** Preventing accountability or denying actions
- **I — Information Disclosure:** Unauthorized exposure of information
- **D — Denial of Service:** Preventing legitimate access or operation
- **E — Elevation of Privilege:** Gaining unauthorized capabilities

---

# 1. Spoofing Threats

## Threat ID: EHR-S1

**Category:** Spoofing

**Description:**

An attacker obtains clinician credentials and impersonates a legitimate healthcare provider to access patient records through the EHR application.

**Attack Vector:**

Phishing / Spear Phishing → stolen credentials → EHR login.

**Impact:**

Unauthorized access to patient charts, exposure of protected health information (PHI), and potential fraudulent medical record access.

**Existing Control:**

- Authentication controls
- User account management procedures

**Gap:**

- **G6:** Weak identity and access management controls
- **G11:** Weak credential practices

---

## Threat ID: EHR-S2

**Category:** Spoofing

**Description:**

A compromised workstation impersonates a trusted clinical endpoint and communicates with `ehr-srv-01` to access EHR resources.

**Attack Vector:**

Malware infection or stolen workstation credentials → internal network access.

**Impact:**

Attackers gain the ability to view or interact with clinical applications as legitimate users.

**Existing Control:**

- Endpoint antivirus protection

**Gap:**

- **G3:** Lack of EDR/SIEM monitoring
- **G2:** Flat network architecture

---

# 2. Tampering Threats

## Threat ID: EHR-T1

**Category:** Tampering

**Description:**

An attacker modifies patient records within `ehr-db-01`, altering medications, diagnoses, or clinical notes.

**Attack Vector:**

Database access through exposed PostgreSQL service (TCP 5432) after internal compromise.

**Impact:**

Incorrect clinical decisions, patient safety risks, legal exposure, and loss of record integrity.

**Existing Control:**

- Database authentication controls

**Gap:**

- **G2:** Flat network architecture
- **G10:** Excessive privileges

---

## Threat ID: EHR-T2

**Category:** Tampering

**Description:**

A malicious insider modifies EHR application configurations on `ehr-srv-01` to change workflows or disable security logging.

**Attack Vector:**

Insider abuse → privileged administrative access.

**Impact:**

Unauthorized clinical workflow changes and potential manipulation of patient information.

**Existing Control:**

- Administrative access restrictions

**Gap:**

- **G10:** Excessive administrative privileges
- **G8:** Insufficient monitoring

---

# 3. Repudiation Threats

## Threat ID: EHR-R1

**Category:** Repudiation

**Description:**

A user accesses patient records through shared clinical accounts, preventing investigators from determining the actual person responsible.

**Attack Vector:**

Default/shared credentials → EHR access.

**Impact:**

Loss of accountability, inability to prove who accessed records, and increased compliance risk.

**Existing Control:**

- Basic account authentication

**Gap:**

- **G7:** Shared accounts
- **G8:** Insufficient audit monitoring

---

## Threat ID: EHR-R2

**Category:** Repudiation

**Description:**

An attacker deletes or alters EHR audit logs after compromising administrative access.

**Attack Vector:**

Privilege escalation → administrative database access.

**Impact:**

Security investigations become ineffective, delaying breach response and regulatory reporting.

**Existing Control:**

- Limited system logging

**Gap:**

- **G3:** No centralized SIEM monitoring

---

# 4. Information Disclosure Threats

## Threat ID: EHR-I1

**Category:** Information Disclosure

**Description:**

An attacker extracts thousands of patient records directly from `ehr-db-01`.

**Attack Vector:**

PostgreSQL exposure → stolen credentials → database extraction.

**Impact:**

Large-scale PHI breach including medical history, identifiers, and insurance information.

**Existing Control:**

- Database authentication

**Gap:**

- **G2:** Flat network architecture
- **G3:** Lack of database activity monitoring

---

## Threat ID: EHR-I2

**Category:** Information Disclosure

**Description:**

A compromised clinical workstation allows malware to capture patient information displayed through the EHR application.

**Attack Vector:**

Phishing → workstation compromise → credential theft/data capture.

**Impact:**

Unauthorized disclosure of sensitive patient information.

**Existing Control:**

- Endpoint antivirus

**Gap:**

- **G3:** No EDR monitoring
- **G8:** Security awareness gaps

---

# 5. Denial of Service Threats

## Threat ID: EHR-D1

**Category:** Denial of Service

**Description:**

Ransomware encrypts `ehr-srv-01` and `ehr-db-01`, preventing clinicians from accessing patient records.

**Attack Vector:**

Vulnerable software exploit → lateral movement → ransomware deployment.

**Impact:**

Clinical disruption, delayed treatment, diversion of patients, and operational shutdown.

**Existing Control:**

- Backup procedures

**Gap:**

- **G4:** Poor backup isolation
- **G1:** Vulnerable systems

---

## Threat ID: EHR-D2

**Category:** Denial of Service

**Description:**

An attacker intentionally overwhelms EHR database resources by executing excessive database queries.

**Attack Vector:**

Compromised internal account → PostgreSQL resource exhaustion.

**Impact:**

EHR performance degradation or complete clinical application outage.

**Existing Control:**

- Database availability controls

**Gap:**

- **G3:** Limited monitoring
- **G2:** Lack of network segmentation

---

# 6. Elevation of Privilege Threats

## Threat ID: EHR-E1

**Category:** Elevation of Privilege

**Description:**

A standard clinical user escalates privileges to an administrator account and gains unauthorized EHR management capabilities.

**Attack Vector:**

Credential theft → privilege escalation → Active Directory compromise.

**Impact:**

Unauthorized access to all patient records and administrative functions.

**Existing Control:**

- Role-based access permissions

**Gap:**

- **G10:** Excessive privileges
- **G6:** Weak identity controls

---

## Threat ID: EHR-E2

**Category:** Elevation of Privilege

**Description:**

An attacker compromises `ehr-srv-01` and uses local privilege escalation techniques to obtain administrator-level access.

**Attack Vector:**

Vulnerable software exploit → server compromise → privilege escalation.

**Impact:**

Full control of the EHR application environment and ability to steal or modify patient data.

**Existing Control:**

- Server access controls

**Gap:**

- **G1:** Vulnerable software
- **G3:** Limited endpoint monitoring

---

# STRIDE Threat Inventory Summary

| Category | Threat IDs | Risk Level |
|----------|------------|------------|
| Spoofing | EHR-S1, EHR-S2 | High |
| Tampering | EHR-T1, EHR-T2 | Critical |
| Repudiation | EHR-R1, EHR-R2 | High |
| Information Disclosure | EHR-I1, EHR-I2 | Critical |
| Denial of Service | EHR-D1, EHR-D2 | Critical |
| Elevation of Privilege | EHR-E1, EHR-E2 | Critical |

---

# STRIDE Summary for EHR

The highest-risk STRIDE categories for MedDefense's EHR environment are **Information Disclosure, Denial of Service, and Elevation of Privilege** because the EHR system combines extremely sensitive patient data with direct clinical dependency. A successful compromise does not only create a privacy incident; it can prevent physicians and nurses from accessing critical medical information during patient care. The combination of a flat internal network, exposed database services, weak identity controls, insufficient monitoring, and ransomware exposure allows attackers to move from credential theft or technical exploitation into complete EHR compromise. In healthcare, these threats are particularly dangerous because confidentiality breaches create regulatory consequences while availability and integrity failures can directly affect patient safety.
