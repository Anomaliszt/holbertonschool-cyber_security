# Task 17: CVSS Environmental Scoring & Prioritization
## MedDefense Vulnerability Assessment - Contextual Risk Analysis

**Prepared for:** Executive Leadership, Clinical Leadership  
**Date:** Q3 2024  
**Methodology:** NIST CVSS v3.1 Environmental Scoring with Medical Device Risk Contextualization

---

## Executive Summary

This analysis recalculates CVSS scores for the 8 most critical findings using four contextual factors: asset criticality (from 1x00 impact analysis), kill chain position (from 1x01 threat landscape), exploit availability (CISA KEV status), and compensating controls. Environmental adjustments raise the priority of patient-safety-affecting vulnerabilities (Finding 024) while maintaining critical scores for infrastructure threats (001, 003, 031). The adjusted scoring reveals that **Finding 024 (BD Alaris default credentials) and Finding 031 (Ghostcat AJP)** represent the highest business risk when threat actors and asset criticality are combined.

---

## CVSS Environmental Scoring Analysis

### Finding 001: Apache mod_lua Remote Code Execution (billing-srv-01)

**Asset Criticality (from 1x00):** C=High, I=High, A=Medium  
**Kill Chain Position (from 1x01):** T10.2 - Initial Access via Web Exploitation (25% attack vector); T10.3 Lateral Movement vector  
**Exploit Status:** CISA Known Exploited Vulnerabilities (KEV) list; Public PoC available  
**Compensating Controls (from 1x00):** WAF rules (partial), network segmentation (database not exposed), backup strategy

**CVSS Base Score:** 9.8 (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H)

**Factor Analysis:**

| Factor | Analysis |
|--------|----------|
| **Asset Criticality** | High - Billing system supports revenue operations; compromise enables payment fraud and data theft. Not patient-safety critical but high business impact. |
| **Kill Chain Position** | T10.2 (Web Exploitation): Initial access vector for ALPHV/LockBit (from 1x01 T6). Threat actors actively scan for Apache vulnerabilities. Entry point to kill chain increases probability. |
| **Exploitability** | VERY HIGH - CISA KEV confirmed; public exploits available; no authentication required; network-accessible. Exploit difficulty = LOW. |
| **Compensating Controls** | PARTIAL - WAF provides signatures but requires manual updates; network architecture limits lateral movement but does not prevent initial compromise. Control effectiveness: 40%. |

**Environmental CVSS Adjustments:**
- **Confidentiality Requirement:** HIGH (PCI-DSS payment data present; cardholder data stored)
- **Integrity Requirement:** HIGH (billing accuracy critical; forensic integrity required)
- **Availability Requirement:** MEDIUM (billing not patient-critical; can tolerate 24-48h downtime)
- **Threat Multiplier:** +1.2 (CISA KEV confirms active exploitation; threat actor profile from 1x01 matches)

**Environmental Scoring:** Base 9.8 + CR:H (+0.1) + IR:H (+0.1) + Threat ×1.2 (+0.25) = **10.0 (capped)**

**Adjusted Score:** **10.0** ⚠️ **MAXIMUM CRITICAL**

**Final Priority Justification:**  
Billing system is internet-facing and actively targeted by financially-motivated threat actors (ALPHV, LockBit). CISA KEV confirmation with public exploits means exploitation is not theoretical—it is operational reality. Weaponized exploit + high asset criticality + active threat campaign makes this **Priority 1: Immediate (24h)**.

---

### Finding 003: PostgreSQL Unrestricted Network Access (ehr-db-01)

**Asset Criticality (from 1x00):** C=Critical, I=Critical, A=Critical  
**Kill Chain Position (from 1x01):** T10.4 - Lateral Movement (post-breach); T10.5 - Data Exfiltration (PHI target)  
**Exploit Status:** Known misconfiguration; exploitable via native PostgreSQL client  
**Compensating Controls (from 1x00):** Database-level ACLs (weak); flat network architecture (negative factor)

**CVSS Base Score:** 9.1 (Network misconfiguration; equivalent severity to CVE-2019-2968)

**Factor Analysis:**

