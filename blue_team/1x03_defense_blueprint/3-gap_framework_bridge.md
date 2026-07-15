# Gap-to-Framework Traceability Bridge

## Highest-Priority Gap Traceability

### 1. Gap Reference: G-005
**Description:** Flat internal network allows unrestricted lateral movement between workstations, servers, backups, and medical devices.  
**Vulnerability Evidence:** Finding 003 (PostgreSQL unrestricted access), Findings 008/009 (legacy MRI exposure), Finding 024 (BD Alaris default credentials).  
**Threat Context:** ALPHV/LockBit/RansomHub; Kill Chains #1, #3, and #5 from 1x01.  
**NIST CSF Function:** Protect (PR.IR)  
**CIS Control:** Control 12 - Network Infrastructure Management  
**Recommended Action:** Implement VLAN-based segmentation with firewall enforcement between server, workstation, medical device, management, guest, and vendor zones.

### 2. Gap Reference: G-001
**Description:** No centralized logging, correlation, or real-time alerting.  
**Vulnerability Evidence:** Billing cryptominer persisted undetected; 1x02 validation showed no SIEM-backed visibility around critical findings.  
**Threat Context:** RaaS, malicious insiders, and vendor compromise; Kill Chains #1, #2, and #3.  
**NIST CSF Function:** Detect (DE.CM / DE.AE)  
**CIS Control:** Control 8 and Control 13  
**Recommended Action:** Deploy Wazuh with critical server, AD, VPN, and endpoint telemetry plus a defined alert triage process.

### 3. Gap Reference: G-002
**Description:** Core servers lack endpoint protection and behavioral detection.  
**Vulnerability Evidence:** 1x00 Sophos gap, unnoticed cryptominer on `billing-srv-01`, Findings 001 and 031 would allow payload execution on exposed servers.  
**Threat Context:** Ransomware operators and opportunistic malware; Kill Chain #1.  
**NIST CSF Function:** Protect / Detect (PR.PS, DE.CM)  
**CIS Control:** Control 10 - Malware Defenses  
**Recommended Action:** Upgrade to enterprise EDR coverage for all servers and priority workstations, with isolation and ransomware behavior blocking enabled.

### 4. Gap Reference: G-003
**Description:** No formal incident response, business continuity, or disaster recovery plans.  
**Vulnerability Evidence:** January ransomware response was improvised; no tested recovery runbook.  
**Threat Context:** All major actor types; any kill chain that reaches impact phase.  
**NIST CSF Function:** Respond / Recover (RS.MA, RC.RP)  
**CIS Control:** Control 17 and Control 11  
**Recommended Action:** Approve IR, BC, and DR playbooks and exercise them through a tabletop within 90 days.

### 5. Gap Reference: G-004
**Description:** Backups are incomplete, non-immutable, and not fully tested.  
**Vulnerability Evidence:** PACS, Westside, O365, and some device settings excluded; NAS co-located with production; no full DR test.  
**Threat Context:** Ransomware groups, malicious insiders; Kill Chains #1 and #4.  
**NIST CSF Function:** Recover (RC.RP)  
**CIS Control:** Control 11 - Data Recovery  
**Recommended Action:** Add immutable offsite replication, complete backup coverage, and run a full restoration exercise against EHR/PACS workloads.

### 6. Gap Reference: F-001 / F-031
**Description:** Internet-facing Apache and Tomcat services expose remote code execution paths.  
**Vulnerability Evidence:** Finding 001 (Apache mod_lua RCE) and Finding 031 (Ghostcat AJP RCE).  
**Threat Context:** Ransomware affiliates and opportunistic attackers; Kill Chain #1.  
**NIST CSF Function:** Protect (PR.PS)  
**CIS Control:** Control 7 and Control 16  
**Recommended Action:** Establish a 14-day SLA for critical internet-facing patches and require emergency change windows for KEV-listed exposures.

### 7. Gap Reference: F-018 / F-019
**Description:** Weak AD protocol security enables credential relay and domain compromise.  
**Vulnerability Evidence:** Finding 018 (LDAP signing disabled) and Finding 019 (SMBv1 enabled).  
**Threat Context:** LockBit/ALPHV ransomware and insider privilege abuse; Kill Chains #1 and #2.  
**NIST CSF Function:** Protect (PR.AA)  
**CIS Control:** Control 6 - Access Control Management  
**Recommended Action:** Enforce LDAP signing, disable SMBv1, and require MFA for all administrative access.

### 8. Gap Reference: F-024
**Description:** Medical devices use default credentials on a flat network.  
**Vulnerability Evidence:** Finding 024 (BD Alaris default credentials); 1x00 documented unmanaged medical IoT exposure.  
**Threat Context:** Opportunistic attackers and insiders; Kill Chain #5.  
**NIST CSF Function:** Protect (PR.AA / PR.PS)  
**CIS Control:** Control 4 and Control 12  
**Recommended Action:** Eliminate vendor-default passwords, isolate the pump network, and monitor device administration events.

## Traceability Summary Table
| Gap | Vulnerability Evidence | Threat Context | NIST CSF | CIS Control | Why It Matters |
|---|---|---|---|---|---|
| G-005 Flat network | 003, 008/009, 024 | RaaS, insider, supply chain | PR.IR | 12 | Turns any foothold into enterprise compromise |
| G-001 No SIEM | Undetected miner, no alerting | RaaS, insider, vendor | DE.CM / DE.AE | 8, 13 | Extends attacker dwell time |
| G-002 No server EDR | 001, 031 + miner | RaaS | PR.PS / DE.CM | 10 | Allows malware to run unhindered |
| G-003 No IR/BC/DR plans | Improvised prior response | All actor types | RS / RC | 17, 11 | Slows containment and recovery |
| G-004 Weak backups | Missing PACS/O365/DR tests | RaaS, insider | RC.RP | 11 | Makes ransomware far more damaging |
| F-001/F-031 Web RCE | 001, 031 | RaaS, opportunistic | PR.PS | 7, 16 | Gives attackers initial access |
| F-018/F-019 AD weakness | 018, 019 | RaaS, insider | PR.AA | 6 | Enables domain-wide escalation |
| F-024 Default device creds | 024 | Insider, opportunistic | PR.AA / PR.PS | 4, 12 | Creates patient-safety and pivot risk |

## Conclusion
This bridge shows that MedDefense's security strategy is not based on abstract best practice. Each proposed action is traceable from a **real gap** to a **validated weakness**, through a **realistic attack path**, into a **recognized framework outcome** and a **specific corrective action**.
