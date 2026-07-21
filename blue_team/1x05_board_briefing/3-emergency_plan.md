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

---

### Tier 1, Action 1: FortiGate Firmware Version Verification and Audit

**Phase Blocked:** Phase 1 (Initial Access)

**Action:**  
1. James Chen and Sarah Park: SSH to FW-01 FortiGate as admin (or use web console)
2. Execute: `get system status` (shows firmware version, serial, license status)
3. Document exact FortiOS version (e.g., 7.2.3 or 7.0.8)
4. If version 7.2.0-7.2.4 or 7.0.0-7.0.11: **IMMEDIATELY VULNERABLE**
5. If version 7.2.5+ or 7.0.12+: **ALREADY PATCHED**
6. Review FortiGate logs for IOCs: unusual /remote/logincheck requests, unexpected VPN sessions, suspicious CLI commands
7. Document findings and escalate if anomalies detected

**Owner:** James Chen (firmware), Sarah Park (log review)  
**Prerequisites:** FortiGate admin credentials (existing)  
**Expected Outcome:** Firmware version confirmed; no active compromise detected  
**Time Estimate:** 30 minutes

**Risk of Taking Action (Minimal):**
- Read-only verification; no system changes
- Brief console session; no production impact
- **Risk Level: NEGLIGIBLE** (<0.1% impact probability)

**Risk of NOT Taking Action (Critical):**
- If vulnerable firmware exists: **100% probability FortiGate will be targeted**
- If already compromised: Attack could be hours into initial compromise, destroying evidence window
- Tier 2 patching cannot proceed without knowing current firmware status
- **Expected Loss if Not Verified: $1.19M annual** (CVE-2023-27997 exploitation cost)

**Decision Rationale:** Risk of verification is zero; risk of inaction is $1.19M loss. **MANDATORY.**

---

### Tier 1, Action 2: NAS-01 Physical Network Isolation

**Phase Blocked:** Phase 5 (Backup Destruction)

**Action:**  
1. Sarah Park: Physically disconnect network cable from NAS-01 (Synology array in server room)
2. Verify NAS-01 LED stops blinking (no network activity)
3. Document cable removal in change log with timestamp
4. Notify backup team: "NAS-01 offline; backups queue locally. Do NOT reconnect without CISO approval."
5. Test backup-srv-01 local queue: Verify jobs queue and succeed without NAS-01

**Owner:** Sarah Park (IT staff)  
**Prerequisites:** Physical access to server room  
**Expected Outcome:** NAS-01 completely isolated; backups queue locally; no backup failures  
**Time Estimate:** 15 minutes

**Risk of Taking Action (Minimal):**
- Physical isolation of storage device; no production services affected
- Backups queue locally on backup-srv-01 (no loss of backup data)
- If issue: Simply reconnect cable, restore normal backup flow (15 minutes to undo)
- **Risk Level: MINIMAL** (easily reversible, no impact to running systems)

**Risk of NOT Taking Action (Catastrophic):**
- **100% probability ransomware will destroy backups** if compromised (flat network access)
- All backups on same network = single point of failure
- Hospital B scenario: backups encrypted, 14-day recovery time (vs. 48-hour recovery with isolated backup)
- **Expected Loss if Not Isolated: $200K-$400K** (backup destruction + extended recovery downtime)

**Decision Rationale:** Physical isolation is irreversible protection with zero implementation risk. **HIGHEST ROI in Tier 1. MANDATORY.**

---

### Tier 1, Action 3: Incident Response Team Activation

**Phase Blocked:** Phase 7 (Extortion/Response)

**Action:**  
1. James Chen: Email Board (Dr. Morales, Robert Kim, Dr. Reeves) and Legal (Maria Santos)
2. Subject: "SECURITY ALERT: Activating Incident Response for Ransomware Threat"
3. Include: Current threat status, findings summary, Tier 1 actions underway, Tier 2 pending approval
4. Establish 24/7 on-call escalation: James Chen (primary), Sarah Park (backup), IT on-call
5. Create emergency Slack channel: #security-incident for real-time updates
6. Brief on-call staff on IOCs: unusual data transfers, GPO changes, VSS deletion, rclone.exe, new domain admins, unusual admin logins

**Owner:** James Chen (Board notification), Sarah Park (team coordination)  
**Prerequisites:** None  
**Expected Outcome:** Board informed; IR team on standby; monitoring active  
**Time Estimate:** 20 minutes

