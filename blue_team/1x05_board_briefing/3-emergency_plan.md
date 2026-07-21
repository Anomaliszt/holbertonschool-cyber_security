# MedDefense 72-Hour Emergency Response Plan

**Prepared for:** Board Meeting, 9:00 AM  
**Threat:** Crimson Tide ransomware campaign (CISA AA26-077A)  
**Risk Level:** CRITICAL (3 victims in MedDefense region, 1 actively compromised 45 miles away)  
**Execution Window:** 72 hours (tonight through Friday, 11:59 PM)

---

## TIER 1: TONIGHT (0-12 hours) — Immediate Actions

**Owner Responsibility:** James Chen (CISO) + Sarah Park (IT Director) + On-Call IT Staff  
**Timeline:** Start NOW, complete by 6:00 AM  
**Budget Impact:** $0 (use existing staff + budget authority)  
**Risk of Implementation:** MINIMAL (read-only checks, isolated testing, no production impact)

---

### Tier 1, Action 1: FortiGate Firmware Version Verification and Audit

**Action:**  
1. James Chen and Sarah Park: SSH to FW-01 FortiGate as admin (or use FortiGate web console)
2. Execute command: `get system status` (shows firmware version, serial number, license status)
3. Document exact FortiOS version (e.g., 7.2.3 or 7.0.8)
4. If version is 7.2.0-7.2.4 or 7.0.0-7.0.11: **ALERT — IMMEDIATELY VULNERABLE**
5. If version is 7.2.5+ or 7.0.12+: **SAFE — ALREADY PATCHED**
6. Review FortiGate logs for indicators of compromise (see IOCs in 0-advisory_analysis.md):
   - Unusual `/remote/logincheck` requests in access logs
   - Unexpected VPN sessions (review active VPN user list: `diagnose user get`; compare to known admin VPN credentials)
   - Suspicious CLI commands executed (review FortiGate audit log for `show system interface`, `show system route`, etc.)
   - Large outbound data transfers (check interface statistics: `diagnose hardware sensors view` + `get system performance status`)

**Phase Blocked:** Phase 1 (Initial Access) — Verification prevents "attack already in progress" scenario  
**Owner:** James Chen (firmware query), Sarah Park (log review)  
**Prerequisites:** None. FortiGate admin credentials already known.  
**Expected Outcome:** Firmware version confirmed; no suspicious activity detected (or urgent escalation if found)  
**Time Estimate:** 30 minutes  
**Escalation:** If vulnerable firmware detected, immediately proceed to Tier 2, Action 1 (support contract + patch)

---

### Tier 1, Action 2: NAS-01 Physical Network Isolation

**Action:**  
1. Sarah Park: Physically disconnect the network cable from NAS-01 (Synology storage array in server room)
2. Verify NAS-01 status light shows no network activity (LED should stop blinking)
3. Document cable removal in change log with timestamp
4. Inform backup team: "NAS-01 is offline; backups will queue locally until restoration. Do NOT connect NAS-01 to network without CISO approval."
5. Test local backup queue on backup-srv-01 (Veeam): Verify that backup jobs queue and do not fail due to NAS-01 unavailability

**Phase Blocked:** Phase 5 (Backup Destruction) — Isolates backup storage from network, preventing ransomware from reaching NAS-01  
**Owner:** Sarah Park (IT staff)  
**Prerequisites:** None. Physical access to server room.  
**Expected Outcome:** NAS-01 completely isolated from network; backups queue locally without failure  
**Time Estimate:** 15 minutes  
**Escalation:** If backup jobs fail after NAS-01 disconnect, Tier 2 action needed (configure local backup queue)  
**CRITICAL NOTE:** This is the highest-ROI action in Tier 1. An unencrypted, network-accessible NAS is a guaranteed ransomware disaster. Physical isolation = instant 100% protection.

---

### Tier 1, Action 3: Incident Response Team Activation

