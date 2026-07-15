# MedDefense Governance Architecture

## Part 1 - RACI Matrix

| Security Activity | CEO | Deputy CISO (James) | IT Director (Sarah) | Dept Heads | Security Analyst |
|---|---|---|---|---|---|
| Security budget approval | **A** | R | C | C | C |
| Vulnerability remediation | I | **A** | **R** | C | C |
| Incident response execution | I | **A** | **R** | C | **R** |
| Security policy approval | **A** | **R** | C | C | C |
| Risk acceptance decisions | **A** (Critical/High) | **R** | C | C | C |
| Security awareness training | I | **A** | C | **R** | **R** |
| Vendor risk assessment | I | **A** | C | C | **R** |
| Audit coordination | I | **A** | C | C | **R** |

**Interpretation:** James owns the security program, Sarah owns most technical execution, department heads own workforce compliance inside their areas, and the CEO retains final authority for budget, policy, and acceptance of material risk.

## Part 2 - Role Definitions

### Data Owner
**Assigned role:** Clinical and business department heads (for example, Radiology for PACS data, Finance for billing data, and the clinical leadership represented by Dr. Patel for patient-care records).  
**Meaning:** The data owner decides why the data exists, who should have access, and what level of protection is required.  
**Why this role fits:** Department leadership understands operational need, regulatory sensitivity, and the consequence of misuse better than IT alone.

### Data Controller
**Assigned role:** MedDefense executive leadership, operating through the CEO and Deputy CISO.  
**Meaning:** The controller determines the purposes and means of processing organizational data.  
**Why this role fits:** Under healthcare governance, the hospital itself decides how PHI, financial records, and workforce data are used and protected.

### Data Processor
**Assigned role:** Application support, business operations teams, and authorized workforce members processing data under MedDefense instruction.  
**Meaning:** Processors handle data as part of operational workflows but do not set the policy purpose of processing.  
**Why this role fits:** Clinicians, billing staff, and support teams use and update records to deliver care and run the business under the hospital's rules.

### Data Custodian / Steward
**Assigned role:** Sarah Park's IT operations team, with the security analyst providing control oversight.  
**Meaning:** Custodians implement the technical and operational safeguards that protect data in systems, backups, networks, and endpoints.  
**Why this role fits:** IT controls the infrastructure, permissions, backups, patching, and endpoint configuration that keep the data usable and protected.

## Part 3 - The CISO Question
MedDefense's vacant CISO role creates three immediate problems: no single executive owns enterprise security strategy end-to-end, risk acceptance can become informal or politically driven, and Board communication depends too heavily on operational staff. That increases the chance that security work remains reactive and fragmented between IT, compliance, and clinical leadership.

**Recommendation:** MedDefense should use a **vCISO model for year 1**, not hire a full-time CISO immediately. A strong full-time healthcare CISO would likely cost $180K-$250K in salary and benefits alone, which exceeds the current security investment envelope; a vCISO at roughly $40K-$60K annually can provide Board reporting, policy governance, and strategic oversight while James Chen remains the internal accountable deputy. This gives MedDefense executive-level security leadership now without crowding out the higher-priority control investments in segmentation, MFA, EDR, logging, and backup resilience.
