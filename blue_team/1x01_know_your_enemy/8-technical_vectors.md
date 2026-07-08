# Technical Vector Assessment — MedDefense

## Overview

Technical attack vectors are non-human methods that adversaries use to gain access, establish persistence, move laterally, or compromise systems. Based on the Project 1x00 Network Scan Summary and security posture assessment, MedDefense exhibits multiple technical vectors that align with the Security+ (2.2) framework.

---

# 1. Vulnerable Software

**Vector Category:** Vulnerable Software

**MedDefense Evidence:**

- Apache **2.4.29** running on `billing-srv-01` with known Remote Code Execution (RCE) vulnerabilities.
- **Ubuntu 18.04 LTS** (End-of-Life) supporting Internet-facing services.
- Multiple systems operating with delayed security patch cycles.

**Affected Asset(s):**

- `billing-srv-01`
- Internet-facing Apache web server
- Ubuntu application servers

**Actor Most Likely to Exploit:**

- **Ransomware Groups (Organized Crime / RaaS)**
- **Unskilled / Opportunistic Attackers**

**Exploitation Scenario:**

An attacker performs automated Internet scanning and identifies the vulnerable Apache server. Using a publicly available exploit for the known RCE vulnerability, they gain an initial foothold, establish persistence, and begin lateral movement toward the EHR environment before deploying ransomware or stealing sensitive data.

**Current Protection:**

- Perimeter firewall
- Routine patch management process (not consistently applied)

**Gap Reference:**

- **G1:** Unpatched public-facing systems
- **G15:** Vulnerability management deficiencies

---

# 2. Unsupported Systems

**Vector Category:** Unsupported Systems

**MedDefense Evidence:**

- Windows XP workstation supporting the MRI scanner.
- Windows Server 2012 R2 on `print-srv-01`, approaching or beyond vendor support lifecycle.

**Affected Asset(s):**

- MRI workstation
- `print-srv-01`
- Legacy medical device environment

**Actor Most Likely to Exploit:**

- **Ransomware Groups**
- **Nation-State APT**
- **Unskilled / Opportunistic Attackers**

**Exploitation Scenario:**

Legacy operating systems lack modern security updates and are vulnerable to well-known exploits. After gaining internal access, an attacker targets these unsupported systems to establish persistence or pivot into other clinical systems with minimal resistance.

**Current Protection:**

- Limited network firewall controls
- Vendor maintenance procedures for medical devices

**Gap Reference:**

- **G1:** Legacy and unsupported systems
- **G2:** Lack of network segmentation

---

# 3. Open Service Ports

**Vector Category:** Open Service Ports

**MedDefense Evidence:**

- MySQL (TCP **3306**) on `billing-srv-01` accessible throughout the internal network.
- PostgreSQL (TCP **5432**) on `ehr-db-01` accessible network-wide.
- RDP enabled on selected workstations.
- Medical IoT web management interfaces exposed internally.

**Affected Asset(s):**

- `billing-srv-01`
- `ehr-db-01`
- Administrative workstations
- Medical IoT devices
- Internal database servers

**Actor Most Likely to Exploit:**

- **Ransomware Groups**
- **Malicious Insider**
- **Opportunistic Attackers**

**Exploitation Scenario:**

Following an initial compromise, attackers enumerate internal services and discover unrestricted database ports and management interfaces. In the absence of segmentation, they connect directly to databases, harvest sensitive information, and move laterally to additional systems.

**Current Protection:**

- Internal firewall policies
- Standard authentication controls

**Gap Reference:**

- **G2:** Flat network architecture
- **G3:** Limited monitoring of internal traffic

---

# 4. Default Credentials

**Vector Category:** Default Credentials

**MedDefense Evidence:**

- Shared PACS administrative account.
- Default credentials present on BD Alaris pump management interfaces.
- Shared departmental accounts within clinical environments.

**Affected Asset(s):**

- PACS imaging systems
- Medical IoT devices
- Clinical support systems

**Actor Most Likely to Exploit:**

- **Malicious Insider**
- **Ransomware Groups**
- **Opportunistic Attackers**

**Exploitation Scenario:**

An attacker discovers default or shared credentials during internal reconnaissance and logs into imaging systems or medical devices without triggering account-specific auditing. This allows privilege escalation, unauthorized configuration changes, or further movement toward critical systems.

**Current Protection:**

- Password policies
- Basic authentication mechanisms

**Gap Reference:**

- **G7:** Shared accounts
- **G11:** Weak credential management

---

# 5. Unsecure Networks

**Vector Category:** Unsecure Networks

**MedDefense Evidence:**

- Flat internal network with no segmentation between clinical, administrative, billing, and medical device environments.
- Consumer-grade router deployed at the Westside facility.
- Uncertainty regarding wireless client isolation and guest network separation.

**Affected Asset(s):**

- Entire MedDefense enterprise network
- Clinical systems
- Medical devices
- Administrative systems
- Wireless infrastructure

**Actor Most Likely to Exploit:**

- **Ransomware Groups**
- **Nation-State APT**
- **Opportunistic Attackers**

**Exploitation Scenario:**

After compromising a single workstation or VPN account, an attacker encounters minimal internal barriers. They freely enumerate systems, access sensitive servers, compromise domain controllers, and spread ransomware across the enterprise without being restricted by network segmentation.

**Current Protection:**

- Perimeter firewall
- VLAN implementation in limited areas

**Gap Reference:**

- **G2:** Flat network architecture
- **G14:** Network infrastructure weaknesses

---

# 6. Removable Devices / Unmanaged Endpoints

**Vector Category:** Removable Devices / Unmanaged Endpoints

**MedDefense Evidence:**

- No Group Policy restrictions preventing USB storage device usage.
- Unmanaged iPads connected to the environment.
- Shadow IT devices introduced without formal approval (e.g., Raspberry Pi).
- Personally owned devices operating outside centralized endpoint management.

**Affected Asset(s):**

- Clinical workstations
- Administrative workstations
- Mobile devices
- Internal network

**Actor Most Likely to Exploit:**

- **Negligent Insider**
- **Malicious Insider**
- **Opportunistic Attackers**

**Exploitation Scenario:**

An employee connects an infected USB device or unmanaged endpoint to the corporate network. Malware is introduced into the environment, allowing attackers to establish persistence, steal credentials, or pivot to high-value systems while bypassing centrally managed security controls.

**Current Protection:**

- Endpoint antivirus on managed devices
- Acceptable Use Policy

**Gap Reference:**

- **G7:** Shadow IT
- **G8:** Security awareness deficiencies
- **G12:** Endpoint management weaknesses

---

# Overall Assessment

The **highest-risk technical vector** for MedDefense is the combination of **vulnerable software and an unsecure internal network**. Public-facing systems running outdated software provide attackers with realistic initial access opportunities, while the flat network architecture enables unrestricted lateral movement once inside. Legacy operating systems, exposed service ports, default credentials, and unmanaged endpoints further expand the attack surface and significantly increase the likelihood that a single compromise could escalate into a full-scale ransomware incident or widespread compromise of patient care systems.
