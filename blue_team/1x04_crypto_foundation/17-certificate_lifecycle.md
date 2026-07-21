## CERTIFICATE LIFECYCLE MANAGEMENT PLAN FOR MEDDEFENSE

### Certificate Inventory

| Certificate | Purpose | Current Issuer | Expiration (Est.) | Responsible Owner | Current Status |
|---|---|---|---|---|---|
| **patient-portal.crt** | Patient portal HTTPS (portal.meddefense.local) | Let's Encrypt | 18 days overdue | Sarah Park (IT Director) | ⚠️ CRITICAL—RENEW IMMEDIATELY |
| **ehr-internal.crt** | Internal EHR communication (ehr-srv-01) | Self-signed or internal CA | Unknown (likely expired) | DBA team | ❌ NOT TRACKED |
| **pacs-certificate.crt** | PACS server (pacs-srv-01) | Self-signed | Unknown | Biomedical team | ❌ NOT TRACKED |
| **vpn-central.crt** | VPN endpoint (FortiGate Central) | Likely self-signed or commercial | Unknown | Network team | ❌ NOT TRACKED |
| **vpn-westside.crt** | VPN endpoint (Netgear Westside) | Likely self-signed | Unknown | Network team | ❌ NOT TRACKED |
| **email-signing.crt** | S/MIME code signing (future implementation) | N/A (not yet deployed) | N/A | Compliance | 📋 PLANNED |

---

### Auto-Renewal Strategy

**Recommendation for Patient Portal:** **Commercial CA (DigiCert) with manual 1-year certificates**

**Rationale:**

| Factor | Let's Encrypt (ACME/Automated) | Commercial CA (Manual/1-year) | MedDefense Choice |
|---|---|---|---|
| **Certificate Validity** | 90 days | 1-365 days | 1-year (commercial) |
| **Automation** | Fully automated (renewal 30 days before expiry) | Manual; requires human process | Manual |
| **Certificate Type** | DV only (domain validation) | OV, EV available | OV (commercial) |
| **Clinical Impact** | Every 90 days = 4 renewals/year; every renewal = brief downtime risk | Once/year = lower disruption | Once/year (1 disruption risk) |
| **Cost** | Free | $400-800/year | Affordable for healthcare |
| **Audit Compliance** | Acceptable but frequent renewals complicate audits | Standard for healthcare; predictable cycle | Preferred |
| **Patient Experience** | Risk: If automation fails, portal expires; 800 daily patients affected | Lower risk: Annual renewal = one scheduled maintenance window | Safer for operations |

**MedDefense Decision:** Use commercial CA (DigiCert or Sectigo) with **1-year validity** and **manual renewal process**, not ACME automation. Reason: With 800 daily patients, a certificate expiration is a clinical incident (patients cannot access medical records). Automatic renewal introduces risk of failure; manual renewal with calendar-based scheduling is more reliable for healthcare.

---

### Monitoring and Alerting

**System:** Implement certificate monitoring using Certbot or Zabbix

**Alert Thresholds:**

| Days Remaining | Severity | Recipient | Action |
|---|---|---|---|
| >90 days | ℹ️ Info | None | Certificate is healthy |
| 60 days | 🟡 Warning | Sarah Park (IT Director) | Planning email: "Certificate renewal due in 60 days; schedule CSR/issuance" |
| 30 days | 🟠 Alert | Sarah Park + backup (CTO) | "Certificate renewal required in 30 days; begin CSR process" |
| 7 days | 🔴 Critical | Sarah Park + CTO + Security Lead | "Certificate expires in 7 days; URGENT—issue new cert and deploy" |
| 1 day | 🔴 EMERGENCY | All IT leadership + CMO | "Certificate expires tomorrow; emergency deployment required" |
| 0 days (expired) | 🔴 CRITICAL INCIDENT | Executive escalation | Portal is down; breach of service |

**Monitoring Tool Setup:**
```bash
# Using certbot (if automated renewal) or manual check
certbot certificates

# Using Zabbix
zabbix_agent → check TLS certificate validity → alert if expiring soon

# Using openssl (manual check)
echo | openssl s_client -servername portal.meddefense.local -connect portal.meddefense.local:443 2>/dev/null | openssl x509 -noout -dates
```

---

### Certificate Policy (5 Rules)

**Policy #1: Certificate Authority Approval**
"All production certificates must be issued by a trusted public Certificate Authority (DigiCert, Sectigo, GlobalSign, etc.) or by MedDefense's internal CA (if established). Self-signed certificates are prohibited in production environments. Exception: Temporary self-signed certs for testing/development must be clearly marked and retired before production deployment."

**Policy #2: Certificate Type and Validation**
"Patient-facing services (patient portal, API) must use Organization-Validated (OV) or Extended-Validation (EV) certificates to verify organizational identity. Internal services may use Domain-Validated (DV) or internal CA certificates. All certificates must include complete Subject Alternative Names (SAN) covering all domains/services protected by the cert."

**Policy #3: Key Algorithm and Strength**
"All certificates issued after [DATE] must use ECC P-256 or RSA-2048+ key algorithms. DES, 3DES, MD5, SHA-1, and RC4 are prohibited. Cipher suites must prioritize AES-256-GCM. TLS 1.2 minimum; TLS 1.3 preferred for new deployments."

**Policy #4: Renewal and Expiration Management**
"Certificate renewal must begin at least 30 days before expiration. Renewals must not cause service downtime; schedule during maintenance windows or use zero-downtime renewal techniques (simultaneous cert deployment). Expired certificates automatically trigger incident response; expiration of a patient-facing service is considered a security breach."

**Policy #5: Key Storage and Access Control**
"Private keys associated with production certificates must be stored in a Hardware Security Module (HSM) or encrypted key vault (HashiCorp Vault, AWS KMS) with restricted access. Keys must not be stored in plaintext on servers. Access to private keys must be logged and auditable. Annual key rotation is mandatory; compromised keys trigger immediate certificate revocation and reissuance."

---

### Implementation Schedule

| Week | Action | Owner | Status |
|---|---|---|---|
| This Week | EMERGENCY: Renew patient portal certificate (expires in 18 days) | Sarah Park | 🔴 URGENT |
| Week 2 | Audit all other certificates; document expiration dates | IT Compliance | 📋 Pending |
| Week 3 | Purchase OV certificates from DigiCert for portal + internal services | Sarah Park | 📋 Pending |
| Week 4 | Implement Zabbix certificate monitoring alerts | IT Operations | 📋 Pending |
| Month 2 | Deploy new OV certificates to all services | IT Deployment | 📋 Pending |
| Month 2 | Establish annual certificate renewal calendar (Jan 1 renewal date) | Compliance | 📋 Pending |
| Ongoing | Monitor certificate expiration; renew 30 days before expiry | IT Operations | 🔄 Ongoing |

