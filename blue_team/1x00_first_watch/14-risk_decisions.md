# MedDefense Health Systems: Strategic Risk Treatment Framework

**Prepared for:** James Chen, Chief Information Officer  
**Fiscal Year Budget:** $120,000 USD  
**Strategic Focus:** Cost-Optimized Risk Reduction via Open-Source Solutions, Process Re-engineering, and Resource Maximization  

---

## Executive Summary

This framework establishes the tactical roadmap to address MedDefense Health Systems' top 7 critical security gaps under realistic financial constraints. By rejecting the traditional approach of purchasing high-cost, single-point enterprise licenses—such as an $80,000 commercial SIEM—we leverage open-source platforms, existing hardware capabilities, internal engineering hours, and strategic cloud-tiering. 

As a result, all 7 critical gaps are aggressively addressed for a total expenditure of **$93,000**, leaving a **$27,000 strategic contingency reserve** for unforeseen emergency remediation needs.

---

## 1. Prioritized Risk Treatment Decisions

### GAP-001: Absolute Lack of Centralized Logging and Automated Security Alerting
* **Risk Level:** Critical
* **Treatment Strategy:** Mitigate
* **Justification:** An enterprise SIEM license at $80,000 would consume 66% of our entire annual security budget, leaving the remaining gaps completely exposed. Instead, we will deploy a mature, open-source SIEM platform (Wazuh or ELK with security extensions) hosted on a dedicated internal bare-metal server. This satisfies our detective control requirements without bankrupting our fiscal year strategy.
* **Proposed Controls:** Technical / Detective: Centralized open-source log aggregation server with hardened agent endpoints deployed on all core infrastructure (`ehr-db-01`, `ehr-srv-01`, `billing-srv-01`, `ad-dc-01`). Real-time alerting rules integrated into internal IT notification systems.
* **Estimated Cost:** $1-10K ($8,500 for a high-performance server node and specialized external setup/tuning support).
* **Implementation Effort:** Long-term > 1 month
* **Expected Risk Reduction:** High. Eliminates the 100% detective blind spot across critical databases. It reduces attacker dwell time from months to minutes by alerting on brute-force attempts, unauthorized administrative changes, and internal network lateral movement.
* **Trade-offs:** Significantly increases operational overhead for our internal IT engineering team, who must manually manage, tune, and monitor the open-source platform without vendor-backed 24/7 commercial support SLA structures.

---

### GAP-011: Absence of Multi-Factor Authentication (MFA) and Automated Account Offboarding Integration
* **Risk Level:** Critical
* **Treatment Strategy:** Mitigate
* **Justification:** Real-world breach intelligence demonstrates that unauthenticated external access vectors (VPNs and public web apps) represent the highest-probability entry points for modern healthcare threat actors. Enforcing MFA provides immediate, robust protection against credential-stuffing and orphaned accounts at a highly predictable operational cost.
* **Proposed Controls:** Technical / Preventive: Mandatory multi-factor authentication enforcement across all external entry layers (FortiGate VPN Gateways) and critical internal software applications (EHR system portals).
* **Estimated Cost:** $10-50K ($11,500 for enterprise identity provider user licensing like Duo Security or Microsoft Entra ID).
* **Implementation Effort:** Short-term < 1 month
* **Expected Risk Reduction:** Extremely High. Effectively neutralizes compromised, leaked, or legacy employee credentials used by remote threat actors or disgruntled terminated personnel trying to perform unauthorized data exfiltration.
* **Trade-offs:** Introduces minor authentication friction into fast-paced clinical workflows; requires structured change management and training for clinical personnel unaccustomed to secondary authentication factors during emergencies.

---