**Risk of Taking Action (Minimal):**
- Communication and coordination only; no production changes
- If alert is false alarm: No negative consequence to Board/IR team being aware
- **Risk Level: NEGLIGIBLE** (pure information flow)

**Risk of NOT Taking Action (High):**
- If ransomware attack occurs and IR team is NOT activated: 2-4 hour detection/response delay
- Each hour of undetected attack = higher encryption scope, more backup deletion, more data exfiltration
- **Expected Loss if Delayed Response: $50K-$100K** (faster detection saves $50K+ in prevention scope)

**Decision Rationale:** Activation cost is zero; detection speed saves $50K+. **MANDATORY.**

---

### Tier 1, Action 4: FortiGate Log Capture and Archival

**Phase Blocked:** Phase 1-2 (Initial Access, Reconnaissance)

**Action:**  
1. James Chen: SSH to FW-01; execute backup command:
   ```
   execute backup full-config ftp://[backup-srv-01-IP]/fortigate_config_backup_[DATE].bak
   ```
2. Alternatively, download config via web console: System → Configuration → Backup
3. Capture last 7 days of FortiGate logs: Save to USB or backup-srv-01 (NOT on FortiGate)
4. Archive for forensic analysis if incident occurs

**Owner:** James Chen  
**Prerequisites:** FortiGate admin credentials (existing)  
**Expected Outcome:** Full config + 7-day logs archived off-device  
**Time Estimate:** 20 minutes

**Risk of Taking Action (Minimal):**
- Backup creation adds <100MB storage
- No performance impact on firewall
- If issue: Simply delete backup, create new one (no harm)
- **Risk Level: NEGLIGIBLE** (storage/logging only)

**Risk of NOT Taking Action (Moderate):**
- If FortiGate is compromised: Evidence window closes in 24-48 hours (logs overwritten)
- Forensic analysis becomes impossible; cannot determine attack timeline or method
- Regulatory investigation requirement (FBI, state Health Department) = forensic evidence mandatory
- **Expected Loss if Evidence Lost: $100K-$200K** (regulatory fines for "inadequate evidence preservation")

**Decision Rationale:** Backup cost is zero; evidence loss cost is $100K+. **MANDATORY.**

---

## TIER 2: TOMORROW (12-36 hours) — Urgent Actions Requiring Board Approval

**Owner Responsibility:** James Chen + Sarah Park + Board authorization  
**Timeline:** 7:00 AM - 9:00 PM (business hours)  
**Budget Impact:** $2,400 (FortiGate support) + labor  

---

### Tier 2, Action 1: FortiGate Support Contract Renewal and Emergency Patching

**Phase Blocked:** Phase 1 (Initial Access) — **CLOSES CVE-2023-27997 ENTIRELY**

**Action:**  
1. Board Approval (9:00 AM meeting): $2,400 emergency spending authorization
2. Post-approval (10:00 AM): Robert Kim initiates Fortinet contract renewal (account number, serial)
3. Contract Active (11:00 AM-12:00 PM): Sarah Park downloads FortiOS 7.2.5 or 7.0.12
4. Maintenance Window (12:00 PM-1:00 PM): 1-hour VPN/internet downtime; Dr. Reeves notifies clinical staff
5. Patching (12:30 PM): James Chen executes upgrade:
   ```
   execute restore image [firmware_file].bin
   # System reboots; patch applied
   ```
6. Post-Patch Verification (1:15 PM): 
   - Firmware version = 7.2.5+ or 7.0.12+
   - Run `diagnose firewall policy validate`
   - Test VPN connectivity
   - Monitor CPU/memory (should be normal)
7. Document: Update Asset Registry with new firmware version + patch date

**Owner:** James Chen (technical), Sarah Park (scheduling), Robert Kim (budget), Dr. Reeves (clinical notification)  
**Prerequisites:** Board approval in Tier 2; Fortinet contract activated  
**Expected Outcome:** FortiGate patched; CVE-2023-27997 no longer exploitable  
**Time Estimate:** 6 hours (contract process + maintenance + verification)

**Risk of Taking Action (Moderate):**
- 1-hour VPN/internet downtime during patch (maintenance window)
- If patch fails: Fallback to pre-patch backup; recovery = 30 minutes additional downtime
- During maintenance window: Physicians cannot access EHR via remote access (but on-site access works)
- **Risk Level: MODERATE** (1-hour controlled downtime; easily reversible)
- **Mitigation: Schedule during low-demand period (12 PM lunch hour); have rollback ready**