**Action:**  
1. James Chen: Send email to Board (Dr. Morales, Robert Kim, Dr. Reeves) and Legal (Maria Santos) with subject line "SECURITY ALERT: Activating Incident Response for Ransomware Threat"
2. Include: Current threat status (Crimson Tide in region), summary of 0-advisory_analysis.md findings, Tier 1 actions underway, Tier 2 actions pending Board approval
3. Establish 24/7 on-call escalation: James Chen (primary), Sarah Park (backup), IT on-call staff
4. Set up emergency communication channel: Slack channel `#security-incident` for real-time updates
5. Brief on-call staff: What to watch for? (See IOCs: unusual data transfers, GPO changes, VSS deletion commands, rclone.exe appearing, new domain admins created, unusual admin logins at odd hours)

**Phase Blocked:** Phase 7 (Extortion/Response) — Establishes 24/7 monitoring and rapid escalation for early detection  
**Owner:** James Chen (Board notification), Sarah Park (team coordination)  
**Prerequisites:** None.  
**Expected Outcome:** Board is informed; IR team is on standby; monitoring is active  
**Time Estimate:** 20 minutes

---

### Tier 1, Action 4: FortiGate Log Capture and Archival

**Action:**  
1. James Chen: SSH to FW-01 and execute FortiGate backup command:  
   `execute backup full-config ftp://[backup-srv-01-IP]/fortigate_config_backup_[DATE].bak admin [password]`
2. Alternatively, download FortiGate configuration via web console: System → Configuration → Backup
3. Capture the last 7 days of FortiGate logs:  
   `diagnose debug service fortimanager4 5` (to confirm logging is working)  
   Save logs to external USB or backup server (NOT on FortiGate itself)
4. Archive on backup-srv-01 for forensic analysis if incident occurs

**Phase Blocked:** Phase 1-2 — Preserves evidence if FortiGate has been compromised; allows forensic analysis of attack timeline  
**Owner:** James Chen  
**Prerequisites:** FortiGate admin credentials, backup server access  
**Expected Outcome:** Full FortiGate config + 7-day logs archived off-device  
**Time Estimate:** 20 minutes

---

## TIER 2: TOMORROW (12-36 hours) — Urgent Actions Requiring Board Approval

**Owner Responsibility:** James Chen + Sarah Park + Board authorization  
**Timeline:** 7:00 AM - 9:00 PM (during business hours)  
**Budget Impact:** $2,400 (FortiGate support contract) + potential after-hours labor  
**Risk of Implementation:** MODERATE (FortiGate patching requires brief maintenance window; AD Kerberos changes require careful testing)

---

### Tier 2, Action 1: FortiGate Support Contract Renewal and Emergency Patching

**Action:**  
1. **Board Approval (9:00 AM meeting):** Request emergency spending authorization for $2,400 Fortinet support contract renewal
2. **Post-approval (10:00 AM):** Robert Kim (CFO) initiates contract renewal with Fortinet sales (reference account number, FortiGate serial number)
3. **Contract Active (estimated 11:00 AM-12:00 PM):** Sarah Park downloads FortiOS 7.2.5 (if on 7.2.x) or 7.0.12 (if on 7.0.x) from Fortinet Customer Support Portal
4. **Maintenance Window (12:00 PM-1:00 PM):** Schedule 1-hour maintenance window; notify clinical staff via Dr. Reeves (Director of Clinical Operations) of brief VPN/internet connectivity interruption
5. **Patching (12:30 PM):** James Chen executes firmware upgrade on FW-01:
   ```
   execute restore image [upgrade_file].bin
   # System will reboot and apply patch
   ```
6. **Post-Patch Verification (1:15 PM):** 
   - Confirm FortiOS version = 7.2.5+ or 7.0.12+
   - Run `diagnose firewall policy validate` to confirm ACL integrity
   - Test VPN connectivity: Ensure admin can connect via VPN, confirm MFA works (if enabled)
   - Monitor FortiGate CPU/memory (should be normal, 10-20%, not spiked)
7. **Document:** Update Asset Registry to show FW-01 firmware version = [new version] and patch date

