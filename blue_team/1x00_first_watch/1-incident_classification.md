# MedDefense Health Systems: Incident Analysis & CIA Triad Classification

## 1. Incident Classification Table

The six documented security incidents are classified below by their impact on the **CIA Triad** (Confidentiality, Integrity, and Availability):

| Incident ID | Date | Primary Pillar Impacted | Secondary Pillar Impacted |
| :--- | :--- | :--- | :--- |
| **Incident A** | January 15 | **Availability** | **Integrity** |
| **Incident B** | February 2 | **Confidentiality** | None |
| **Incident C** | March 18 | **Integrity** | **Availability** |
| **Incident D** | April 5 | **Integrity** | **Availability** |
| **Incident E** | May 22 | **Availability** | None |
| **Incident F** | June 10 | **Confidentiality** | None |

---

## 2. Detailed Incident Analysis

### Incident A: Ransomware on Billing Server (`billing-srv-01`)
* **Primary Pillar Impacted:** **Availability**
* **Justification:** The primary impact was to availability because the ransomware payload completely encrypted the billing server, rendering the system entirely inaccessible and halting critical insurance claims processing for 4 days.
* **Secondary Pillar Impacted:** **Integrity**
    * *Connection:* The ransomware unauthorizedly modified and scrambled the filesystem on the server; additionally, because a misconfigured cron job left the team with a 3-week-old backup, 21 days of financial transaction data suffered a permanent or temporary loss of accuracy and trustworthiness.

### Incident B: Patient Portal Broken Access Control
* **Primary Pillar Impacted:** **Confidentiality**
* **Justification:** The primary impact was to confidentiality because a severe authorization flaw directly exposed private patient lab results to unauthorized individuals through simple URL parameter manipulation.
* **Secondary Pillar Impacted:** None
    * *Connection:* The private data was viewed without authorization, but there is no evidence indicating that the underlying files were altered (Integrity) or that the portal itself was knocked offline (Availability).

### Incident C: Database Update Script Bug (Incorrect Dosages)
* **Primary Pillar Impacted:** **Integrity**
* **Justification:** The primary impact was to integrity because a buggy corporate script actively overwrote, corrupted, and invalidated critical medication dosage values within the pharmacy management system database.
* **Secondary Pillar Impacted:** **Availability**
    * *Connection:* Because the dosage numbers were completely untrustworthy and dangerous to use for patient care, the reliable operational service of the pharmacy management system was effectively disrupted and unusable for approximately 6 hours.

### Incident D: Public Website Defacement (`web-srv-01`)
* **Primary Pillar Impacted:** **Integrity**
* **Justification:** The primary impact was to integrity because unauthorized parties successfully modified the web server's files to replace the legitimate corporate homepage with a political message.
* **Secondary Pillar Impacted:** **Availability**
    * *Connection:* The official, intended public website content was unavailable to legitimate users and patients for the 2 hours it took the IT team to restore the system from a clean backup.

### Incident E: EHR System Outage During Migration
* **Primary Pillar Impacted:** **Availability**
* **Justification:** The primary impact was to availability because a prolonged database migration combined with an untested rollback procedure forced a total 9-hour blackout of the Electronic Health Record system, forcing clinical staff to resort to paper charting.
* **Secondary Pillar Impacted:** None
    * *Connection:* While clinical operations were heavily disrupted by the downtime, there is no evidence that patient data was permanently corrupted (Integrity) or exposed to unauthorized eyes (Confidentiality).

### Incident F: IT Intern's Personal Torrenting Laptop on Corporate WiFi
* **Primary Pillar Impacted:** **Confidentiality**
* **Justification:** The primary impact was to confidentiality because an unmanaged, unauthenticated personal device running peer-to-peer software was improperly allowed onto the internal corporate network segment for 3 weeks, exposing sensitive HR file shares to unauthorized access.
* **Secondary Pillar Impacted:** Availability & Integrity
    Connection (Availability): Active torrent clients generate high volumes of concurrent connections and heavy bandwidth consumption, risking severe network degradation or denial of service for critical hospital systems sharing that same flat broadcast domain.

    Connection (Integrity): P2P software serves as a prime delivery mechanism for malware and malicious payloads. Given that the device sat on the same network segment as the HR file share for three weeks, it created an unmitigated risk for lateral malware propagation capable of modifying, deleting, or encrypting corporate data.
