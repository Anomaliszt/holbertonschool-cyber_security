# MedDefense Health Systems Security Strategy Document

## 1. Executive Summary
MedDefense's current cyber posture is **improving in visibility but still structurally high-risk**: the hospital has identified its key assets, threat actors, and vulnerabilities, yet core weaknesses remain in segmentation, identity, detection, and recovery. The most serious business problem is that a single compromise can still become a multi-system patient-care incident.

This strategy adopts **NIST CSF 2.0** as the governing framework and **CIS Controls v8** as the implementation baseline. MedDefense is requesting approval for a **year-1 control package of $113,000** within the existing $120,000 security budget, preserving a $7,000 contingency. That package is expected to reduce approximately **$3.19M in annualized loss exposure** across MedDefense's highest-priority risks.

**Top 3 priority actions:**
1. Segment the flat network into enforceable security zones.
2. Enforce MFA for VPN and administrative access.
3. Build resilient detection and recovery through SIEM, EDR, and immutable offsite backups.

## 2. Governance Framework
### Framework selection rationale
- **Strategic backbone:** NIST CSF 2.0  
- **Execution baseline:** CIS Controls v8 IG1 + selected IG2  
- **Future audit model:** ISO 27001-aligned governance in year 2

### NIST CSF Current vs Target summary
| Function | Current | 6-Month Target |
|---|---|---|
| Govern | Partial | Managed |
| Identify | Partial | Managed |
| Protect | Partial | Managed |
| Detect | Not Implemented | Managed |
| Respond | Partial | Managed |
| Recover | Partial | Managed |

### CIS Controls maturity summary
- Implemented: 0  
- Partial: 12  
- Not Implemented: 6  
Top priority control domains are Access Control, Network Infrastructure, Audit Logging, Malware Defense, and Data Recovery.

### Governance structure and roles
James Chen owns the security program, Sarah Park owns most technical implementation, department heads own data access and workforce compliance in their areas, and the CEO retains final authority for material risk acceptance, policy approval, and budget approval. Because the CISO role is vacant, MedDefense should use a **vCISO** in year 1 to provide executive oversight without displacing core control spend.

## 3. Quantitative Risk Analysis
### Top 5 risks by ALE
| Rank | Risk | ALE |
|---|---|---:|
| 1 | EHR PHI breach | $2,845,013 |
| 2 | VPN compromise / full network access | $2,104,830 |
| 3 | Enterprise ransomware | $765,000 |
| 4 | Negligent insider data loss | $300,000 |
| 5 | Medical device compromise | $58,500 |

### Risk Register summary
The top 10 risks span ransomware, PHI breach, VPN/identity compromise, vendor access, negligent insider behavior, medical device risk, backup failure, legacy MRI exposure, and after-hours monitoring gaps. Eight are treated through mitigation; two are formally accepted in year 1 with compensating controls and review triggers.

### Risk appetite statement
MedDefense has low appetite for any cyber event that could endanger patients, materially disrupt EHR availability, or trigger large-scale PHI breach. Risks above an inherent score of 12 require documented executive acceptance, and patient-safety risks require clinical owner review.

## 4. Control Strategy
### Cost-benefit results
The highest-value year-1 controls are:
- Network segmentation (net value ~$1.032M)
- MFA for VPN/admin access (net value ~$612K)
- EDR upgrade (net value ~$468K)
- Wazuh SIEM (net value ~$458K)
- Immutable offsite backups (net value ~$406K)

### Year-1 budget allocation
| Funded Control | Cost |
|---|---:|
| Network segmentation | $18,000 |
| MFA for VPN/admin | $8,000 |
| Wazuh SIEM | $22,000 |
| Immutable offsite backups | $14,000 |
| EDR upgrade | $42,000 |
| Westside firewall | $9,000 |
| **Total** | **$113,000** |

Deferred: medical device isolation ($28K).  
Rejected for year 1: outsourced 24/7 SOC ($95K).

