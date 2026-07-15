# Task 23: Post-Remediation Validation Plan
## MedDefense Vulnerability Assessment - Verification & Continuous Monitoring

**Prepared for:** IT Operations, Security Operations, Compliance  
**Effective Date:** Upon completion of Task 19 (Remediation Implementation)

---

## EXECUTIVE SUMMARY

Post-remediation validation ensures that fixes are correctly applied and vulnerabilities are eliminated. This plan defines testing procedures for each of the three "Immediate" findings (24-48h remediation timeline), monitoring strategies to verify compensating controls remain effective, and continuous intelligence integration to prevent vulnerability reintroduction.

---

## 1. POST-PATCH VERIFICATION PROCEDURES

### Finding 001: Apache mod_lua RCE (billing-srv-01) - Patch Validation

**Objective:** Confirm Apache has been patched to 2.4.51+ and mod_lua vulnerability is eliminated.

**Verification Steps:**

1. **Version Verification (Immediate Post-Patch):**
   ```bash
   # On billing-srv-01:
   apache2ctl -v
   # Expected output: "Apache/2.4.51" or higher
   
   # Check module list
   apache2ctl -M | grep lua
   # Expected: No lua module listed (or lua listed but patched version)
   ```

2. **CVE-Specific Test:**
   ```bash
   # Test for CVE-2021-41773 (path traversal RCE)
   curl -v "http://billing-srv-01/cgi-bin/../../../../etc/passwd"
   # Expected: 404 Not Found or Access Denied
   # Vulnerable response: File contents displayed
   
   # Test for CVE-2021-42013 (related RCE vector)
   curl -v "http://billing-srv-01/icons/..;/..;/..;/etc/passwd"
   # Expected: 404 or Access Denied (not file disclosure)
   ```

3. **Vulnerability Scanner Verification:**
   ```bash
   # Re-run OpenVAS scan targeting billing-srv-01
   # Filter for CVE-2021-41773, CVE-2021-42013
   # Expected: Both CVEs show "Not Vulnerable" or absent from results
   ```

4. **Functional Testing (Post-Patch):**
   - [ ] Billing portal loads without errors (test homepage)
   - [ ] User login workflow functions (test authentication)
   - [ ] Payment processing works end-to-end (test transaction)
   - [ ] No 500 errors in Apache error log: `tail -50 /var/log/apache2/error.log`
   - [ ] No suspicious entries in access log: `tail -100 /var/log/apache2/access.log`

5. **Performance Baseline:**
   - Measure response time: `curl -o /dev/null -s -w "%{time_total}\n" http://billing-srv-01/`
   - Expected: <1 second (post-patch performance should not degrade)

**Validation Success Criteria:**
- ✓ Apache version 2.4.51 or higher confirmed
- ✓ CVE-2021-41773 & CVE-2021-42013 tests show "Not Vulnerable"
- ✓ Vulnerability scanner confirms absence
- ✓ All functional tests pass without errors
- ✓ Performance within baseline

**Validation Timeline:** T+6 hours post-patch (after rollout to production)

**Owner:** Application Operations  
**Success Threshold:** ALL criteria must pass (no partial credit)

---

### Finding 031: Ghostcat AJP RCE (ehr-srv-01) - Patch Validation

**Objective:** Confirm Tomcat patched to 9.0.31+ and AJP remote code execution eliminated.

**Verification Steps:**

1. **Version Verification:**
   ```bash
   # On ehr-srv-01:
   /opt/tomcat/bin/version.sh
   # Expected output: Apache Tomcat 9.0.31 or higher
   
   # Verify AJP connector is localhost-bound:
   grep -A 3 "protocol=\"AJP/1.3\"" /opt/tomcat/conf/server.xml
   # Expected: address="127.0.0.1" (NOT 0.0.0.0)
   ```

2. **CVE-Specific Test:**
   ```bash
   # Test for CVE-2020-1938 (Ghostcat RCE)
   # Requires AJP protocol tester; using nmap:
   nmap -p 8009 ehr-srv-01 -sC
   # Expected: Port 8009 closed or filtered (not open)
   
   # Alternative: Metasploit verification
   msfconsole -x "use exploit/windows/http/tomcat_cve_2020_1938_rce; 
     set RHOST ehr-srv-01; check"
   # Expected: "CheckCode: Safe" (not vulnerable)
   ```

