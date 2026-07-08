# MITRE ATT&CK Mapping Assessment — MedDefense

---

# Scenario Alpha: "Operation Flatline" — Ransomware Campaign

**Threat Actor:** BlackReef affiliate (Organized Crime / Ransomware-as-a-Service)  
**Objective:** Double extortion through patient data theft and ransomware deployment.

---

## Step 1: Initial Access Broker Identifies MedDefense VPN Exposure

**Brief Description:**  
BlackReef affiliate purchases a list of healthcare organizations with exposed Fortinet VPN appliances from an Initial Access Broker.

**Tactic:**  
Reconnaissance

**Technique:**  
**Gather Victim Network Information (T1590.005)**  
*Alternative: Active Scanning (T1595)*

**MedDefense Factor:**  
MedDefense exposes FortiGate VPN infrastructure externally, and healthcare sector targeting makes internet-facing healthcare assets valuable targets for access brokers.

---

## Step 2: Spear Phishing Delivers Reverse Shell Payload

**Brief Description:**  
Affiliate sends fake Fortinet support email to Sarah Park. Sarah opens a malicious document that executes PowerShell and downloads a reverse shell.

**Tactic:**  
Initial Access / Execution

**Technique:**  
**Phishing: Spearphishing Link (T1566.002)**  
**Command and Scripting Interpreter: PowerShell (T1059.001)**

**MedDefense Factor:**  
IT staff are high-value phishing targets, and MedDefense lacks strong email security controls and user awareness protections.

---

## Step 3: Persistent Backdoor Created on IT Director Workstation

**Brief Description:**  
Attacker creates a scheduled task disguised as Windows Update to reconnect every 30 minutes.

**Tactic:**  
Persistence

**Technique:**  
**Scheduled Task/Job: Scheduled Task (T1053.005)**

**MedDefense Factor:**  
Limited endpoint monitoring and lack of EDR allows unauthorized persistence mechanisms to operate without detection.

---

## Step 4: Network Discovery Across Flat Internal Environment

**Brief Description:**  
Affiliate runs AD and network discovery commands to identify domain controllers, EHR systems, billing servers, and backups.

**Tactic:**  
Discovery

**Technique:**  
**Permission Groups Discovery: Domain Groups (T1069.002)**  
**System Network Configuration Discovery (T1016)**

**MedDefense Factor:**  
The flat network design allows a compromised workstation to discover critical systems across the entire 10.10.0.0/16 environment.

---

## Step 5: Credential Dumping from IT Director Workstation

**Brief Description:**  
Mimikatz extracts cached credentials and discovers a Domain Admin service account hash.

**Tactic:**  
Credential Access

**Technique:**  
**OS Credential Dumping (T1003)**

**MedDefense Factor:**  
Excessive workstation privileges and reuse of privileged accounts expose domain credentials.

---

## Step 6: Pass-the-Hash to Domain Administrator Access

**Brief Description:**  
Attacker uses svc_backup NTLM hash to authenticate directly to Active Directory.

**Tactic:**  
Privilege Escalation / Lateral Movement

**Technique:**  
**Use Alternate Authentication Material: Pass the Hash (T1550.002)**

**MedDefense Factor:**  
Weak identity controls, no MFA for privileged accounts, and unrestricted internal access enable domain compromise.

---

## Step 7: Patient Data Collection and Exfiltration

**Brief Description:**  
Attacker exports PostgreSQL EHR data and file server documents, then transfers them using Rclone.

**Tactic:**  
Collection / Exfiltration

**Technique:**  
**Data from Information Repositories (T1213)**  
**Exfiltration Over Web Service (T1567)**

**MedDefense Factor:**  
EHR database access is insufficiently restricted, PostgreSQL is network-accessible, and SIEM/EDR monitoring is absent.

---

## Step 8: Backup Destruction

**Brief Description:**  
Attacker deletes NAS backups and removes Windows Volume Shadow Copies.

**Tactic:**  
Impact / Defense Evasion

**Technique:**  
**Inhibit System Recovery (T1490)**

