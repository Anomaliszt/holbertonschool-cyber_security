# MedDefense Health Systems: Structured Environment Summary

## 1. Organization Overview

### Sites and Locations
MedDefense Health Systems operates across three physical locations:

| Site Name | Location Type | Function | Approximate Headcount |
| :--- | :--- | :--- | :--- |
| **MedDefense Central Hospital** | Downtown | 350-bed acute care clinical facility, administrative departments, central server room. | ~1,400 (clinical + support) |
| **Westside Clinic** | Suburban | Outpatient clinic offering primary care, blood work, minor procedures, physical therapy, and diagnostic imaging (X-ray, ultrasound; no MRI). | ~180 |
| **Corporate HQ** | Leased Business Park | Administrative space housing executive leadership, IT department, Finance, HR, Legal, and Marketing. | ~220 |

### Departments (Relevant to Security/IT)
* **Clinical (Central):** Emergency, Surgery, Cardiology, Radiology, Oncology, Pediatrics, Maternity, Pharmacy, Laboratory.
* **Clinical (Westside):** Primary Care, Diagnostic Imaging, Blood Work, Physical Therapy.
* **Administrative/Support:** Administration, Finance, HR, Legal, Marketing, Executive Leadership.
* **IT & Security:** Managed out of Corporate HQ, consisting of 12 total staff members.

### Reporting and Leadership Structure
* **CEO:** Dr. Patricia Morales 
* **CISO Role:** Vacant. James Chen serves as the **Deputy CISO** (acting) and handles security policy. While he technically reports to the vacant CISO slot, in practice he reports directly to the CEO.
* **IT Operations:** Sarah Park serves as the **IT Director**. She is a peer to James Chen, meaning James has authority over security policy but zero operational authority over IT implementation, which is noted as a source of organizational friction.
* **IT Staff (Under Sarah Park):**
    * 3x System Administrators
    * 2x Network Technicians
    * 1x Database Administrator
    * 2x Helpdesk Analysts (including Mike Torres, Lead)
    * 2x Desktop Support Technicians
    * 1x IT Intern (vacant)
* **Security Analyst (You):** Reports directly to James Chen, Deputy CISO (replacing Marcus Webb).

---

## 2. IT Infrastructure Identified

### Servers

#### MedDefense Central Hospital (Basement Level Server Room)
* `ehr-srv-01`: Ubuntu 20.04 LTS; hosts the EHR Application Server.
* `ehr-db-01`: Ubuntu 20.04 LTS; hosts the EHR Database running PostgreSQL.
* `pacs-srv-01`: Windows Server 2016; PACS Imaging Server.
* `billing-srv-01`: Ubuntu 18.04 LTS; handles Billing/Claims Processing. Experiencing uninvestigated performance issues and was struck by ransomware in January.
* `ad-dc-01`: Windows Server 2019; Primary Domain Controller.
* `ad-dc-02`: Windows Server 2019; Secondary Domain Controller.
* `file-srv-01`: Windows Server 2016; hosts Department File Shares.
* `print-srv-01`: Windows Server 2012 R2 **[UNVERIFIED]**; Print Server. Operating past its October 2023 End of Support date.
* `backup-srv-01`: Ubuntu 22.04 LTS; Backup Server utilizing a Veeam agent.
* `web-srv-01`: Ubuntu 20.04 LTS; Public Website + Patient Portal (situated in the DMZ).
* **Local NAS:** Hardware appliance deployed in the same server room, rack, and network domain as production systems; target destination for nightly Veeam backups.

#### Westside Clinic (Local Server Closet)
* `ws-srv-01`: Windows Server 2016; local file server and appointment scheduling.

#### Corporate HQ
* *No on-premise servers.* Operates strictly on cloud services and remote connections.

### Network Devices
* **Central Hospital:**
    * 1x Fortinet FortiGate 100F firewall.
    * 1x Cisco core switch (exact model unknown).
    * 12x Cisco access switches (deployed as 2x per floor across 6 floors).
    * 12x Ubiquiti UniFi Wireless Access Points (APs).
* **Westside Clinic:**
    * 1x Consumer-grade Netgear Nighthawk router (terminates the IPSec VPN connection to Central).
    * 1x Unmanaged switch (brand/model unknown).
* **Corporate HQ:**
    * Infrastructure is owned and managed by the building landlord; MedDefense traffic is restricted to a dedicated landlord-configured VLAN. Connects via site-to-site VPN to Central.

### Endpoint Categories
* **Windows Workstations:** ~320 Windows 10 machines at Central, ~45 Windows 10 machines at Westside, and ~120 Windows 10/11 machines at HQ. (Data source: 8-month-old Active Directory report).
* **Laptops:** ~30 remote-capable laptops deployed at HQ.
* **Thin Clients:** ~60 thin clients deployed across clinical areas at Central.
* **Tablets:** ~25 iPads used by physicians for hospital rounds at Central.

