# MedDefense Health Systems: Consolidated Master Asset Registry

## 1. Comprehensive Asset Registry

The following registry consolidates information across all project sources: the initial Environment Summary, Incident Logs, Physical Observations, Control Artifacts, the Legacy MRI Case Study, and the new Network Scan data.

| Asset ID | Name | Type | Location | Owner (Dept) | OS/Platform | Critical Services | Network Segment | Status | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **A-001** | `ehr-srv-01` | Server | Central Hospital | IT Operations | Ubuntu 20.04 LTS | EHR Application Server | 10.10.2.0/24 (Servers) | Active | Core clinical application. Hardened with key-only auth (Control C-004). |
| **A-002** | `ehr-db-01` | Server | Central Hospital | IT Operations | Ubuntu 20.04 LTS | PostgreSQL Database | 10.10.2.0/24 (Servers) | Active | Core relational database holding all primary PHI records. |
| **A-003** | `pacs-srv-01` | Server | Central Hospital | Radiology | Windows Server 2016 | PACS Imaging Engine | 10.10.2.0/24 (Servers) | Active | Excluded from nightly Veeam backups due to storage footprint constraints. |
| **A-004** | `billing-srv-01` | Server | Central Hospital | Finance / Billing | Ubuntu 18.04 LTS | Apache 2.4.29, MySQL | 10.10.2.0/24 (Servers) | Active | Target of Jan ransomware and crypto-miner (PID 8834). Highly vulnerable/EOL. |
| **A-005** | `ad-dc-01` | Server | Central Hospital | IT Operations | Windows Server 2019 | Active Directory, DNS | 10.10.2.0/24 (Servers) | Active | Primary Domain Controller. Enforces Group Policy password controls. |
| **A-006** | `ad-dc-02` | Server | Central Hospital | IT Operations | Windows Server 2019 | Active Directory Backup | 10.10.2.0/24 (Servers) | Active | Secondary DC. Not backed up by Veeam due to assumed "redundancy". |
| **A-007** | `file-srv-01` | Server | Central Hospital | Administration | Windows Server 2016 | SMB/Department Shares | 10.10.2.0/24 (Servers) | Active | Hosts corporate network shares. Shared a segment with the intern's laptop. |
| **A-008** | `print-srv-01` | Server | Central Hospital | IT Operations | Windows Server 2012 R2 | Print Spooler | 10.10.2.0/24 (Servers) | Deprecated | EOL since October 2023. Missing from active network scan verification. |
| **A-009** | `backup-srv-01` | Server | Central Hospital | IT Operations | Ubuntu 22.04 LTS | Veeam Backup Engine | 10.10.2.0/24 (Servers) | Active | Dedicated backup engine appliance running Veeam. |
| **A-010** | `NAS-01` | Data Store | Central Hospital | IT Operations | Synology DSM | Network Attached Storage | 10.10.2.0/24 (Servers) | Active | Synology DS1621+ RAID5 target for backups. Colocated in the same server rack row. |
| **A-011** | `web-srv-01` | Server | Central Hospital | Marketing / IT | Ubuntu 20.04 LTS | HTTP/HTTPS (Patient Portal) | 10.10.254.0/24 (DMZ) | Active | Public-facing web server. Defaced in April; houses the broken patient portal. |
| **A-012** | `ws-srv-01` | Server | Westside Clinic | Westside Admin | Windows Server 2016 | File Share / Scheduling | 10.20.1.0/24 (Westside) | Active | Main local infrastructure for outpatient branch. Excluded from Veeam. |
| **A-013** | `ws-srv-02` | Server | Westside Clinic | Unknown | Windows Server 2012 R2 | SMB/File Services | 10.20.1.0/24 (Westside) | Shadow IT | The "unverified second server" hinted at by helpdesk. Unmanaged and unpatched. |
| **A-014** | `FW-01` | Network Device | Central Hospital | IT Operations | FortiOS (FortiGate 100F) | Perimeter Firewall, VPN | Network Boundaries | Active | Coordinates WAN boundaries and terminates site-to-site VPN tunnels. |
| **A-015** | `Core-SW-01` | Network Device | Central Hospital | IT Operations | Cisco IOS | Core Routing / Switching | Core Infrastructure | Active | Main network core switch bridging all hospital segments. Firmware unverified. |
| **A-016** | `RTR-01` | Network Device | Westside Clinic | Westside Admin | Netgear Nighthawk | Gateway / IPSec VPN | Westside Boundary | Active | Consumer-grade perimeter router terminating the IPSec VPN to Central. |
| **A-017** | `MRI-MAGNETOM` | IoT Medical | Central Hospital | Radiology | Windows XP Embedded | Siemens Control Terminal | 10.10.3.0/24 (Workstations) | Active | $2.1M scanner running EOL OS. Flat network risk. Connected to port MED-3F-12. |
| **A-018** | `Vitals-Mon-01` | IoT Medical | Central Hospital | Clinical Nursing | Proprietary (v2.1.3, 2019) | Patient Vitals Feed | 10.10.3.47 (Workstations) | Active | ~80 network-connected units. Displays active IP/firmware directly in rooms. |
| **A-019** | `Infusion-Alaris` | IoT Medical | Central Hospital | Pharmacy / Nursing | Linux Embedded | Automated Medication Dosage | 10.10.3.0/24 (Workstations) | Active | ~120 network-connected BD Alaris automated pump endpoints. |
| **A-020** | `Workstations (Gen)`| Endpoint | Multiple Sites | All Departments | Windows 10 / 11 | General Productivity, EHR | Multiple Subnets | Active | ~485 desktop environments. Active Directory report is 8 months stale. |
| **A-021** | `Intern-Laptop` | Endpoint | Central Hospital | Unmanaged (Personal) | Windows 10 / P2P Client | File Torrenting Client | 10.10.1.0/24 (Internal HQ) | Shadow IT | Discovered running torrent software on the internal network segment for 3 weeks. |
| **A-022** | `Clinical-iPads` | Endpoint | Central Hospital | Clinical Nursing | iOS | Mobile Clinical Rounding | Wireless Infrastructure | Unknown | 25 tablets used for rounds. No MDM profile configuration tracking confirmed. |

