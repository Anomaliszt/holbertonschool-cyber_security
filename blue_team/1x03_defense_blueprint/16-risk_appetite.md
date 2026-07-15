# MedDefense Risk Appetite

## Part 1 - Risk Appetite Statement
MedDefense has a **low overall risk appetite** for cybersecurity events that could affect patient safety, EHR availability, large-scale PHI exposure, or the hospital's ability to meet HIPAA and clinical continuity obligations. Risks with a credible path to patient harm, enterprise-wide outage, or reportable breach must be actively mitigated unless no practical treatment exists in the current operating period. MedDefense may accept limited residual risk where the treatment cost is disproportionate to the annualized loss or where operational constraints make immediate remediation impossible, but any acceptance above an inherent score of 12 requires documented approval by executive leadership. Risks involving direct patient safety require review by both executive leadership and the relevant clinical owner.

## Part 2 - The Three Decisions

### Risk: RISK-009
**Treatment Decision:** Accept  
**Authority:** CEO + Radiology Director + James Chen; this is their decision because it affects both patient-care operations and enterprise risk.  
**Justification:** Replacing the Windows XP MRI control workstation before the scanner lease expires would consume capital far beyond the year-1 security budget, while segmentation and monitoring reduce the ARO enough to make temporary acceptance rational.  
**Compensating Measure:** Dedicated VLAN isolation, deny-all outbound policy except approved support traffic, and flow monitoring from the Management Zone.  
**Review Trigger:** Lease milestone, vendor support change, segmentation exception, or any suspicious traffic involving the MRI VLAN.

### Risk: RISK-010
**Treatment Decision:** Accept  
**Authority:** CEO + James Chen; the decision is governance- and budget-driven because MedDefense is intentionally deferring outsourced 24/7 SOC services.  
**Justification:** Task 7 showed that a managed SOC is not cost-justified in year 1 given immature telemetry; the wiser investment is to fund SIEM/EDR first and revisit MDR once signal quality improves.  
**Compensating Measure:** Business-hours SIEM review, on-call escalation roster, critical alert paging, and badge log review for after-hours physical access.  
**Review Trigger:** Any overnight alert linked to critical assets, an incident missed after hours, or cyber insurance requirements changing.

### Risk: RISK-005
**Treatment Decision:** Accept (residual vendor risk after baseline controls)  
**Authority:** James Chen with CEO acknowledgment, because vendor access is required for operational support but remains a material enterprise trust decision.  
**Justification:** Eliminating vendor remote access entirely would impair EHR and medical system support; a full PAM/vendor-access platform this year would cost more than higher-priority year-1 controls. Accepting a reduced, monitored residual risk is more rational than attempting total elimination immediately.  
**Compensating Measure:** Vendor MFA, jump host access, approved maintenance windows, session logging, and zone-based restrictions.  
**Review Trigger:** Vendor security incident, access outside approved windows, or failure to enroll all vendor accounts in MFA.

## Part 3 - The Debate
### James Chen's argument for mitigation
The MRI workstation is a known unsupported Windows XP system tied to a critical diagnostic service. Even with segmentation, the hospital is knowingly carrying a legacy exploit surface that would be unacceptable anywhere else in the enterprise. Eighteen months is a long time in ransomware terms, and if the segmentation control fails, the organization has little technical recourse. From a security-first standpoint, the safest answer is to accelerate replacement or fund a stronger compensating architecture immediately.

### Robert Kim's argument for acceptance
Replacing or re-platforming the MRI control environment before the lease expires would consume capital far above the entire year-1 cyber budget and would displace controls that protect the whole hospital. The modeled ALE for the MRI risk is meaningful but still far lower than the hospital-wide ransomware and PHI breach risks. Because segmentation, deny rules, and monitoring can materially lower probability, a time-bound acceptance is economically rational. In short, the organization should not spend enterprise-level money to solve a lower-frequency risk ahead of higher-return controls.

### Verdict
Robert's reasoning is more persuasive **for the next 18 months**, but only if the acceptance is formal, monitored, and revisited on schedule. James is correct that unsupported clinical technology is strategically dangerous; however, the hospital gains more total risk reduction this year by funding MFA, segmentation, EDR, SIEM, and backup resilience first. The right decision is not to ignore the MRI risk—it is to **accept it transparently with strong compensating controls and a defined expiration date**.