3. **Vulnerability Scanner Verification:**
   ```bash
   # Re-run OpenVAS scan targeting ehr-srv-01
   # Filter for CVE-2020-1938
   # Expected: CVE-2020-1938 shows "Not Vulnerable"
   ```

4. **Functional Testing:**
   - [ ] EHR web portal loads without errors
   - [ ] User authentication works (login/logout)
   - [ ] Patient record retrieval functions (test search)
   - [ ] No stack traces in Tomcat logs: `tail -100 /opt/tomcat/logs/catalina.out`
   - [ ] No permission denied errors in system logs

5. **Application Smoke Tests:**
   - [ ] EHR homepage loads: `curl -s http://ehr-srv-01/ | grep -q "Welcome"` 
   - [ ] Database connectivity verified: `curl -s http://ehr-srv-01/health` returns 200 OK
   - [ ] API endpoints respond: `curl -s http://ehr-srv-01/api/v1/health` returns JSON

**Validation Success Criteria:**
- ✓ Tomcat version 9.0.31 or higher confirmed
- ✓ AJP connector bound to localhost only
- ✓ CVE-2020-1938 tests show "Not Vulnerable"
- ✓ Vulnerability scanner confirms absence
- ✓ All functional tests pass

**Validation Timeline:** T+6 hours post-patch

**Owner:** Application Operations  
**Success Threshold:** ALL criteria must pass

---

### Finding 024: BD Alaris Default Credentials (Infusion Pumps) - Verification

**Objective:** Confirm all 12 infusion pumps have strong credentials and unauthorized access is blocked.

**Verification Steps:**

1. **Inventory & Documentation:**
   ```bash
   # Verify all 12 pumps identified and documented:
   - [ ] Pump 01 (NICU - Bed A1): 192.168.20.50 - Password changed
   - [ ] Pump 02 (NICU - Bed A2): 192.168.20.51 - Password changed
   - [ ] ... [continue for all 12 pumps]
   
   # Passwords stored in secure vault (encrypted):
   - Vault: HashiCorp Vault / LastPass Enterprise
   - Access: Clinical Engineering + IT Security only
   - Audit trail enabled for credential access
   ```

2. **Credential Validation (Old Credentials Blocked):**
   ```bash
   # For each pump, attempt login with OLD default credentials:
   curl -u admin:admin http://192.168.20.50/control
   # Expected: 401 Unauthorized (login fails)
   
   # Attempt login with NEW credentials:
   curl -u admin:NEWSTRONGPASSWORD http://192.168.20.50/control
   # Expected: 200 OK or 403 Forbidden (credential accepted or permission denied, not credential failure)
   ```

3. **Network Access Test (Part of Phase 2 Validation at T+7):**
   ```bash
   # Once network segmentation is implemented:
   # From general hospital network:
   ping 192.168.40.50  # Pump VLAN
   # Expected: No response (segmentation working)
   
   # From clinical workstation on pump VLAN:
   ping 192.168.40.50
   # Expected: Response (authorized access working)
   ```

4. **Clinical Operations Verification:**
   - [ ] Pumps function normally during password reset
   - [ ] No pump alarms or error messages
   - [ ] Infusion rates & drug parameters unchanged
   - [ ] Clinical staff confirm normal operation (no workflow disruption)
   - [ ] Incident tracking: Zero pump access issues reported

5. **Audit Trail Review:**
   - Pump web interface logs reviewed for failed authentication attempts
   - Expected: NO successful login with default credentials post-change
   - Expected: Possible failed attempts with old credentials (normal during reset period)

**Validation Success Criteria:**
- ✓ All 12 pumps have strong credentials confirmed changed
- ✓ Old credentials blocked on all pumps
- ✓ New credentials work for authenticated access
- ✓ No clinical workflow disruption observed
- ✓ Pump operations normal

**Validation Timeline:** T+4 hours post-credential-change (immediate)

