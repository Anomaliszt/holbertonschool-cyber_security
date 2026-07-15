# MedDefense Red Team Blueprint

## Part 1 - The Attacker's Perspective

### Which kill chain is still viable?
The kill chain that remains most viable after the year-1 controls is **Kill Chain #2: credential phishing leading to privileged abuse**. MFA on VPN and admin accounts, segmentation, EDR, SIEM, and immutable backups all make the original ransomware path much harder, but MedDefense still lacks phishing-resistant MFA for all users, user behavior analytics, DLP, PAM, and 24/7 monitoring. An attacker who steals a valid user session, waits for an overnight window, and moves carefully may still be able to harvest sensitive data before business-hours review catches the activity.

### Alternative attack path against deferred gaps
**BlackReef alternative sequence:**
1. Phish a clinician or billing user and capture a valid session token or consented cloud session rather than relying on a raw password.
2. Use that legitimate session after hours to access normal clinical workflows and identify high-value records that do not require admin access.
3. Because full medical device monitoring was deferred, pivot through a poorly monitored clinical subnet or legacy device-adjacent path to establish low-noise persistence.
4. Stage small-volume PHI exports over multiple nights, staying below simple threshold alerts while the hospital lacks 24/7 SOC coverage.
5. If valuable enough, return later through the same foothold or a trusted vendor path to escalate, disrupt, or extort.

### Insider scenario that remains dangerous
The most dangerous remaining insider scenario is still the **slow data theft pattern** from 1x01: a legitimate user exporting patient records in small batches that resemble normal work. Year-1 controls reduce USB and credential risk, but without DLP and mature behavior analytics, a motivated insider can still abuse legitimate access better than an external actor can.

## Part 2 - The Honest Assessment
**Residual risk rating:** **High**  
MedDefense's year-1 program meaningfully reduces catastrophic ransomware probability, but residual risk remains High because the hospital still depends on legacy medical technology, limited after-hours monitoring, and incomplete identity maturity.

**Single biggest remaining gap:** The largest remaining gap is **continuous monitoring and privileged activity visibility after hours**. SIEM and EDR create telemetry, but without MDR/SOC coverage or mature UBA/PAM, MedDefense will still rely heavily on business-hours response.

**#1 priority for next year's budget:** **24/7 managed detection and response with privileged activity monitoring.** Year 1 should build the telemetry foundation; year 2 should ensure that suspicious activity is actually reviewed fast enough to stop a determined attacker before impact.
