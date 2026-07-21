Goal: Map every data flow at MedDefense against its current cryptographic protection state, exposing every gap in one document.

Context: Before you can fix MedDefense's cryptographic posture, you need to see the full picture in one place. The vulnerability findings from 1x02 identified individual crypto weaknesses (TLS 1.0 on the portal, unencrypted backups, cleartext DICOM). The risk register in 1x03 tracked some of these as risks. But nobody has produced a systematic inventory that maps every category of data, in every state, to its current level of protection.

This is the document that makes the invisible visible. When you finish, every cell where it says "None" is a gap that the rest of this project will address.

Provided Files: meddefense-crypto-audit-notes.txt

Instructions: Produce a Data Protection Map for MedDefense. The map is a matrix that crosses data categories (rows) with data states (columns).

---

## MEDDEFENSE DATA PROTECTION MAP

### Cryptographic Protection Matrix

| Data Category | At Rest | In Transit | In Use |
|---|---|---|---|
| **1. Patient Medical Records (EHR)** | **None** | **Partial (Weak)** | **None** |
| | **Protection:** Ext4 filesystem, no disk encryption | **Protection:** PostgreSQL SSL available but not enforced; pg_hba.conf allows non-SSL connections from 10.10.0.0/16 | **Protection:** None; data decrypted in memory and displayed unencrypted on nurse station workstations |
| | **Evidence:** Audit notes (ehr-db-01); 1x00 observation - any root compromise exposes all plaintext records | **Evidence:** Finding 007 (scan) - LDAP signing not required; audit notes confirm "hostnossl" entries allow cleartext connections | **Evidence:** Audit notes - screensaver timeout set to "Never" in Group Policy; unattended workstations display PHI |
| | **Status:** ❌ ABSENT | **Status:** ⚠️ WEAK | **Status:** ❌ ABSENT |
| | | | |
| **2. Financial/Billing Data (MySQL)** | **None** | **None** | **None** |
| | **Protection:** Ext4 filesystem, no encryption; data directory readable from filesystem without MySQL credentials | **Protection:** None; MySQL bound to 0.0.0.0 without enforced SSL; plaintext MySQL protocol over flat network | **Protection:** None; billing staff access plaintext data from unencrypted connections |
| | **Evidence:** Audit notes (billing-srv-01); 1x00 crypto-miner incident - database files readable without credentials; forensics showed exfiltration risk | **Evidence:** Audit notes - no SSL enforcement; Finding 015 (scan) - NAS accessible from flat network indicates weak segmentation | **Evidence:** Audit notes - cleartext connections; no additional display-layer protection |
| | **Status:** ❌ ABSENT | **Status:** ❌ ABSENT | **Status:** ❌ ABSENT |
| | | | |
| **3. Medical Images (DICOM/PACS)** | **None** | **None** | **None** |
| | **Protection:** Local disk storage on pacs-srv-01 without encryption | **Protection:** DICOM protocol (ports 4242, 11112) operates in cleartext; DICOM TLS (DICOM PS3.15) not configured; headers contain PHI (name, DOB, MRN, study description) in plaintext | **Protection:** None; radiology workstations display DICOM images with embedded PHI unencrypted |
| | **Evidence:** Audit notes (pacs-srv-01); Finding 016 (scan) - DICOM cleartext noted | **Evidence:** Finding 016 (scan) - DICOM cleartext traffic confirmed; audit notes confirm TLS not implemented | **Evidence:** Audit notes - DICOM headers readable with standard viewers or text editor |
| | **Status:** ❌ ABSENT | **Status:** ❌ ABSENT | **Status:** ❌ ABSENT |
| | | | |
| **4. Credentials (Active Directory/Domain Auth)** | **Weak** | **Weak** | **Weak** |
| | **Protection:** NTHash (MD4-based) for NTLM backward compatibility; Kerberos supports AES-256, AES-128, RC4, DES but DES and RC4 remain enabled | **Protection:** LDAP signing not enforced; Kerberos tickets encrypted but weak cipher suites (RC4, DES) still negotiable; vulnerable to Kerberoasting | **Evidence:** Finding 018 (scan) - DES and RC4 encryption types enabled; no documentation of which systems require legacy support |
| | **Status:** ⚠️ WEAK | **Status:** ⚠️ WEAK | **Status:** ⚠️ WEAK |
| | | | |
| **5. Backup Data (NAS-01)** | **None** | **None** | **None** |
| | **Protection:** Synology RAID-5 without encryption layer; AES-256-CBC encryption feature available but not enabled; if enabled, key stored on same NAS (single point of failure) | **Protection:** No encryption for backup transmission; NAS DSM interface accessible over flat network | **Protection:** Backup staff access unencrypted backup data via plaintext NAS interface |
| | **Evidence:** Audit notes (NAS-01); Finding 015 (scan) - NAS management interface accessible from flat network | **Evidence:** Audit notes - NAS supports Synology encryption but not implemented; kill chain analysis shows NAS compromise as key ransomware step | **Evidence:** Audit notes - key concern: if backups encrypted on NAS but key stored on same NAS, ransomware could encrypt both backups and keys |
| | **Status:** ❌ ABSENT | **Status:** ❌ ABSENT | **Status:** ❌ ABSENT |
| | | | |
| **6. Email (O365)** | **Adequate** | **Adequate** | **Weak** |
| | **Protection:** Microsoft BitLocker on datacenter disks + per-mailbox encryption with Microsoft-managed keys | **Protection:** TLS 1.2 enforced for all Exchange Online connections (enforced by Microsoft in 2023) | **Protection:** S/MIME and Office Message Encryption (OME) not configured; sensitive PHI emailed in plaintext by physicians (audit notes) |
| | **Evidence:** Audit notes (O365 configuration) - Microsoft-managed encryption | **Evidence:** Audit notes - TLS 1.2 mandatory for O365 | **Evidence:** Audit notes - "I've told them not to email PHI. They do it anyway." - no technical enforcement of encryption for sensitive emails |
| | **Status:** ✅ ADEQUATE | **Status:** ✅ ADEQUATE | **Status:** ⚠️ WEAK |
| | | | |
| **7. VPN Traffic (Site-to-Site IPSec)** | **N/A** | **Adequate** | **N/A** |
| | **Protection:** N/A (VPN is in-transit only) | **Protection:** IPSec tunnels (Central↔Westside, Central↔HQ) encrypted with AES-256 + SHA-256 HMAC; key exchange via IKEv2 with DH Group 14 (2048-bit) | **Protection:** N/A (VPN is in-transit only) |
| | | **Evidence:** Audit notes - FortiGate configuration appears adequate; however, Westside endpoint terminated on Netgear Nighthawk consumer router with unknown firmware update history | **Evidence:** Concern: if consumer router's IPSec implementation has vulnerability, encryption compromised despite algorithm strength |
| | | **Status:** ✅ ADEQUATE* | |
| | | *[Caveat: dependent on consumer router firmware security] | |

