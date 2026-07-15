# MedDefense 6-Month Security Roadmap

## Month-by-Month Plan

### Month 1 (August 2026)
- **Actions:** Approve AUP, approve risk register/governance cadence, inventory VPN/admin accounts, enable MFA enrollment, change BD Alaris default credentials, disable SMBv1 / enable LDAP signing.  
- **Owner:** James Chen / Sarah Park / Security Analyst  
- **Dependencies:** Executive approval of strategy and policy baseline  
- **Completion Criteria:** 100% of VPN/admin accounts enrolled in MFA; Findings 018/019 and 024 remediated or validated closed.

### Month 2 (September 2026)
- **Actions:** Restrict PostgreSQL access, finalize segmentation design, procure EDR upgrade, procure Westside firewall, configure immutable backup target, publish IR plan draft.  
- **Owner:** Sarah Park  
- **Dependencies:** Month 1 account and asset cleanup; approved network design  
- **Completion Criteria:** DB access limited to approved hosts; all procurement approved; backup replication pilot succeeds.

### Month 3 (October 2026)
- **Actions:** Deploy Westside firewall, implement server/management/guest VLANs, stand up Wazuh, onboard FortiGate, AD, EHR, billing, and backup logs.  
- **Owner:** Sarah Park + Security Analyst  
- **Dependencies:** Procurement completed; maintenance windows approved  
- **Completion Criteria:** Westside consumer router retired; SIEM receiving logs from all priority systems; guest zone isolated from internal network.

### Month 4 (November 2026)
- **Actions:** Extend segmentation to clinical and medical device-adjacent zones, deploy EDR to servers and priority endpoints, complete offsite immutable backup replication, approve vendor access standard.  
- **Owner:** Sarah Park / Clinical Engineering / James Chen  
- **Dependencies:** Core VLAN implementation from Month 3; testing sign-off from department heads  
- **Completion Criteria:** 95% of servers protected by EDR; immutable backup copy verified; vendor access forced through approved path.

### Month 5 (December 2026)
- **Actions:** Tune SIEM/EDR alerts, run incident response tabletop, run full restore test for EHR/billing backup set, document accepted-risk exceptions (MRI, after-hours monitoring).  
- **Owner:** James Chen + Security Analyst  
- **Dependencies:** SIEM and backup controls live  
- **Completion Criteria:** Restore test meets target; tabletop produces tracked actions; KRIs baselined.

### Month 6 (January 2027)
- **Actions:** Review residual risk, present Board maturity update, finalize year-2 budget request for MDR/PAM/medical device monitoring, update roadmap based on results.  
- **Owner:** James Chen / CEO / vCISO (if engaged)  
- **Dependencies:** Completion of testing and control tuning  
- **Completion Criteria:** Board receives measurable progress report; year-2 priorities approved for planning.

## Dependency Chain
1. **Account inventory -> MFA deployment -> vendor jump-host enforcement**  
2. **Segmentation design -> core VLAN implementation -> medical/MRI isolation**  
3. **SIEM deployment -> log source onboarding -> meaningful alert monitoring**  
4. **Backup scope validation -> immutable replication -> full restore exercise**

## Milestones
| Date | Milestone | What Has Been Accomplished | Indicator of Success |
|---|---|---|---|
| 2026-08-31 | Identity Baseline Locked | MFA on VPN/admin accounts; AD hardening complete | 100% MFA coverage; no SMBv1 on supported hosts |
| 2026-10-15 | Visibility Online | Wazuh ingesting critical logs; Westside boundary hardened | Critical log sources online; consumer router retired |
| 2026-11-30 | Core Architecture Protected | Segmentation, EDR, and immutable backups operational | 95% server EDR coverage; backup immutability verified |
| 2027-01-15 | Program Validated | Restore test, IR tabletop, and Board update completed | Successful restore within target RTO; risk dashboard delivered |

## Risks to Timeline
### 1. Clinical change-window resistance
**Why likely:** Segmentation and AD changes can affect clinical workflows and are difficult to schedule.  
**Contingency:** Use phased pilots, overnight maintenance windows, and written rollback plans approved jointly by IT and department heads.

### 2. Small-team capacity constraints
**Why likely:** Sarah, James, and one analyst are covering governance, design, deployment, and operations simultaneously.  
**Contingency:** Use the $7K reserve for temporary implementation support, prioritize highest-risk assets first, and delay lower-impact tuning tasks rather than core control deployment.
