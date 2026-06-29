# MedDefense Health Systems: Shadow IT Assessment & Governance Strategy

## 1. Shadow IT Risk Profiles & Management Protocols

### System 1: Dr. Patel’s Personal Office NAS Drive
* **Risk Assessment:**
    * **Sensitive Data Exposure:** Contains clinical research records, patient case notes, historical medical analytics, and potentially raw Protected Health Information (PHI) bypassed from the hospital's official network paths.
    * **Missing Controls:** Operates entirely outside of **C-005** (AD Password Complexity Enforcement), **C-007** (Sophos Endpoint Protection), and **C-008** (Nightly Veeam VM Backups). It is a completely unmonitored storage node.
    * **Worst-Case Scenario:** An external attacker compromises the unpatched NAS over the flat network, uses it to steal years of clinical research data (causing a severe data breach), and permanently encrypts the files with ransomware, destroying the data because no backups exist.
* **Recommended Response:** **Migrate**
    * *Justification:* Keeping a retail-grade personal storage device attached directly to a clinical wall port presents an unmanaged physical and technical risk that violates HIPAA regulations. The data must be securely migrated to an encrypted, managed storage tier on `file-srv-01` or an enterprise-grade cloud repository. Once verified, the physical hardware must be disconnected.

---

### System 2: Marketing Team’s Shared Google Drive (Personal Gmail)
* **Risk Assessment:**
    * **Sensitive Data Exposure:** Houses internal hospital press communications, upcoming marketing campaigns, corporate media assets, and potentially unredacted patient testimonials or authorization forms.
    * **Missing Controls:** Bypasses **C-005** and **C-006** (Active Directory identity management, multi-factor authentication, and lockout boundaries). It is governed completely by a personal, unmonitored external account.
    * **Worst-Case Scenario:** The personal Gmail account is compromised via credential stuffing or phishing. The attacker gains full read/write access to the Google Drive, leaks sensitive corporate internal documents, and uses the platform to host phishing landing pages disguised under MedDefense's branding.
* **Recommended Response:** **Migrate**
    * *Justification:* Marketing requires cloud collaboration tools to do their jobs effectively, but using a personal account breaks compliance boundaries. The entire data repository must be moved over to an enterprise-managed platform (such as a corporate Microsoft OneDrive or Google Workspace account) that enforces Single Sign-On (SSO), corporate password rules, and administrative monitoring.

---

### System 3: Abandoned Intern Raspberry Pi (Second Floor Network Monitor)
* **Risk Assessment:**
    * **Sensitive Data Exposure:** Provides raw access to internal network packets, network monitoring configurations, and potentially unencrypted local traffic logs or system credentials captured from the flat network domain.
    * **Missing Controls:** Completely misses **C-004** (Hardened SSH access restrictions) and **C-007** (Sophos Endpoint Protection), and lacks any physical access monitoring or visibility under **C-013**.
    * **Worst-Case Scenario:** An attacker identifies the unpatched, abandoned Linux micro-appliance running with default credentials over the network. They hijack the device and turn it into a persistent, hidden backdoor inside the production network segment, allowing them to sniff unencrypted traffic or launch lateral attacks completely undetected.
* **Recommended Response:** **Decommission**
    * *Justification:* The device is unmanaged, has had no software maintenance for months, and lacks a designated owner. Because its original monitoring goal is unverified and unmaintained, it presents a serious network threat. The device must be physically found, unplugged, and safely wiped.

---

## 2. Asset Registry Expansion (Shadow IT Nodes)

| Asset ID | Name | Type | Location | Owner (Dept) | OS/Platform | Critical Services | Network Segment | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **A-023** | `patel-office-nas` | Data Store | Central Hospital (Office) | Cardiology (Dr. Patel) | Embedded Linux / Consumer | Local File Storage (SMB) | 10.10.3.0/24 (Workstations) | **Shadow IT** | Personal NAS drive plugged into local office wall port. Unbacked and unmonitored. |
| **A-024** | `mktg-gdrive` | Application | Public Cloud | Marketing | Google Cloud App | Document Sharing / Media | External (Public Cloud) | **Shadow IT** | Shared media folder linked to an employee's personal Gmail account. |
| **A-025** | `intern-pi-mon` | Network Device | Central Hospital (2nd Floor) | IT Operations (Legacy) | Raspberry Pi OS | Legacy Network Monitor | 10.10.3.0/24 (Workstations) | **Shadow IT** | Abandoned micro-appliance. Placed by a former intern; lacks an active maintainer. |

---

## 3. Strategic Shadow IT Policy Recommendation

To reduce the likelihood of future Shadow IT deployments across the enterprise, MedDefense must implement an automated **Network Access Control (NAC) policy combined with strict port-security enforcement.** Instead of relying solely on users following written policies, this technical control uses the core network infrastructure to actively enforce compliance. The network switch ports must be configured to drop connections from unauthorized MAC addresses immediately, while the corporate wireless system must quarantine unknown endpoints into an isolated guest network. By programmatically preventing unmanaged personal storage devices, unauthorized micro-appliances, or personal routers from communicating with internal network subnets, MedDefense can prevent data silos and shadow infrastructure from appearing, forcing departments to request vetted IT solutions through official review channels.