**Risk of NOT Taking Action (Catastrophic):**
- FortiGate remains vulnerable to CVE-2023-27997 (CVSS 9.2, actively exploited by Crimson Tide)
- If compromised: Attacker gains firewall access → can access internal network → ransomware deployment
- **Expected Loss if Not Patched: $1.19M** (annual loss from CVE exploitation)
- **Incident Probability if Not Patched: 95%** (within 30 days)

**Decision Rationale:** 1-hour maintenance window prevents $1.19M loss (1,207:1 ROI on time). **MANDATORY.**

---

### Tier 2, Action 2: Active Directory RC4 Kerberos Disablement

**Phase Blocked:** Phase 3 (Lateral Movement) — **ELIMINATES KERBEROASTING ATTACK**

**Action:**  
1. Testing Window (2:00 PM): James Chen tests on lab/non-prod DC first:
   ```powershell
   # Disable RC4 + DES; enable AES-only
   Get-GPO -Name "Default Domain Policy" | Set-GPRegistryValue `
     -Key "HKLM\System\CurrentControlSet\Services\Kdc" `
     -ValueName "SupportedEncryptionTypes" -Type DWord -Value 32
   ```
2. Test: `kinit` from workstation (verify AES negotiation, no RC4)
3. If successful: Deploy to production via Group Policy
4. Monitor: Watch for auth failures (should be none)
5. Rollback plan: If issues occur, revert GPO within 5 minutes

**Owner:** James Chen (AD admin)  
**Prerequisites:** AD admin credentials; test environment available; IR team on standby  
**Expected Outcome:** All Kerberos traffic uses AES; Kerberoasting ineffective  
**Time Estimate:** 4-6 hours (testing + deployment + monitoring)

**Risk of Taking Action (Moderate):**
- If GPO deployed without testing: Could break service authentication (e.g., SQL Server, Apache)
- Risk of service tickets failing for legacy applications that require RC4
- If failure occurs: Revert GPO takes 5 minutes; services recover within 15 minutes
- **Risk Level: MODERATE** (potential brief auth failures; fully reversible)
- **Mitigation: Test on lab DC first; have rollback plan ready; monitor first 2 hours**

**Risk of NOT Taking Action (High):**
- RC4 Kerberos remains enabled → Kerberoasting attack remains viable
- If attacker gains user password: Can perform Kerberoasting offline (extract all service account credentials in <30 min)
- **Expected Loss if Not Disabled: $400K-$600K** (domain credential compromise enables Phase 4-5 attacks)

**Decision Rationale:** Tested implementation with rollback is reversible; leaving RC4 enabled costs $400K+. **MANDATORY.**

---

### Tier 2, Action 3: VPN Multi-Factor Authentication (MFA) Enablement

**Phase Blocked:** Phase 2 (Reconnaissance) — **STOLEN CREDENTIALS INSUFFICIENT FOR ACCESS**

**Action:**  
1. Prerequisites: FortiGate patched (from Action 1)
2. MFA Token Provisioning: Work with Fortinet support to enable TOTP for all VPN admins
3. FortiGate Configuration (3:00 PM): James Chen edits VPN policy:
   ```
   Edit VPN policy: Require two-factor authentication = YES
   Accepted auth methods = TOTP + password
   ```
4. Testing (3:15 PM): Each admin tests VPN: username + password + TOTP token required
5. Enable VPN block-all rule (backup): If MFA not presented, deny access

**Owner:** James Chen (MFA setup + policy)  
**Prerequisites:** FortiGate patched; Fortinet support access; admin smartphones  
**Expected Outcome:** All VPN users required MFA; stolen credentials insufficient  
**Time Estimate:** 4-5 hours (token provisioning + configuration + testing)

**Risk of Taking Action (Minimal):**
- Adds 30 seconds to VPN login process (human usability minor impact)
- If TOTP token lost: Admin can use backup codes or Fortinet support to reset
- If issue: MFA can be disabled and re-enabled without loss of data
- **Risk Level: MINIMAL** (usability friction; fully reversible)

**Risk of NOT Taking Action (High):**
- If VPN credentials stolen: Attacker has immediate internal network access (no MFA barrier)
- Stolen creds = Lateral movement → Domain admin escalation → ransomware deployment
- **Expected Loss if MFA Not Enabled: $800K** (credential-based lateral movement enables phases 3-6)

**Decision Rationale:** 30-second VPN delay prevents $800K loss (ROI 26,667:1). **MANDATORY.**

---

## TIER 3: THIS WEEK (36-72 hours) — Strategic Actions Requiring Budget

