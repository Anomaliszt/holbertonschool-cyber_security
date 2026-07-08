# MedDefense Vector-to-Asset Matrix

## Critical Assets

| Attack Vector ↓ / Asset → | **EHR Database (`ehr-db-01`)** | **Patient Portal (`web-srv-01`)** | **Billing Server (`billing-srv-01`)** | **Backup NAS** | **Microsoft 365 / Email** | **Medical IoT** | **Active Directory** |
|----------------------------|--------------------------------|-----------------------------------|---------------------------------------|----------------|---------------------------|-----------------|----------------------|
| **Phishing / Spear Phishing** | Phishing → clinician credentials → flat network → PostgreSQL 5432 → EHR patient records. | Phishing → stolen web administrator credentials → patient portal administration. | Phishing → compromised workstation → lateral movement → Apache server access. | Phishing → admin credentials → NAS management interface → backup deletion. | Phishing → Microsoft 365 credentials → mailbox compromise → BEC and data theft. | Phishing → privileged credentials → lateral movement → IoT management interfaces. | Phishing → privileged credentials → Domain Admin compromise → enterprise control. |
| **VPN Exploit** | Exploited FortiGate VPN → internal network → unrestricted access → EHR database. | VPN access → internal management network → patient portal server administration. | VPN exploit → direct access to vulnerable Apache server. | VPN compromise → access NAS shares → encrypt backups before ransomware deployment. | VPN compromise → authenticated access → Microsoft 365 synchronization services. | VPN compromise → medical device VLAN → legacy workstation compromise. | VPN exploit → credential dumping → Domain Controller takeover. |
| **Default / Shared Credentials** | Shared EHR credentials → unauthorized patient record access. | Shared administrator account → patient portal modification. | Shared billing credentials → billing application access. | Shared NAS administrator account → backup deletion or encryption. | Shared mailbox credentials → unauthorized email access. | Default PACS/BD Alaris credentials → device administration. | Shared administrator credentials → Active Directory privilege escalation. |
| **Vulnerable Software Exploit** | Apache RCE → flat network → PostgreSQL access → EHR compromise. | Web application exploit → compromise of public patient portal. | Apache 2.4.29 RCE → direct compromise of `billing-srv-01`. | Server compromise → lateral movement → NAS encryption. | Server compromise → credential theft → Microsoft 365 compromise. | Exploited server → lateral movement → Windows XP MRI workstation. | Server compromise → Mimikatz → Domain Admin credentials. |
| **Supply Chain Compromise** | Compromised MedTech account → trusted EHR maintenance access → patient database. | Vendor maintenance account → patient portal administration. | Compromised vendor support account → billing server access. | Compromised backup vendor credentials → NAS administration. | Microsoft tenant compromise → organization-wide email exposure. | Compromised Siemens maintenance account → MRI workstation compromise. | Trusted vendor account → privileged Active Directory access. |
| **Insider (Malicious)** | Authorized employee exports PHI for financial gain. | Administrator intentionally modifies or disables portal services. | Insider manipulates billing records or financial databases. | IT administrator deletes backups before sabotage. | Employee exports confidential executive communications. | Biomedical technician alters medical device configurations. | Domain administrator abuses privileged access for sabotage or persistence. |
| **Insider (Negligent)** | Employee falls for phishing and exposes EHR credentials. | Weak password or misconfiguration exposes portal administration. | Misconfigured billing server exposes sensitive services. | Backup permissions incorrectly configured, allowing unauthorized access. | User approves MFA fatigue request, exposing Microsoft 365 account. | Unmanaged tablet introduces malware into clinical device network. | Administrator accidentally exposes privileged credentials or scripts. |
| **Physical Access** | Unlocked clinical workstation → authenticated EHR session abuse. | Physical access to administrator workstation → portal management. | Physical access to billing workstation → authenticated server access. | Server room access → direct NAS manipulation or theft. | Logged-in executive workstation → email compromise. | Physical access to medical devices → maintenance interface abuse. | Tailgating into IT office → Domain Controller administration console access. |

---

# Most Connected Assets

## 1. Active Directory

**Reachable by:** 8 of 8 attack vectors

Active Directory is the most connected asset because nearly every successful attack eventually seeks privileged authentication control, enabling enterprise-wide compromise.

---

## 2. EHR Database (`ehr-db-01`)

**Reachable by:** 8 of 8 attack vectors

The EHR database stores MedDefense's most valuable asset—protected health information (PHI)—making it a primary objective for ransomware operators, insiders, and data thieves.

---

## 3. Billing Server (`billing-srv-01`)

**Reachable by:** 8 of 8 attack vectors

The billing server is both Internet-facing and internally accessible, making it an ideal initial foothold and pivot point into the flat internal network.

---

# Most Versatile Attack Vectors

## 1. Phishing / Spear Phishing

**Reaches:** All 7 critical assets

Phishing is the most versatile vector because compromised credentials can provide attackers with access to cloud services, internal systems, privileged accounts, and sensitive patient data.

---

## 2. Supply Chain Compromise

**Reaches:** All 7 critical assets

Trusted vendors possess privileged access to critical systems, allowing attackers to bypass perimeter defenses and directly access sensitive infrastructure.

---

## 3. VPN Exploit

**Reaches:** All 7 critical assets

A compromised VPN endpoint provides attackers with legitimate internal network access, allowing unrestricted lateral movement due to MedDefense's flat network architecture.

---

# Overall Assessment

The matrix demonstrates that **Active Directory, the EHR database, and the billing server** are the most exposed assets because every major attack vector can ultimately reach them. Likewise, **phishing, supply chain compromise, and VPN exploitation** are the most dangerous vectors because they provide reliable initial access and enable attackers to exploit MedDefense's flat network, weak segmentation, and privileged access paths. These intersections should be MedDefense's highest security priorities, as strengthening identity protection, network segmentation, vendor access controls, and phishing resistance would simultaneously reduce risk across multiple attack paths.
