# MedDefense Quick Wins (0-14 Days)

## Quick Win #1: Remove Default Credentials from BD Alaris Pumps
**Risk Addressed:** RISK-007  
**Action:** Inventory each pump, change vendor-default admin passwords to unique credentials, store credentials in the approved admin vault, and validate logon failure with the old password.  
**Owner:** Clinical Engineering + Security Analyst  
**Timeline:** 2-5 days  
**Cost:** $0 (internal labor only)  
**Risk Reduction:** Breaks Kill Chain #5 at Step 1 by removing trivial administrative access to medical devices.  
**Verification:** Credential checklist signed for each device; sample retest confirms default credentials no longer work.

## Quick Win #2: Enable LDAP Signing and Disable SMBv1
**Risk Addressed:** RISK-004  
**Action:** Update domain controller settings, push GPO changes to pilot systems, validate business-critical applications, then roll out to all supported systems.  
**Owner:** Sarah Park  
**Timeline:** 3-7 days  
**Cost:** $0-$500 (staff overtime only)  
**Risk Reduction:** Disrupts Kill Chains #1 and #2 by blocking common relay-based escalation into Active Directory.  
**Verification:** GPO reporting, protocol validation, and follow-up vulnerability retest for Findings 018/019.

## Quick Win #3: Enforce MFA on VPN and Administrative Accounts
**Risk Addressed:** RISK-003  
**Action:** Inventory all admin and VPN-enabled accounts, remove stale entries, enroll remaining users in MFA, and disable legacy authentication where feasible.  
**Owner:** James Chen + Sarah Park  
**Timeline:** 5-10 days  
**Cost:** $0 incremental licensing; labor covered by existing staff  
**Risk Reduction:** Breaks Kill Chains #1, #2, and #3 by making stolen passwords alone insufficient.  
**Verification:** MFA enrollment report shows 100% of admin/VPN accounts protected.

## Quick Win #4: Block Unauthorized USB Storage and Reconfirm Guest/Personal Device Policy
**Risk Addressed:** RISK-006  
**Action:** Use Group Policy to block USB storage on standard workstations, circulate interim AUP guidance, and remove any unauthorized personal laptops from internal wired networks.  
**Owner:** Security Analyst + Desktop Support  
**Timeline:** 4-8 days  
**Cost:** $0  
**Risk Reduction:** Disrupts 1x01 insider scenario paths involving removable media and shadow IT.  
**Verification:** GPO applied to workstation OU; spot checks confirm USB storage is blocked.

## Quick Win #5: Restrict PostgreSQL Access to Approved Hosts Only
**Risk Addressed:** RISK-002  
**Action:** Tighten `pg_hba.conf`, apply host firewall rules, allow only the EHR app and backup systems, and confirm application connectivity.  
**Owner:** Server Team / Sarah Park  
**Timeline:** 2-4 days  
**Cost:** $0  
**Risk Reduction:** Breaks Kill Chain #1 at the data-access step by removing broad network reachability to the EHR database.  
**Verification:** Port scan from non-approved subnet fails; EHR application and backup jobs still function normally.

## Why Quick Wins Matter
Quick wins do more than reduce immediate risk. They show the Board and frontline staff that the security program can deliver visible improvement quickly, build trust in James and Sarah's leadership, create momentum for larger architecture changes, and prove that MedDefense is not waiting for a perfect future state before taking sensible action.