**Phase Blocked:** Phase 1 (Initial Access) — Closes CVE-2023-27997 vulnerability entirely  
**Owner:** James Chen (technical), Sarah Park (scheduling), Robert Kim (budget), Dr. Reeves (clinical notification)  
**Prerequisites:** Board approval in Tier 2; Fortinet support contract renewal  
**Expected Outcome:** FortiGate patched to safe version; CVE-2023-27997 no longer exploitable on MedDefense infrastructure  
**Time Estimate:** 6 hours (contract process + maintenance window)  
**Escalation:** If patch fails, rollback to pre-patch backup; engage Fortinet TAC support immediately  
**CRITICAL:** This is the single highest-priority Tier 2 action. No other action matters if FortiGate remains exploitable.

---

### Tier 2, Action 2: Active Directory RC4 Kerberos Disablement

**Action:**  
1. **Testing Window (2:00 PM tomorrow):** James Chen tests on non-production DC (or AD lab) first:
   - Execute PowerShell as Domain Admin:
   ```powershell
   # Disable RC4 and DES, enable AES-only
   Get-GPO -Name "Default Domain Policy" | Set-GPRegistryValue -Key "HKLM\System\CurrentControlSet\Services\Kdc" -ValueName "SupportedEncryptionTypes" -Type DWord -Value 32 (AES-only flag)
   ```
   - Test: `kinit` from a workstation (should negotiate AES, not RC4)
   - Confirm no authentication failures on existing user logins
2. **If no issues found:** Deploy to production domain via Group Policy:
   - Update Default Domain Policy on ad-dc-01 and ad-dc-02
   - GPO applies to all systems within 1 hour (before end of business)
3. **Monitoring:** Watch for authentication failures or service tickets with RC4 (should disappear)
4. **Rollback plan:** If production authentication breaks, revert GPO within 5 minutes

**Phase Blocked:** Phase 3 (Lateral Movement) — Eliminates Kerberoasting attack path; forces AES encryption, making offline cracking infeasible  
**Owner:** James Chen (AD admin)  
**Prerequisites:** AD admin credentials; testing environment available; IR team on standby for rollback  
**Expected Outcome:** All Kerberos traffic uses AES instead of RC4; Kerberoasting becomes ineffective  
**Time Estimate:** 4-6 hours (testing + deployment + monitoring)  
**Risk:** If GPO deployed without testing, could break authentication for some services; have rollback ready  
**Escalation:** If authentication failures occur, revert GPO immediately and investigate service ticket requirements

---

### Tier 2, Action 3: VPN Multi-Factor Authentication (MFA) Enablement

**Action:**  
1. **Prerequisites:** Confirm FortiGate has been patched to 7.2.5+ or 7.0.12+ (from Tier 2 Action 1)
2. **MFA Token Provisioning:** Work with Fortinet support to provision TOTP-based MFA for admin VPN users:
   - James Chen, Sarah Park, Dr. Reeves, clinical engineering staff (anyone with VPN access)
   - Use FreeOTP or Authy app on admin smartphones
3. **FortiGate Configuration (3:00 PM):** James Chen edits FortiGate firewall policy:
   ```
   Edit VPN policy:
   - Require two-factor authentication = YES
   - Accepted authentication methods = TOTP + password
   ```
4. **Testing (3:15 PM):** Each admin tests VPN login: must enter username + password + TOTP token to connect
5. **Enable VPN block-all rule (backup):** If MFA not in use, VPN access is denied (defense-in-depth)

**Phase Blocked:** Phase 2 (Reconnaissance) — Even if VPN credentials are stolen, attacker cannot authenticate without TOTP token  
**Owner:** James Chen (MFA setup + configuration)  
**Prerequisites:** FortiGate patched; Fortinet support access; admin smartphones  
**Expected Outcome:** All VPN users required to use MFA; VPN credentials alone are insufficient for attacker  
**Time Estimate:** 4-5 hours (token provisioning + testing + policy update)

---

## TIER 3: THIS WEEK (36-72 hours) — Strategic Actions Requiring Vendor/Planning