---

## GAP SUMMARY

### Overall Crypto Coverage Analysis

**Total Cells Analyzed:** 21 cells (7 data categories × 3 states)

**Protection Breakdown:**

- ✅ **Adequate Protection:** 3 cells (14.3%)
  - Email: At Rest (BitLocker + per-mailbox encryption)
  - Email: In Transit (TLS 1.2)
  - VPN: In Transit (AES-256 + SHA-256, IKEv2)

- ⚠️ **Weak Protection:** 5 cells (23.8%)
  - Patient Records: In Transit (SSL available but not enforced)
  - Credentials: At Rest (NTHash + legacy encryption types)
  - Credentials: In Transit (LDAP not signed; RC4/DES negotiable)
  - Credentials: In Use (weak cipher suite negotiation)
  - Email: In Use (S/MIME not configured, plaintext PHI emails)

- ❌ **Absent Protection:** 13 cells (61.9%)
  - Patient Records: At Rest, In Use
  - Financial Data: All 3 states (At Rest, In Transit, In Use)
  - Medical Images: All 3 states (At Rest, In Transit, In Use)
  - Backups: All 3 states (At Rest, In Transit, In Use)

### Critical Risk Assessment

**Highest Priority Gaps (Patient Safety & Privacy Impact):**

1. **Medical Images (DICOM) - All States (Absent):** 9.1% of data protection coverage
   - **Impact:** DICOM files embedded with PHI (name, DOB, MRN) transmitted in cleartext; HIPAA violation risk
   - **Regulatory Consequence:** Mandatory breach notification if exfiltrated
   
2. **Patient Medical Records - At Rest (Absent):** 9.1% of data protection coverage
   - **Impact:** Unencrypted PostgreSQL data directory; any root compromise or physical theft exposes all patient records
   - **Clinical Consequence:** Patient harm if records modified; diagnosis/treatment history corruption
   