**Owner:** Clinical Engineering + IT Security  
**Success Threshold:** ALL criteria must pass; ANY pump still accepting defaults = CRITICAL failure

---

## 2. COMPENSATING CONTROL VALIDATION

### Finding 008/009: EternalBlue + BlueKeep (Windows XP MRI) - Network Isolation Verification

**Objective:** Confirm VLAN isolation preventing MRI compromise from compromising clinical network.

**Verification Steps:**

1. **VLAN Configuration Verification (Network Operations):**
   ```bash
   # On network switch (VLAN 30 = Medical Devices):
   show vlan 30
   # Expected:
   # VLAN ID: 30
   # Name: Medical-Devices
   # Ports: Switch port to MRI switch only
   
   # Verify VLAN Access Control List:
   show access-lists
   # Expected: ACL denying traffic from VLAN 30 to clinical networks (10, 20)
   ```

2. **Segmentation Testing (Isolation Confirmation):**
   ```bash
   # From clinical workstation (different VLAN):
   ping 192.168.30.50  # MRI workstation
   # Expected: "Destination unreachable" or timeout (no response)
   
   nmap -p 445,139,135 192.168.30.50  # SMB ports that EternalBlue uses
   # Expected: All ports filtered/closed
   
   # From MRI workstation:
   ping 192.168.10.0/24  # Clinical network
   # Expected: "Destination unreachable" (blocked outbound)
   ```

3. **Flow Monitoring (Anomaly Detection):**
   ```bash
   # Enable NetFlow on MRI VLAN:
   # Alert if:
   # - MRI initiates connection to clinical network
   # - Unusual port activity on MRI (445, 139, 3389 outbound)
   # - Traffic volume spikes (potential worm attempt)
   # - Unknown systems connecting to MRI
   
   # Weekly review of MRI network flows
   # Expected: Only legitimate traffic (imaging data, NTP, DNS)
   ```

4. **Documentation & Change Control:**
   - [ ] Network architecture diagram with MRI VLAN clearly marked
   - [ ] Change control ticket documenting MRI isolation design
   - [ ] Incident response procedure: "If MRI isolation breached"
   - [ ] Quarterly audit of VLAN membership (ensure MRI still isolated)

**Validation Success Criteria:**
- ✓ VLAN isolation confirmed configured on switch
- ✓ Cross-VLAN traffic tests show blocking
- ✓ NetFlow monitoring enabled and alerting configured
- ✓ Documentation current and accessible

**Validation Timeline:** Immediate (network should already be isolated per 1x00)

**Validation Frequency:** Weekly flow monitoring; quarterly configuration audit

**Owner:** Network Operations  
**Escalation:** If any traffic detected between MRI VLAN and clinical network, trigger incident response immediately

---

### Finding 018/019: LDAP Signing + SMBv1 Verification

**Objective:** Confirm LDAP signing enabled and SMBv1 disabled across domain; relay attacks blocked.

**Verification Steps:**

1. **LDAP Signing Enabled (Domain Controller):**
   ```powershell
   # On AD domain controller:
   Get-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=meddefense,DC=local" -Properties LDAPServerIntegrity | Select LDAPServerIntegrity
   # Expected: LDAPServerIntegrity = 2 (signing required)
   
   # Test LDAP signing enforcement:
   nltest /server:ad-dc-01 /ldaptest:3
   # Expected: "passed test LdapSigning"
   ```

2. **SMBv1 Disabled (All Systems):**
   ```powershell
   # On each server and workstation:
   Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol | Select State
   # Expected: State = Disabled
   
   # Verify no SMBv1 sessions active:
   Get-SmbSession | Where-Object {$_.Dialect -eq "1.0"}
   # Expected: No results (no SMBv1 sessions)
   
   # Check Group Policy applied:
   gpresult /h gpreport.html /f  # HTML group policy report
   # Search for "SMB1" or "SMBv1" in report
   # Expected: Policy applied: "Disable SMBv1"
   ```

