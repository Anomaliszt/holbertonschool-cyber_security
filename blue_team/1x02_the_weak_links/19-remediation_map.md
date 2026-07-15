# Task 19: Detailed Remediation Plans
## MedDefense Vulnerability Assessment - Implementation Roadmap

**Prepared for:** CIO, IT Operations, Security Operations  
**Date:** Q3 2024  
**Scope:** 8 prioritized findings from CVSS environmental scoring (Task 17)

---

## Finding 001: Apache mod_lua Remote Code Execution (billing-srv-01)

**CVSS 10.0 | Priority 1: Immediate (24h)**

### Response Type: Patch

**Patch Details:**
- **CVE:** CVE-2021-41773 / CVE-2021-42013 (Apache mod_lua path traversal RCE)
- **Source:** Apache Security Advisories; vendor patch from Apache 2.4.51+
- **Prerequisites:**
  - Maintenance window (2-4 hours downtime acceptable for billing system per 1x00)
  - Backup of current Apache configuration
  - Test environment available for patch validation
  - Rollback plan documented

**Implementation:**
1. **Pre-patch (T+0-2h):**
   - Schedule maintenance window with Finance team
   - Snapshot billing-srv-01 VM/server
   - Export current Apache configuration & module list
   - Verify backup of billing database completed
   - Notify customers of upcoming maintenance

2. **Patch Application (T+2-4h):**
   ```bash
   # Stop Apache
   systemctl stop apache2
   
   # Backup current Apache
   cp -r /etc/apache2 /etc/apache2.backup
   cp /usr/sbin/apache2 /usr/sbin/apache2.backup
   
   # Apply patch (via package manager)
   apt update
   apt install apache2=2.4.51-1ubuntu1  # Or equivalent version
   
   # Verify mod_lua disabled or patched
   apache2ctl -M | grep lua
   
   # Restart Apache
   systemctl start apache2
   ```

3. **Post-patch Validation (T+4-6h):**
   - Verify billing web portal loads correctly
   - Test payment processing workflow end-to-end
   - Scan with vulnerability scanner to confirm CVE-2021-41773 resolved
   - Monitor logs for errors or anomalies

**Rollback Plan:**
- **If issues detected:** Restore from snapshot, revert Apache to backup:
  ```bash
  systemctl stop apache2
  rm -rf /etc/apache2
  cp -r /etc/apache2.backup /etc/apache2
  cp /usr/sbin/apache2.backup /usr/sbin/apache2
  systemctl start apache2
  ```
- **Estimated rollback time:** 30 minutes
- **Trigger:** Billing portal unable to accept transactions; critical errors in logs

**Operational Risk:** LOW
- Billing system not patient-critical (can tolerate 24-48h downtime)
- Patch is well-tested and widely deployed
- Clear rollback path available

**Cost Estimate:** $0-1K (staff time for maintenance, no vendor cost)

**Owner:** IT Infrastructure  
**Timeline:** 24 hours from approval

---

## Finding 003: PostgreSQL Unrestricted Network Access (ehr-db-01)

**CVSS 9.9 | Priority 1: Immediate (24h) - Multi-phase**

### Response Type: Configuration Change + Network Remediation

**Phase 1: Immediate (24h) - Emergency Isolation**

**Configuration Change:**
1. **Restrict PostgreSQL network access:**
   ```sql
   -- On ehr-db-01 PostgreSQL:
   
   -- Current state: pg_hba.conf allows "host all all 0.0.0.0/0 md5"
   -- Change to:
   
   host    all             all             127.0.0.1/32            md5
   host    all             all             ::1/128                 md5
   host    ehr_app         ehr_app         192.168.50.0/24         md5  # EHR app server subnet only
   host    backup_user     all             192.168.50.100/32       md5  # Backup server only
   ```

2. **Firewall rules (iptables on ehr-db-01):**
   ```bash
   # Block PostgreSQL port except from authorized subnets
   ufw default deny incoming
   ufw allow from 192.168.50.0/24 to any port 5432 proto tcp  # EHR app subnet
   ufw allow from 192.168.50.100 to any port 5432 proto tcp   # Backup server
   ufw allow from 192.168.50.10 to any port 22 proto tcp      # DBA access for maintenance
   ```