---

## 2. Reconciliation & Gap Analysis Notes

### Shadows & Hidden Infrastructure (Found in Scan, Missing from Docs)
* **`ws-srv-02` (The Ghost Server Verified):** The network scan flags an active machine response (`10.20.1.12`) out of the Westside Clinic server closet running an outdated instance of Windows Server 2012 R2 with open file-sharing ports. This directly confirms Marcus's notes regarding a rumored second server. It is unpatched, unmonitored, and operates entirely as **Shadow IT**.
* **IT Intern Laptop Network Exposure:** The network scan and logs validate that an unmanaged personal device bypassed endpoint profiling controls and attached directly to the internal broadcast domain (`10.10.1.0/24`) for three full weeks rather than being restricted to the isolated Guest Wi-Fi network.

### Missing & Ghost Infrastructure (In Docs, Missing from Scan)
* **`print-srv-01` Absolute Absence:** This legacy Windows Server 2012 R2 print server was explicitly documented as an operational system component but failed to respond across any scanned IP subnets. It is either completely offline, decommissioned without update tracking, or inaccessible due to a physical hardware breakdown.
* **15 Non-Reporting Sophos Endpoints:** The Sophos administrative report notes 15 registered machines failing to pass heartbeat checks for over 14–30 days. These devices failed to show up in the active network scan, suggesting asset loss, theft, or untracked off-network decommissioning.

### Structural Source Discrepancies & Contradictions
* **Stale Active Directory Metrics:** The official system documentation claims ~570 client endpoints across the enterprise. However, this count is derived from an 8-month-old AD export. It directly contradicts the live Sophos Central deployment report, which registers only 387 total managed, licensed endpoints, exposing a tracking discrepancy of nearly **180 endpoints**.
* **The Server Backup Paradox:** The IT administration notes claim "Microsoft handles" all Office 365 protection models. This reflects a fundamental misunderstanding of the cloud Shared Responsibility Model; MedDefense currently maintains no actual administrative backups of emails, SharePoint, or OneDrive records. 
* **The Software Support License Illusion:** The asset audit reveals that while management assumes Sophos covers the entire infrastructure, the actual license tier completely excludes all 15 core Windows production servers and all Ubuntu Linux databases due to unapproved budget requests.