3. **Relay Attack Test (Red Team Simulation - After 24h Stabilization):**
   ```bash
   # After SMBv1/LDAP signing remediation stabilizes (24h post-deployment):
   # Controlled security test of relay attack blocking
   
   # Simulate NTLM relay attack from lab workstation:
   # - Attempt LDAP relay without signing enforcement
   # - Expected: Relay attack fails (signing required)
   # - Result: "LDAP signing is required"
   
   # Test SMBv1 relay:
   # - Attempt SMB relay attack
   # - Expected: No SMBv1 sessions available
   # - Result: "No SMBv1 compatible servers found"
   ```

4. **Authentication Traffic Analysis:**
   ```bash
   # Monitor authentication logs for relay attempt indicators
   # Windows Event Log: Security > Audit Failure
   # Look for: NTLM authentication failures (expected for relay attempts)
   # Unusual LDAP connection patterns (possible MITM attempts)
   
   # Network IDS/IPS should alert on:
   # - NTLM relay traffic patterns
   # - SMB protocol version downgrade attempts
   # - LDAP over unencrypted channels (should be encrypted)
   ```

5. **Functional Testing (Ensure Normal Operations):**
   - [ ] Domain computers authenticate normally
   - [ ] File sharing (SMBv2/v3) works across domain
   - [ ] Printers accessible via network
   - [ ] Legacy applications still function (or documented exceptions)
   - [ ] No authentication timeouts or delays

**Validation Success Criteria:**
- ✓ LDAP signing enforcement confirmed (LDAPServerIntegrity = 2)
- ✓ SMBv1 disabled on 100% of systems
- ✓ Red team relay attack test shows "relay blocked"
- ✓ No authentication-related service disruptions
- ✓ Authentication traffic shows no downgrade attempts

**Validation Timeline:** T+24 hours post-deployment (after systems stabilize)

**Validation Frequency:** Weekly authentication log review; monthly relay attack simulation

**Owner:** Directory Services + Security Operations  
**Success Threshold:** Zero successful relay attacks detected in testing

---

## 3. RESCAN & CONTINUOUS VALIDATION

### Scheduled Vulnerability Rescans

**Post-Remediation Rescan Schedule:**

| Timeline | Scope | Tool | Owner | Success Criteria |
|----------|-------|------|-------|------------------|
| **T+2h post-patch** | Findings 001, 031 only | OpenVAS + Metasploit | IT Ops | CVE-2021-41773, CVE-2020-1938 marked "Not Vulnerable" |
| **T+24h post-patch** | All systems | OpenVAS full scan | Security Ops | 0 Critical findings; all 6 major findings remediated |
| **T+7 days post-remediation** | Full network | OpenVAS + authenticated scan | Security Ops | Compare to baseline; verify no reintroduction; measure improvement |
| **T+30 days post-remediation** | Full network + new configs | OpenVAS + custom checks | Security Ops | Validate sustained remediation; identify new vulnerabilities |
| **Quarterly (90 days)** | Comprehensive assessment | OpenVAS + threat landscape review | Security + Threat Intel | Measure overall posture improvement; plan next phase (1x03 Defense Blueprint) |

**Scan Parameters:**
- **Credential scans:** Enabled (authenticated scanning more accurate than unauthenticated)
- **False positive filtering:** Applied (based on Task 11 FP definitions)
- **Scope:** All 47 identified assets + any new systems added
- **Reporting:** Automated dashboard + executive summary + detailed findings

---

## 4. CONTINUOUS INTELLIGENCE INTEGRATION

### External Intelligence Feeds

**CISA Known Exploited Vulnerabilities (KEV) Monitoring:**
- **Frequency:** Daily automated check
- **Process:**
  1. Download latest CISA KEV list (updated daily)
  2. Check MedDefense asset inventory against KEV CVEs
  3. If match: Alert to Security Operations immediately (treat as urgent)
  4. Action: Prioritize for emergency patching
- **Tool:** Automated script checking MedDefense CVE inventory against CISA KEV
- **Alert Threshold:** Any KEV CVE found on MedDefense systems = Priority 1

**Vendor Security Advisories:**
- **Vendors:** Apache (Apache.org), Tomcat (Apache.org), Postgres (postgresql.org), Microsoft (Microsoft Security Updates), BD (BD.com)
- **Frequency:** Weekly review + automatic email subscriptions
- **Process:**
  1. Subscribe to vendor security mailing lists
  2. Weekly review of security advisories
  3. Cross-reference against MedDefense deployed versions
  4. If critical: Evaluate impact and prioritize patching