3. **Database privilege remediation:**
   ```sql
   -- Remove excessive privileges
   
   -- Current: developer role has SELECT on all schemas
   -- Change to: Minimal required permissions per role
   
   REVOKE ALL ON ALL TABLES IN SCHEMA public FROM developer;
   GRANT SELECT ON TABLE patient_demographics, encounter_history 
     ON SCHEMA public TO developer;
   
   GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO developer;
   
   -- Audit permissions
   \du  # List roles
   ```

4. **Enable PostgreSQL network logging:**
   ```sql
   -- postgresql.conf:
   log_connections = on
   log_disconnections = on
   log_statement = 'all'  # Temporary (high volume)
   log_duration = on
   ```

**Phase 1 Timeline:** 2-4 hours  
**Phase 1 Risk:** MEDIUM - Must test connectivity from authorized sources immediately

**Phase 2: Medium-term (7 days) - Network Architecture**

**Network Segmentation:**
- Create database VLAN isolated from general network
- Implement micro-segmentation: only ehr-srv-01 (EHR app) + backup server can reach ehr-db-01
- Deploy network firewall rules to enforce segmentation

**Phase 3: Long-term (30 days) - Encryption**

**Encryption at Rest:**
- Enable PostgreSQL table-level encryption or full-disk encryption
- Separate storage for encrypted PHI
- Key management via centralized vault (e.g., HashiCorp Vault)

**Impact Assessment:**
- **Performance Impact:** MINIMAL - Firewall rules do not affect authenticated connections; privilege restriction reduces but does not block legitimate queries
- **Downtime:** 30-60 minutes (for firewall configuration + database restart)
- **Reversibility:** HIGH - Changes can be reverted within 2 hours if issues arise

**Residual Risk:**
- Internal lateral movement still possible if network segmentation not implemented (Phase 2)
- Database credential compromise would still grant access (requires Phase 3 encryption)

**Cost Estimate:** $1-10K (network configuration labor + monitoring setup + potential encryption licensing)

**Owner:** IT Infrastructure + Security Operations  
**Timeline:** 24h (Phase 1), 7d (Phase 2), 30d (Phase 3)

---

## Finding 008/009: EternalBlue + BlueKeep (WS-RAD-01 - Windows XP MRI)

**CVSS 9.5 | Priority 1: Urgent (7 days)**

### Response Type: Compensating Control + Device Replacement (Cannot Patch XP)

**Immediate Response (24h): Compensating Control Validation**

**Network Isolation Verification:**
1. Confirm VLAN isolation active:
   ```bash
   # On network switch:
   show vlan id 30  # Assuming medical device VLAN
   show access-list  # Verify ACL denies cross-VLAN traffic
   ```

2. Test isolation:
   ```bash
   # From clinical workstation (different VLAN):
   ping 192.168.30.50    # WS-RAD-01 MRI should NOT respond
   nmap 192.168.30.50    # Should show "host is down"
   ```

3. Enable flow monitoring on MRI VLAN:
   - Deploy NetFlow/sFlow to monitor all traffic to/from MRI
   - Alert if MRI initiates outbound connections
   - Alert if any system attempts connection to MRI on non-standard ports

4. Document compensating controls:
   - Network architecture diagram with MRI isolation marked
   - Change control documentation
   - Incident response procedure if isolation breached

**Phase 2 (30 days): Device Replacement Planning**

**Procurement:**
- Research MRI vendor replacement options
- Compatibility verification with existing image processing software
- Cost analysis: MRI replacement vs. 5-year risk acceptance
- Estimated cost: $50K+ (major medical equipment)

**Implementation:**
- Coordinate with Radiology department for downtime window
- Plan transition from Windows XP → Windows 10/11 compatible system
- Data migration from old MRI workstation
- Validation of image quality + processing workflow

**Residual Risk:**
- Until replacement: WS-RAD-01 remains unpatched but isolated
- If segmentation fails: EternalBlue exploitation likely
- Monitor for segmentation failures; maintain incident response posture