### GAP-006: Flat Network Architecture and Missing Internal Segment Isolation
* **Risk Level:** Critical
* **Treatment Strategy:** Mitigate
* **Justification:** MedDefense cannot afford to purchase separate dedicated internal network firewalls for every department. However, our existing FortiGate perimeter appliance has unutilized physical interfaces and robust virtual local area network (VLAN) routing capabilities. We will leverage internal engineering hours to segment the network without paying new licensing fees.
* **Proposed Controls:** Technical / Preventive: Layer-3 network micro-segmentation separating core server clusters, medical IoT networks, public guest Wi-Fi, and general clinical workstations, paired with strict egress firewall filtering rules.
* **Estimated Cost:** $0-1K ($0 - Leverages existing FortiGate hardware capabilities and internal network staff hours).
* **Implementation Effort:** Long-term > 1 month
* **Expected Risk Reduction:** High. Heavily restricts internal lateral threat movement. If a single public workstation is compromised via phishing, it can no longer natively scan, ping, or query our critical clinical databases.
* **Trade-offs:** High risk of temporary operational or clinical disruption during deployment if critical clinical data paths or medical device telemetry links are accidentally blocked during the initial VLAN transition.

---

### GAP-004: Lack of Off-Site Redundancy and Co-location of Backup Hardware
* **Risk Level:** Critical
* **Treatment Strategy:** Mitigate
* **Justification:** Storing unencrypted virtual machine backups on a local NAS in the same server row creates an unacceptable, single point of failure. A ransomware attack or physical server room fire would result in catastrophic, permanent data loss. Establishing an off-site, unalterable backup repository is mandatory for business continuity.
* **Proposed Controls:** Technical & Administrative / Corrective: Immutable cloud-tier repository mapping (AWS S3 Object Lock or Azure Immutable Blob) integrated into our existing Veeam license, configured with daily automated off-site synchronization.
* **Estimated Cost:** $1-10K ($9,000 annual cloud storage consumption and bandwidth consumption fees).
* **Implementation Effort:** Short-term < 1 month
* **Expected Risk Reduction:** Critical. Guarantees that even if our local infrastructure is completely compromised, encrypted, or physically destroyed, unalterable backup snapshots remain safe and available for systematic disaster recovery.
* **Trade-offs:** Initial synchronization will heavily consume local upload bandwidth. Furthermore, system recovery times (RTO) will be bounded by cloud-to-on-prem internet download speeds compared to rapid local network restorations.

---

### GAP-002: Zero Endpoint Protection and Threat Isolation on Production Servers
* **Risk Level:** Critical
* **Treatment Strategy:** Mitigate
* **Justification:** While user workstations are protected by Sophos agents, our servers holding restricted patient medical records are completely unmonitored at the OS layer. Extending our endpoint protection directly to our high-value targets seals off lateral exploitation pathways.
* **Proposed Controls:** Technical / Preventive & Detective: Deployment of server-tier Endpoint Detection and Response (EDR) agents to provide kernel-level malicious behavioral analysis and instant host isolation capabilities.
* **Estimated Cost:** $10-50K ($34,000 for server licenses extending our existing Sophos deployment framework).
* **Implementation Effort:** Short-term < 1 month
* **Expected Risk Reduction:** High. Instantly blocks and alerts on malicious payloads, automated crypto-miners, or file-encrypting ransomware executing directly on clinical databases or domain controller kernels.
* **Trade-offs:** Consumes minor host-level compute and RAM resources on older production hardware; requires extensive configuration exclusions to ensure real-time endpoint scanning does not lock or slow active EHR database files.

---

