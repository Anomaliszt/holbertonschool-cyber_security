# Quantitative Risk Analysis Practice — SLE, ARO, ALE

## Scenario 1 - Ransomware Attack on `billing-srv-01`
**Asset Value (AV):** **$548,000**  
- Recovery / rebuild / forensics: $85,000  
- Revenue loss during 18 days of disruption: $16,000 × 18 = $288,000  
- HIPAA / breach penalty assumption: $100,000  
- Reputational and customer confidence impact estimate: $75,000  

**Exposure Factor (EF):** **80%**  
Reasoning: A ransomware event would not destroy the hospital permanently, but it would realize most of the downtime, recovery, penalty, and trust costs.

**SLE:** $548,000 × 0.80 = **$438,400**  
**ARO:** **0.30** (about once every 3.3 years)  
Reasoning: 1x01 threat intelligence placed comparable hospitals at roughly one ransomware event every 3-4 years.

**ALE:** $438,400 × 0.30 = **$131,520**  
**Confidence:** Medium  
**Most sensitive assumption:** ARO. If MedDefense's actual ransomware probability is closer to once every 2 years, the ALE rises sharply.

---

## Scenario 2 - Patient Data Breach via EHR System
**Asset Value (AV):** **$9,075,000**  
- 50,000 records × $165 per breached record = $8,250,000  
- Breach notification / credit monitoring: $25,000  
- Litigation exposure: $200,000  
- Patient attrition over 2 years: $600,000  

**Exposure Factor (EF):** **95%**  
Reasoning: Once a major EHR breach occurs, nearly all associated legal, notification, and trust costs are triggered.

**SLE:** $9,075,000 × 0.95 = **$8,621,250**  
**ARO:** **0.33** (about once every 3 years)  
Reasoning: Sector breach frequency is already high, and MedDefense is above average risk because it lacks SIEM, segmentation, and mature access control.

**ALE:** $8,621,250 × 0.33 = **$2,845,013**  
**Confidence:** Medium  
**Most sensitive assumption:** Breach scope. If fewer than 50,000 records are affected, the AV and ALE drop materially.

---

## Scenario 3 - Negligent Insider Data Theft
**Asset Value (AV):** **$120,000**  
This scenario already provides an average healthcare negligent insider incident cost covering investigation, containment, remediation, and reporting.

**Exposure Factor (EF):** **100%**  
Reasoning: If the incident happens, the organization incurs the full response cost profile.

**SLE:** $120,000 × 1.00 = **$120,000**  
**ARO:** **2.5**  
Reasoning: With 2,000 staff, weak training, no DLP, shared accounts, and no USB restriction, 2-3 incidents per year is credible.

**ALE:** $120,000 × 2.5 = **$300,000**  
**Confidence:** High  
**Most sensitive assumption:** Incident frequency. Better awareness training and USB control could reduce the ARO quickly.

---

## Scenario 4 - Medical Device Compromise
### 4A. Device Denial-of-Service / Quarantine Event
**Asset Value (AV):** **$255,000**  
- Pump replacement value: $105,000  
- Operational disruption: $20,000 × 5 days = $100,000  
- Investigation / validation / safety review estimate: $50,000  

**Exposure Factor (EF):** **60%**  
Reasoning: A DoS event would disrupt use and trigger validation costs, but it is unlikely to destroy every device fully.

**SLE:** $255,000 × 0.60 = **$153,000**  
**ARO:** **0.10**  
Reasoning: About once every 10 years under current conditions.

**ALE:** $153,000 × 0.10 = **$15,300**

### 4B. Patient Safety Event
**Asset Value (AV):** **$3,250,000**  
- Liability estimate midpoint: $3,000,000  
- FDA / regulatory investigation: $150,000  
- Operational disruption: $100,000  

**Exposure Factor (EF):** **90%**  
Reasoning: A true safety event would realize nearly all direct liability and regulatory cost.

**SLE:** $3,250,000 × 0.90 = **$2,925,000**  
**ARO:** **0.02**  
Reasoning: Roughly once every 50 years, but non-zero because default credentials and a flat network make the path plausible.

**ALE:** $2,925,000 × 0.02 = **$58,500**

### Combined Medical Device ALE
**Total ALE:** $15,300 + $58,500 = **$73,800**  
**Confidence:** Low  
**Most sensitive assumption:** Patient safety liability. A major injury case could exceed the midpoint estimate substantially.

---

## Scenario 5 - VPN Compromise Leading to Full Network Access
**Asset Value (AV):** **$10,023,000**  
- Scenario 1 AV (billing ransomware path): $548,000  
- Scenario 2 AV (EHR breach path): $9,075,000  
- AD / enterprise rebuild and containment estimate: $400,000  

**Exposure Factor (EF):** **70%**  
Reasoning: A VPN compromise does not guarantee the absolute worst case, but on a flat network it can trigger a multi-system breach and ransomware campaign.

**SLE:** $10,023,000 × 0.70 = **$7,016,100**  
**ARO:** **0.30**  
Reasoning: 1x01 identified VPN compromise as a meaningful healthcare access vector, and MedDefense lacks confidence in patch cadence and MFA maturity.

**ALE:** $7,016,100 × 0.30 = **$2,104,830**  
**Confidence:** Low-Medium  
**Most sensitive assumption:** Exposure factor. If a VPN compromise is contained before domain escalation, loss would be far lower.

---

## Ranking by ALE
| Rank | Scenario | ALE |
|---|---|---:|
| 1 | EHR patient data breach | $2,845,013 |
| 2 | VPN compromise / full network access | $2,104,830 |
| 3 | Negligent insider data theft | $300,000 |
| 4 | Billing ransomware | $131,520 |
| 5 | Medical device compromise (combined) | $73,800 |

## Takeaway
The math shows why MedDefense cannot budget only against point failures. The largest annualized loss does not come from replacing hardware; it comes from **data breach, enterprise access, and prolonged operational disruption**.
