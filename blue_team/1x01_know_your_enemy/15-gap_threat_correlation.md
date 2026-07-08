# Threat-Informed Gap Prioritization — MedDefense

## Purpose

This assessment recalibrates the original 1x00 posture-based gap ranking by adding threat intelligence from 1x01. Each gap is evaluated against:

- Threat actors likely to exploit it.
- MITRE ATT&CK attack paths and kill chains.
- Completed MedDefense threat scenarios.
- Frequency across realistic attack sequences.

---

# Threat-Informed Gap Correlation Matrix

| Gap ID | Gap Description | Original Risk Level | Threat Actors | Kill Chains | Scenarios | Updated Risk Level | Justification |
|---|---|---|---|---|---|---|---|
| **G1** | Unpatched public-facing systems (FortiGate exposure, Apache billing server vulnerabilities) | High | Ransomware Groups, Opportunistic Attackers, Nation-State APT | Kill Chain #1 — BlackReef ransomware campaign | Scenario 1 — BlackReef Hospital Lockdown | **Upgraded → Critical** | Originally viewed as an external exposure issue. Threat analysis showed it is a primary initial access path for RaaS affiliates using vulnerability scanning and exploit chains. |
| **G2** | Flat network architecture with no internal segmentation | High | Ransomware Groups, Insider Threats, Supply Chain Attackers | Kill Chain #1, Kill Chain #3 | Scenario 1, Scenario 3 | **Upgraded → Critical** | Appears in multiple attack paths because any initial compromise can become enterprise-wide compromise. It directly enables lateral movement from low-value systems to EHR and Active Directory. |
| **G3** | No SIEM/EDR monitoring and limited detection capability | High | Ransomware Groups, Malicious Insiders, External Attackers | Kill Chain #1, Kill Chain #2, Kill Chain #3 | Scenario 1, Scenario 2, Scenario 3 | **Upgraded → Critical** | Threat analysis showed attackers and insiders rely on visibility gaps. Lack of detection allows credential theft, persistence, data theft, and vendor abuse to continue undetected. |
| **G4** | Backups not isolated or immutable | High | Ransomware Groups | Kill Chain #1 | Scenario 1 | **Same → High** | Remains primarily ransomware-focused. However, the impact is severe because backup destruction removes MedDefense's recovery option after encryption. |
| **G5** | Excessive vendor access and insufficient vendor controls | Medium/High | Supply Chain Attackers, Ransomware Groups | Kill Chain #3 | Scenario 3 — Vendor Gateway Breach | **Upgraded → High** | Initially assessed as a vendor governance concern. Threat modeling demonstrated that trusted vendor access can bypass perimeter defenses and directly reach critical systems. |
| **G6** | Weak identity controls (no MFA, excessive privileges, weak privileged account management) | High | Ransomware Groups, Insider Threats, Nation-State APT | Kill Chain #1, Kill Chain #2, Kill Chain #3 | Scenario 1, Scenario 2, Scenario 3 | **Upgraded → Critical** | Identity compromise appears in every major threat path. Attackers use stolen credentials, pass-the-hash, valid accounts, and vendor accounts to gain access. |
| **G7** | Excessive user permissions and shared accounts | Medium | Malicious Insiders, Negligent Insiders | Kill Chain #2 | Scenario 2 | **Upgraded → High** | Insider analysis showed healthcare workflows create significant exposure when users can access more patient data than required. |
| **G8** | Weak access monitoring and audit review | Medium | Malicious Insiders, Ransomware Groups | Kill Chain #1, Kill Chain #2, Kill Chain #3 | Scenario 1, Scenario 2, Scenario 3 | **Upgraded → High** | Lack of monitoring is a common enabler across external, internal, and third-party attacks. |
| **G9** | Poor employee offboarding process | Medium | Malicious Insiders | Kill Chain #2 | Scenario 2 | **Same → Medium** | Important insider weakness but applies primarily to one attack path. |
| **G10** | Excessive administrative privileges | High | Ransomware Groups, Malicious Insiders, Supply Chain Attackers | Kill Chain #1, Kill Chain #2, Kill Chain #3 | Scenario 1, Scenario 2, Scenario 3 | **Upgraded → Critical** | Privilege abuse is required for ransomware deployment, insider misuse, and vendor escalation. |
| **G11** | Weak credential practices | Medium | Insiders, Ransomware Groups, Opportunistic Attackers | Kill Chain #1, Kill Chain #2 | Scenario 1, Scenario 2 | **Upgraded → High** | Credential theft is a recurring mechanism across multiple attacker types. |
| **G12** | Weak data handling controls (USB, DLP, export restrictions) | Medium | Malicious Insiders, Negligent Insiders | Kill Chain #2 | Scenario 2 | **Same → Medium/High** | Becomes more important after insider analysis but remains narrower than identity and monitoring failures. |