- **Action:** Add matching CVEs to vulnerability tracking system; assign severity

**Threat Intelligence Feeds:**
- **Sources:**
  - Healthcare ISAC (H-ISAC): Sector-specific threat sharing
  - Shodan/GreyNoise: Internet exposure monitoring
  - Microsoft Defender Threat Intelligence: Regional threat trends
  - Talos Intelligence (Cisco): General vulnerability trends
- **Frequency:** Weekly threat summary review
- **Process:**
  1. Weekly threat briefing from H-ISAC
  2. Check if MedDefense appears in threat patterns (specific targeting)
  3. Update threat model if new vectors identified
  4. Adjust prioritization if new threats emerge
- **Action:** Update threat assessment; re-prioritize findings if landscape changes

### Vulnerability Lifecycle Management

**Tracking System:** Central vulnerability management database (e.g., Tenable SecurityCenter, Qualys, or custom SQL database)

**Key Metrics Tracked:**
- Vulnerability ID + CVE
- Discovery date
- Severity (CVSS)
- Affected asset
- Remediation plan
- Target remediation date
- Actual remediation date
- Validation status
- Time-to-remediation (metric)

**Reporting Cadence:**
- **Daily:** Automated dashboard (CIO + Security leadership) - shows "red/yellow/green" status
- **Weekly:** Security operations briefing - detailed findings + blockers
- **Monthly:** Executive summary - trends + metrics + budget impact
- **Quarterly:** Board briefing - strategic posture + long-term roadmap

---

## 5. LIFECYCLE DIAGRAM: Scan → Triage → Prioritize → Remediate → Validate → Repeat

```
┌─────────────────────────────────────────────────────────────────┐
│                    VULNERABILITY LIFECYCLE                       │
│                   (MedDefense Continuous Process)                │
└─────────────────────────────────────────────────────────────────┘

PHASE 1: SCAN (Weekly)
─────────────────────
    Responsible: Security Operations
    Tool: OpenVAS (automated)
    Input: All 47 MedDefense assets
    Output: Raw vulnerability list (usually 0-5 new findings/week)
    
    Example Week: 2 new medium-risk findings discovered
                  ↓
PHASE 2: TRIAGE (Within 24h of scan)
─────────────────────────────────────
    Responsible: Security Operations Lead
    Process:
      1. Remove known false positives (based on Task 11 FP definitions)
      2. Validate critical findings (manual confirmation)
      3. Assign severity (CVSS score)
      4. Categorize (patch, config, design)
    Output: Actionable findings list
    
    Example: 2 findings triaged
             1 confirmed critical (CVSS 8.2) - unpatched SSH
             1 confirmed low (CVSS 4.1) - missing banner
                  ↓
PHASE 3: PRIORITIZE (Within 48h of triage)
──────────────────────────────────────────
    Responsible: CIO + Security Leadership
    Process:
      1. Map to assets (which system affected)
      2. Check against threat landscape (1x01 updated)
      3. Verify compensating controls
      4. Calculate environmental CVSS
      5. Assign timeline (immediate/7d/30d/90d)
    Output: Prioritized fix list with timeline
    
    Example: SSH finding
             Asset: bastion-host (infrastructure-critical)
             Threat: Low (not on active threat actor list)
             Compensating Control: Good (network ACLs)
             Timeline: 30 days (Medium-term)
                  ↓
PHASE 4: REMEDIATE (Per timeline)
──────────────────
    Responsible: IT Operations (or specialized team per finding type)
    Process:
      1. Plan remediation (patch, config, architecture change)
      2. Test in lab environment
      3. Schedule maintenance window
      4. Apply fix
      5. Document change control
    Output: Remediation completion notification
    Duration: Depends on finding (1 hour to 90 days)
    
    Example: SSH remediation
             Action: Update SSH config; disable weak ciphers
             Lab test: Pass (no functionality broken)
             Maintenance window: Thursday 11pm
             Completion: Thursday 11:45pm
                  ↓
PHASE 5: VALIDATE (Within 24h of remediation)
──────────────────
    Responsible: Security Operations + IT Operations
    Process:
      1. Re-scan with OpenVAS (verify finding resolved)
      2. Test functionality (business process still works)
      3. Performance baseline (ensure no degradation)
      4. Update tracking system
    Output: Validation report; finding marked "RESOLVED"
    
    Example: SSH finding revalidation
             OpenVAS rescan: SSH weak ciphers no longer detected ✓
             Functional test: SSH login works normally ✓
             Performance: Connection time <100ms (normal) ✓
             Status: RESOLVED (moved to archive)
                  ↓
PHASE 6: CONTINUOUS INTELLIGENCE → REPEAT
─────────────────────────────────────────
    Monitor external feeds (CISA KEV, vendor advisories, threat intel)
    If NEW threat discovered affecting similar system:
        → Escalate priority
        → Add to "standing watch" monitoring
    
    LOOP REPEATS: Weekly scans continue; new findings → triage → prioritize...


RESPONSIBLE PARTIES & ESCALATION:
──────────────────────────────────
Level 1 (Daily Operations):     Security Operations (T1 issues)
Level 2 (Weekly Management):    CIO + IT Director (escalations)
Level 3 (Monthly Executive):    Chief Information Security Officer (trends)
Level 4 (Quarterly Strategic):  Board of Directors (policy + budget decisions)

METRICS TRACKED:
────────────────
- Mean Time to Detect (MTTD): ~3 days (weekly scan + triage)
- Mean Time to Remediate (MTTR): Target 14 days (varies by severity)
- Vulnerability Aging: % of findings >30 days without remediation (target: <10%)
- Reintroduction Rate: % of previously-fixed findings reappearing (target: 0%)

```

