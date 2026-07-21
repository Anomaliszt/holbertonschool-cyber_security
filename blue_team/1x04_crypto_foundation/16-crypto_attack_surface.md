## MEDDEFENSE CRYPTOGRAPHIC ATTACK SURFACE

### Attack 1: TLS Downgrade Attack

**Attack:** TLS Downgrade (Force TLS 1.0 instead of 1.2)

**Mechanism:** When a browser connects to patient portal, it supports multiple TLS versions: "I support TLS 1.3, 1.2, and 1.0." An attacker on the network intercepts the ClientHello and modifies it to only support TLS 1.0. The server (which supports both) downgrades to TLS 1.0. Once downgraded, BEAST, POODLE, or Lucky Thirteen attacks become possible against the weakened protocol.

**MedDefense Vulnerability:** Portal supports TLS 1.0 (Finding 005). An attacker on coffee shop WiFi, a compromised router, or an ISP can force the downgrade.

**Evidence:** Finding 005 (1x02): "TLS 1.0 and TLS 1.2 supported; TLS 1.0 vulnerable to BEAST, POODLE"

**Viable Today:** ✅ YES - Portal explicitly allows TLS 1.0 negotiation. Attacker can execute downgrade attack and crack POODLE/Lucky Thirteen in minutes.

**Mitigation:** Disable TLS 1.0 entirely:
```apache
SSLProtocol -all +TLSv1.2 +TLSv1.3
```
Server refuses TLS 1.0 requests; browser shows error (not silent downgrade). Deploy HSTS header to prevent SSLStrip.

---

### Attack 2: MD5 Collision / Kerberoasting

**Attack:** Kerberoasting with RC4/DES Cracking

**Mechanism:** Attacker runs `GetUserSPNs` or similar to find service principal names (SPNs) in Active Directory. Attacker requests Kerberos ticket for the SPN encrypted with weak RC4 or DES. Attacker captures the ticket on the network (or cracks offline with GPU). Once ticket is captured, attacker can crack the service account password offline in hours/minutes depending on password strength.

**MedDefense Vulnerability:** Active Directory enables RC4 and DES encryption for Kerberos (Finding 018). Any service account with an SPN (SQL Server, Exchange, MIS Systems, etc.) is vulnerable.

**Evidence:** Finding 018 (scan): "DES and RC4 still enabled in domain controller Kerberos encryption types." Audit notes confirm no documentation of which systems require legacy support.

**Viable Today:** ✅ YES - Attacker on hospital network can enumerate SPNs, request weak-encrypted tickets, and crack offline.

**Mitigation:** Enforce AES-only Kerberos:
1. Run `Set-ADUser` to require AES on all service accounts
2. Disable DES/RC4 in domain Kerberos policy
3. Test applications to confirm AES support

---

### Attack 3: Birthday Attack (Theoretical)

**Attack:** Birthday Attack on Encryption

**Mechanism:** The "birthday paradox" states that in a group of 23 people, there's a >50% chance two share a birthday. Similarly, in cryptography, with a cipher that produces N-bit output, an attacker needs only ~2^(N/2) encryptions to find a collision (two different plaintexts encrypting to the same ciphertext). If a collision is found, the attacker can deduce information about the plaintext.

**MedDefense Vulnerability:** If MedDefense uses 64-bit block size encryption (DES, 3DES), birthday attacks are practical. After 2^32 (4 billion) encryptions, collisions become likely. In high-volume systems (databases processing millions of transactions/day), this could occur within months.

**Evidence:** T0 audit notes mention 3DES used for legacy compatibility; T6 algorithm landscape recommends against 64-bit ciphers.

**Viable Today:** ⚠️ THEORETICAL (not currently exploited, but risk exists if 3DES is deployed). If MedDefense encrypts thousands of DICOM images daily with 3DES, 2^32 block boundary could be reached in weeks.

**Mitigation:** Use AES (128-bit block size, 2^64 block threshold before collision risk). Do NOT use 3DES or any 64-bit block ciphers.

---

### Attack 4: Kerberoasting with Password Cracking

**Attack:** Offline Service Ticket Cracking (Kerberoasting)

**Mechanism:** Same as Attack 2, but this focuses on the offline cracking phase. Attacker captures Kerberos TGS (Ticket Granting Service) ticket encrypted with RC4. Using tools like `hashcat` with GPU, attacker runs password dictionary against the ticket. If service account password is weak (e.g., "ServiceAccount123!"), attacker cracks it in seconds.