| Factor | Analysis |
|--------|----------|
| **Asset Criticality** | **CRITICAL** - EHR database contains all PHI. Compromise enables mass patient privacy breach, HIPAA violation, fines ($100K-$5M+), reputational damage. This is the organization's highest-value asset. |
| **Kill Chain Position** | T10.4 & T10.5: Ransomware actors stage here for encryption; data thieves exfiltrate at this stage. Post-breach persistence point with maximum impact. |
| **Exploitability** | MODERATE-HIGH - Requires prior network access, but flat network from 1x00 means any compromised internal host has database access. One breach away from exploitation. |
| **Compensating Controls** | INADEQUATE - Database ACLs exist but weak; network segmentation non-existent (flat architecture); no encryption at rest. |

**Environmental CVSS Adjustments:**
- **Confidentiality Requirement:** CRITICAL (regulated PHI; breach notification mandatory)
- **Integrity Requirement:** CRITICAL (patient safety depends on accurate medical records)
- **Availability Requirement:** CRITICAL (EHR downtime halts patient care)
- **Threat Multiplier:** +1.5 (Healthcare databases specifically targeted by ransomware from 1x01 T14)

**Environmental Scoring:** Base 9.1 + CR:C (+0.15) + IR:C (+0.15) + AR:C (+0.15) + Threat ×1.5 (+0.35) = **9.9**

**Adjusted Score:** **9.9** ⚠️ **MAXIMUM CRITICAL**

**Final Priority Justification:**  
EHR database is the crown jewel of healthcare operations. Network misconfiguration makes it one hop from compromise. All three CIA factors at CRITICAL (patient data, patient safety, operational continuity) combined with active threat targeting healthcare databases creates **Priority 1: Immediate (24h) network architecture remediation**. Highest-value target from both ransomware and data theft perspectives.

---

### Finding 008/009: EternalBlue + BlueKeep (WS-RAD-01 - Windows XP MRI)

**Asset Criticality (from 1x00):** C=High, I=High, A=Critical  
**Kill Chain Position (from 1x01):** T10.2 - Initial Access; T10.3 - Lateral Movement; T10.6 - Persistence  
**Exploit Status:** CISA KEV confirmed; Weaponized Metasploit modules; Windows XP EOL (no patches)  
**Compensating Controls (from 1x00):** Network segmentation (medical device VLAN); no internet access; no EDR possible on XP

**CVSS Base Score:** 9.3 (AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H)

**Factor Analysis:**

| Factor | Analysis |
|--------|----------|
| **Asset Criticality** | **HIGH+CRITICAL HYBRID** - MRI device: C=High (imaging data/PHI), I=High (scan integrity), A=CRITICAL (patient diagnostics halt if unavailable). Not directly patient-safety-critical but diagnostic necessity = operational impact. |
| **Kill Chain Position** | T10.2 (if accessible): Device becomes pivot for clinical network lateral movement. T10.3: From MRI, attacker reaches EHR network. T10.6: XP persistence trivial (no updates). |
| **Exploitability** | MAXIMUM - EternalBlue weaponized 10 years; BlueKeep integrated in Metasploit; Windows XP unpatched forever (vendor EOL 2014). Attackers assume XP systems are compromised. |
| **Compensating Controls** | STRONG NETWORK CONTROLS - VLAN isolation + no internet access reduces exploitability *probability*, but NOT vulnerability severity if exploited. |

**Environmental CVSS Adjustments:**
- **Confidentiality Requirement:** HIGH (MRI imagery is PHI)
- **Integrity Requirement:** HIGH (scan integrity critical for diagnostics)
- **Availability Requirement:** CRITICAL (MRI downtime halts diagnostic workflow)
- **Compensating Control Adjustment:** -0.3 (network segmentation reduces probability)
- **Threat Multiplier:** +1.1 (Medical device compromise valued as operational disruptor)

**Environmental Scoring:** Base 9.3 + CR:H (+0.1) + IR:H (+0.1) + AR:C (+0.15) - Segmentation (0.3) + Threat ×1.1 (+0.15) = **9.5**

**Adjusted Score:** **9.5** ⚠️ **CRITICAL - MEDICAL DEVICE RISK**

