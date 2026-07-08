# MedDefense Attack Surface Map

## Overview

An **attack surface** includes every point where an attacker can interact with MedDefense's systems, data, or personnel. It consists of three primary dimensions:

1. **External Surface** — Internet-accessible systems
2. **Internal Surface** — Systems reachable after obtaining network access
3. **Human Surface** — Employees, contractors, and trusted users who can be targeted through social engineering

This assessment references the **Project 1x00 Network Scan Summary, Asset Registry, Control Matrix, and documented security gaps.**

---

# Section 1 – External Attack Surface

| Entry Point | Asset Behind It | Existing Protection (1x00 Controls) | Documented Gap (1x00) |
|-------------|-----------------|--------------------------------------|-----------------------|
| **Patient Portal (`web-srv-01`)** | Public patient portal providing appointment scheduling and patient access to health information | HTTPS/TLS, web authentication, perimeter firewall | **G1:** Public-facing server requires timely patching and hardening against web application attacks. |
| **VPN Endpoint (FortiGate 100F)** | Remote access gateway for employees and vendors | VPN authentication, firewall access policies, MFA (where implemented) | **G1:** Delayed firmware patching exposes the VPN to known vulnerabilities. |
| **Microsoft 365 (O365 / Entra ID)** | Email, SharePoint, OneDrive, cloud identity services | Microsoft cloud security controls, authentication policies, conditional access (where configured) | **G6:** Identity security depends on proper MFA enforcement and privileged account protection. |
| **Public Website** | Corporate information and public communications | Firewall protection, HTTPS | **G13:** Public web services remain susceptible to web application attacks and defacement if not continuously maintained. |
| **Public DNS Services** | Domain name resolution for MedDefense Internet services | Managed DNS infrastructure | **G13:** DNS infrastructure may be abused through phishing, typosquatting, or domain spoofing if monitoring is insufficient. |
| **Apache Server (`billing-srv-01`)** | Billing application accessible from the Internet | Firewall filtering | **G1:** Known Remote Code Execution (RCE) vulnerabilities remain unpatched, providing a direct initial access path. |
| **Vendor Remote Access Services** | Third-party maintenance connections (e.g., MedTech Solutions) | Vendor agreements, remote access controls | **G5:** Trusted vendor connectivity increases supply chain exposure if vendor credentials are compromised. |

---

# Section 2 – Internal Attack Surface

**Key Finding:**  
The most significant internal exposure identified in Project 1x00 is the **flat network architecture**. Once an attacker gains an initial foothold, there are minimal internal barriers preventing movement between administrative, clinical, billing, and medical device systems.

| Asset | Exposure (Network Scan) | Why This Matters in a Flat Network |
|-------|--------------------------|------------------------------------|
| **`billing-srv-01`** | MySQL service accessible across the internal network | Attackers can directly access billing databases after compromising any internal host, increasing the risk of financial data theft and lateral movement. |
| **`ehr-db-01`** | PostgreSQL database accessible network-wide | Direct access to the EHR database increases the likelihood of patient data theft or ransomware deployment if internal credentials are compromised. |
| **Network-Attached Storage (NAS)** | Administrative management interface reachable internally | Attackers can locate and encrypt backups, eliminating recovery options before deploying ransomware. |
| **FortiGate Administrative Interface** | Internal management interface | If administrator credentials are stolen, attackers can modify firewall policies, create VPN accounts, or disable security protections. |
| **Medical IoT Device Web Interfaces** | HTTP/HTTPS management interfaces | Many medical devices expose management portals that provide administrative access to clinical equipment. |
| **PACS Imaging Systems** | Default administrative credentials identified | Default credentials provide attackers with immediate administrative access to imaging infrastructure and potentially patient imaging records. |
| **Medical IoT Devices** | Default usernames and passwords | Default credentials are widely documented and frequently exploited during automated attacks. |
| **Windows XP MRI Workstation** | Legacy operating system | Unsupported software cannot receive modern security patches, making exploitation significantly easier. |
| **Windows Server 2012 R2 Systems** | Legacy operating system | End-of-support systems present elevated risk due to limited security updates and known vulnerabilities. |
| **Entire Internal Network** | No network segmentation | A compromise of a single workstation can allow unrestricted lateral movement to domain controllers, EHR systems, billing servers, backup systems, and medical devices. |

---

# Section 3 – Human Attack Surface

| Role | Access Level | Why They Are Targetable | Control / Training Gap (1x00) |
|------|--------------|-------------------------|-------------------------------|
| **Clinical Staff (Doctors and Nurses)** | EHR systems, patient records, clinical applications | Operate under constant time pressure, prioritize patient care, and are frequent targets for phishing, vishing, and credential theft. | **G8:** Low security awareness training completion.<br>**G11:** Weak credential practices. |
| **Reception Staff** | Appointment scheduling systems, patient registration, visitor management | Serve as the first point of contact for visitors and callers, making them vulnerable to impersonation, tailgating, and social engineering. | **G8:** Limited security awareness.<br>**G12:** Weak verification procedures. |
| **IT Staff** | Administrative privileges, servers, network infrastructure, security systems | Elevated privileges make IT personnel attractive targets for phishing, credential theft, and privilege escalation attacks. A small team increases fatigue and the likelihood of mistakes. | **G10:** Privileged access management weaknesses.<br>**G3:** Limited centralized monitoring. |
| **Executives** | Strategic information, financial approvals, executive communications | Frequently targeted through Business Email Compromise (BEC), executive impersonation, and spear-phishing attacks due to their authority over financial decisions. | **G6:** Identity protection weaknesses.<br>**G8:** Executive-targeted security awareness gaps. |
| **External Contractors and Vendors** | Varies by contract (EHR maintenance, endpoint security, building management, medical equipment support) | Possess trusted access outside MedDefense's direct administrative control. A vendor compromise can provide attackers with legitimate access paths. | **G5:** Third-party access management weaknesses and insufficient vendor monitoring. |

---

# Surface Assessment Summary

While all three attack surface categories present meaningful risk, the **internal attack surface** currently represents the greatest threat to MedDefense. Project 1x00 identified a **flat network architecture** where critical systems—including EHR databases, billing servers, backup infrastructure, administrative interfaces, and legacy medical devices—are broadly accessible once an attacker gains an initial foothold. External attacks such as phishing, VPN exploitation, or vulnerable public-facing servers become significantly more damaging because there are few internal controls to prevent lateral movement. Combined with limited security monitoring, legacy systems, default credentials, and insufficient network segmentation, a single successful compromise can rapidly escalate into an organization-wide incident affecting patient care, protected health information (PHI), and business operations.