**Cost Estimate:**
- Immediate: $0-1K (monitoring setup, validation labor)
- 30d: $50K+ (device replacement)

**Owner:** Clinical Engineering + IT Infrastructure  
**Timeline:** Immediate (isolation validation), 30-90d (replacement procurement)

---

## Finding 018/019: LDAP Signing Disabled + SMBv1 (ad-dc-01)

**CVSS 9.75 | Priority 1: Immediate (24h)**

### Response Type: Configuration Change (Two-part)

**Part 1: Enable LDAP Signing (4 hours)**

**Configuration:**
1. **On AD Domain Controller (PowerShell as Administrator):**
   ```powershell
   # Check current LDAP signing configuration
   Get-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=meddefense,DC=local" -Properties LDAPServerIntegrity
   
   # Expected: LDAPServerIntegrity = 2 (signing required)
   # Current: Likely 0 or 1 (not required)
   
   # Enable LDAP Signing Requirement
   Set-ADObject -Identity "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,DC=meddefense,DC=local" -Add @{LDAPServerIntegrity=2}
   
   # Restart LDAP service
   Restart-Service NTDS
   ```

2. **On all client computers (Group Policy):**
   - Create GPO: "LDAP Signing Required"
   - Domain Computer Configuration → Policies → Windows Settings → Security Settings → Local Policies → Security Options
   - Set "Network Security: LDAP Client Signing Requirements" = Require Signing

3. **Verification:**
   ```powershell
   # Test LDAP signing requirement
   nltest /server:ad-dc-01 /ldaptest:3
   
   # Expected output: "passed test LdapSigning"
   ```

**Part 2: Disable SMBv1 (2 hours)**

**Configuration:**
1. **On all servers and workstations (PowerShell as Administrator):**
   ```powershell
   # Disable SMBv1
   Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
   
   # Verify SMBv1 disabled
   Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
   # Expected: State = Disabled
   
   # Restart system
   Restart-Computer -Force
   ```

2. **On Domain Controller - Enforce via Group Policy:**
   - Create GPO: "SMBv1 Disabled"
   - Computer Configuration → Administrative Templates → Network → Lanman Workstation
   - Set "Enable insecure guest logons" = Disabled

3. **Verification (post-reboot, all systems):**
   ```powershell
   Get-SmbServerConfiguration | Select EnableSMB1Protocol
   # Expected: False
   
   Get-SmbSession | Where-Object Dialect -EQ "1.0"
   # Expected: No results (no SMBv1 sessions)
   ```

**Testing & Rollback:**

**Pre-implementation Testing (T+0):**
- Test LDAP signing in lab environment with sample clients
- Verify SMBv1 disablement does not break network scanning/administration tools
- Identify any legacy systems that require SMBv1 (document for exception request)

**Rollback Plan:**
- Keep snapshot of AD database
- If LDAP signing causes client authentication failures: Disable signing requirement in Directory Service (5-minute fix)
- If SMBv1 disablement breaks workflows: Re-enable via GPO (2-minute fix + 10-minute reboot)

**Operational Risk:** MEDIUM
- LDAP signing: Minimal impact (modern clients support signing)
- SMBv1 disablement: Risk to legacy systems/network monitoring tools that rely on SMBv1
- Estimated systems affected: 5-10 legacy applications per 1x00 assessment

**Phased Rollout:**
1. **T+0-4h:** DC only (enable LDAP signing + disable SMBv1)
2. **T+4-8h:** Test with sample client systems
3. **T+8-24h:** Servers via Group Policy (if successful in Phase 1)
4. **T+24-48h:** Workstations via Group Policy (staged: 25%, 50%, 100%)

**Impact Assessment:**
- **Performance:** NONE (cryptographic operations are negligible overhead)
- **Functionality:** HIGH confidence no impact; modern SMB (v2/v3) supports all normal operations
- **Backwards Compatibility:** Any SMBv1-dependent systems will fail; document exceptions

**Cost Estimate:** $0-1K (staff time for configuration + testing; no vendor cost)

