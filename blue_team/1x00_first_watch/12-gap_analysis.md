# MedDefense Health Systems: Prioritized Strategic Gap Analysis

This formal gap analysis systematically cross-references asset criticality, operational data paths, control effectiveness, and structural deficiencies across MedDefense Health Systems to deliver a prioritized security remediation roadmap for executive leadership.

---

## 1. Prioritized Security Gap Register

### GAP-001: Absolute Lack of Centralized Logging and Automated Security Alerting
* **Affected Asset(s):** All core production servers (`ehr-db-01` [Critical], `ehr-srv-01` [Critical], `billing-srv-01` [High], `ad-dc-01` [Critical])
* **Data at Risk:** Patient Medical Records (Restricted), System Credentials (Restricted), Financial & Billing Data (Restricted)
* **Current Control Status:** **Weak.** Systems generate separate local files independently (**C-009**); firewall logs are overwritten locally every 30 days (**C-001**).
* **What is Missing:** Technical / Detective control function (SIEM, centralized log aggregator, real-time alert definitions).
* **Risk Level:** **Critical**
* **Risk Justification:** Affects top-tier critical clinical databases and restricted data. There are zero detective controls capable of flagging unauthorized access, configuration modifications, or lateral movement across the network.
* **Potential Impact:** Attackers can compromise critical medical directories and roam undetected for months (high dwell time), silently exfiltrating patient files or altering healthcare metrics without triggering any administrative alerts.

---

### GAP-002: Zero Endpoint Protection and Threat Isolation on Production Servers
* **Affected Asset(s):** Core Server Infrastructure Network Segment (`ehr-db-01` [Critical], `ehr-srv-01` [Critical], `billing-srv-01` [High])
* **Data at Risk:** Patient Medical Records (Restricted), Financial & Billing Data (Restricted), Employee HR Records (Confidential)
* **Current Control Status:** **Weak.** Sophos Endpoint Protection (**C-007**) is deployed on user workstations only; licenses for production servers were denied due to budget blocks.
* **What is Missing:** Technical / Preventive and Detective host controls (Server-tier Anti-Malware / Endpoint Detection and Response).
* **Risk Level:** **Critical**
* **Risk Justification:** Core infrastructure processing restricted patient data completely lacks endpoint threat mitigation. It relies entirely on boundary firewall defense rules.
* **Potential Impact:** A workstation infection can shift laterally onto the server tier. Payloads like file-encrypting ransomware or automated background crypto-miners can execute directly on database kernels, destroying data availability and shutting down medical services.

---

### GAP-003: Complete Exclusion of PACS Imaging Infrastructure from Enterprise Backups
* **Affected Asset(s):** `pacs-srv-01` (PACS Imaging Engine Server) [Critical]
* **Data at Risk:** Medical Imaging Data (Restricted)
* **Current Control Status:** **Weak.** Completely skipped by the nightly Veeam automation loop (**C-008**) because its storage requirements exceed NAS boundaries.
* **What is Missing:** Technical / Corrective lifecycle validation (Data Backup and Restoration redundancy for high-capacity visual assets).
* **Risk Level:** **Critical**
* **Risk Justification:** High-criticality clinical asset containing restricted visual records has zero backup or recovery options. A hardware failure or ransomware hit results in permanent data destruction.
* **Potential Impact:** A storage crash or ransomware attack permanently destroys millions of dollars in patient historical MRIs, CT scans, and X-rays, disrupting radiology diagnostics, stopping surgeries, and exposing the facility to massive malpractice liability.

---

### GAP-004: Lack of Off-Site Redundancy and Co-location of Backup Hardware
* **Affected Asset(s):** `NAS-01` (Synology Network Attached Storage) [Critical], `backup-srv-01` [Critical]
* **Data at Risk:** Nightly Backup Sets of All Critical Virtual Machines (Restricted Patient Data / Financial Infrastructure)
* **Current Control Status:** **Weak.** Veeam runs nightly full copies (**C-008**), but backup files are unencrypted and stored on a NAS in the same server room rack row as the live production hardware.
* **What is Missing:** Technical & Administrative / Corrective functions (Off-site replication, immutable cloud storage mapping, air-gapped recovery copies).
* **Risk Level:** **Critical**
* **Risk Justification:** The entire backup architecture sits on the same network subnet and inside the same physical room as production, creating a single point of failure.
* **Potential Impact:** A physical server room fire, flood, or a ransomware payload with administrative rights will simultaneously destroy both the live production environment and its backup sets, leading to catastrophic, unrecoverable data loss.