**MedDefense Vulnerability:** Finding 018 enables RC4; any service account with weak password is at risk. Example: MSSQL service account has SPN "MSSQLSvc/db-sql-01.meddefense.local:1433" with password "SQLPassword123" (weak). Attacker captures RC4-encrypted ticket → cracks password offline → gains database access.

**Evidence:** Finding 018; no audit of service account password policies documented in findings.

**Viable Today:** ✅ YES - If any service account has SPN + weak password + RC4 encryption enabled.

**Mitigation:**
1. Enforce AES-only Kerberos encryption (removes RC4 weakness)
2. Audit all service accounts: require 16+ character random passwords
3. Implement Managed Service Accounts (MSA) with automatic password rotation

---

### Attack 5: Unencrypted DICOM Traffic Interception

**Attack:** On-Path Eavesdropping on DICOM Network

**Mechanism:** DICOM traffic flows over ports 4242/11112 in plaintext. An attacker on the hospital network (compromised PC, rogue access point, VLAN hopping) can capture DICOM traffic with a packet sniffer (tcpdump, Wireshark). DICOM files contain embedded PHI: patient name, DOB, MRN, study description, diagnosis. Attacker extracts PHI from captured traffic.

**MedDefense Vulnerability:** Finding 016 confirms DICOM cleartext traffic. Flat hospital network (Finding 001) means any device can reach PACS. Compromised workstation or insider can sniff DICOM.

**Evidence:** Finding 016: "DICOM traffic unencrypted on ports 4242/11112. DICOM headers contain patient name, DOB, MRN."

**Viable Today:** ✅ YES - DICOM sniffer + patient network access = PHI capture in seconds.

**Mitigation:** Implement DICOM TLS (DICOM PS3.15):
```bash
storescp --tls-require /path/to/cert.pem 4242  # Enable DICOM TLS on port 4242
```

---

### Attack 6: Database Connection Eavesdropping + Key Recovery from Memory

**Attack:** Unencrypted Database Access + Attacker with Root Privileges

**Mechanism:** PostgreSQL connection from ehr-srv-01 to ehr-db-01 is in plaintext (audit notes: pg_hba.conf allows "hostnossl"). An attacker with root on the application server can: (A) sniff database queries showing patient data in plaintext, or (B) extract AES encryption keys from PostgreSQL process memory using `gdb` or similar if database-level encryption keys are stored in RAM.

**MedDefense Vulnerability:** Database connections are unencrypted (audit notes confirm). If database encryption keys are stored in memory (not HSM), attacker can:
1. Sniff database traffic → see all queries (including PHI)
2. Dump memory of PostgreSQL process → extract encryption key
3. Decrypt all database files with extracted key

**Evidence:** T0 audit notes: "PostgreSQL configured with ssl=on, but pg_hba.conf allows non-SSL connections from 10.10.0.0/16 ('hostnossl' lines exist)." No mention of key protection mechanism.

**Viable Today:** ✅ YES (if attacker gains root on ehr-srv-01). Unencrypted database connections + weak key protection = both plaintext and key exfiltration possible.

**Mitigation:**
1. Enforce encrypted connections: Remove "hostnossl" lines; require "hostssl" or "hostgssapi"
2. Store encryption keys in external Vault or HSM (not PostgreSQL process memory)
3. Implement Host-Based Access Control: ehr-srv-01 can only connect to ehr-db-01 via specific encrypted channels
4. Monitor: Alert on any database connection attempts without TLS

---

### Attack Summary: Viability Matrix

| Attack | Viable Today | System Affected | Time to Execute | Damage | Mitigation |
|---|---|---|---|---|---|
| TLS Downgrade | ✅ YES | Portal (TLS 1.0) | 1 minute | PHI in transit captured | Disable TLS <1.2 |
| Kerberoasting | ✅ YES | Domain (RC4/DES) | 5-60 minutes (crack offline) | Service account compromise | AES-only encryption |
| Birthday Attack | ⚠️ THEORETICAL | If 3DES used | Weeks-months | Collision -> plaintext deduction | Use AES only |
| Weak Kerberos + Weak Password | ✅ YES | Any SPN account | Minutes (crack weak password) | Service account + database access | Enforce AES + strong passwords |
| DICOM Eavesdropping | ✅ YES | PACS (cleartext) | 1 minute (tcpdump) | All DICOM PHI on network | Implement DICOM TLS |
| Database Eavesdropping + Key Extraction | ✅ YES (if root) | Database (plaintext) | 5-30 minutes | All patient records compromised | Enforce SSL + external key storage |

