## DATA CLASSIFICATION MATRIX FOR MEDDEFENSE

### PART 1: Data Type Inventory

| Data Type | Examples | Classification Level | Encryption Required | Retention |
|---|---|---|---|---|
| **Regulated/PHI** | Patient name, SSN, DOB, medical records, diagnoses, medications, lab results, imaging, vital signs | Restricted | AES-256 at rest + in transit | 7 years (minimum) |
| **PII (Non-PHI)** | Employee personal information, contractor details, staff directory (not public) | Confidential | AES-256 at rest; TLS in transit | Per employee agreement |
| **Financial** | Patient billing, insurance claims, credit card data, payment records | Confidential / Restricted | AES-256 at rest; PCI-DSS compliance required | 7 years |
| **Intellectual Property** | Treatment protocols, clinical research, proprietary workflows | Confidential | AES-256 at rest; restricted access | Duration of value |
| **Legal/Compliance** | HIPAA audit logs, incident reports, litigation files, compliance documentation | Confidential / Restricted | AES-256 at rest; access restricted | Per legal hold |
| **Operational** | Staff schedules, facility maintenance, equipment inventory, vendor contacts, hospital address/hours | Internal | Optional encryption; TLS for network | Until superseded |

---

### PART 2: Classification Levels

#### Level 1: PUBLIC
- **Who can access:** General public, website visitors, media, anyone
- **Examples:** Hospital address, visiting hours, general facility information, public research publications
- **Encryption Required:** None (publicly available anyway)
- **If exposed:** No regulatory impact; no patient harm
- **Marking:** [PUBLIC]

#### Level 2: INTERNAL
- **Who can access:** MedDefense staff only (employees + authorized contractors)
- **Examples:** Staff directory, meeting schedules, internal policies, non-sensitive operational data, facility information
- **Encryption Required:** Recommended for in-transit (TLS); optional at rest
- **If exposed:** Information about operations disclosed; no patient data compromised
- **Marking:** [INTERNAL]

#### Level 3: CONFIDENTIAL
- **Who can access:** Authorized personnel based on job function (finance, compliance, management)
- **Examples:** Financial reports, vendor contracts, salary information, insurance policy details (non-patient), facility security plans
- **Encryption Required:** AES-256 at rest; TLS 1.2+ in transit; access control enforced
- **If exposed:** Breach of confidentiality; potential competitive harm; regulatory inquiry likely
- **Marking:** [CONFIDENTIAL]

#### Level 4: RESTRICTED
- **Who can access:** Specific individuals with explicit need-to-know (clinicians for their patients, admins for systems they manage)
- **Examples:** Patient medical records, PHI, credentials, encryption keys, genetic data, mental health records, HIV status
- **Encryption Required:** AES-256-GCM at rest (mandatory); AES-256 in transit (mandatory); encryption keys in HSM
- **If exposed:** HIPAA violation; mandatory breach notification; patient harm; criminal liability possible
- **Marking:** [RESTRICTED]

---

### PART 3: Classification Decision Tree

```
START: I have a new data type to classify.

  ├─ Does it contain PATIENT MEDICAL INFORMATION (name, SSN, diagnosis, medication, lab, imaging)?
  │  ├─ YES → RESTRICTED (PHI/HIPAA-regulated)
  │  └─ NO → Continue...
  │
  ├─ Does it contain FINANCIAL INFORMATION (credit cards, billing, insurance, SSN for billing)?
  │  ├─ YES → CONFIDENTIAL or RESTRICTED (depends on financial sensitivity; credit card → RESTRICTED)
  │  └─ NO → Continue...
  │
  ├─ Does it contain PASSWORDS, ENCRYPTION KEYS, or CREDENTIALS?
  │  ├─ YES → RESTRICTED (if compromised, entire systems at risk)
  │  └─ NO → Continue...
  │
  ├─ Does it contain EMPLOYEE PERSONAL INFORMATION (home address, salary, SSN)?
  │  ├─ YES → CONFIDENTIAL
  │  └─ NO → Continue...
  │
  ├─ Does it contain FACILITY SECURITY INFORMATION (floor plans with security cameras, alarm codes, access control systems)?
  │  ├─ YES → CONFIDENTIAL or RESTRICTED (depends on critical nature)
  │  └─ NO → Continue...
  │
  ├─ Does it contain RESEARCH or INTELLECTUAL PROPERTY?
  │  ├─ YES → CONFIDENTIAL (publication pending) or INTERNAL (published)
  │  └─ NO → Continue...
  │
  ├─ Is it STAFF DIRECTORY, MEETING SCHEDULES, or GENERAL OPERATIONAL DATA?
  │  ├─ YES → INTERNAL
  │  └─ NO → Continue...
  │
  └─ Is it PUBLICLY AVAILABLE INFORMATION?
     ├─ YES → PUBLIC
     └─ UNCERTAIN? → CONFIDENTIAL (default to higher classification if uncertain)

END: Data classified.
```

---

### PART 4: Sovereignty and Geolocation Requirements

**HIPAA Compliance:** HIPAA does not explicitly require data residency within the US, but CMS guidance strongly recommends it. Business Associate Agreements (BAAs) with cloud providers must specify data location.

**MedDefense Policy:**
- All PHI must be stored in US data centers (East Coast preferred for latency to hospital locations)
- If using cloud services (AWS, Azure, Google Cloud), must be configured with US data centers only
- Backup data must be geographically separate from production (disaster recovery) but still in US
- No patient data shall be processed, stored, or transmitted outside the US without explicit legal review

**Practical Implementation:**
- Patient records database: On-premises in hospital data center (maximum control)
- Backups: On-premises in separate location OR AWS US regions (us-east-1, us-west-2 only)
- Email (O365): Microsoft US data centers (standard Office 365 configuration for healthcare)
- VPN: All endpoints must be in US locations