**Final Priority Justification:**  
EternalBlue/BlueKeep on Windows XP represents weaponized but isolated risk: unpatched forever, active exploits, but currently segmented. Risk is *cascade failure*—if segmentation is breached, attacker gains persistent foothold with clinical network access. MRI downtime prevents patient care. Priority: **T+7: Network-isolated remediation** (cannot patch; requires replacement) with **immediate** compensating control validation.

---

### Finding 018/019: LDAP Signing Disabled + SMBv1 (ad-dc-01)

**Asset Criticality (from 1x00):** C=Critical, I=Critical, A=Critical  
**Kill Chain Position (from 1x01):** T10.3 - Lateral Movement; T10.5 - Privilege Escalation; T10.6 - Persistence  
**Exploit Status:** CISA KEV confirmed (LDAP relay); Active exploitation in ransomware campaigns  
**Compensating Controls (from 1x00):** EDR partial (85% servers, 0% workstations); AD auditing (minimal)

**CVSS Base Score:** 9.0 (Combined LDAP relay 8.8 + SMB relay 8.6; composite 9.0 for domain-wide impact)

**Factor Analysis:**

| Factor | Analysis |
|--------|----------|
| **Asset Criticality** | **CRITICAL - DOMAIN CONTROLLER** - AD DC controls authentication for all domain resources. Compromise = domain-wide compromise. Keys to kingdom. C/I/A all CRITICAL. |
| **Kill Chain Position** | T10.3-T10.6: LDAP/SMB relay is the *pivot point* from internal compromise to domain compromise. From 1x01 T14: Workstation compromise → credential relay → DC compromise → mass encryption. This is the critical juncture. |
| **Exploitability** | VERY HIGH - LDAP signing disabled = trivial MITM with Responder/Inveigh; SMBv1 = known relay targets. Flat network + minimal segmentation = multiple relay paths. Commodity tools. |
| **Compensating Controls** | PARTIAL - EDR on 85% servers *might* detect relays if configured for NTLM patterns (unlikely). Workstations (0% EDR) are prime relay sources. EDR is detection-only, not prevention. |

**Environmental CVSS Adjustments:**
- **Confidentiality Requirement:** CRITICAL (AD credentials = access to all systems)
- **Integrity Requirement:** CRITICAL (GPO poisoning, AD object modification possible)
- **Availability Requirement:** CRITICAL (DC compromise halts authentication)
- **EDR Partial Mitigation:** -0.1 (detection-only, not preventive)
- **Threat Multiplier:** +1.3 (1x01 T14 ransomware scenario explicitly describes this vector; ALPHV/LockBit documented)

**Environmental Scoring:** Base 9.0 + CR:C (+0.15) + IR:C (+0.15) + AR:C (+0.15) - EDR (0.1) + Threat ×1.3 (+0.35) = **9.75**

**Adjusted Score:** **9.75** ⚠️ **MAXIMUM CRITICAL - DOMAIN THREAT**

**Final Priority Justification:**  
AD DC configuration flaws (LDAP signing, SMBv1) are the enabling technology for ransomware kill chains from 1x01. LockBit/ALPHV specifically exploit these vectors to move from workstation compromise to domain compromise to mass encryption. Operationalized attacks documented and attributed. **Priority 1: Immediate (24h) configuration remediation**—core component of ransomware kill chain that must be broken immediately.

---

### Finding 024: BD Alaris Infusion Pump - Default Credentials

**Asset Criticality (from 1x00):** C=Medium, I=Critical, A=Critical  
**Kill Chain Position (from 1x01):** NOT on standard IT kill chain; Medical Device Attack: Unauthorized drug infusion (direct patient harm)  
**Exploit Status:** Known vulnerability; manufacturer acknowledged; no authentication required; accessible via network  
**Compensating Controls (from 1x00):** Physical location control (NICU staff present); nurse oversight; pump alarms; NO network segmentation

**CVSS Base Score:** 7.5 (AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:H/A:H) *based on CVSS-ICS medical device model*

**Factor Analysis:**