### Control selection and framework mapping
Every funded control maps directly to both NIST CSF and CIS Controls: segmentation to PR.IR / CIS 12, MFA to PR.AA / CIS 6, SIEM to DE.CM / CIS 8 and 13, backups to RC.RP / CIS 11, and EDR to PR.PS / CIS 10.

### Quick wins (first 2 weeks)
- Remove default medical device credentials
- Enable LDAP signing and disable SMBv1
- Enforce MFA on VPN/admin users
- Block unauthorized USB storage
- Restrict PostgreSQL access to approved hosts only

## 5. Architecture Recommendations
### Segmentation design
The target architecture creates distinct DMZ, Server, Clinical Workstation, Medical Device, Management, Guest, and Westside zones. That prevents a compromised workstation or vendor path from connecting directly to crown-jewel systems and reduces the blast radius of phishing, ransomware, and insider activity.

### Kill chain disruption
Segmentation plus MFA, EDR, and backups materially disrupt the highest-risk ransomware chain at the lateral movement, privilege escalation, and impact stages. Overall, the design is expected to disrupt roughly **80% of MedDefense's top five kill chains**.

## 6. Policy Foundation
### AUP summary
The AUP defines enforceable rules for acceptable system use, personal devices, removable media, passwords/MFA, data handling, monitoring, and sanctions. It is intentionally short enough for a hospital workforce to follow and directly addresses shadow IT, USB use, credential sharing, and unnecessary access to PHI.

### Policy roadmap
- **Month 1:** Approve AUP and privileged access standard  
- **Month 2:** Incident Response Plan  
- **Month 3:** Backup and DR Policy  
- **Month 4:** Vendor Access Standard  
- **Month 5:** Data Classification and Retention Refresh  
- **Month 6:** Risk Acceptance Standard and annual review cadence

## 7. Residual Risk Assessment
### Red team findings
After year-1 controls, the most viable remaining attacker path is controlled phishing/session abuse combined with slow data theft during off-hours. Residual risk remains **High**, not because the strategy fails, but because MedDefense will still lack full 24/7 monitoring, PAM, DLP, and complete medical-device isolation.

### Accepted risks
- Windows XP MRI workstation through lease end, with segmentation and monitoring  
- After-hours monitoring gap until telemetry maturity justifies MDR/SOC  
- Residual vendor support risk after jump-host and MFA restrictions

### Year-2 priorities
1. 24/7 managed detection and response  
2. Medical device monitoring/isolation expansion  
3. PAM and privileged session recording  
4. DLP / user behavior analytics  
5. ISO 27001-style governance maturation

## 8. Implementation Roadmap
### Phase 1 (Month 1-2): Quick wins + procurement
- Remove default credentials, enforce MFA, disable SMBv1, restrict database access
- Procure EDR upgrade, Westside firewall, and backup replication storage
- Publish AUP and launch governance cadence

**Success metrics:** 100% MFA on admin/VPN accounts; 0 default BD Alaris credentials; Findings 018/019 closed; backup scope documented.

### Phase 2 (Month 3-4): Core controls deployment
- Implement network segmentation and Westside boundary replacement
- Deploy Wazuh and onboard critical logs
- Roll out EDR to all servers and high-priority endpoints
- Enable offsite immutable replication

**Success metrics:** All critical servers in segmented zones; SIEM coverage for AD, VPN, EHR, billing, and backup; 95% server EDR coverage; immutable copy verified.

### Phase 3 (Month 5-6): Validation + optimization
- Run restore exercise and IR tabletop
- Tune SIEM/EDR alerts and exception handling
- Review residual risks and prepare year-2 budget package

**Success metrics:** Successful restore within target window; tabletop completed; KRIs trending down; Board receives first maturity update.

## 9. Next Steps
This strategy sets the conditions for **Project 1x04 (Cryptographic Foundation)**. Once MedDefense has governance, segmentation, logging, and recovery discipline in place, the next logical step is to strengthen encryption at rest and in transit, key management, certificate lifecycle management, and secrets handling. The path forward is now clear: MedDefense has moved from scattered findings to a prioritized, fundable, and measurable security program.
