# MedDefense Defense Blueprint — Framework Landscape

## Part 1 - Three-Framework Summary

### NIST Cybersecurity Framework (CSF) 2.0
NIST CSF 2.0 is a voluntary cybersecurity framework published by the U.S. National Institute of Standards and Technology. Its purpose is to help organizations organize cybersecurity activity around business risk, using the six core functions: Govern, Identify, Protect, Detect, Respond, and Recover. It is structured as Functions, Categories, and Subcategories that describe desired outcomes rather than prescribing specific products. It is widely used by U.S. healthcare, state/local government, and private-sector organizations because it is flexible, business-oriented, and easy to use for Board reporting.

### CIS Controls v8
CIS Controls v8 is a prioritized set of security controls published by the Center for Internet Security. Its purpose is to translate broad security goals into concrete implementation actions, especially for organizations that need practical guidance on what to deploy first. It is structured into 18 Controls with Safeguards, organized across Implementation Groups (IG1-IG3). It is commonly used by security and IT operations teams that need an actionable baseline for hardening endpoints, identities, networks, logging, and recovery.

### ISO/IEC 27001
ISO/IEC 27001 is an international standard for establishing, operating, monitoring, and improving an Information Security Management System (ISMS). Its purpose is to prove that security is governed systematically through policy, risk management, control selection, internal audit, and management review. It is structured around management system clauses plus Annex A control domains. It is typically used by organizations that need external assurance for regulators, partners, insurers, or customers.

## Part 2 - Relationship Map
These frameworks are complementary, not competing. NIST CSF 2.0 gives MedDefense the strategic view of **what outcomes** must exist across governance, protection, detection, response, and recovery. CIS Controls v8 gives the hospital the operational detail of **how to implement** many of those outcomes in a practical order, which is especially valuable for a small team with a limited budget. ISO 27001 provides the management-system layer to **prove discipline and oversight** through documented policy, risk treatment, audit, and continuous improvement. For MedDefense, the best mental model is: **NIST CSF defines direction, CIS Controls drive implementation, ISO 27001 demonstrates governance maturity and auditability.**

## Part 3 - MedDefense Framework Selection
MedDefense should adopt **NIST CSF 2.0 as its strategic backbone** and use **CIS Controls v8 IG1/IG2 as the implementation baseline**. This combination fits a regional hospital with one security analyst, a deputy CISO, and a $120K annual security budget because it balances Board-level clarity with hands-on execution. MedDefense is not a federal agency and does not need the overhead of a full NIST RMF program, but it does need a framework that connects cyber risk to patient safety, HIPAA, ransomware resilience, and executive oversight. ISO 27001 should be treated as a **year-2 governance target**, not a year-1 operating framework; the hospital first needs basic controls, logging, segmentation, and recovery discipline before pursuing formal ISMS maturity or certification-style evidence. In short: **Adopt NIST CSF for strategy, CIS Controls for execution, and align future policy/audit work to ISO 27001 principles.**