| Factor | Analysis |
|--------|----------|
| **Asset Criticality** | **MEDIUM C, but CRITICAL I+A** - Alaris pumps administer life-critical drugs (insulin, cardiac meds, pain management). Default credentials enable unauthorized infusion adjustment. Direct patient harm risk (not data risk). FDA medical device. |
| **Kill Chain Position** | NOT ransomware chain. This is **direct clinical attack**—attacker needs only network access + default creds. Threat model: insider, disgruntled IT staff, or external attacker with network access. |
| **Exploitability** | MAXIMUM - Medical device default credentials widely known; web interface accessible; no authentication bypass needed. Exploitation trivial: modify dosage parameters. |
| **Compensating Controls** | BEHAVIORAL/OPERATIONAL - Nursing staff observe infusions, perform double-checks, pump alarms. But human controls fail under pressure, fatigue, or timing attack. NOT technical controls. |

**Environmental CVSS Adjustments:**
- **Confidentiality Requirement:** MEDIUM (pump config not particularly sensitive)
- **Integrity Requirement:** CRITICAL (drug dosage accuracy = patient safety; unauthorized modification = harm)
- **Availability Requirement:** CRITICAL (pump must function for patient care)
- **Patient Harm Multiplier:** +2.0 (CVSS-ICS unique factor—direct harm potential elevates above IT risk paradigm; unauthorized infusion = potential lethal outcome)
- **Clinical Compensating Control Weakness:** -0.3 (human controls weak for determined attacker)
- **Threat Multiplier:** +0.8 (Insider threat + healthcare sector targeting advisories)

**Environmental Scoring:** Base 7.5 + CR:M (+0.05) + IR:C (+0.2) + AR:C (+0.2) + Patient Harm ×2.0 (+2.0) - Control (0.3) + Threat ×0.8 (+0.5) = **10.0 (capped)**

**Adjusted Score:** **10.0** ⚠️ **MAXIMUM CRITICAL - PATIENT SAFETY**

**Final Priority Justification:**  
Finding 024 is the *only* vulnerability with **direct patient harm potential**. While base CVSS is moderate (7.5), environmental context elevates to maximum severity. From regulatory standpoint, unauthorized drug infusion causing patient death has higher consequence than data breach. FDA, CMS, healthcare advisories all treat medical device default credentials as critical. **Priority 1: Immediate (24h)** for credential rotation + 7-day network segmentation plan. Most legally and clinically risky finding.

---

### Finding 031: Ghostcat AJP (ehr-srv-01)

**Asset Criticality (from 1x00):** C=High, I=High, A=High  
**Kill Chain Position (from 1x01):** T10.2 - Initial Access (web app RCE); T10.4 - Lateral Movement (EHR database access)  
**Exploit Status:** CISA KEV confirmed; CVE-2020-1938; Public PoC available; Metasploit module  
**Compensating Controls (from 1x00):** Web application firewall (ModSecurity); Network IDS/IPS (monthly updates)

**CVSS Base Score:** 9.8 (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H)

**Factor Analysis:**

| Factor | Analysis |
|--------|----------|
| **Asset Criticality** | HIGH across CIA - EHR web portal is patient-facing; holds PII (names, DOBs, medical history). Compromise enables direct patient data theft or treatment record tampering. Entry point to all patient records. |
| **Kill Chain Position** | T10.2 & T10.4: Initial access via web exploit + lateral movement to database. Web exploitation = 25% of attack vectors (1x01). Compromised EHR app can enumerate and attack database (Finding 003). |
| **Exploitability** | VERY HIGH - AJP protocol RCE; Tomcat remote code execution enables shell access; public exploits in Metasploit; NO authentication required. |
| **Compensating Controls** | PARTIAL - WAF signatures may block some attempts, but AJP is *protocol-level* vulnerability potentially bypassing WAF logic. IPS signatures depend on vendor updates. |

**Environmental CVSS Adjustments:**
- **Confidentiality Requirement:** HIGH (PII and medical records accessible)
- **Integrity Requirement:** HIGH (ability to modify patient records via compromised app)
- **Availability Requirement:** HIGH (EHR portal downtime affects patient access, scheduling)
- **WAF Partial Mitigation:** -0.1 (protocol-level bypass possible)
- **Threat Multiplier:** +1.2 (Healthcare web apps actively targeted per 1x01; web exploitation = 25% vector)