**Owner Responsibility:** James Chen + Sarah Park + Board funding  
**Timeline:** Thursday-Friday (36-72 hours)  
**Budget Impact:** $15,000-$25,000 (EDR software, SIEM pilot, segmentation switch config)  
**Risk of Implementation:** MODERATE-HIGH (network changes require testing; EDR deployment requires endpoint coordination)

---

### Tier 3, Action 1: Network Segmentation Planning and Switch Configuration

**Action:**  
1. **Design Review (Wednesday evening, 6:00 PM):** James Chen and Sarah Park review network segmentation design from 1x03 strategy
2. **Procurement (Thursday morning, 8:00 AM):** Initiate procurement for additional managed switches or VLAN licensing if needed (estimated cost: $3,000-$5,000)
3. **Switch Configuration (Thursday afternoon):** Network engineer (contract if needed) configures Cisco switches and FortiGate ACLs:
   - Server VLAN: 10.20.0.0/24 (production servers only)
   - Workstation VLAN: 10.30.0.0/24 (clinical staff, admin workstations)
   - Medical Device VLAN: 10.40.0.0/24 (infusion pumps, monitors, PACS)
   - Management VLAN: 10.50.0.0/24 (FortiGate, switches, SIEM if deployed)
   - Guest/Test VLAN: 10.60.0.0/24 (guest WiFi, testing)
4. **Firewall Rules (Thursday):** Implement ACLs on FW-01 to deny inter-VLAN traffic except:
   - Workstations → Servers (TCP 3306, 5432 for DB access)
   - Workstations → Medical Device VLAN (limited to authorized devices, DICOM port 104 for PACS)
   - Servers → Servers (internal communication)
   - Management VLAN → All (for admin access)
5. **Staged Rollout (Friday):** Move systems incrementally to correct VLAN (test each move to ensure connectivity before next)
6. **Validation (Friday EOD):** Confirm no legitimate traffic is blocked; measure internal data transfer performance

**Phase Blocked:** Phase 3 (Lateral Movement) — Prevents RDP/SSH/WMI from workstation to server unless explicitly allowed by ACL  
**Owner:** James Chen (design), Sarah Park (implementation), Contract network engineer (switch configuration)  
**Prerequisites:** Board approval for budget; vendor procurement (if switches needed)  
**Expected Outcome:** Flat network (10.10.0.0/16) broken into isolated VLANs; inter-VLAN traffic restricted by firewall rules  
**Time Estimate:** 16-20 hours (design + procurement + config + testing + validation)  
**Escalation:** If performance degrades after segmentation, adjust ACL rules to allow necessary traffic

---

### Tier 3, Action 2: Endpoint Detection and Response (EDR) Pilot Deployment

**Action:**  
1. **Vendor Selection (Thursday morning):** Evaluate EDR solutions (CrowdStrike, Falcon, Microsoft Defender for Endpoint ATP, or Sophos Intercept X)
   - Estimated cost: $100-$150 per endpoint/year; MedDefense has 80 endpoints = $8,000-$12,000/year
2. **Pilot Phase (Thursday):** Deploy EDR agent to 10 critical systems first:
   - ad-dc-01, ad-dc-02 (domain controllers)
   - ehr-srv-01, pacs-srv-01, backup-srv-01, billing-srv-01 (critical servers)
   - 4 clinical workstations (test endpoints)
3. **Configuration:** Enable behavioral monitoring, process injection detection, ransomware detection rules
4. **Testing (Friday):** Generate test alerts to confirm EDR is detecting:
   - Executable injection attempts
   - Suspicious PowerShell scripts
   - Unauthorized admin access
   - Ransomware behavioral patterns (mass file encryption attempts)
5. **Full Rollout (Week of next Monday):** Deploy EDR to remaining 70 endpoints

**Phase Blocked:** Phase 6 (Ransomware Deployment) — EDR would detect ransomware process injection and mass file encryption, alert SOC, allow manual intervention  
**Owner:** James Chen (vendor evaluation), Sarah Park (deployment)  
**Prerequisites:** Board approval for $8K-$12K annual budget; vendor contract signed  
**Expected Outcome:** EDR monitoring active on all critical systems; ransomware behavioral detection enabled  
**Time Estimate:** 12-16 hours (vendor selection + pilot + configuration + testing)