3. **Backup Data - All States (Absent):** 9.1% of data protection coverage
   - **Impact:** All backups (including exfiltrated databases) stored unencrypted on NAS; ransomware target
   - **Operational Consequence:** Backups compromised = no recovery option if systems encrypted

4. **Financial Data - All States (Absent):** 9.1% of data protection coverage
   - **Impact:** SSNs, credit card data, insurance policy numbers stored and transmitted in plaintext
   - **Regulatory Consequence:** PCI-DSS non-compliance; mandatory notification if exfiltrated

5. **Active Directory Encryption Types - All States (Weak):** 14.3% of data protection coverage
   - **Impact:** RC4/DES negotiable; Kerberoasting attacks can crack offline; NTLM MD4 hash breakable
   - **Attack Consequence:** Domain compromise; lateral movement to all systems

### Crypto Coverage Percentage

```
Adequate Coverage:  3/21 = 14.3%
Weak Coverage:      5/21 = 23.8%
Absent Coverage:   13/21 = 61.9%

Overall Secure Coverage (Adequate + Weak): 38.1%
Cryptographic Protection Gaps:             61.9%
```

**Conclusion:** MedDefense currently protects only **14.3% of critical data flows adequately**. The organization has a **61.9% cryptographic protection gap** that must be remediated across the next phases of this project. The weakest areas (Patient Records, Medical Images, Financial Data, Backups) coincide with the highest-value targets in the ransomware attack scenarios identified in 1x01 threat landscape.

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 0-crypto_inventory.md

================================================================================
          MEDDEFENSE HEALTH SYSTEMS
          Cryptographic Audit Notes
          Prepared by: Sarah Park (IT Director)
          Date: [Week 5, Day 1]
          Purpose: Inventory of current encryption state across all systems
          Status: Working notes, not a formal assessment
================================================================================

NOTES FROM SARAH PARK:

James asked me to document what we currently encrypt and what we
don't. I went through every major system and service. Some of this
I already knew. Some of it... I wish I didn't know.

========================================================================
PATIENT DATA (EHR System: ehr-srv-01 / ehr-db-01)
========================================================================

Database: PostgreSQL 14 on ehr-db-01
  Encryption at rest: NONE. The PostgreSQL data directory is stored
  on an ext4 filesystem with no encryption layer. If someone gets
  root on the server (or pulls the drive), every patient record is
  readable in plaintext.

  Encryption in transit: PARTIAL. The EHR application (ehr-srv-01)
  connects to the database (ehr-db-01) over the local network.
  PostgreSQL is configured with ssl=on, but the pg_hba.conf allows
  non-SSL connections from the 10.10.0.0/16 range ("hostnossl" lines
  exist alongside "hostssl" lines). This means the application
  COULD connect without encryption, and we have no way to confirm
  which connections are encrypted and which are not.

  Encryption in use: NONE. When a clinician views a patient record,
  it is decrypted in memory on ehr-srv-01 and transmitted to the
  browser. No additional protection exists for data being actively
  processed. The nurse station workstations do not lock automatically
  (screensaver timeout is set to "Never" in Group Policy).

========================================================================
FINANCIAL DATA (Billing: billing-srv-01)
========================================================================

Database: MySQL on billing-srv-01
  Encryption at rest: NONE. Same situation as PostgreSQL. The MySQL
  data directory sits on an unencrypted ext4 filesystem. The
  billing database contains: patient names, dates of birth, SSNs,
  insurance policy numbers, credit card last-4-digits, and 3 years
  of billing records.

  NOTE from the crypto-miner incident (1x00): during the forensic
  review after the crypto-miner was found on billing-srv-01, the
  incident responder noted that all database files were readable
  from the filesystem without needing MySQL credentials. This means
  the crypto-miner operator COULD have exfiltrated billing data,
  though there is no evidence they did.

  Encryption in transit: WEAK. MySQL is bound to 0.0.0.0 and does
  not enforce SSL for connections. The billing application connects
  via plaintext MySQL protocol over the flat network.

========================================================================
MEDICAL IMAGES (PACS: pacs-srv-01)
========================================================================

DICOM traffic: NONE. Medical images (MRI, CT, X-ray) are transmitted
between the MRI workstation (Windows XP), radiology workstations,
and the PACS server using the DICOM protocol on ports 4242 and
11112. DICOM does support TLS (DICOM TLS, defined in DICOM PS3.15),
but it is not configured on any MedDefense system. All imaging data,
including patient identifiers embedded in DICOM headers (name, DOB,
MRN, study description), traverses the network in cleartext.