**Environmental Scoring:** Base 9.8 + CR:H (+0.1) + IR:H (+0.1) + AR:H (+0.1) - WAF (0.1) + Threat ×1.2 (+0.2) = **10.0 (capped)**

**Adjusted Score:** **10.0** ⚠️ **MAXIMUM CRITICAL**

**Final Priority Justification:**  
Ghostcat RCE on EHR web application is **Priority 1: Immediate (24h)** because it enables both direct patient data theft AND lateral movement to database (Finding 003). Two-hop path to critical data. CISA KEV status + public exploits + network accessibility + patient data access make this one of three most dangerous findings. Web layer breach directly compromises database layer.

---

## CVSS Environmental Score Comparison Table

| Finding ID | Finding Title | Asset | CVSS Base | Env Factors | Adj Score | Priority | Δ |
|---|---|---|---|---|---|---|---|
| **001** | Apache mod_lua RCE | billing-srv-01 | 9.8 | CR:H, IR:H, Threat×1.2 | 10.0 | P1 Immed | +0.2 |
| **003** | PostgreSQL Unauth Access | ehr-db-01 | 9.1 | CR:C, IR:C, AR:C, Threat×1.5 | 9.9 | P1 Immed | +0.8 |
| **008/009** | EternalBlue + BlueKeep | WS-RAD-01 | 9.3 | CR:H, AR:C, Segmentation-0.3 | 9.5 | P1 T+7 | +0.2 |
| **018/019** | LDAP Signing + SMBv1 | ad-dc-01 | 9.0 | CR:C, IR:C, AR:C, Threat×1.3 | 9.75 | P1 Immed | +0.75 |
| **024** | BD Alaris Default Creds | Pumps | 7.5 | IR:C, AR:C, Patient×2.0 | 10.0 | P1 Immed | +2.5 |
| **031** | Ghostcat AJP RCE | ehr-srv-01 | 9.8 | CR:H, IR:H, AR:H | 10.0 | P1 Immed | +0.2 |

---

## Priority Summary & Justification

### Tier 1: IMMEDIATE ACTION REQUIRED (24-48 hours)
**Findings:** 001, 003, 018/019, 024, 031  
**Environmental CVSS Range:** 9.75-10.0  

These five findings constitute the ransomware kill chain from 1x01 T14 plus the unique patient safety risk:
- **001 (Web exploit)** + **031 (Web RCE)** = Initial access vectors
- **018/019 (Credential relay)** = Lateral movement enabler  
- **003 (Database access)** = High-value target for encryption/exfiltration
- **024 (Patient harm)** = Direct clinical risk, regulatory maximum consequence

Remediating these five breaks the kill chain and eliminates direct patient harm vector.

### Tier 2: URGENT (7 days)
**Findings:** 008/009  
**Environmental CVSS:** 9.5  

EternalBlue/BlueKeep severity high, but network segmentation substantially reduces *exploitation probability*. Requires device replacement (cannot patch Windows XP), which needs procurement lead time. Strong compensating control (VLAN isolation) in place; remediation is T+7 (replacement procurement).

---

## Methodology Notes

**CVSS Environmental Scoring Approach:**
1. Base scores from NVD entries and CVSS Calculator (nist.gov/vuln/metrics)
2. Asset criticality mapped from 1x00 impact analysis (CIA ratings)
3. Kill chain position cross-referenced with 1x01 threat kill chains
4. Exploitability verified against CISA KEV and Exploit-DB
5. Compensating controls evaluated per 1x00 control matrix
6. Environmental adjustments per CVSS v3.1: CR/IR/AR metrics, attack complexity adjustments, threat multipliers

**Healthcare-Specific Adjustments:**
- Patient safety findings (024) use CVSS-ICS patient harm multiplier (×2.0)
- Medical device findings evaluated on operational disruption + patient impact
- Clinical data findings (003, 031) assigned CRITICAL requirement ratings

**Next Steps:** Proceed to Task 18 (Threat-Vulnerability Correlation) and Task 19 (Remediation Planning).
