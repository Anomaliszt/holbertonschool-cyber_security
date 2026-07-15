# Control Selection and Framework Mapping

## Risk-to-Control Mapping

### RISK-001 - Enterprise ransomware
- **Selected Control:** Immutable offsite backups with quarterly restore testing  
  **CIS Mapping:** Control 11.2, 11.3, 11.4  
  **NIST CSF Mapping:** RC.RP, PR.DS  
  **Control Type:** Corrective  
  **Control Category:** Technical / Operational  
  **Implementation Cost:** $14,000  
  **Expected Risk Reduction:** ~$420,000 ALE reduction  
  **Dependencies:** Backup inventory and retention policy
- **Selected Control:** EDR on servers and endpoints  
  **CIS Mapping:** Control 10.1, 10.2  
  **NIST CSF Mapping:** PR.PS, DE.CM  
  **Control Type:** Preventive / Detective  
  **Control Category:** Technical  
  **Implementation Cost:** $42,000  
  **Expected Risk Reduction:** ~$510,000 ALE reduction  
  **Dependencies:** Asset inventory and change windows

### RISK-002 - EHR PHI breach
- **Selected Control:** Server/database network segmentation  
  **CIS Mapping:** Control 12.2, 12.6  
  **NIST CSF Mapping:** PR.IR, PR.AA  
  **Control Type:** Preventive  
  **Control Category:** Technical  
  **Implementation Cost:** $18,000  
  **Expected Risk Reduction:** ~$1,050,000 shared reduction across top risks  
  **Dependencies:** Approved zone design and firewall rule set
- **Selected Control:** Wazuh SIEM with DB / AD / VPN logging  
  **CIS Mapping:** Control 8.2, 8.3, 13.1  
  **NIST CSF Mapping:** DE.CM, DE.AE  
  **Control Type:** Detective  
  **Control Category:** Technical / Operational  
  **Implementation Cost:** $22,000  
  **Expected Risk Reduction:** ~$480,000 shared reduction  
  **Dependencies:** Log source onboarding

### RISK-003 - VPN compromise
- **Selected Control:** MFA for VPN and admin accounts  
  **CIS Mapping:** Control 6.3, 6.4, 6.5  
  **NIST CSF Mapping:** PR.AA  
  **Control Type:** Preventive  
  **Control Category:** Technical / Administrative  
  **Implementation Cost:** $8,000  
  **Expected Risk Reduction:** ~$620,000  
  **Dependencies:** Account inventory and enrollment process
- **Selected Control:** FortiGate patch governance standard  
  **CIS Mapping:** Control 7.3, 12.1  
  **NIST CSF Mapping:** PR.PS  
  **Control Type:** Preventive  
  **Control Category:** Operational  
  **Implementation Cost:** Included in existing staff time  
  **Expected Risk Reduction:** Lowers ARO materially  
  **Dependencies:** Monthly maintenance window

### RISK-004 - AD compromise
- **Selected Control:** Enable LDAP signing and disable SMBv1  
  **CIS Mapping:** Control 4.1, 4.6, 6.5  
  **NIST CSF Mapping:** PR.AA, PR.PS  
  **Control Type:** Preventive  
  **Control Category:** Technical  
  **Implementation Cost:** Minimal / internal labor  
  **Expected Risk Reduction:** High for relay-based escalation  
  **Dependencies:** Change testing on legacy systems

### RISK-005 - Vendor remote access compromise
- **Selected Control:** Vendor jump host with MFA and session logging  
  **CIS Mapping:** Control 6.4, 15.1, 15.2  
  **NIST CSF Mapping:** GV.SC, PR.AA, DE.CM  
  **Control Type:** Preventive / Detective  
  **Control Category:** Technical / Administrative  
  **Implementation Cost:** Uses SIEM + MFA + segmentation baseline; incremental labor only  
  **Expected Risk Reduction:** Narrows vendor blast radius and improves auditability  
  **Dependencies:** MFA and management zone operational

### RISK-006 - Negligent insider data loss
- **Selected Control:** Acceptable Use Policy + USB storage blocking  
  **CIS Mapping:** Control 3.3, 9.1, 14.4, 14.6  
  **NIST CSF Mapping:** PR.AT, PR.DS  
  **Control Type:** Preventive  
  **Control Category:** Administrative / Technical  
  **Implementation Cost:** ~$6,000  
  **Expected Risk Reduction:** ~$180,000  
  **Dependencies:** Policy approval and endpoint GPO deployment

### RISK-007 - Medical device compromise
- **Selected Control:** Unique device credentials + phased device isolation  
  **CIS Mapping:** Control 4.7, 12.2, 13.1  
  **NIST CSF Mapping:** PR.AA, PR.IR, DE.CM  
  **Control Type:** Preventive / Compensating  
  **Control Category:** Technical / Operational  
  **Implementation Cost:** $28,000 if fully funded; password reset is immediate low-cost component  
  **Expected Risk Reduction:** ~$210,000 full-control reduction  
  **Dependencies:** Network segmentation and clinical engineering coordination

### RISK-008 - Recovery failure
- **Selected Control:** Immutable offsite replication + DR exercise  
  **CIS Mapping:** Control 11.1, 11.2, 11.4  
  **NIST CSF Mapping:** RC.RP, RC.CO  
  **Control Type:** Corrective  
  **Control Category:** Technical / Operational  
  **Implementation Cost:** $14,000  
  **Expected Risk Reduction:** ~$420,000  
  **Dependencies:** Backup scope validation and retention approval

### RISK-009 - Legacy MRI workstation (accepted risk with compensating controls)
- **Selected Control:** VLAN isolation, deny-all inbound except approved support path, flow monitoring  
  **CIS Mapping:** Control 12.2, 13.6  
  **NIST CSF Mapping:** PR.IR, DE.CM  
  **Control Type:** Compensating  
  **Control Category:** Technical  
  **Implementation Cost:** Covered by segmentation baseline  
  **Expected Risk Reduction:** Lowers ARO until replacement is feasible  
  **Dependencies:** Segmentation go-live

### RISK-010 - Off-hours monitoring gap (accepted for year 1)
- **Selected Control:** SIEM alert queue + on-call escalation + badge review  
  **CIS Mapping:** Control 8.2, 13.1  
  **NIST CSF Mapping:** DE.CM, RS.CO  
  **Control Type:** Detective / Compensating  
  **Control Category:** Operational  
  **Implementation Cost:** Included in SIEM deployment and staff process  
  **Expected Risk Reduction:** Moderate; not equivalent to a 24/7 SOC  
  **Dependencies:** SIEM deployment first

## Control Dependency Map
```text
Asset / account inventory
    -> MFA enrollment
        -> Vendor jump host enforcement

Network segmentation design
    -> Core VLAN implementation
        -> MRI isolation
        -> Medical device isolation
        -> Westside firewall policy alignment

SIEM deployment
    -> Log source onboarding
        -> Alert triage process
            -> Future 24/7 SOC / MDR decision

Backup scope validation
    -> Offsite immutable replication
        -> Full restore exercise
```

## Summary
Control selection at MedDefense follows three rules: reduce the specific risk, fit the budget, and map cleanly to recognized frameworks. The dependency map also shows why year-1 success depends on **sequence**, not just funding.