### Medical Devices (IoT) & Operational Technology
* **Connected Patient Monitors:** ~80 Philips IntelliVue units deployed across Central.
* **Infusion Pumps:** ~120 network-connected BD Alaris units used for automated dosage updates.
* **MRI Scanner:** 1x Siemens MAGNETOM unit (Radiology Department, Central). Critical security note: Runs on an obsolete Windows XP operating system.
* **CT Scanner:** 1x GE Revolution unit (Central).
* **Nurse Call System:** IP-based system integrated directly into the facility's phone framework.
* **Badge/Physical Access System:** HID Global hardware, partially integrated with Active Directory for selective doors.

---

## 3. Data and Services

### Data Handled by MedDefense
* **Electronic Health Records (EHR) & Protected Health Information (PHI):** Medical histories, clinical notes, patient diagnostics, and pharmacy data.
* **Medical Imaging Data:** Radiology images, X-rays, ultrasound scans, and MRI data managed by the PACS system.
* **Financial & Billing Data:** Patient insurance information, claims data, billing histories, and transaction records.
* **Identity & Authentication Data:** Active Directory credentials, user permissions, and physical access badge control mappings.
* **Corporate Data:** Internal legal documents, HR records, financial budgets, and marketing assets.

### Critical IT-Dependent Services and Their Users

| Service | Infrastructure Dependency | Primary Users |
| :--- | :--- | :--- |
| **Clinical Charting & Data Entry** | `ehr-srv-01`, `ehr-db-01`, endpoints, thin clients, tablets | Physicians, Nurses, Clinical Staff |
| **Diagnostic Imaging Retrieval** | `pacs-srv-01`, PACS workstations, X-Ray/Ultrasound/MRI/CT hardware | Radiologists, Physicians, Technicians |
| **Patient Care & Monitoring** | Philips IntelliVue monitors, BD Alaris infusion pumps, Nurse Call IP System | Clinical Nursing Staff, Floor Physicians |
| **Claims & Financial Processing** | `billing-srv-01` | Finance Department, Billing Clerks |
| **Authentication & File Access** | `ad-dc-01`, `ad-dc-02`, `file-srv-01` | All internal organization staff |
| **Scheduling & Local Files (Westside)** | `ws-srv-01` | Westside outpatient administrative and clinical staff |
| **Public Portal & Website** | `web-srv-01` | Patients and the general public |
| **Corporate Communication** | Microsoft O365 suite, Corporate HQ site-to-site VPN | Executive Leadership, HR, Legal, Finance, IT |

---

## 4. Known Unknowns

The documentation reveals extensive gaps in asset management, configuration verification, network state, and administrative oversight. The specific discrepancies are classified below:

### Missing Asset and Configuration Data
* **The Unverified Westside Server:** Marcus Webb's notes point out that Mike Torres (Lead Helpdesk) mentioned a potential *second* server sitting in the Westside server closet, but its existence, OS, and purpose remain completely unverified.
* **Endpoint Counts:** The provided endpoint metrics (~570 total combined workstations, laptops, thin clients, and tablets) are derived from an Active Directory report that is 8 months out of date. The current exact numbers are unknown.
* **iPad Management:** It is entirely unconfirmed whether the 25 clinical iPads are enrolled in a Mobile Device Management (MDM) solution or left unmanaged.
* **CT Scanner OS:** The underlying operating system running the GE Revolution CT Scanner is undocumented.
* **Cisco Core Switch:** The exact hardware model and software/firmware version of the central core switch are unknown.
* **Westside Network Hardware:** The brand, model, and configuration capability of the unmanaged switch at Westside are unknown. The specific model line of the consumer Netgear Nighthawk router is also unspecified.
* **Westside WiFi:** There is no documentation regarding what wireless access points (if any) are running at the Westside Clinic.
* **Cloud Applications:** Aside from Microsoft O365, there is zero official inventory of shadow IT or individual cloud software platforms utilized by disparate corporate departments.

### System Verification and Operational Gaps
* **`print-srv-01` Status:** This legacy Windows Server 2012 R2 system is marked explicitly as `[UNVERIFIED]` and has not been physically or systematically confirmed in over a year.
* **Endpoint Protection Currency:** While Sophos is contracted for endpoint protection, the security team does not know if the agent is actively installed or running current definition updates across all corporate and clinical machines.
* **Vulnerability Landscapes:** No formal vulnerability assessment has ever been completed for the server infrastructure, and no formal threat landscape analysis exists.

### Network and Security Control Obscurities
* **Guest WiFi Isolation:** A separate SSID exists for Guest WiFi at Central, but its network isolation status has never been tested or verified.
* **VPN Access Controls:** The Access Control Lists (ACLs) governing the site-to-site VPN tunnel from Corporate HQ to Central have never been audited.
* **`billing-srv-01` Performance Flaws:** The root cause behind the recurring performance crashes on the billing server remains unknown; IT staff simply reboot it as a workaround.

### Compliance and Policy Absence
* **HIPAA Assessment Documentation:** No formal HIPAA Security Rule assessment has ever been performed, leaving the organization's true regulatory alignment unknown despite claims by Legal.
* **Incident Response, BC, and DR Plans:** There are no formal documentation materials or structured guidelines for Incident Response (the January ransomware attack was handled entirely ad-hoc). There are also no Business Continuity or Disaster Recovery plans indicating how clinical operations proceed if Central Hospital experiences an outage exceeding its 20-minute UPS capacity.