---

## 6. ESCALATION PROCEDURES

### Critical Finding Detected (During Scan or Intelligence Monitoring)

**Trigger:** CVSS ≥9.0 OR CISA KEV confirmed active exploitation

**Immediate Actions (within 1 hour):**
1. Security Ops confirms finding validity (no false positive)
2. Notify CIO + IT Director
3. Alert affected department head (if clinical asset)
4. Assess: "Can we patch today or need emergency exception?"

**Escalation Path:**
- If patchable within 24h → Approve emergency maintenance window
- If requires downtime beyond 24h → CIO makes risk decision: patch despite disruption vs. accept risk
- If no immediate fix available → Activate compensating controls / isolation procedure

---

## 7. SUCCESS METRICS (Post-Remediation Assessment)

**By Week 1 (Post-Tier 1 Remediation):**
- ✓ 5 critical findings (CVSS 9.75-10.0) resolved
- ✓ Ransomware kill chain broken (confirmed via red team test)
- ✓ Patient safety risk (Finding 024) mitigated

**By Day 30 (Post-Tier 2-3 Remediation):**
- ✓ 18+ of 24 actionable findings remediated
- ✓ Network architecture significantly hardened
- ✓ Automated patching system deployed
- ✓ Remaining critical vulnerabilities on defined remediation timeline

**By Day 90 (Post-Comprehensive Remediation):**
- ✓ 24 of 24 actionable findings closed or mitigated
- ✓ Security maturity improved from 2.5 → 3.0 (Emerging → Repeatable)
- ✓ Continuous monitoring and intelligence feeds operational
- ✓ Readiness for 1x03 Defense Blueprint (proactive security program)

---

## NEXT STEPS

1. **Immediate:** Execute Phase 1-3 validation procedures (post-Tier 1 remediation)
2. **Week 2:** Begin Phase 4-5 validation (post-Tier 2 remediation)
3. **Week 4:** Establish continuous intelligence feeds (vendor + threat intel)
4. **Day 30:** Conduct comprehensive post-remediation assessment
5. **Day 90:** Begin transition planning for 1x03 Defense Blueprint (proactive security roadmap)

---

## APPENDIX: Testing Checklists

See **Detailed Validation Checklists** in separate document for field-level testing procedures for clinical staff, IT operations, and security personnel.