---

### Tier 3, Action 3: Backup Encryption and Immutable Cloud Replica (Design Phase)

**Action:**  
1. **Design Review (Thursday):** James Chen and Sarah Park review backup encryption strategy from 1x04:
   - Implement LUKS encryption on NAS-01 backup volume (using 12-luks_manager.sh script)
   - Establish immutable cloud backup to AWS S3 with MFA Delete enabled
   - Separate encryption keys: Vault key for on-prem, AWS KMS key for cloud
2. **Procurement (Thursday-Friday):** 
   - AWS S3 account setup (if not already present): ~$0 base, pay-per-GB storage (~$0.03/GB/month; MedDefense = 2TB backup × $0.03 = ~$60/month)
   - Backup software upgrade to support cloud replication (if needed)
3. **Staging Environment Testing (Friday):** Test on lab backup volume before production:
   - LUKS volume creation and mounting
   - Cloud backup replication to S3
   - Immutability testing (attempt to delete S3 object, confirm rejection)
4. **Production Rollout (Week of next Monday):** Implement on NAS-01 after Board approval

**Phase Blocked:** Phase 5 (Backup Destruction) — Encryption + immutable cloud means attacker cannot destroy backups even if NAS-01 is compromised  
**Owner:** James Chen (design), Sarah Park (testing), Backup admin (rollout)  
**Prerequisites:** Board approval for AWS charges (~$60-$100/month); backup software vendor support  
**Expected Outcome:** Backup encryption active; immutable cloud replica in place; recovery is possible even if on-prem backups destroyed  
**Time Estimate:** 8-12 hours (design + testing + S3 setup)

---

## SUMMARY: What Gets Done When

| Tier | Phase | Timeline | Budget | Status | Impact |
|---|---|---|---|---|---|
| **Tier 1** | Tonight (0-12h) | FW version check, NAS isolation, IR activation, log archival | $0 | Ready to execute immediately | Stops nothing, but detects compromise and isolates backups |
| **Tier 2, Action 1** | Tomorrow AM (12-24h) | FortiGate patch (requires Board approval) | $2,400 | Requires Board YES vote at 9 AM | **BLOCKS PHASE 1** — Eliminates CVE-2023-27997 entirely |
| **Tier 2, Actions 2-3** | Tomorrow (12-36h) | RC4 disablement + VPN MFA | $0 | Can execute once FortiGate patched | Blocks phases 2-3 |
| **Tier 3** | Thursday-Friday (36-72h) | Segmentation, EDR, backup encryption | $15K-$25K | Requires Board approval for budget | Blocks phases 3, 5, 6 completely |

---

## Board Decision Points

**At 9:00 AM Board Meeting:**
1. **APPROVE** $2,400 emergency spending for FortiGate support contract renewal → Tier 2 Action 1 can proceed immediately
2. **APPROVE** $20,000 allocation for EDR, segmentation, and cloud backup → Tier 3 can proceed this week
3. **AUTHORIZE** James Chen and Sarah Park to execute Tier 1 actions tonight (already started)
4. **AUTHORIZE** clinical disruption window tomorrow 12:00-1:00 PM for FortiGate patching

**If Board does not approve emergency spending:**
- MedDefense remains exploitable to Crimson Tide
- Ransomware attack is likely within 3-5 days based on advisory timeline
- Recovery cost = $1.2M-$3.5M ransom + $2M HIPAA fines >> $22.4K emergency spend

**Recommendation:** APPROVE all emergency spending. The cost of inaction far exceeds the cost of action.
Risk of Action: [What could go wrong?]
Risk of Inaction: [What happens if this is not done?]
End with a Resource Conflict Assessment: Are any Tier 1 and Tier 2 actions in conflict (same person needed for multiple tasks, same system needing multiple changes) ? How do you resolve the conflicts ?

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x05_board_briefing
Fichier: 3-emergency_plan.md