---

### GAP-005: Unsecured Network Closets and Exposed Switch Admin Credentials
* **Affected Asset(s):** `Core-SW-01` (Cisco Switches) [Critical], Central Hospital Floor Closets [High]
* **Data at Risk:** Network Routing Paths, Administrative Control Profiles (Restricted)
* **Current Control Status:** **Weak.** Closets are left unlocked and propped open; clear administrative console passwords are taped directly to internal wall surfaces.
* **What is Missing:** Physical / Preventive & Technical / Preventive (Physical perimeter isolation, strict password vaulting infrastructure).
* **Risk Level:** **Critical**
* **Risk Justification:** Provides unauthenticated physical access to core network hardware along with plaintext administrative credentials, allowing full control over floor-wide routing loops within seconds.
* **Potential Impact:** Any patient or visitor can step into a closet, connect a personal device, and use the exposed credentials to reconfigure switch matrices, change data directions to intercept patient info, or shut down entire clinical floors.

---

### GAP-006: Flat Network Architecture and Missing Internal Segment Isolation
* **Affected Asset(s):** Entire Central Hospital Broadcast Network Domain ($10.10.0.0/16$) [Critical Network Core]
* **Data at Risk:** Internal Clinical Traffic, Medical IoT Feeds, Patient Records (Restricted)
* **Current Control Status:** **Weak.** FortiGate perimeter filters external boundaries (**C-003**), but internal zones operate on a flat domain with no egress limits on outbound traffic (**C-002**).
* **What is Missing:** Technical / Preventive control structure (Internal VLAN micro-segmentation, Layer-3 security perimeters, egress filtering policies).
* **Risk Level:** **Critical**
* **Risk Justification:** A flat network layout allows any compromised device—from a public workstation to a shadow IT notebook—to reach critical medical databases and IoT hardware without passing an internal firewall check.
* **Potential Impact:** Compromised internal devices can freely scan the network, move laterally to vulnerable targets, and effortlessly exfiltrate restricted data to external servers over open, unmonitored ports.

---

### GAP-007: Unsecured User Sessions and Cultural Authentication Overrides at Nurse Stations
* **Affected Asset(s):** Workstations (Gen) [Critical Clinical Endpoints]
* **Data at Risk:** Patient Medical Records / EHR Active Windows (Restricted)
* **Current Control Status:** **Weak.** Windows Active Directory enforces complex user account rules (**C-005**), but clinical terminals are left logged into active EHR sessions unattended for over 15 minutes due to placards instructing staff not to lock systems.
* **What is Missing:** Technical / Preventive and Administrative / Preventive (Automated session timeouts, mandatory clean-desk policing, proximity badge lock integration).
* **Risk Level:** **High**
* **Risk Justification:** Exposes restricted patient records directly to high-traffic areas, allowing unauthenticated physical users to view or modify active clinical files under a legitimate nurse's identity.
* **Potential Impact:** Passersby or malicious actors can view private patient health data or change medical charts (e.g., altering drug dosage orders), causing patient care safety risks and clear HIPAA violations.

---

### GAP-008: Outdated Medical Device Firmware and Displayed Endpoint Telemetry
* **Affected Asset(s):** `Vitals-Mon-01` [Critical Medical IoT], `MRI-MAGNETOM` [Critical Medical IoT]
* **Data at Risk:** Live Patient Vital Metrics, Device Configuration Firmware (Restricted)
* **Current Control Status:** **Weak.** Legacy unpatched endpoint firmware (v2.1.3, last updated in 2019) running on a flat network domain with active IP addresses displayed publicly on the device screen.
* **What is Missing:** Technical / Compensating and Preventive (Network-level micro-segmentation, disabling of descriptive screen telemetry).
* **Risk Level:** **High**
* **Risk Justification:** Critical medical IoT infrastructure runs unpatched software on a flat network, making it highly vulnerable to lateral network scanning and known exploit vectors.
* **Potential Impact:** Attackers can target these devices to modify real-time vital metrics sent to nursing dashboards, spoof telemetry, or crash the systems during active patient procedures, endangering patient safety.