**MedDefense Factor:**  
Backups are connected to the production network and lack isolation or immutability.

---

## Step 9: Domain-Wide Ransomware Deployment

**Brief Description:**  
BlackReef deploys ransomware through Group Policy and encrypts systems.

**Tactic:**  
Impact

**Technique:**  
**Data Encrypted for Impact (T1486)**

**MedDefense Factor:**  
Domain Admin compromise allows centralized ransomware deployment across Windows systems.

---

# Scenario Beta: "The Quiet Departure" — Insider Data Theft

**Threat Actor:** Malicious Insider (Billing Employee)  
**Objective:** Theft and sale of patient records.

---

## Step 1: Insider Abuses Legitimate Access

**Brief Description:**  
Maria decides to steal patient data using her existing billing and EHR permissions.

**Tactic:**  
Initial Access

**Technique:**  
**Valid Accounts (T1078)**

**MedDefense Factor:**  
Employees have broad access to sensitive systems with limited behavioral monitoring.

---

## Step 2: Data Access Discovery

**Brief Description:**  
Maria reviews available patient information through billing and EHR applications.

**Tactic:**  
Discovery

**Technique:**  
**Account Discovery (T1087)**  
*Alternative: Data from Information Repositories (T1213)*

**MedDefense Factor:**  
EHR permissions allow broad record visibility without restricting unusual access patterns.

---

## Step 3: Bulk Patient Record Export

**Brief Description:**  
Maria exports hundreds of patient records daily using normal EHR functionality.

**Tactic:**  
Collection

**Technique:**  
**Data from Information Repositories (T1213)**

**MedDefense Factor:**  
No DLP controls, export restrictions, or active review of EHR audit logs exist.

---

## Step 4: Transfer Data to USB Device

**Brief Description:**  
Maria copies CSV exports to a personal USB drive.

**Tactic:**  
Exfiltration

**Technique:**  
**Exfiltration Over Physical Medium: Exfiltration Over USB (T1052.001)**

**MedDefense Factor:**  
No USB restrictions or endpoint controls prevent removable media transfers.

---

## Step 5: Attempt to Remove Evidence

**Brief Description:**  
Maria deletes local CSV files and empties the recycle bin.

**Tactic:**  
Defense Evasion

**Technique:**  
**Indicator Removal: File Deletion (T1070.004)**

**MedDefense Factor:**  
Audit logs exist but are not proactively reviewed.

---

## Step 6: Theft of Database Credentials

**Brief Description:**  
Maria copies database credentials stored in a workstation configuration file.

**Tactic:**  
Credential Access

**Technique:**  
**Unsecured Credentials: Credentials In Files (T1552.001)**

**MedDefense Factor:**  
Application credentials are stored insecurely on endpoints.

---

## Step 7: Delayed Account Deactivation

**Brief Description:**  
Maria's account remains active for five days after termination.

**Tactic:**  
Persistence

**Technique:**  
**Valid Accounts (T1078)**

**MedDefense Factor:**  
Manual offboarding process lacks automation and SLA enforcement.

---

## Step 8: Post-Termination VPN Access and Database Extraction

**Brief Description:**  
Maria reconnects through VPN and extracts additional billing records.

**Tactic:**  
Initial Access / Collection / Exfiltration

**Technique:**  
**External Remote Services (T1133)**  
**Data from Information Repositories (T1213)**

**MedDefense Factor:**  
Active VPN credentials after termination and excessive database permissions enable continued access.

---

# ATT&CK Coverage Assessment

Both attack scenarios share several critical ATT&CK tactics: **Initial Access, Discovery, Credential Access, Collection, Exfiltration, and Impact/Persistence-related activity**. The ransomware campaign demonstrates an external attacker progressing through the full attack lifecycle, while the insider scenario shows how legitimate access can bypass many traditional perimeter defenses. The overlap indicates that MedDefense urgently needs detection capability around **identity misuse, credential abuse, abnormal data access, lateral movement, and unauthorized data movement**. Current weaknesses in SIEM coverage, endpoint monitoring, privileged account management, and audit review create visibility gaps exactly where both attackers and insiders operate.
