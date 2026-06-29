# MedDefense Health Systems: Security Controls Inventory & Structural Assessment

## 1. Security Controls Inventory

### Technical Controls

#### Control ID: C-001
* **Control Name:** Inbound DMZ Traffic Filtering
* **Description:** Restricts external, untrusted traffic coming from the WAN interface (`wan1`) to the public web server (`web-srv-01`) specifically to standard web traffic protocols over ports 80 (HTTP) and 443 (HTTPS).
* **Category:** Technical
* **Function:** Preventive
* **Asset(s) Protected:** `web-srv-01` (Public Website + Patient Portal)
* **Source:** Artifact 1: Firewall Configuration Extract (Rule 1)

#### Control ID: C-002
* **Control Name:** Site-to-Site VPN Firewalled Interconnects
* **Description:** Configures explicit firewall pathways on the FortiGate 100F to accept incoming data from remote site-to-site VPN interfaces (`vpn-westside` and `vpn-hq`) to route from remote subnets exclusively into the internal server subnet.
* **Category:** Technical
* **Function:** Preventive
* **Asset(s) Protected:** Internal Central Hospital Server Subnet
* **Source:** Artifact 1: Firewall Configuration Extract (Rules 2 and 3)

#### Control ID: C-003
* **Control Name:** Default-Deny Firewall Policy
* **Description:** Implements a final catch-all security boundary rule that drops all traffic between any source and destination interface that has not been explicitly authorized by preceding firewall policies.
* **Category:** Technical
* **Function:** Preventive
* **Asset(s) Protected:** All internal network segments and assets
* **Source:** Artifact 1: Firewall Configuration Extract (Rule 5)

#### Control ID: C-004
* **Control Name:** Hardened SSH Remote Access Policy
* **Description:** Hardens SSH endpoints on `ehr-srv-01` by explicitly prohibiting root user logins (`PermitRootLogin no`), disabling legacy password-based authentication (`PasswordAuthentication no`), enforcing cryptographic key authentication (`PubkeyAuthentication yes`), and setting a low authentication threshold (`MaxAuthTries 3`).
* **Category:** Technical
* **Function:** Preventive
* **Asset(s) Protected:** `ehr-srv-01` (EHR Application Server)
* **Source:** Artifact 2: SSH Configuration

#### Control ID: C-005
* **Control Name:** Active Directory Enforced Password Complexities
* **Description:** Automates password security settings via Windows Active Directory Group Policy to require a minimum length of 8 characters, multi-character complexity parameters, a 90-day mandatory rotation schedule, and a rolling historical retention block of the last 5 configurations.
* **Category:** Technical
* **Function:** Preventive
* **Asset(s) Protected:** All Windows-joined domain assets and accounts
* **Source:** Artifact 3: Password Policy (Sections 2 & 5)

#### Control ID: C-006
* **Control Name:** Automated Account Lockout Policy
* **Description:** Programmatically locks user accounts across Active Directory for a duration of 30 minutes if 5 consecutive invalid login attempts occur within a tracking window.
* **Category:** Technical
* **Function:** Preventive
* **Asset(s) Protected:** Domain Accounts / Active Directory Identity Management
* **Source:** Artifact 3: Password Policy (Sections 2 & 5)

#### Control ID: C-007
* **Control Name:** Host-Based Antivirus and Endpoint Protection
* **Description:** Deploys Sophos Endpoint Protection on managed Windows workstations and select servers to scan file states, block malware, and isolate identified security threats.
* **Category:** Technical
* **Function:** Preventive / Detective
* **Asset(s) Protected:** 372 Windows Workstations and 15 Windows Servers
* **Source:** Artifact 4: Sophos Antivirus Status Report

#### Control ID: C-008
* **Control Name:** Nightly Virtual Machine Backups
* **Description:** Executes an automated full-image backup process every night at 02:00 AM using Veeam Backup & Replication software, retaining images for 14 days.
* **Category:** Technical
* **Function:** Corrective
* **Asset(s) Protected:** `ehr-srv-01`, `ehr-db-01`, `billing-srv-01`, `ad-dc-01`, `file-srv-01`, and `web-srv-01`
* **Source:** Artifact 5: Backup Configuration

#### Control ID: C-009
* **Control Name:** Local Linux Syslog Generation
* **Description:** Captures internal operating system activities and authentication events on Linux appliances using local syslog subroutines running at a `VERBOSE` log level.
* **Category:** Technical
* **Function:** Detective
* **Asset(s) Protected:** Linux Server Operating Systems (e.g., `ehr-srv-01`)
* **Source:** Artifact 2: SSH Configuration / Artifact 8: Log Management

---

### Administrative Controls

#### Control ID: C-010
* **Control Name:** Information Security Password Policy
* **Description:** Standardizes authentication requirements, shared account guidelines, and policy governance across corporate staff via a formal corporate policy approved by leadership.
* **Category:** Administrative
* **Function:** Preventive
* **Asset(s) Protected:** Corporate Information Systems / System Credentials
* **Source:** Artifact 3: Password Policy

#### Control ID: C-011
* **Control Name:** Mandatory Security Awareness Training
* **Description:** Administers a mandatory 45-minute annual online educational seminar ("CyberSafe Basics") instructing employees on how to manage password hygiene, identify phishing scams, and notice tailgating threats.
* **Category:** Administrative
* **Function:** Preventive
* **Asset(s) Protected:** Human layer / All corporate data spaces
* **Source:** Artifact 7: Training Records

---

### Physical Controls

#### Control ID: C-012
* **Control Name:** Main Entrance Lobby Security Guard
* **Description:** Restricts physical entrance access to MedDefense Central Hospital by stationing a single contracted security guard at the main lobby entrance from Monday to Friday (07:00 to 19:00) to verify badges and sign in visitors.
* **Category:** Physical
* **Function:** Preventive / Detective
* **Asset(s) Protected:** MedDefense Central Hospital Facility (Main entrance perimeter)
* **Source:** Artifact 6: Physical Security Contract

#### Control ID: C-013
* **Control Name:** Standalone Closed-Circuit Television (CCTV) System
* **Description:** Records visual footage using local analog cameras focused on high-traffic external perimeters (main doors, ER lobby, parking garage entrances), saving data onto a local DVR with a rolling 30-day overwriting format.
* **Category:** Physical
* **Function:** Detective
* **Asset(s) Protected:** Central Hospital Perimeters and Westside Front Entrance
* **Source:** Artifact 6: Physical Security Contract (Camera System)

---

## 2. Control Summary Matrix

| Category | Preventive | Detective | Corrective | Compensating | Deterrent |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Technical** | C-001, C-002, C-003, C-004, C-005, C-006, C-007 | C-007, C-009 | C-008 | *None* | *None* |
| **Administrative** | C-010, C-011 | *None* | *None* | *None* | *None* |
| **Physical** | C-012 | C-012, C-013 | *None* | *None* | *None* |

> ### Key Security Gap Observations from Matrix Analysis:
> * **Zero Explicit Deterrent Controls:** There are no documented deterrent controls (such as legal warning banners on login interfaces, clear physical property warning signs, or visible notice displays over restricted facility spaces).
> * **Zero Formal Compensating Controls:** The organization lacks alternative engineering measures to cover vulnerable legacy systems, such as isolating the unpatched Windows XP operating system powering the critical Siemens MRI appliance.
> * **Substantial Deficiencies in Administrative and Physical Detection/Correction:** No administrative discovery protocols exist (such as active credential audits or compliance logs). Similarly, there are no physical restoration capabilities or guard backup procedures documented to address off-hours security incidents.