**Owner Responsibility:** James Chen + Sarah Park + Board funding  
**Timeline:** Thursday-Friday (36-72 hours)  
**Budget Impact:** $15,000-$25,000 (segmentation, EDR, encryption design)

---

### Tier 3, Action 1: Network Segmentation Planning and Switch Configuration

**Phase Blocked:** Phase 3 (Lateral Movement) — **RESTRICTS RANSOMWARE PROPAGATION**

**Action:**  
1. Design Review (Wed 6 PM): Review 1x03 segmentation plan
2. Procurement (Thu 8 AM): Order managed switches (if needed) = $3K-$5K
3. Configuration (Thu PM): Network engineer configures VLANs:
   - Server VLAN: 10.20.0.0/24
   - Workstation VLAN: 10.30.0.0/24
   - Medical Device VLAN: 10.40.0.0/24
   - Management VLAN: 10.50.0.0/24
   - Guest VLAN: 10.60.0.0/24
4. Firewall Rules (Thu): Deploy ACLs on FW-01 restricting inter-VLAN traffic
5. Staged Rollout (Fri): Incrementally move systems; verify connectivity before each move
6. Validation (Fri EOD): Confirm legitimate traffic works; measure performance

**Owner:** James Chen (design), Sarah Park (impl), Network Engineer (switches)  
**Prerequisites:** Board approval for budget; vendor procurement  
**Expected Outcome:** Flat network segmented; inter-VLAN traffic restricted by ACL  
**Time Estimate:** 16-20 hours

**Risk of Taking Action (Moderate-High):**
- Network configuration changes always carry outage risk
- If ACL misconfigured: Some services may lose connectivity
- If switch firmware buggy: Brief outages possible during configuration
- **Risk Level: MODERATE** (recoverable via ACL rollback; estimated 1-2 hour potential disruption if issue occurs)
- **Mitigation: Test all moves on isolated network first; have rollback ACL ready; schedule during low-demand window**

**Risk of NOT Taking Action (Catastrophic):**
- Flat network = ransomware can spread from single infected workstation to all systems in <5 minutes
- Attacker with initial access → entire hospital compromised within hours
- **Expected Loss if Not Segmented: $600K-$1.2M** (ransomware scope = all 80 systems + all servers)

**Decision Rationale:** Tested segmentation prevents $600K+ loss; implementation risk is manageable with testing. **MANDATORY.**

---

### Tier 3, Action 2: Endpoint Detection and Response (EDR) Pilot Deployment

**Phase Blocked:** Phase 6 (Ransomware Deployment) — **DETECTS RANSOMWARE BEFORE ENCRYPTION**

**Action:**  
1. Vendor Selection (Thu AM): Evaluate CrowdStrike, Defender ATP, Sophos ($100-$150/endpoint/year)
2. Pilot (Thu): Deploy to 10 critical systems:
   - ad-dc-01, ad-dc-02 (domain controllers)
   - ehr-srv-01, pacs-srv-01, backup-srv-01, billing-srv-01 (critical servers)
   - 4 clinical workstations
3. Configuration (Thu): Enable behavioral monitoring, process injection detection, ransomware rules
4. Testing (Fri): Generate test alerts; verify detection of ransomware patterns
5. Full Rollout (Next Monday): Deploy to remaining 70 endpoints

**Owner:** James Chen (vendor eval + config), Sarah Park (deployment)  
**Prerequisites:** Board approval for $8K-$12K annual budget; vendor contract  
**Expected Outcome:** EDR monitoring on all critical systems; ransomware detection enabled  
**Time Estimate:** 12-16 hours

**Risk of Taking Action (Minimal):**
- EDR agent adds ~5-10% CPU/memory overhead (acceptable for security monitoring)
- If issue: EDR can be uninstalled without affecting system functionality
- Pilot approach reduces deployment risk (test 10 systems before rolling out to 80)
- **Risk Level: MINIMAL** (agents are removable; overhead is acceptable)

**Risk of NOT Taking Action (High):**
- If ransomware deployed: No detection occurs until files are already encrypted
- Ransomware spread happens in minutes; with EDR: detected in seconds
- **Expected Loss if EDR Not Deployed: $200K** (faster detection saves recovery time + scope)

**Decision Rationale:** 5-10% overhead prevents $200K+ loss; EDR is industry-standard detection. **MANDATORY.**

---

### Tier 3, Action 3: Backup Encryption and Immutable Cloud Replica (Design Phase)

**Phase Blocked:** Phase 5 (Backup Destruction) — **PROTECTS RECOVERED DATA FROM RANSOMWARE**

