# MedDefense CIS Controls v8 Audit

## Control-by-Control Assessment

### CIS Control 1: Inventory and Control of Enterprise Assets
**Score:** Partial  
**Evidence:** 1x00 produced a consolidated asset registry, but the hospital entered the assessment with stale AD counts, shadow systems such as `ws-srv-02`, and unmanaged devices such as the intern laptop and clinical iPads.

### CIS Control 2: Inventory and Control of Software Assets
**Score:** Partial  
**Evidence:** 1x02 identified unsupported Ubuntu 18.04, Windows XP, Windows Server 2012 R2, and outdated Apache/Tomcat components, showing MedDefense does not maintain a complete, support-status-aware software inventory.

### CIS Control 3: Data Protection
**Score:** Partial  
**Evidence:** 1x00 classified PHI and financial data as critical, but 1x02 Finding 003 showed unrestricted PostgreSQL access and 1x00 showed incomplete O365/PACS backup protection.

### CIS Control 4: Secure Configuration of Enterprise Assets and Software
**Score:** Partial  
**Evidence:** Default credentials on BD Alaris pumps (Finding 024), LDAP signing disabled and SMBv1 enabled (Findings 018/019), and exposed AJP/Apache services demonstrate inconsistent hardening.

### CIS Control 5: Account Management
**Score:** Partial  
**Evidence:** 1x01 documented shared accounts, weak privileged account hygiene, and offboarding delays that allowed former users to retain access.

### CIS Control 6: Access Control Management
**Score:** Partial  
**Evidence:** 1x00 and 1x01 repeatedly identified no MFA for VPN or administrative access, excessive permissions, and weak vendor access controls.

### CIS Control 7: Continuous Vulnerability Management
**Score:** Partial  
**Evidence:** 1x02 found 31 issues including six actionable critical findings, proving some vulnerability discovery exists but remediation is not fast enough for internet-facing and crown-jewel systems.

### CIS Control 8: Audit Log Management
**Score:** Not Implemented  
**Evidence:** Gap G-001 states there is no SIEM or centralized logging, logs rotate locally, and alerting is absent.

### CIS Control 9: Email and Web Browser Protections
**Score:** Partial  
**Evidence:** Phishing remains the most likely attack vector from 1x01, indicating security awareness and browser/email protections exist only at a basic level.

### CIS Control 10: Malware Defenses
**Score:** Not Implemented  
**Evidence:** Gap G-002 confirmed production servers lack endpoint protection, and the billing server cryptominer ran undetected.

### CIS Control 11: Data Recovery
**Score:** Partial  
**Evidence:** Backups exist through Veeam/NAS, but 1x00 showed missing coverage, no immutability, and no full restoration test.

### CIS Control 12: Network Infrastructure Management
**Score:** Partial  
**Evidence:** The FortiGate perimeter exists, but Gap G-005 and 1x02 make clear the internal network is effectively flat and Westside relies on a consumer-grade router.

### CIS Control 13: Network Monitoring and Defense
**Score:** Not Implemented  
**Evidence:** 1x00 documented no centralized event alerting, and 1x01 showed every major kill chain benefits from the monitoring blind spot.

### CIS Control 14: Security Awareness and Skills Training
**Score:** Partial  
**Evidence:** Basic annual awareness exists, but 1x01 still ranks phishing as the dominant vector and insider scenarios remain highly plausible.

### CIS Control 15: Service Provider Management
**Score:** Partial  
**Evidence:** 1x01 identified trusted vendor maintenance paths as a realistic kill chain, showing third-party access exists without sufficient governance.

### CIS Control 16: Application Software Security
**Score:** Not Implemented  
**Evidence:** 1x02 identified exploitable Apache and Tomcat weaknesses on production web systems, with no evidence of a secure SDLC or application security testing discipline.

### CIS Control 17: Incident Response Management
**Score:** Not Implemented  
**Evidence:** 1x00 Gap G-003 confirmed no formal incident response plan existed and ransomware response was improvised.

### CIS Control 18: Penetration Testing
**Score:** Not Implemented  
**Evidence:** There is no documented penetration testing program; 1x01 threat modeling and 1x02 scanning were assessment exercises, not an ongoing validation process.

## Scorecard Summary
| Status | Count |
|---|---:|
| Implemented | 0 |
| Partial | 12 |
| Not Implemented | 6 |

## Top 5 Priority Controls
1. **Control 6 - Access Control Management:** MFA and privileged access governance break the highest number of ransomware, insider, and vendor kill chains.  
2. **Control 12 - Network Infrastructure Management:** Segmentation is the foundational architectural fix because the flat network amplifies nearly every other weakness.  
3. **Control 8 - Audit Log Management:** Without centralized logs, MedDefense cannot know whether preventive controls are working or failing.  
4. **Control 10 - Malware Defenses:** Server and endpoint detection are required to stop cryptominers, ransomware execution, and malicious persistence.  
5. **Control 11 - Data Recovery:** In healthcare, recovery capability is directly tied to patient safety and business continuity, not just IT convenience.

## Overall Assessment
MedDefense is best described as **IG1 incomplete and IG2 largely absent**. The hospital has fragments of a security program, but its operating baseline is not yet mature enough for modern healthcare ransomware pressure. The year-1 target should be to fully stabilize the most important IG1 safeguards and selectively add IG2 capabilities in segmentation, network monitoring, and vendor control.
