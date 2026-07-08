# STRIDE Threat Model — Additional MedDefense Critical Systems

---

# System: PACS / Medical Imaging System

## Architecture Notes

The PACS environment consists of:

- **`pacs-srv-01`** storing diagnostic medical images.
- MRI workstation running **Windows XP** for scanner operations.
- Radiology workstations accessing PACS over the internal network.
- Network path shared with the broader MedDefense flat network.

Key concerns identified from 1x00:

- Shared PACS credentials.
- Legacy unsupported Windows XP workstation.
- Flat network access between clinical systems.
- Limited monitoring of medical device traffic.

| STRIDE | Threat | Impact | Severity |
|--------|--------|--------|----------|
| **S** | Attacker uses shared PACS credentials or stolen radiology credentials to impersonate an authorized imaging user and access patient scans. | Unauthorized access to diagnostic images and PHI exposure. | High |
| **T** | Attacker modifies or replaces medical images stored in PACS after compromising the imaging server. | Incorrect diagnoses, patient safety risk, and loss of medical record integrity. | Critical |
| **R** | Shared radiology accounts prevent investigators from proving which user viewed, exported, or altered images. | Compliance violations and inability to establish accountability during investigations. | High |
| **I** | Attacker accesses PACS storage or unencrypted image transfers to steal patient imaging records. | HIPAA breach involving sensitive medical images and patient identifiers. | Critical |
| **D** | Ransomware encrypts PACS storage or disables the Windows XP MRI workstation, preventing image availability. | Radiology shutdown, delayed diagnosis, and clinical disruption. | Critical |
| **E** | Attacker exploits the Windows XP MRI workstation or PACS permissions to obtain administrative access to imaging systems. | Full control of medical imaging infrastructure and possible pivot into clinical networks. | High |

## Top Threat:

**Information Disclosure is the most dangerous PACS threat** because medical images contain highly sensitive patient information and are valuable targets for extortion. The combination of shared credentials, weak segmentation, and legacy systems allows attackers to steal large volumes of diagnostic data with limited detection.

---

# System: Active Directory (`ad-dc-01` + `ad-dc-02`)

## Architecture Notes

The Active Directory environment provides centralized authentication and authorization for:

- Clinical users
- Administrative users
- Servers
- Medical systems
- Network resources

Key concerns identified from 1x00:

- No MFA for critical accounts.
- Weak identity controls.
- Excessive privileges.
- Flat network architecture.
- Limited centralized monitoring.

| STRIDE | Threat | Impact | Severity |
|--------|--------|--------|----------|
| **S** | Attacker uses stolen administrator credentials to impersonate a legitimate domain user. | Unauthorized access across the entire organization. | Critical |
| **T** | Attacker with Domain Admin privileges modifies Group Policy, disables security tools, or creates unauthorized accounts. | Enterprise-wide compromise and loss of system integrity. | Critical |
| **R** | Lack of centralized auditing allows privileged users or attackers to deny unauthorized administrative actions. | Reduced incident investigation capability and compliance risk. | High |
| **I** | Domain compromise exposes usernames, password hashes, organizational structure, and access relationships. | Enables further attacks and large-scale credential compromise. | Critical |
| **D** | Ransomware operator disables domain services or corrupts Active Directory databases. | Authentication failure prevents access to clinical and business systems. | Critical |
| **E** | Attacker exploits weak permissions or credential theft to escalate from standard user to Domain Admin. | Complete organizational takeover and unrestricted system access. | Critical |

## Top Threat:

**Elevation of Privilege is the most dangerous Active Directory threat** because Active Directory is the control plane for MedDefense. A single Domain Admin compromise allows attackers to control servers, deploy ransomware, access patient systems, and disable defensive controls throughout the organization.

---

# System: Network Infrastructure

## Architecture Notes

The network infrastructure includes:

- **FortiGate firewall** as the primary Internet perimeter defense.
- Core switching infrastructure.
- VPN remote access services.
- Westside consumer-grade router.
- Internal network with limited segmentation.

Key concerns identified from 1x00:

- Single perimeter defense dependency.
- Flat internal network.
- Permissive VPN access.
- Consumer-grade network equipment.
- Lack of internal segmentation.

| STRIDE | Threat | Impact | Severity |
|--------|--------|--------|----------|
| **S** | Attacker compromises VPN credentials and impersonates a legitimate remote user. | Unauthorized access to internal systems through trusted network paths. | Critical |
| **T** | Attacker gains FortiGate administrative access and modifies firewall rules or VPN configurations. | Loss of network security controls and attacker persistence. | Critical |
| **R** | Limited network logging prevents proving who changed firewall rules or accessed sensitive network resources. | Delayed investigations and compliance challenges. | High |
| **I** | Misconfigured firewall rules or flat network design expose internal services and sensitive traffic. | Unauthorized access to patient and operational data. | High |
| **D** | Attacker disrupts firewall, VPN, or routing services through configuration changes or denial-of-service activity. | Remote access failure and interruption of hospital operations. | Critical |
| **E** | Attacker exploits vulnerable network devices or stolen administrative credentials to obtain network administrator privileges. | Complete network takeover and ability to control traffic flows. | Critical |

## Top Threat:

**Elevation of Privilege is the most dangerous network infrastructure threat** because control of the firewall and routing environment provides attackers with the ability to bypass security boundaries, maintain persistence, and reach every connected system. The absence of internal segmentation magnifies the impact because a network compromise can quickly become an enterprise-wide compromise.

---

# Cross-System STRIDE Priority Summary

| System | Highest-Risk STRIDE Category | Reason |
|--------|------------------------------|--------|
| PACS / Medical Imaging | Information Disclosure | Medical images contain sensitive PHI and can be stolen or monetized through extortion. |
| Active Directory | Elevation of Privilege | Domain compromise gives attackers control over the entire MedDefense environment. |
| Network Infrastructure | Elevation of Privilege | Network control bypasses defenses and enables unrestricted movement across systems. |

## Overall Assessment

Across these three systems, the most significant risk pattern is **centralized control failure**. Active Directory and network infrastructure represent high-impact control points where compromise enables attackers to affect the entire organization, while PACS represents a high-value clinical data target. MedDefense's largest risk multipliers are the same weaknesses identified throughout the assessment: flat network architecture, weak identity controls, legacy systems, insufficient monitoring, and excessive trust relationships between critical systems.
