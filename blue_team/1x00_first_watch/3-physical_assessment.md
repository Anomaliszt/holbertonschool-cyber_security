# MedDefense Central: Physical Security Walk-Through & Risk Decomposition

## Observation 1: Server Room Access
* **Vulnerability:** Weak physical access control and lack of monitoring. The server room uses a generic badge issued to all 2,000 employees organization-wide, lacks a visitor log, and has no surveillance camera coverage in a high-traffic corridor shared with the cafeteria.
* **Threat:** An unauthorized employee (e.g., disgruntled staff or a compromised insider) or an adversarial visitor leveraging an unmonitored generic badge enters the server room undetected to steal hardware, unplug cables, or insert a malicious USB drive.
* **Impact:** **Confidentiality, Integrity, and Availability**
    * *Connection:* A malicious actor could physically steal hard drives containing unencrypted patient data (Confidentiality), deploy physical network taps or alter server configurations (Integrity), or simply power down critical infrastructure and cut lines, triggering immediate hospital-wide downtime (Availability).
* **Severity:** **Critical**
    * *Justification:* This represents a single point of failure where the core data infrastructure of the entire hospital can be physically accessed undetected by any individual inside the building.

---

## Observation 2: Network Closet Security and Asset Exposure
* **Vulnerability:** Unsecured physical access combined with exposed plain-text administrative credentials. The network closet door is unlocked and left ajar, and a laminated sheet containing the switch management interface credentials is taped directly to the wall.
* **Threat:** A patient, visitor, or unauthorized employee walks into the open closet and uses the exposed credentials to log into the network switch management console via a personal device, or physically manipulates the patch panels.
* **Impact:** **Confidentiality, Integrity, and Availability**
    * *Connection:* The threat actor could mirror network traffic to intercept unencrypted clinical communications (Confidentiality), reconfigure the switch to manipulate data paths or alter network settings (Integrity), or completely disable ports to shut down connectivity across the entire floor (Availability).
* **Severity:** **Critical**
    * *Justification:* An attacker is handed both unrestricted physical access and administrative credentials on a silver platter, allowing for total administrative compromise of floor-wide network infrastructure within seconds.

---

## Observation 3: Abandoned Nurse Station Workstation
* **Vulnerability:** Session management failure and a cultural bypass of authentication policies. The workstation is logged into an active EHR session, left entirely unattended in a public-facing clinical area for over 15 minutes, with explicit administrative signage encouraging staff not to lock the system.
* **Threat:** A passerby, visitor, or unauthorized individual steps behind the counter and interacts with the active EHR session to view, copy, or modify patient records under a legitimate nurse's active credentials.
* **Impact:** **Confidentiality and Integrity**
    * *Connection:* Private protected health information (PHI) can be read or stolen on screen (Confidentiality), and malicious or erroneous changes could be saved directly into a patient’s active medical chart under a falsified user identity (Integrity).
* **Severity:** **High**
    * *Justification:* This exposes highly regulated patient charts directly to public traffic, running counter to HIPAA compliance guidelines and introducing severe patient care risks via unauthenticated data entry.

---

## Observation 4: Exposed and Outdated Medical IoT Device
* **Vulnerability:** Unpatched, legacy endpoint firmware (v2.1.3, last updated in 2019) paired with a lack of network segmentation (the vital monitor sits on the exact same broadcast domain as public-facing nurse workstations). The device also displays its active IP address to anyone in the patient room.
* **Threat:** A malicious actor plugs a device into the wall port or connects over the flat network to target the vital monitor's unpatched 2019 firmware vulnerabilities, executing remote code or running an automated exploit.
* **Impact:** **Availability and Integrity**
    * *Connection:* An attacker could spoof or alter real-time vital sign metrics being sent to clinical dashboards (Integrity) or crash the unit completely during active patient care (Availability), while potentially using the device as a pivot point to attack nurse workstations on the shared network segment.
* **Severity:** **High**
    * *Justification:* Compromising an active patient monitor directly threatens patient safety, and its placement on a flat network allows an exploit to easily pivot laterally into the broader corporate environment.

---

## Observation 5: Propped-Open Emergency Exit Door
* **Vulnerability:** Unauthorized physical bypass of a perimeter boundary. A fire exit door designed to segregate a public waiting area from a restricted administrative wing has been deliberately propped open with a wooden wedge.
* **Threat:** An unauthorized visitor, social engineer, or threat actor walks straight out of the public waiting room through the open fire exit directly into the administrative wing, gaining tailgating-free access to executive and IT security offices.
* **Impact:** **Confidentiality, Integrity, and Availability**
    * *Connection:* The intruder could steal paper records from desks or sneak into the IT department to access sensitive administrative terminals (Confidentiality/Integrity), or physically disrupt executive and security operations during a crisis (Availability).
* **Severity:** **Medium**
    * *Justification:* While it completely compromises the physical perimeter separating public spaces from internal administration, it primarily exposes office workspace areas rather than direct server room hardware.