---

# Re-Prioritized Gap List

## Critical Priority

| Rank | Gap | Change | Reason |
|---|---|---|---|
| 1 | **G6 — Weak Identity Controls** | Upgraded | Appears in ransomware, insider, and vendor compromise chains. Identity is the common control plane attackers target. |
| 2 | **G2 — Flat Network Architecture** | Upgraded | Converts single-system compromise into enterprise-wide compromise. |
| 3 | **G3 — No SIEM/EDR Monitoring** | Upgraded | Allows every attack type to operate longer without detection. |
| 4 | **G10 — Excessive Administrative Privileges** | Upgraded | Enables full environment takeover after initial access. |
| 5 | **G1 — Unpatched Public-Facing Systems** | Upgraded | Provides the primary external entry point for ransomware and opportunistic attackers. |

---

## High Priority

| Rank | Gap | Change | Reason |
|---|---|---|---|
| 6 | G5 — Vendor Access Exposure | Upgraded | Enables trusted third-party compromise paths. |
| 7 | G4 — Poor Backup Isolation | Same | Critical ransomware impact multiplier. |
| 8 | G8 — Weak Access Monitoring | Upgraded | Required for detection of insider and external abuse. |
| 9 | G7 — Excessive User Permissions | Upgraded | Enables insider data theft. |
| 10 | G11 — Weak Credential Practices | Upgraded | Supports credential theft attacks. |

---

## Medium Priority

| Rank | Gap | Change | Reason |
|---|---|---|---|
| 11 | G12 — Weak Data Handling Controls | Same | Important but primarily affects insider scenarios. |
| 12 | G9 — Poor Offboarding Process | Same | Serious but limited attack scope. |

---

# The Critical Three

## 1. G6 — Weak Identity Controls

**Why it matters:**

Identity compromise appears across almost every major attack path:

- BlackReef ransomware uses credential theft and pass-the-hash.
- Insiders abuse legitimate accounts.
- Vendors use trusted credentials.

Improving identity security disrupts the largest number of attack chains.

**Priority Controls:**

- MFA for all privileged and remote accounts.
- Privileged Access Management (PAM).
- Eliminate shared accounts.
- Credential rotation.

---

## 2. G2 — Flat Network Architecture

**Why it matters:**

A compromised workstation, vendor account, or medical device becomes a pathway to:

- Active Directory.
- EHR databases.
- Backups.
- Clinical systems.

Segmentation converts one compromise from an enterprise incident into a contained event.

**Priority Controls:**

- Clinical network segmentation.
- Vendor access VLANs.
- Firewall rules between critical systems.
- Zero Trust access controls.

---

## 3. G3 — Lack of SIEM/EDR Monitoring

**Why it matters:**

Every analyzed attacker benefits from poor visibility:

- Ransomware operators hide persistence.
- Insiders perform bulk exports unnoticed.
- Vendor compromise appears legitimate.

Without detection, preventive controls become the only defense layer.

**Priority Controls:**

- Deploy EDR.
- Implement SIEM monitoring.
- Centralize authentication logs.
- Monitor privileged activity.

---

# The Surprise

## G5 — Vendor Access Exposure (Originally Medium/High → Upgraded High)

### Original Understanding:

Vendor access was viewed primarily as a governance issue involving contracts and third-party management.

### Threat-Informed Understanding:

The attack scenarios demonstrated that vendor access is effectively an extension of MedDefense's internal network.

A compromised vendor account can:

1. Bypass perimeter defenses.
2. Access trusted maintenance pathways.
3. Reach EHR infrastructure.
4. Avoid suspicion because activity appears legitimate.

The MedTech Solutions scenario showed that supply chain compromise can create a direct path to the organization's most critical assets.

**New Priority Controls:**

- Vendor MFA requirements.
- Time-limited maintenance access.
- Vendor activity logging.
- Network isolation for third parties.
- Annual vendor security assessments.

---

# Final Assessment

The threat-informed analysis changes MedDefense's priorities from simply fixing visible vulnerabilities to disrupting attacker workflows. The most dangerous weaknesses are not isolated technical flaws; they are **identity, trust, and visibility failures** that appear repeatedly across ransomware, insider, and supply-chain attack paths. Closing G6, G2, and G3 would remove the largest number of attack pathways and provide the greatest reduction in enterprise risk.
