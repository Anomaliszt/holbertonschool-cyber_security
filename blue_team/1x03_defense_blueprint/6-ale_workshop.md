# MedDefense Top 5 ALE Workshop

## 1. Risk: Enterprise PHI Breach from EHR Data Exfiltration
**Source:** G-005 flat network + Finding 003 PostgreSQL unrestricted access + malicious insider / ransomware operator from 1x01  
**Asset:** `ehr-srv-01` + `ehr-db-01`  
**Asset Value (AV):** **$9,075,000**  
- Replacement / recovery / legal response: included in breach cost model  
- Regulatory penalties / notification: $225,000 combined baseline  
- Reputation / patient attrition: $600,000  
- Record exposure cost: $8,250,000  

**Exposure Factor (EF):** **95%**  
**Reasoning:** A major EHR breach triggers almost the full cost stack once records are exfiltrated.  
**SLE:** $9,075,000 × 0.95 = **$8,621,250**  
**ARO:** **0.33**  
**Reasoning:** Above-average hospital breach probability due to no SIEM, flat network, and weak access controls.  
**ALE:** **$2,845,013**  

**Proposed Control:** Segmentation + database ACL hardening + Wazuh SIEM  
**Control Annual Cost:** **$40,000**  
**Estimated ALE After Control:** **$1,034,550** (ARO reduced to 0.12 by containment and improved detection)  
**Net Benefit:** $2,845,013 - $1,034,550 - $40,000 = **$1,770,463**

---

## 2. Risk: VPN Compromise Leads to Full Network Access
**Source:** Weak identity controls / unknown FortiGate patch cadence + 1x01 VPN attack path + flat network  
**Asset:** `FW-01` as gateway to the full MedDefense network  
**Asset Value (AV):** **$10,023,000**  
- Aggregate of billing ransomware path, EHR breach path, and AD containment  

**Exposure Factor (EF):** **70%**  
**Reasoning:** On the current network, a VPN foothold can realistically reach most critical assets.  
**SLE:** $10,023,000 × 0.70 = **$7,016,100**  
**ARO:** **0.30**  
**Reasoning:** Healthcare VPN compromise remains a common initial access route, especially where MFA is incomplete.  
**ALE:** **$2,104,830**  

**Proposed Control:** MFA for VPN/admin access + monthly FortiGate patch review  
**Control Annual Cost:** **$12,000**  
**Estimated ALE After Control:** **$631,449** (ARO reduced to 0.09)  
**Net Benefit:** $2,104,830 - $631,449 - $12,000 = **$1,461,381**

---

## 3. Risk: Enterprise Ransomware Disrupts EHR, AD, and Backups
**Source:** Findings 001, 031, 018/019 + G-004 weak backups + BlackReef/LockBit kill chain  
**Asset:** EHR platform, Active Directory, and backup infrastructure  
**Asset Value (AV):** **$2,550,000**  
- Recovery / forensics / rebuild: $400,000  
- Clinical productivity and downtime: $150,000/day × 7 days = $1,050,000  
- Regulatory and legal: $500,000  
- Reputation / patient confidence: $600,000  

**Exposure Factor (EF):** **75%**  
**Reasoning:** A successful ransomware event would not destroy the enterprise permanently, but it would consume most of the modeled loss.  
**SLE:** $2,550,000 × 0.75 = **$1,912,500**  
**ARO:** **0.40**  
**Reasoning:** Threat intelligence shows MedDefense strongly matches the ransomware victim profile and current defenses are weak.  
**ALE:** **$765,000**  

**Proposed Control:** Immutable offsite backups + EDR + segmentation  
**Control Annual Cost:** **$74,000**  
**Estimated ALE After Control:** **$168,300** (ARO 0.12; EF 55%)  
**Net Benefit:** $765,000 - $168,300 - $74,000 = **$522,700**

---

## 4. Risk: Negligent Insider Exports Patient Data
**Source:** 1x01 insider scenarios + shared accounts / removable media weakness + lack of DLP  
**Asset:** Patient data accessible from clinical workstations  
**Asset Value (AV):** **$120,000 per incident**  
- Investigation: $30,000  
- Containment: $25,000  
- Remediation: $40,000  
- Reporting: $25,000  

**Exposure Factor (EF):** **100%**  
**Reasoning:** If the incident occurs, the full incident cost profile is incurred.  
**SLE:** **$120,000**  
**ARO:** **2.5**  
**Reasoning:** Large workforce, no DLP, no USB restriction, and uneven training.  
**ALE:** **$300,000**  

**Proposed Control:** AUP enforcement + USB blocking + targeted awareness training  
**Control Annual Cost:** **$6,000**  
**Estimated ALE After Control:** **$120,000** (ARO reduced to 1.0)  
**Net Benefit:** $300,000 - $120,000 - $6,000 = **$174,000**

---

## 5. Risk: Medical Device Compromise Affects Patient Safety
**Source:** F-024 default credentials + flat network + opportunistic/internal attacker  
**Asset:** BD Alaris infusion pumps and adjacent clinical workflow  
**Asset Value (AV):** **$3,250,000**  
- Safety liability midpoint: $3,000,000  
- FDA / regulatory review: $150,000  
- Operational disruption: $100,000  

**Exposure Factor (EF):** **90%**  
**Reasoning:** A true safety-impacting event would realize most direct loss categories.  
**SLE:** $3,250,000 × 0.90 = **$2,925,000**  
**ARO:** **0.02**  
**Reasoning:** Low-frequency, high-impact scenario; plausible but not common.  
**ALE:** **$58,500**  

**Proposed Control:** Unique device credentials + dedicated medical device isolation  
**Control Annual Cost:** **$28,000**  
**Estimated ALE After Control:** **$11,700** (ARO reduced to 0.004)  
**Net Benefit:** $58,500 - $11,700 - $28,000 = **$18,800**

## Risk Prioritization by ALE
| Rank | Risk | ALE Before | Proposed Control | ALE After |
|---|---|---:|---|---:|
| 1 | EHR PHI breach | $2,845,013 | Segmentation + DB hardening + SIEM | $1,034,550 |
| 2 | VPN compromise / full network access | $2,104,830 | MFA + patch governance | $631,449 |
| 3 | Enterprise ransomware | $765,000 | Immutable backups + EDR + segmentation | $168,300 |
| 4 | Negligent insider data loss | $300,000 | AUP + USB control + training | $120,000 |
| 5 | Medical device compromise | $58,500 | Device isolation + credential reset | $11,700 |

## Bottom Line
The top three risks are all **identity- and architecture-driven**. That is why MedDefense's first-year program must prioritize MFA, segmentation, detection, and recoverability over niche point solutions.
