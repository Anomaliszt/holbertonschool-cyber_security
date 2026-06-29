# MedDefense Health Systems: Control Framework Gap Analysis

## 1. Systemic Control Gaps Identified

### Gap ID: G-001
* **Gap Description:** Complete lack of Centralized Log Management and Automated Incident Alerting (No SIEM or centralized syslog engine). 
* **Category x Function Missing:** Technical Detective
* **Affected Asset(s) or Zone:** The entire MedDefense network infrastructure, including all clinical servers (`ehr-srv-01`, `ehr-db-01`, `pacs-srv-01`), the billing server (`billing-srv-01`), and active Active Directory domain controllers.
* **Risk if Unaddressed:** **Confidentiality, Integrity, and Availability**
    * *Connection:* Threat actors can compromise endpoints, establish persistence, exfiltrate data, or execute malicious binaries silently. Without automated detection and alert notifications, malicious activities remain completely invisible until widespread disruption occurs, heavily extending the attacker's dwell time.
* **Evidence:** Artifact 8 explicitly states that no centralized log management system exists, logs rotate locally and are overwritten within 30 days, and there is no real-time alerting on security configurations or Active Directory events.

---

### Gap ID: G-002
* **Gap Description:** Absence of Server-Level Endpoint Protection and Antivirus coverage for core enterprise servers.
* **Category x Function Missing:** Technical Preventive / Technical Detective
* **Affected Asset(s) or Zone:** All core infrastructure systems, including 15 Windows servers and all Ubuntu Linux servers (`ehr-srv-01`, `ehr-db-01`, `billing-srv-01`, `backup-srv-01`, `web-srv-01`).
* **Risk if Unaddressed:** **Integrity and Availability**
    * *Connection:* Servers lack real-time file-integrity monitoring, exploit mitigation, or runtime protection. This allows file-encrypting ransomware or unauthorized background binaries (such as the `kworker` Monero cryptominer) to execute unhindered, damaging data integrity and exhausting machine processing availability.
* **Evidence:** Artifact 4 (Sophos Status Report) establishes that server protection licenses were never purchased for the 15 Windows servers, and Linux servers are entirely unsupported by the organization's current pricing tier.

---

### Gap ID: G-003
* **Gap Description:** Total absence of formal administrative blueprints for incident handling, business operations continuity, or system disaster recovery.
* **Category x Function Missing:** Administrative Corrective
* **Affected Asset(s) or Zone:** The entire enterprise organization, particularly critical healthcare-delivery services dependent on system availability.
* **Risk if Unaddressed:** **Availability**
    * *Connection:* When a disruptive incident strikes, response efforts are forced to rely on ad-hoc improvisation. This significantly delays recovery windows, increases operational confusion, impacts regulatory compliance standings, and risks extended downtimes that directly threaten safe patient clinical care.
* **Evidence:** Marcus Webb's personal notes (Document 3) verify that no formal incident response, business continuity, or disaster recovery plans exist. The response to the January ransomware attack was completely improvised.

---

### Gap ID: G-004
* **Gap Description:** Incomplete Data Backups and Missing Disaster Recovery Validation. Critical clinical repositories are excluded from backups, and full infrastructure restorations are never tested.
* **Category x Function Missing:** Technical Corrective
* **Affected Asset(s) or Zone:** `pacs-srv-01` (PACS Imaging Server), `ws-srv-01` (Westside Clinic Server), individual workstation configurations, medical device settings, and all Microsoft Office 365 cloud environments.
* **Risk if Unaddressed:** **Availability and Integrity**
    * *Connection:* If a severe technical failure, physical fire, or ransomware payload hits the clinic or the PACS framework, the data cannot be recovered. This results in permanent loss of critical patient historical data (Integrity) and extended, unmitigated disruptions to patient imaging services (Availability).
* **Evidence:** Artifact 5 shows that PACS data, the Westside server, and O365 are explicitly skipped during backup jobs. Furthermore, a full DR recovery test has never been executed, and a partial single-server recovery took 6 hours.

---

### Gap ID: G-005
* **Gap Description:** Missing Internal Network Edge Controls (Egress Filtering) and Core Network Isolation (Segmentation).
* **Category x Function Missing:** Technical Preventive
* **Affected Asset(s) or Zone:** Internal Central Hospital subnet broadcast domain (10.10.0.0/16), containing all medical IoT endpoints (infusion pumps, connected vital monitors), clinical servers, and generic employee workstations.
* **Risk if Unaddressed:** **Confidentiality, Integrity, and Availability**
    * *Connection:* The flat network profile lets any compromised endpoint talk to any server or medical IoT device without passing internal firewall checkpoints. Simultaneously, the lack of egress filtering lets malicious payloads effortlessly reach external command-and-control (C2) servers or public mining pools over arbitrary ports.
* **Evidence:** Document 5 (Network Diagram) and Marcus's notes (Document 3 / Artifact 1) confirm the existence of a completely flat 10.10.0.0/16 broadcast domain where firewall Rule 4 passes all outbound internal traffic to the WAN without filtering.

---

### Gap ID: G-006
* **Gap Description:** Inadequate off-hours physical perimeter security and non-existent internal surveillance covering critical infrastructure zones.
* **Category x Function Missing:** Physical Detective / Physical Preventive
* **Affected Asset(s) or Zone:** Central Hospital ground-floor server room, floor network closets, and the entire facility outside the hours of 07:00–19:00 Monday through Friday.
* **Risk if Unaddressed:** **Confidentiality, Integrity, and Availability**
    * *Connection:* Intruders can physically access internal network hardware during nights or weekends completely undetected. Malicious actors can tap connections, steal hard drives, or sabotage network links without leaving any visual evidence or generating physical alarms.
* **Evidence:** Physical Security Contract (Artifact 6) states that guard services are restricted to weekdays from 07:00 to 19:00 at the main entrance only. Furthermore, Tom Reeves's notes confirm there are zero cameras monitoring the server room area or network closets.

---

## 2. Conclusion: Strategic Pattern Analysis

Looking at the identified control gaps as a whole, a definitive pattern emerges: MedDefense's security framework is heavily unbalanced, favoring a **prevention-oriented** posture while suffering from a complete breakdown in **detective** and **corrective** capabilities. The organization relies almost exclusively on its perimeter firewall, basic active directory configurations, and standard endpoint antivirus definitions to deny entry to threats. 

This lopsided strategy implies that MedDefense is profoundly ill-equipped to handle any attack that successfully slips past its outer boundaries. Because the internal architecture lacks centralized log auditing, internal network segmentation, server endpoint protection, or documented incident response and recovery procedures, an attacker can dwell inside the environment undetected for months. Once a threat actor activates a payload—such as the January ransomware or the persistent Monero miner—MedDefense has no automated way to discover the intrusion and lacks the operational playbook required to systematically contain and recover from the breach.
