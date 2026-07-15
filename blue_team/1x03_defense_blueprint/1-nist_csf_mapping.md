# MedDefense NIST CSF 2.0 Current Profile

## Maturity Scale
- **Not Implemented:** No meaningful capability exists
- **Partial:** Some activity exists, but it is informal or incomplete
- **Managed:** Documented, repeatable, and covers most scope
- **Optimized:** Measured, tested, and continuously improved

## Govern (GV)
**Current Level:** Partial  
**Evidence:** MedDefense has named security stakeholders (James Chen and Sarah Park), but 1x00 identified no formal security strategy, no incident response/business continuity/disaster recovery plans (G-003), and inconsistent ownership of security decisions. Board reporting exists only through ad hoc briefings rather than a standing governance process.  
**Key Gaps:** No documented risk appetite, no policy architecture, no formal risk acceptance process, and no executive security steering cadence.  
**Target Level (6 months):** Managed. MedDefense can realistically reach Managed by approving a security strategy, AUP, risk register, RACI, and monthly governance review process without adding a large headcount burden.

## Identify (ID)
**Current Level:** Partial  
**Evidence:** The 1x00 project produced a usable asset registry and criticality assessment, but those artifacts had to be built because MedDefense did not maintain them reliably beforehand; the AD inventory was 8 months stale and software/asset counts conflicted across tools. 1x01 and 1x02 now provide threat and vulnerability assessments, but these are not yet institutionalized as recurring processes.  
**Key Gaps:** Asset/software inventory discipline, data flow mapping, and recurring risk assessment are inconsistent.  
**Target Level (6 months):** Managed. With quarterly asset reconciliation, annual risk review, and a maintained risk register, MedDefense can close the gap between one-time assessment and repeatable process.

## Protect (PR)
**Current Level:** Partial  
**Evidence:** MedDefense has a perimeter firewall, some workstation AV, AD password controls, and pockets of hardening, but 1x00 and 1x02 showed major weaknesses: no MFA, no internal segmentation, no server EDR, default credentials on BD Alaris pumps (Finding 024), unrestricted PostgreSQL access (Finding 003), LDAP signing/SMBv1 weakness (Findings 018/019), and exposed web application RCE paths (Findings 001 and 031).  
**Key Gaps:** Identity protection, network segmentation, server security, privileged access control, and medical device hardening.  
**Target Level (6 months):** Managed. The funded year-1 control set can raise protection substantially, but not to Optimized, because legacy devices and least-privilege cleanup will still be in progress.

## Detect (DE)
**Current Level:** Not Implemented  
**Evidence:** 1x00 Gap G-001 documented no SIEM, no centralized alerting, and local logs overwritten within about 30 days. The unnoticed cryptominer on billing-srv-01 and the lack of server telemetry show that MedDefense cannot reliably detect hostile activity.  
**Key Gaps:** Central log collection, alert triage, endpoint detection, and after-hours monitoring.  
**Target Level (6 months):** Managed. Wazuh plus EDR and defined alert handling can create a repeatable core detection capability, even if 24/7 monitoring remains a year-2 goal.

## Respond (RS)
**Current Level:** Partial  
**Evidence:** MedDefense has experienced incidents, including ransomware, but 1x00 confirmed the response was improvised and no formal IR plan existed. Roles are understood informally, yet triage, escalation, communications, and legal/regulatory notification procedures are not documented or tested.  
**Key Gaps:** Formal IR plan, contact trees, evidence handling, communications playbooks, and tabletop testing.  
**Target Level (6 months):** Managed. A documented IR plan and at least one tabletop exercise are achievable within existing staffing.

## Recover (RC)
**Current Level:** Partial  
**Evidence:** Backups exist, but 1x00 Gap G-004 showed PACS, Westside, O365, and some device settings were excluded; backups are not isolated, and full DR restoration has never been tested. Recovery therefore exists, but it is incomplete and not trustworthy for a major ransomware event.  
**Key Gaps:** Incomplete backup coverage, no immutability/offsite isolation, no tested RTO/RPO, and no formal recovery communications plan.  
**Target Level (6 months):** Managed. Immutable offsite replication, a recovery runbook, and one full restore exercise would materially improve recoverability.

## 6-Month Target Profile Summary
| Function | Current | 6-Month Target | Primary Driver |
|---|---|---|---|
| Govern | Partial | Managed | Strategy, policy, risk register, RACI |
| Identify | Partial | Managed | Asset discipline and recurring risk review |
| Protect | Partial | Managed | MFA, segmentation, EDR, hardening |
| Detect | Not Implemented | Managed | SIEM + EDR + alert procedures |
| Respond | Partial | Managed | IR plan and tabletop exercise |
| Recover | Partial | Managed | Immutable backups and DR testing |

**Overall conclusion:** MedDefense is not starting from zero, but it is operating with fragmented and under-documented security practices. The realistic 6-month objective is not optimization; it is **repeatable, governed, and testable baseline maturity** across all six functions.