Storage: NONE. PACS stores images on local disk without encryption.
The DICOM files contain embedded patient identifiers that are
readable with any DICOM viewer or even a text editor (the header
is partially plaintext).

========================================================================
CREDENTIALS (Active Directory: ad-dc-01 / ad-dc-02)
========================================================================

Password storage: Active Directory uses NTHash (MD4) by default for
NTLM compatibility. The domain controllers also support Kerberos
authentication with AES-256, AES-128, RC4, and DES encryption types.

Finding 018 from the vulnerability scan confirmed that DES and RC4
are still enabled. This means:
  1. Kerberoasting attacks can request RC4-encrypted service tickets
     and crack them offline (RC4 uses MD4/MD5 internally).
  2. DES is trivially breakable and should have been disabled years
     ago.
  3. The only reason these are still enabled is "legacy compatibility"
     but nobody has documented which systems actually require them.

LDAP: Not encrypted by default. Finding 007 from the scan confirmed
that LDAP signing is not required on the domain controllers.

========================================================================
BACKUP DATA (NAS-01)
========================================================================

Encryption: NONE. The Synology NAS stores all backup data on a
RAID-5 array with no encryption layer. The NAS management interface
(DSM) is accessible over the flat network (Finding 015 from scan).

If the NAS is compromised (which our kill chains showed is a key
step in the ransomware scenario), every backup, including database
dumps from PostgreSQL and MySQL, is readable in plaintext.

The NAS supports Synology's built-in "shared folder encryption"
feature (AES-256-CBC with key stored in... the NAS's key manager).
We have not enabled it. Sarah's note: "If we encrypt the backups
on the NAS and the key is stored on the NAS, and ransomware encrypts
the NAS, we lose both the backups AND the key. This needs to be
designed properly."

========================================================================
EMAIL (O365)
========================================================================

Microsoft handles encryption for O365:
  In transit: TLS 1.2 for all Exchange Online connections (Microsoft
  enforced this in 2023).
  At rest: BitLocker on Microsoft's datacenter disks + per-mailbox
  encryption (Microsoft-managed keys).
  S/MIME or OME: Not configured. MedDefense does not use email
  encryption for individual messages. Sensitive patient information
  is sometimes emailed between physicians in plaintext. Sarah's
  note: "I've told them not to email PHI. They do it anyway."

========================================================================
VPN TRAFFIC (Site-to-Site Tunnels)
========================================================================

Central to Westside: IPSec tunnel through the FortiGate.
  Encryption: AES-256 with SHA-256 for integrity.
  Key exchange: IKEv2 with DH Group 14.
  Status: Appears adequate based on the FortiGate configuration.

Central to HQ: IPSec tunnel through the FortiGate.
  Same configuration as above.

NOTE: The Westside consumer router (Netgear Nighthawk) terminates
one end of the VPN tunnel. The firmware update history on this
device is unknown. If the router's IPSec implementation has a
vulnerability, the tunnel's encryption could be compromised
regardless of the algorithm strength.

========================================================================
PATIENT PORTAL (web-srv-01)
========================================================================

TLS: WEAK. Finding 005 from the vulnerability scan confirmed:
  Supported: TLS 1.0 and TLS 1.2
  TLS 1.0 is vulnerable to BEAST, POODLE, Lucky Thirteen
  TLS 1.3: Not supported
  HSTS: Not configured
  OCSP Stapling: Not configured

Certificate: Finding 013 confirmed the SSL certificate expires in
23 days (now 18 days, as of this week). Auto-renewal is not
configured. The certificate is issued by Let's Encrypt with a
90-day validity period.

Cipher suites: Not documented. The default Apache configuration
is in use, which likely includes weak cipher suites alongside
strong ones.

========================================================================
SUMMARY FROM SARAH
========================================================================

"The short version: we encrypt almost nothing that we control.
Microsoft handles email encryption for us. The VPN tunnels are
encrypted (but one end is a consumer router). Everything else,
the patient database, the billing database, the medical images,
the backups, the Active Directory authentication, the patient
portal, is either unencrypted or using broken protocols.

The security strategy says 'implement encryption.' This audit
shows exactly where. Over to you."

========================================================================
                    END OF CRYPTO AUDIT NOTES
========================================================================