### GAP-012: Widespread Proliferation of Vendor-Default Credentials on Network-Connected Medical IoT Infrastructure
* **Risk Level:** Critical
* **Treatment Strategy:** Mitigate
* **Justification:** Leaving factory-default credentials active on network-connected medical devices represents a severe risk to patient care safety. Mitigating this vulnerability requires no specialized capital expenditure or software tooling, only diligent administrative execution and internal labor.
* **Proposed Controls:** Technical & Administrative / Preventive: Comprehensive configuration sweep to change all vendor-default passwords across our medical IoT infrastructure, combined with a mandatory procurement standard updating credentials before any appliance network attachment.
* **Estimated Cost:** $0-1K ($0 - Internal labor and asset audit only).
* **Implementation Effort:** Short-term < 1 month
* **Expected Risk Reduction:** High. Completely blocks automated scanning utilities, low-sophistication actors, or malicious insiders from gaining administrative command over patient infusion pumps and vital sign monitors.
* **Trade-offs:** Requires coordinating tight service windows with clinical departments to modify passwords without disrupting ongoing patient monitoring or live procedures.

---

### GAP-003: Complete Exclusion of PACS Imaging Infrastructure from Enterprise Backups
* **Risk Level:** Critical
* **Treatment Strategy:** Transfer
* **Justification:** The sheer storage size of millions of high-resolution medical images (MRIs, CT scans, X-rays) exceeds our local backup storage capacity. Remediating this gap by purchasing massive local physical storage arrays would completely exhaust our budget. By outsourcing this architecture to a medical-grade cloud archive, we shift the massive risk of historical storage loss to a third party.
* **Transfer Mechanism:** Transition PACS storage to a cloud-hosted, certified Vendor Neutral Archive (VNA) outsourced management and backup contract.
* **Residual Risk:** MedDefense retains an absolute operational dependency on local network internet uptime to fetch historical imaging files. Local workspace caches remain vulnerable until successfully synchronized to the cloud provider's network.
* **Trade-offs:** Shifts unpredictable capital expenditure (CapEx) into permanent, recurring operational expenditure (OpEx), creating long-term data custody and pricing dependencies with an external third-party vendor.

---

## 2. Fiscal Year Budget Summary & Resource Allocation

By rejecting expensive single-point security products and utilizing internal capabilities, the proposed remediations fit securely within the $120,000 annual allowance.

| Gap ID | Focus Area | Chosen Strategy | Cost Allocation |
| :--- | :--- | :--- | :--- |
| **GAP-001** | Open-Source Centralized Logging (Wazuh/ELK) | Mitigate | $8,500 |
| **GAP-011** | Enforced Multi-Factor Authentication (MFA) | Mitigate | $11,500 |
| **GAP-006** | Internal Network VLAN Micro-segmentation | Mitigate | $0 *(Internal Labor)* |
| **GAP-004** | Cloud Immutable Off-site Backups (Veeam + AWS) | Mitigate | $9,000 |
| **GAP-002** | Sophos Server EDR Licensing Extension | Mitigate | $34,000 |
| **GAP-012** | Medical IoT Default Password Elimination | Mitigate | $0 *(Internal Labor)* |
| **GAP-003** | Cloud-Hosted PACS Imaging Archive Contract | Transfer | $30,000 |
| **Total** | | | **$93,000** |
| **Reserve** | **Strategic Unallocated Contingency Balance** | | **$27,000** |

### Strategic Deferrals to Next Fiscal Year
Because this framework fits within our financial constraints, no critical gaps were abandoned. However, several lower-ranked gaps have been systematically deferred to the next fiscal year:

1. **GAP-005 (Unsecured Network Closets & Plaintext Credentials):** Partially mitigated in the short term by network segmentation (**GAP-006**). Even if an intruder physically taps into a local switch port, micro-segmentation rules will block them from accessing the primary server tier.
2. **GAP-007 (Nurse Station Cultural Authentication Session Overrides):** Deferred to next fiscal year for capital investment in proximity badge locks. Compensated for this year by the deployment of server-tier EDR (**GAP-002**) and centralized auditing (**GAP-001**) to flag abnormal file modifications or lookups.
3. **GAP-009 (Propped-Open Emergency Exit Door):** Can be addressed via immediate administrative disciplinary mandates and physical key policy changes at zero capital cost, deferring automated electronic badge door sensors to the next budget loop.
