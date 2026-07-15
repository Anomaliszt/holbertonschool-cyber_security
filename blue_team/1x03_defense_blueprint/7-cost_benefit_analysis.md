# MedDefense Control Cost-Benefit Analysis

## Evaluation Criteria
A control is financially justified when the expected annual ALE reduction exceeds the annual cost of the control.

---

## Control 1: Network Segmentation (Server / Workstation / Medical / Guest / Management VLANs)
**CIS Control Reference:** Control 12  
**Annual Cost:** **$18,000** ($14K implementation labor + $4K testing/change windows)  
**Risks Addressed:** EHR breach, VPN compromise, ransomware, vendor compromise, medical device pivoting  
**ALE Reduction:** **$1,050,000**  
**Net Value:** $1,050,000 - $18,000 = **$1,032,000**  
**Verdict:** Justified  
**Recommendation:** **Implement**; this is MedDefense's highest-value architecture control because it reduces the blast radius of nearly every major attack path.

## Control 2: MFA on VPN and Administrative Accounts
**CIS Control Reference:** Control 6  
**Annual Cost:** **$8,000** ($5K implementation/admin labor + $3K enrollment/support; O365 E3 licenses already owned)  
**Risks Addressed:** VPN compromise, AD takeover, vendor account misuse, phishing-based escalation  
**ALE Reduction:** **$620,000**  
**Net Value:** $620,000 - $8,000 = **$612,000**  
**Verdict:** Justified  
**Recommendation:** **Implement**; it is the cheapest high-impact control in the program.

## Control 3: Enterprise SIEM (Wazuh)
**CIS Control Reference:** Controls 8 and 13  
**Annual Cost:** **$22,000** ($18K engineering/tuning labor + $4K storage/retention)  
**Risks Addressed:** EHR breach dwell time, ransomware detection, insider monitoring, vendor anomaly detection  
**ALE Reduction:** **$480,000**  
**Net Value:** $480,000 - $22,000 = **$458,000**  
**Verdict:** Justified  
**Recommendation:** **Implement**; without telemetry, MedDefense cannot prove its defensive controls are working.

## Control 4: Offsite Immutable Backup Replication
**CIS Control Reference:** Control 11  
**Annual Cost:** **$14,000** ($7K cloud storage + $2K recovery testing + $5K admin labor)  
**Risks Addressed:** Enterprise ransomware, backup destruction, extended outage  
**ALE Reduction:** **$420,000**  
**Net Value:** $420,000 - $14,000 = **$406,000**  
**Verdict:** Justified  
**Recommendation:** **Implement**; it materially reduces patient-care downtime and makes ransom payment less likely.

## Control 5: EDR Upgrade (Sophos Intercept X including servers)
**CIS Control Reference:** Control 10  
**Annual Cost:** **$42,000** ($34K licensing + $8K deployment/tuning)  
**Risks Addressed:** Ransomware execution, server malware, credential theft tooling, lateral movement  
**ALE Reduction:** **$510,000**  
**Net Value:** $510,000 - $42,000 = **$468,000**  
**Verdict:** Justified  
**Recommendation:** **Implement**; server coverage closes one of the most serious gaps from 1x00.

## Control 6: Dedicated Firewall for Westside Clinic
**CIS Control Reference:** Control 12  
**Annual Cost:** **$9,000** ($6K appliance/support + $3K implementation labor)  
**Risks Addressed:** Site-to-site pivoting, unmanaged branch exposure, shadow IT at Westside  
**ALE Reduction:** **$110,000**  
**Net Value:** $110,000 - $9,000 = **$101,000**  
**Verdict:** Justified  
**Recommendation:** **Implement**; small spend for a clear reduction in branch-to-core compromise risk.

## Control 7: Outsourced 24/7 SOC Staffing
**CIS Control Reference:** Control 13  
**Annual Cost:** **$95,000** ($84K MDR retainer + $11K onboarding)  
**Risks Addressed:** After-hours detection and response  
**ALE Reduction:** **$70,000**  
**Net Value:** $70,000 - $95,000 = **-$25,000**  
**Verdict:** Not Justified  
**Recommendation:** **Defer/Reject for year 1**; MedDefense should first build telemetry through SIEM and EDR before buying full-time outsourced monitoring.

## Control 8: Full Medical Device Network Isolation with Monitoring
**CIS Control Reference:** Controls 12 and 13  
**Annual Cost:** **$28,000** ($20K segmentation/config labor + $8K passive monitoring capability)  
**Risks Addressed:** BD Alaris compromise, MRI exposure, device-to-server pivoting  
**ALE Reduction:** **$210,000**  
**Net Value:** $210,000 - $28,000 = **$182,000**  
**Verdict:** Justified  
**Recommendation:** **Implement if budget permits; otherwise defer one year** because core segmentation plus device credential reset still provide partial protection.

## Cost-Benefit Summary Table (Ranked by Net Value)
| Rank | Control | Cost | ALE Reduction | Net Value | Budget Fit |
|---|---|---:|---:|---:|---|
| 1 | Network segmentation | $18,000 | $1,050,000 | $1,032,000 | Yes |
| 2 | MFA for VPN/admin | $8,000 | $620,000 | $612,000 | Yes |
| 3 | EDR upgrade | $42,000 | $510,000 | $468,000 | Yes |
| 4 | Wazuh SIEM | $22,000 | $480,000 | $458,000 | Yes |
| 5 | Immutable offsite backups | $14,000 | $420,000 | $406,000 | Yes |
| 6 | Medical device isolation | $28,000 | $210,000 | $182,000 | Yes |
| 7 | Westside firewall | $9,000 | $110,000 | $101,000 | Yes |
| 8 | Outsourced 24/7 SOC | $95,000 | $70,000 | -$25,000 | Yes individually, not justified strategically |

## Controls That Fit Within the $120K Annual Budget
MedDefense can fund a strong year-1 package within budget, but it **cannot fund every justified control simultaneously**. The most efficient year-1 set combines the highest-value baseline controls first: segmentation, MFA, SIEM, immutable backups, EDR, and Westside firewall replacement.