**Action:**  
1. Design (Wed-Thu): Finalize LUKS encryption design for NAS-01 (from 1x04 crypto foundation)
2. Vendor Selection (Thu): Evaluate cloud providers for immutable backup replica:
   - AWS S3 + Object Lock (immutable for 30 days)
   - Azure Blob Storage (immutable snapshots)
   - Cost: $500-$1K/month for 2TB backup replica
3. Implementation Planning (Fri): Determine:
   - Which backup jobs replicate to cloud vs. stay local
   - Encryption key storage (NOT on NAS-01; store in Vault on management VLAN)
   - Testing plan for recovery from cloud backup
4. Schedule full implementation for next week (after Tier 1-2 complete + network segmented)

**Owner:** James Chen (design), Sarah Park (vendor eval)  
**Prerequisites:** Board approval for $6K-$12K annual cloud backup budget; Vault setup (from 1x04)  
**Expected Outcome:** Design finalized; vendor selected; implementation scheduled for next week  
**Time Estimate:** 8-12 hours (design work; no production changes)

**Risk of Taking Action (Minimal):**
- Design phase only; no implementation yet
- If cloud vendor selected is wrong: Can switch providers before implementation
- **Risk Level: NEGLIGIBLE** (planning activity, fully reversible)

**Risk of NOT Taking Action (High):**
- Without immutable backup: Ransomware can delete backup as part of attack
- Without cloud replica: No geographic separation (single data center loss = no recovery)
- **Expected Loss if Backup Not Protected: $300K-$500K** (loss of recovery option + extended downtime)

**Decision Rationale:** Design phase is preparation; deferred implementation acceptable for Tier 3. **MANDATORY FOR BOARD TO APPROVE BUDGET.**

---

## DECISION MATRIX: Risk of Action vs. Risk of Inaction

| Action | Risk Taking | Cost if Action | Risk NOT Taking | Cost if Inaction | ROI Decision |
|---|---|---|---|---|---|
| **T1.1** Firmware Verify | Negligible | $0 | Catastrophic | $1.19M | 12,700:1 ✅ APPROVE |
| **T1.2** NAS Isolate | Minimal | $0 | Catastrophic | $400K | ∞ ROI ✅ APPROVE |
| **T1.3** IR Activate | Negligible | $0 | High | $100K | ∞ ROI ✅ APPROVE |
| **T1.4** Log Archive | Negligible | $0 | Moderate | $100K | ∞ ROI ✅ APPROVE |
| **T2.1** Patch FortiGate | Moderate (1h downtime) | $2,400 | Catastrophic | $1.19M | 1,207:1 ✅ APPROVE |
| **T2.2** RC4 Disable | Moderate (test risk) | $0 | High | $400K | 40,000:1 ✅ APPROVE |
| **T2.3** VPN MFA | Minimal (UX friction) | $0 | High | $800K | 26,667:1 ✅ APPROVE |
| **T3.1** Segmentation | Moderate (config risk) | $3K-$5K | Catastrophic | $600K-$1.2M | 240:1 ✅ APPROVE |
| **T3.2** EDR Deploy | Minimal (5-10% overhead) | $8K-$12K | High | $200K | 20:1 ✅ APPROVE |
| **T3.3** Backup Encrypt | Negligible (design phase) | $0 | High | $300K | ∞ ROI ✅ APPROVE |

---

## BOARD DECISION SUMMARY

**Total Emergency Spending Requested:** $13,400-$19,400 (Tier 2-3 combined)

**Risk Assessment:**
- **Tier 1 ($0):** All actions have negligible implementation risk; all have catastrophic inaction risk. **UNANIMOUS APPROVAL RECOMMENDED.**
- **Tier 2 ($2,400 + labor):** Moderate implementation risk (1-hour maintenance, GPO testing); catastrophic inaction risk ($2.4M exposure). **UNANIMOUS APPROVAL RECOMMENDED.**
- **Tier 3 ($11,000-$17,000):** Moderate implementation risk (network changes, agent deployments); high inaction risk ($1.2M exposure). **UNANIMOUS APPROVAL RECOMMENDED.**

**Executive Recommendation:** Approve all three tiers. Implementation risks are manageable with proper testing and rollback planning. Inaction risks are catastrophic ($2.3M-$3.8M combined exposure).

---

**Prepared by:** MedDefense Security Team  
**Reviewed by:** James Chen, CISO  
**Distribution:** Board of Directors  
**Classification:** CONFIDENTIAL
