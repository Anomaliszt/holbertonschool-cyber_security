# Third-Party Risk Assessment — MedDefense Vendor Ecosystem

---

# Vendor 1: MedTech Solutions

**Service:**  
Electronic Health Record (EHR) maintenance provider. Provides specialized support, troubleshooting, updates, and emergency maintenance for MedDefense’s EHR environment.

**Access Type:**  
- Network access
- Application access
- Privileged administrative access

**Access Scope:**  
MedTech Solutions has direct maintenance access to the EHR server environment. Their access potentially includes:

- EHR application servers
- EHR databases containing protected health information (PHI)
- Application configuration files
- Server operating system administration functions
- Patient records
- Billing information
- Clinical workflow systems

**Compromise Scenario:**  

If MedTech Solutions is breached, attackers could compromise vendor credentials or remote support infrastructure and use the trusted connection to access MedDefense.

Attack path:

1. Attacker compromises a MedTech employee account or remote support system.
2. Attacker authenticates through the vendor maintenance connection.
3. Attacker gains access to EHR servers using trusted vendor privileges.
4. Attacker steals patient records, modifies clinical data, deploys ransomware, or pivots into additional MedDefense systems.
5. Legitimate vendor traffic may delay detection.

**Existing Controls:**  
*(Reference: 1x00 Control Matrix)*

- Vendor access approval process
- Contractual SLA requirements
- Vendor accountability requirements
- Limited purpose access agreement
- Remote access controls

**Risk Assessment:**  

## Critical

**Justification:**  
MedTech Solutions represents the highest-risk vendor because it has direct privileged access to MedDefense’s most sensitive environment. A compromise could bypass perimeter defenses and immediately expose PHI and critical clinical operations.

---

# Vendor 2: Microsoft

**Service:**  
Microsoft 365 E3 productivity and collaboration platform.

Provides:

- Organization-wide email
- SharePoint
- OneDrive
- Identity management through Entra ID (if deployed)

**Access Type:**  

- Application access
- Identity access
- Data access

**Access Scope:**  

Microsoft services may provide access to:

- Employee email accounts
- SharePoint repositories
- OneDrive files
- Cloud documents
- Identity services
- Authentication policies
- User access controls

**Compromise Scenario:**  

A Microsoft 365 compromise could allow attackers to take control of enterprise identities.

Attack path:

1. Attacker compromises a MedDefense employee account through phishing, token theft, or password reuse.
2. Attacker gains access to Microsoft 365 resources.
3. Attacker steals emails, documents, and sensitive information.
4. Attacker performs Business Email Compromise (BEC) or uses privileged identity access for further compromise.
5. Enterprise authentication could be controlled if administrative accounts are compromised.

**Existing Controls:**  
*(Reference: 1x00 Control Matrix)*

- Microsoft security controls
- User authentication policies
- Account management procedures
- Access control policies

**Risk Assessment:**  

## Critical

**Justification:**  
Microsoft is a foundational identity and communication provider. A compromise of privileged Microsoft accounts could affect the entire organization and enable data theft, fraud, or ransomware operations.

---

# Vendor 3: Sophos

**Service:**  
Endpoint protection platform deployed across MedDefense endpoints.

Provides:

- Malware detection
- Endpoint monitoring
- Security updates
- Security configuration management

**Access Type:**  

- Application access
- Endpoint administrative access
- Security management access

**Access Scope:**  

Sophos can potentially:

- Deploy endpoint updates
- Push security policies
- Execute endpoint response actions
- Monitor endpoint activity
- Manage security agents across systems

**Compromise Scenario:**  

If Sophos management infrastructure or administrator credentials are compromised:

Attack path:

1. Attacker compromises Sophos management credentials.
2. Attacker accesses the security console.
3. Attacker disables endpoint protections.
4. Attacker pushes malicious configurations or scripts.
5. Attacker deploys malware or ransomware across multiple endpoints.

**Existing Controls:**  
*(Reference: 1x00 Control Matrix)*

- Endpoint protection deployment
- Security management procedures
- Vendor security controls
- Administrative access restrictions

**Risk Assessment:**  

## High

**Justification:**  
Sophos has broad technical control over MedDefense endpoints. While it does not directly manage clinical systems, compromise could disable security protections and enable large-scale attacks.

---

# Vendor 4: Siemens

**Service:**  
MRI scanner manufacturer and maintenance provider.

Provides:

- MRI hardware support
- Firmware updates
- Medical device maintenance
- Windows XP workstation support

**Access Type:**  

- Physical access
- Application access
- Medical device network access

**Access Scope:**  

Siemens may access:

- MRI workstation systems
- Imaging equipment
- Device configuration settings
- Firmware update processes
- Medical device network segments

Potential data exposure:

- Patient imaging data
- Scheduling information
- Device configuration data

**Compromise Scenario:**  

If Siemens maintenance infrastructure is compromised:

Attack path:

1. Attackers compromise Siemens technician accounts or update mechanisms.
2. Malicious software or firmware is introduced during maintenance.
3. MRI workstation is compromised.
4. Attackers establish persistence on legacy systems.
5. Attackers disrupt imaging services or attempt network pivoting.

**Existing Controls:**  
*(Reference: 1x00 Control Matrix)*

- Vendor maintenance scheduling
- Physical access procedures
- Medical device management policies
- Change approval processes

**Risk Assessment:**  

## High

**Justification:**  
Medical devices frequently rely on legacy technology and have limited security capabilities. A Siemens compromise could affect patient care operations and potentially provide access into clinical networks.

---

# Vendor 5: Greenfield Building Management

**Service:**  
Building infrastructure management.

Provides:

- Network infrastructure management
- Building technology support
- Connectivity services

**Access Type:**  

- Network access
- Physical access

**Access Scope:**  

Greenfield may have access to:

- Building-managed network infrastructure
- VLAN configuration
- Network equipment
- Physical facilities
- Connectivity supporting MedDefense operations

**Compromise Scenario:**  

If Greenfield is breached:

Attack path:

1. Attackers compromise building management systems.
2. Attackers access shared infrastructure supporting the MedDefense VLAN.
3. Attackers perform network discovery.
4. Attackers attempt lateral movement into MedDefense systems.
5. Attackers disrupt operations or access internal resources.

**Existing Controls:**  
*(Reference: 1x00 Control Matrix)*

- VLAN separation
- Physical access controls
- Vendor agreements
- Building security procedures

**Risk Assessment:**  

## Medium–High

**Justification:**  
Greenfield does not directly control clinical applications, but compromise of shared network infrastructure creates a potential pathway into MedDefense. The final impact depends heavily on segmentation effectiveness.

---

# Supply Chain Risk Summary

The single vendor compromise that would cause the greatest damage to MedDefense is **MedTech Solutions** because it has direct privileged maintenance access to the EHR environment containing the organization’s most sensitive systems and patient data. A compromised MedTech account could provide attackers with a trusted path directly into clinical operations, enabling PHI theft, ransomware deployment, or manipulation of patient systems.

Microsoft represents a comparable enterprise-wide risk because identity compromise could affect nearly every user and service connected to the Microsoft ecosystem.

The first control MedDefense should implement to reduce supply chain risk is a **Third-Party Access Management program based on Zero Trust principles**.

Key requirements:

- Eliminate unnecessary vendor access
- Require MFA for all vendor accounts
- Use named individual accounts instead of shared credentials
- Apply least-privilege access controls
- Monitor vendor activity
- Restrict access by time and purpose
- Immediately revoke access after maintenance completion

This control reduces the blast radius of every vendor compromise scenario by limiting what external parties can reach even after their credentials are stolen.