---

### GAP-009: Propped-Open Emergency Exit Door Linking Public Waiting Rooms to Administrative Wings
* **Affected Asset(s):** Central Hospital Administrative Wing & IT Security Offices [High Physical Infrastructure]
* **Data at Risk:** Corporate Financial Records, Paper Medical Charts, Administrative Hardware Nodes (Confidential/Restricted)
* **Current Control Status:** **Weak.** The main lobby entrance utilizes a weekday guard check (**C-012**), but secondary perimeter fire exit barriers are propped open with wooden wedges.
* **What is Missing:** Physical / Preventive and Detective (Active door-ajar sensors, local physical alarms, constant physical perimeter patrols).
* **Risk Level:** **High**
* **Risk Justification:** Completely bypasses the main entrance guard station, providing tailgating-free access from public waiting zones directly into corporate and IT offices.
* **Potential Impact:** Intruders can walk directly into executive or IT workspaces unnoticed to steal physical paperwork, compromise unattended terminals, or install physical keyloggers.

---

### GAP-010: Proliferation of Unmanaged Shadow IT Storage and Communication Nodes
* **Affected Asset(s):** `patel-office-nas` [Shadow IT], `mktg-gdrive` [Shadow IT], `intern-laptop` [Shadow IT]
* **Data at Risk:** Medical Research Files (Restricted), Corporate Press/Media Assets (Confidential), Network Traffic Captures (Confidential)
* **Current Control Status:** **Weak.** Completely misses Active Directory Group Policy rules (**C-005**), Sophos agent scans (**C-007**), or formal backup logging loops (**C-008**).
* **What is Missing:** Technical / Preventive and Administrative / Preventive (Network Access Control system deployment, clear cloud usage policies, automated port security controls).
* **Risk Level:** **High**
* **Risk Justification:** Sensitive clinical data and network configurations are placed on unmanaged personal devices and consumer cloud accounts that lack multi-factor authentication, security oversight, or organizational access controls.
* **Potential Impact:** Compromise of personal accounts or devices leaks internal hospital research or documents, while unmanaged hardware plugged into wall ports provides attackers with a persistent, hidden backdoor inside the internal network.

---

## 2. Strategic Gap Distribution Summary

### Risk Level Breakdown
* **Critical:** **6 Gaps** (GAP-001, GAP-002, GAP-003, GAP-004, GAP-005, GAP-006) — Immediate, systemic threats to restricted data and core infrastructure with zero active discovery boundaries.
* **High:** **4 Gaps** (GAP-007, GAP-008, GAP-009, GAP-010) — Severe risk exposures to clinical endpoints, medical IoT hardware, or corporate perimeters with incomplete control coverage.
* **Medium:** **0 Gaps** — No prioritized gaps currently fall into this tier.
* **Low:** **0 Gaps** — No identified gaps fall into this lowest tier.

### Concentrated Vulnerability Vectors
* **Asset Category Concentration:** Gaps are heavily concentrated around the **Core Server Infrastructure Tier** (EHR, Database, and Backup arrays) and **Clinical Network Endpoints/Medical IoT devices**. These systems handle the highest volume of restricted patient data but are surrounded by the weakest network isolation.
* **Control Category & Function Blind Spots:** The assessment reveals a severe imbalance in control distribution. Remediation focus must shift away from standard edge perimeter prevention. The organization's primary vulnerabilities are concentrated within the **Technical Detective** and **Technical/Administrative Corrective** domains. MedDefense can neither see active internal threats due to the lack of centralized logging, nor recover effectively from a systemic incident due to severe deficiencies in its backup and disaster recovery architecture.
