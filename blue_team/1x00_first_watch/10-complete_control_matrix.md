# MedDefense Health Systems: Master Control Inventory & Strategic Coverage Map

## Part 1: Comprehensive Control Registry

This authoritative register consolidates all controls identified throughout this assessment, including baseline configurations, physical security elements, and engineered compensating controls.

| Control ID | Control Name | Category | Function | Asset(s) Protected | Effectiveness | Evidence / Source |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **C-001** | Inbound DMZ Traffic Filtering | Technical | Preventive | `web-srv-01` | **Adequate** | Artifact 1 (Firewall Rule 1). Effectively limits web ports but does not inspect application-layer input validation flaws. |
| **C-002** | Site-to-Site VPN Interconnects | Technical | Preventive | Internal Server Subnet | **Weak** | Artifact 1 (Firewall Rules 2 & 3). Overly permissive (`service ALL`) settings allow lateral spread from remote sites. |
| **C-003** | Default-Deny Firewall Policy | Technical | Preventive | All Internal Subnets | **Strong** | Artifact 1 (Firewall Rule 5). Standard, hardened clean-up rule securely drops unmapped incoming connections. |
| **C-004** | Hardened SSH Access Policy | Technical | Preventive | `ehr-srv-01` | **Strong** | Artifact 2. Enforces key-only authentication, disables root, and limits maximum tries strictly to 3. |
| **C-005** | AD Enforced Password Complexity | Technical | Preventive | Active Directory Domain | **Strong** | Artifact 3 (Section 2 & 5). Enforced programmatically via Group Policy Objects (GPO) for Windows systems. |
| **C-006** | Automated Account Lockout Policy | Technical | Preventive | Active Directory Identities | **Strong** | Artifact 3 (Section 2 & 5). Successfully blocks brute-force attacks via a 30-minute lockdown after 5 failures. |
| **C-007** | Endpoint Antivirus Protection | Technical | Preventive / Detective | Windows Workstations | **Adequate** | Artifact 4. Strong workstation footprint, but completely unpurchased for Windows/Linux servers. |
| **C-008** | Nightly Virtual Machine Backups | Technical | Corrective | Core Virtual Servers | **Weak** | Artifact 5. Retained for 14 days, but unencrypted, untested for DR, and omits critical nodes like PACS. |
| **C-009** | Local Linux Syslog Generation | Technical | Detective | Linux Server Fleet | **Weak** | Artifact 2 / Artifact 8. Generates verbose internal logs locally, but lacks centralization or active alerts. |
| **C-010** | Corporate Password Policy | Administrative | Preventive | Enterprise Staff | **Adequate** | Artifact 3. Well-defined guidelines, but contains an 18-month stale review stamp and permits shared profiles. |
| **C-011** | Mandatory Security Awareness | Administrative | Preventive | Human Infrastructure | **Weak** | Artifact 7. Low completion rates among clinical staff (71% Central, 58% Westside) and completely generic content. |
| **C-012** | Main Entrance Lobby Guard | Physical | Preventive / Detective | Central Hospital Perimeter | **Adequate** | Artifact 6. Dependable weekday presence, but leaves the facility exposed during nights, weekends, and internal wings. |
| **C-013** | Standalone Perimeter CCTV | Physical | Detective | Exterior Hospital Perimeters | **Weak** | Artifact 6. Analog DVR system overwrites every 30 days and entirely lacks visibility into server rooms/closets. |
| **C-014** | Network Micro-Segmentation (Proposed) | Technical | Compensating | `MRI-MAGNETOM` | **Strong** | Engineered in Task 6. Isolates legacy asset into an explicit VLAN, allowing access *only* to the PACS engine over port 104. |
| **C-015** | Hardware Interface Isolation (Proposed) | Technical / Physical | Compensating | `MRI-MAGNETOM` | **Strong** | Engineered in Task 6. Programmatically disables USB drivers and physically locks physical chassis ports. |
| **C-016** | Explicit Access Auditing (Proposed) | Administrative | Compensating / Detective | `MRI-MAGNETOM` | **Adequate** | Engineered in Task 6. Mandates individual AD credentials coupled with a physical signature logbook. |

---

## Part 2: Updated Control Summary Matrix

This matrix charts the structural distribution of MedDefense’s assets. Each cell displays the **Total Control Count** alongside an **Average Effectiveness Rating**.

| Category | Preventive | Detective | Corrective | Compensating | Deterrent |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Technical** | **7 Controls** <br>*(Avg: Adequate)* | **2 Controls** <br>*(Avg: Weak)* | **1 Control** <br>*(Avg: Weak)* | **2 Controls** <br>*(Avg: Strong)* | **0 Controls** <br>*(N/A)* |
| **Administrative** | **2 Controls** <br>*(Avg: Adequate)* | **0 Controls** <br>*(N/A)* | **0 Controls** <br>*(N/A)* | **1 Control** <br>*(Avg: Adequate)* | **0 Controls** <br>*(N/A)* |
| **Physical** | **1 Control** <br>*(Avg: Adequate)* | **2 Controls** <br>*(Avg: Weak)* | **0 Controls** <br>*(N/A)* | **1 Control** <br>*(Avg: Strong)* | **0 Controls** <br>*(N/A)* |

---

## Part 3: Control Coverage Map

This matrix maps security capabilities specifically against the organization's **Top 5 Most Critical Assets** to highlight missing security domains.

| Critical Asset | Preventive Controls | Detective Controls | Corrective Controls | Compensating Controls | Coverage Assessment |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. `ehr-db-01`** <br>*(Core EHR Database)* | C-003 (Firewall Clean-up), <br>C-005 (AD Password) | *None* (No network alert engines or SIEM) | C-008 (Nightly Veeam VM Backups) | *None* | **Under-Protected** <br>While baseline password structures and a firewall exist, the database lacks any real-time internal monitoring or threat alerting, making it blind to insider manipulation or lateral compromise. |
| **2. `FW-01`** <br>*(FortiGate Firewall)* | C-003 (Default Deny Policy) | C-012 (Lobby Guard physical barrier) | *None* (No configuration tracking backups) | *None* | **Partially Protected** <br>The firewall effectively manages boundary rules, but its internal configurations allow overly permissive traffic (C-002), and its log structures remain unmonitored and decentralized. |
| **3. `ehr-srv-01`** <br>*(Core EHR App Server)* | C-004 (Hardened SSH keys), <br>C-005 (AD Password) | C-009 (Local OS Syslog generation) | C-008 (Nightly Veeam VM Backups) | *None* | **Well-Protected** <br>This is the most secure system in the inventory. It benefits from cryptographic key-only authentication, access throttling, and inclusion in nightly backup loops. |
| **4. `NAS-01`** <br>*(Synology Backup Target)* | C-003 (Perimeter Firewall) | *None* | *None* | *None* | **Under-Protected** <br>Highly vulnerable to ransomware. It sits unsegmented on the same server network tier, completely lacks endpoint agent monitoring, and contains unencrypted files with no secondary off-site replication link. |
| **5. `pacs-srv-01`** <br>*(PACS Imaging Engine)* | C-003 (Perimeter Firewall) | *None* | *None* (Explicitly skipped by Veeam backups) | *None* | **Unprotected** <br>Despite holding millions of dollars in critical patient diagnostic visual imagery, this server is skipped during backup jobs and operates completely unmonitored on a flat network domain. |