**Owner:** Directory Services / Network Operations  
**Timeline:** 24 hours from approval

---

## Finding 024: BD Alaris Infusion Pump - Default Credentials

**CVSS 10.0 | Priority 1: Immediate (24h) - Patient Safety Critical**

### Response Type: Configuration Change + Compensating Control + Procurement

**Phase 1: Emergency (24h) - Password Reset**

**Immediate Actions:**
1. **Identify all BD Alaris pumps on network:**
   ```bash
   # From network admin workstation:
   nmap -p 80,443 192.168.20.0/24 | grep Alaris
   # Assume 12 pumps identified across NICU, ICU, medical floors
   ```

2. **Change default credentials on all pumps:**
   - **Physical method (if web UI unchanged):** Navigate to web interface on each pump (http://pump-ip/)
   - Default creds: admin / admin (or vendor-provided default)
   - Change to: Strong password (16+ chars, alphanumeric + special chars)
   - Document new credentials in secure vault (encrypted, access limited to Clinical Engineering + IT Security)

3. **Verification:**
   - Test login with new credentials on sample pump
   - Verify failed login attempts with old credentials
   - Confirm pump functionality (infusion parameters, drug library access)

**Phase 1 Timeline:** 2-6 hours (depending on number of pumps; can be parallelized)  
**Phase 1 Operational Impact:** MINIMAL - Credential change does not affect pump operation; pumps remain functional during change process

**Phase 2: Short-term (7 days) - Network Segmentation**

**Network Configuration:**
1. Create dedicated medical device VLAN (if not already existing)
2. Place all infusion pumps on isolated VLAN (e.g., 192.168.40.0/24)
3. Firewall rules:
   - Pumps can initiate outbound to drug library server (1x per day update)
   - No inbound access from general network (except from clinical workstations for configuration)
   - Monitoring/alerting for unauthorized access attempts

4. Access control:
   - Only Clinical Engineering staff can connect to pump network
   - Multi-factor authentication required for access to pump VLAN
   - Audit logging for all connections

**Phase 2 Implementation:** 2-4 days  
**Phase 2 Cost:** $1-10K (network configuration + monitoring rules)

**Phase 3: Long-term (30-90 days) - Firmware Update / Replacement Evaluation**

**Vendor Communication:**
- Contact BD support regarding CVE-2023-XXXXX (hypothetical medical device vulnerability)
- Inquire about firmware updates that enforce strong authentication
- Evaluate firmware patching vs. device replacement cost-benefit analysis

**Compensating Control Documentation:**
- Clinical staff education: Pump security best practices (do not share credentials; report unusual behavior)
- Incident response procedure: If unauthorized infusion detected, immediate patient safety assessment
- Regular (monthly) network scans of pump VLAN to detect unauthorized access attempts

**Impact Assessment:**
- **Patient Safety Risk:** ELIMINATED (credentials reset prevents unauthorized access)
- **Operational Impact:** MINIMAL (credential change transparent to clinical staff)
- **Regulatory Risk:** Significantly reduced (FDA/CMS medical device security recommendations addressed)

**Cost Estimate:**
- Phase 1: $0-1K (staff time)
- Phase 2: $1-10K (network configuration)
- Phase 3: $10-50K (firmware updates or replacement evaluation)

**Owner:** Clinical Engineering + IT Security  
**Timeline:** 24h (Phase 1), 7d (Phase 2), 30d (Phase 3)

---

## Finding 031: Ghostcat AJP RCE (ehr-srv-01)

**CVSS 10.0 | Priority 1: Immediate (24h)**

### Response Type: Patch

**Patch Details:**
- **CVE:** CVE-2020-1938 (Apache Tomcat AJP Connector Remote Code Execution)
- **Source:** Apache Tomcat Security Advisory; vendor patch 9.0.31+
- **Prerequisites:**
  - EHR web application must be taken offline during patch (2-4 hours)
  - Patient impact: Users cannot access EHR web portal during maintenance
  - Notification to Clinical and Administrative staff required
  - Database backup confirmed

**Implementation:**

1. **Pre-patch (T+0-1h):**
   - Announce maintenance window (coordinate with Medical Records, Clinical Staff)
   - Schedule for low-traffic period (e.g., 2am-6am if possible)
   - Snapshot ehr-srv-01 VM
   - Backup Tomcat configuration directory: `/opt/tomcat/conf/`
   - Backup web application directory: `/opt/tomcat/webapps/ehr/`

2. **Patch Application (T+1-3h):**
   ```bash
   # Stop Tomcat
   systemctl stop tomcat
   
   # Backup current Tomcat
   cp -r /opt/tomcat /opt/tomcat.backup.pre-patch-001
   
   # Download and verify new Tomcat version
   cd /tmp
   wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.31/bin/apache-tomcat-9.0.31.tar.gz
   tar tzf apache-tomcat-9.0.31.tar.gz > /dev/null && echo "Valid archive"
   
   # Replace Tomcat binaries (preserve configuration + webapps)
   rm -rf /opt/tomcat/bin /opt/tomcat/lib
   cp -r /tmp/apache-tomcat-9.0.31/bin /opt/tomcat/
   cp -r /tmp/apache-tomcat-9.0.31/lib /opt/tomcat/
   
   # Verify AJP connector security
   grep -A 5 "protocol=\"AJP/1.3\"" /opt/tomcat/conf/server.xml
   # Should include: address="127.0.0.1" (localhost only, not 0.0.0.0)
   
   # Update server.xml if needed to restrict AJP to localhost
   sed -i 's/0.0.0.0/127.0.0.1/g' /opt/tomcat/conf/server.xml
   
   # Restart Tomcat
   systemctl start tomcat
   ```

3. **Post-patch Validation (T+3-4h):**
   - EHR web portal loads successfully
   - User login flow works end-to-end
   - Patient records display without errors
   - Scan for CVE-2020-1938 - should show "Not vulnerable"
   - Check Tomcat logs for errors: `tail -100 /opt/tomcat/logs/catalina.out`

**Rollback Plan:**
- **If critical errors detected:** Restore from backup:
  ```bash
  systemctl stop tomcat
  rm -rf /opt/tomcat/bin /opt/tomcat/lib
  cp -r /opt/tomcat.backup.pre-patch-001/bin /opt/tomcat/
  cp -r /opt/tomcat.backup.pre-patch-001/lib /opt/tomcat/
  systemctl start tomcat
  ```
- **Estimated rollback time:** 15 minutes
- **Trigger:** EHR portal unable to load; 500 errors in application logs; database connectivity issues

**Operational Risk:** LOW
- Tomcat patch is well-tested and widely deployed
- EHR downtime acceptable for 2-4 hour maintenance window (not patient-critical during off-hours)
- Web application restart does not impact EHR database; no data loss risk

**Cost Estimate:** $0-1K (staff time for maintenance)

**Owner:** Application Operations / Infrastructure  
**Timeline:** 24 hours from approval

---

## Summary Remediation Timeline

| Finding | Response | Timeline | Cost | Owner | Risk |
|---------|----------|----------|------|-------|------|
| **001** | Patch mod_lua | 24h | $0-1K | IT Infra | LOW |
| **003** | Config + Network | 24h (Phase 1), 7d (Phase 2), 30d (Phase 3) | $1-10K | IT + Security | MEDIUM |
| **008/009** | Validation + Replace | 24h (validation), 30-90d (replace) | $50K+ | Clinical Eng | LOW (isolated) |
| **018/019** | Config Change | 24h | $0-1K | Dir Services | MEDIUM |
| **024** | Credential Reset + Network | 24h (Phase 1), 7d (Phase 2) | $1-10K | Clinical Eng + IT | MINIMAL |
| **031** | Patch Tomcat | 24h | $0-1K | App Ops | LOW |

**Total Cost (Immediate + 7-day):** $2-22K  
**Total Cost (Full 30-day remediation):** $52-72K (primarily MRI replacement)

**Proceed to Task 20 (Priority Matrix) for budget allocation and executive approval.**
