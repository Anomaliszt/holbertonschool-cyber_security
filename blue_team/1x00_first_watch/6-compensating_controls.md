# MedDefense Health Systems: Compensating Control Strategy for Legacy MRI Workstation

## 1. Risk Analysis: The Threat of the Legacy MRI Workstation

The Siemens MRI control workstation represents a critical systemic risk because it operates on Windows XP Embedded—an obsolete operating system that has lacked security patches since 2014—leaving it permanently vulnerable to severe, unpatchable exploits like EternalBlue. Because MedDefense utilizes a completely flat network architecture ($10.10.0.0/16$), this highly vulnerable workstation shares a single broadcast domain with every employee computer, server, and unmanaged device across all facilities. If any single endpoint in the hospital is compromised by malware or a network worm, the threat actor can map, attack, and compromise the MRI workstation laterally without passing through any internal firewall boundaries. Once compromised, this legacy system can be turned into an unmonitored launchpad for attackers to pivot directly into core hospital databases, or its operational availability could be destroyed, directly crippling patient clinical care.

---

## 2. Compensating Control Strategy

When standard patching and lifecycle upgrades are blocked by regulatory and budgetary constraints, alternative engineering and procedural mechanisms must be implemented to isolate the asset and shrink its attack surface.



### Control 1: Network Micro-Segmentation via Port-Based ACLs
* **Description:** Reconfigure the Cisco access switch port hosting the MRI workstation (`MED-3F-12`) to pull the device off the general workstation network and place it into a dedicated, isolated Virtual Local Area Network (VLAN). Configure strict Access Control Lists (ACLs) on the FortiGate 100F firewall to deny all inbound and outbound traffic to this isolated VLAN by default, explicitly permitting *only* outbound communication to the PACS imaging server (`pacs-srv-01`) over the exact ports required for DICOM medical image transmission (e.g., TCP port 104).
* **Category x Function:** Technical x Preventive
* **Risk Reduction Without OS Modification:** This blocks network-based attacks without touching the software. Even though Windows XP remains vulnerable, automated network worms or attackers sitting on the main workstation network can no longer probe, see, or communicate with the device.
* **Limitations/Residual Risk:** This does not protect the device if the trusted PACS server itself becomes compromised, nor does it mitigate threats introduced locally via the machine's physical hardware ports.

### Control 2: Technical Restriction and Physical Lockout of USB Interfaces
* **Description:** Disable the USB storage driver stack within the Windows XP registry to prevent the operating system from mounting external storage volumes, and physically install locked, tamper-resistant USB port blocker caps over all exposed USB slots on the workstation chassis.
* **Category x Function:** Technical & Physical x Preventive
* **Risk Reduction Without OS Modification:** This neutralizes the physical infection vector. Since the machine cannot run endpoint protection or receive patches, blocking the entry of unauthorized physical media ensures that staff, patients, or field service vendors cannot accidentally or maliciously introduce malware via a flash drive.
* **Limitations/Residual Risk:** Disabling USB ports may increase operational friction during mandatory vendor maintenance cycles or machine troubleshooting if service engineers require USB access to pull diagnostic logs or update internal application components manually.

### Control 3: Mandated Unique Authentication and Physical Access Auditing
* **Description:** Implement a strict administrative directive that outlaws the use of generic, shared local credentials at the workstation console. Enforce unique Active Directory user logins for all authorized radiologists and technologists, and mount a physical, serial-numbered paper access logbook at the terminal desk that requires personnel to sign in with their name, unique ID, date, and exact timestamp before touching the console.
* **Category x Function:** Administrative x Preventive & Detective
* **Risk Reduction Without OS Modification:** This mitigates identity-based risks and establishes accountability. By enforcing individual credentials and a matching physical log trail, it prevents unauthenticated staff or visitors from modifying system configurations and provides an immediate forensic baseline if an incident occurs at the console.
* **Limitations/Residual Risk:** This control relies entirely on human policy compliance. It offers no technical protection against automated software exploits or external network-borne attacks targeting the underlying operating system.

---

## 3. Immediate Implementation Priority

If MedDefense can fund and implement only one control immediately due to budget or time constraints, **Control 1: Network Micro-Segmentation via Port-Based ACLs** provides the greatest risk reduction.

### Justification
This control directly addresses the primary threat vector: **lateral network propagation across a flat environment.** While physical USB lockouts stop localized tampering and policy overrides improve user behavior, neither prevents an active network-based threat actor or an automated script running on a compromised nurse workstation from scanning and exploiting the Windows XP machine remotely over the network. 

Micro-segmentation effectively wraps the legacy 20-year-old operating system in a modern, enterprise-grade defensive boundary using existing infrastructure (the FortiGate 100F firewall). It reduces the MRI workstation’s visible network footprint to nearly zero, shielding it from internal malware outbreaks without modifying a single line of certified medical device code.
