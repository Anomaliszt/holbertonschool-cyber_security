# MedDefense Network Segmentation Architecture

## Part 1 - Zone Definition

| Zone | Proposed Range | Systems Included | Allowed Outbound | Allowed Inbound |
|---|---|---|---|---|
| **DMZ / Public Services** | 10.10.10.0/24 | `web-srv-01`, external reverse proxy, vendor jump host | HTTPS to approved backend app services, SIEM/syslog, patch repos | Internet to published HTTPS only; management from Management Zone only |
| **Server Zone** | 10.10.20.0/24 | `ehr-srv-01`, `ehr-db-01`, `billing-srv-01`, `ad-dc-01/02`, `file-srv-01`, `backup-srv-01` | AD/DNS, backup replication, SIEM, approved app flows | Clinical Zone to EHR app ports only; Management Zone for admin; DMZ app traffic only |
| **Clinical Workstation Zone** | 10.10.30.0/23 | Nurse stations, physician workstations, clinical iPads (managed only) | EHR web/app ports, DNS, print, patching, SIEM agent traffic | Management Zone for remote admin; Server Zone for approved app responses only |
| **Medical Device Zone** | 10.10.40.0/24 | BD Alaris pumps, MRI workstation, bedside monitors, PACS modalities | PACS/image transfer, time sync, approved clinical middleware, SIEM/passive monitoring | Clinical Zone only to approved device management ports; Management Zone for biomedical admin |
| **Management / Security Zone** | 10.10.50.0/24 | IT admin workstations, jump hosts, Wazuh, backup console, vulnerability scanner | Administrative protocols to all internal zones as approved; vendor sessions proxied here | None from user or guest zones except explicit VPN/jump-host entry |
| **Guest / Non-Clinical IoT Zone** | 10.10.60.0/24 | Visitor Wi-Fi, TVs, cafeteria kiosks, non-managed devices | Internet only via filtered egress | No inbound from internal zones |
| **Westside Clinic Zone** | 10.20.10.0/24 | Westside servers, workstations, site router/firewall | Site-to-site VPN to published central services only | Central Management Zone and approved clinical apps only |

## Part 2 - Ten Critical Firewall Rules
1. **Clinical Zone -> Server Zone : 443/TCP, 8443/TCP : ALLOW**  
   Permits user access to EHR and approved clinical web applications.
2. **Clinical Zone -> Server Zone : 5432/TCP, 3306/TCP : DENY**  
   Prevents workstations from talking directly to PostgreSQL/MySQL databases.
3. **Guest Zone -> Any Internal Zone : ANY : DENY**  
   Prevents visitor or unmanaged devices from pivoting into hospital systems.
4. **Medical Device Zone -> Server Zone : PACS/DICOM, approved middleware only : ALLOW**  
   Supports required clinical data flows without broad server access.
5. **Medical Device Zone -> Internet : ANY : DENY**  
   Prevents pumps, monitors, and legacy devices from reaching arbitrary external destinations or C2 servers.
6. **Management Zone -> All Internal Zones : SSH/RDP/WinRM/SNMP/HTTPS as approved : ALLOW**  
   Forces administrative activity through controlled systems.
7. **Any User Zone -> Management Zone : ANY : DENY**  
   Prevents compromised workstations from attacking admin tooling and SIEM systems.
8. **DMZ -> Server Zone : 443/TCP to published application backends only : ALLOW**  
   Restricts public-facing systems to narrow backend paths.
9. **Westside Zone -> Server Zone : EHR app ports, DNS, backup relay only : ALLOW**  
   Limits branch-office access to explicitly approved services.
10. **Westside Zone -> AD / Server admin ports : ANY except approved management path : DENY**  
   Prevents the branch from becoming a flat-network transit point into core infrastructure.

### What the deny rules prevent
- **Rule 2** stops a compromised nurse station from connecting directly to `ehr-db-01`, shrinking the blast radius of phishing and malware.  
- **Rule 3** prevents guest Wi-Fi or personal devices from becoming initial footholds into clinical systems.  
- **Rule 5** blocks legacy and medical IoT devices from beaconing externally or downloading payloads.  
- **Rule 7** protects security tooling and administrative workstations from lateral movement.

## Part 3 - Kill Chain Impact
### Kill Chain #1 (Ransomware via Internet-Facing Apache Server)
1. **Initial access on `billing-srv-01`:** Segmentation does **not** stop the initial exploit.  
2. **Foothold / persistence:** EDR and SIEM help here, but segmentation starts to matter immediately after compromise.  
3. **Lateral movement:** The chain is broken when the attacker attempts direct workstation, AD, database, and backup traversal. Database ports are denied, user-to-management traffic is blocked, and admin paths are concentrated in the Management Zone.  
4. **Backup destruction:** Immutable offsite backups reduce impact, and segmentation limits direct NAS reach.  
5. **Mass deployment:** Group Policy abuse becomes harder because reaching and controlling AD from the initial foothold is no longer trivial.

### Estimated Kill Chain Disruption
This design would materially disrupt **4 of the top 5 kill chains (about 80%)** identified in 1x01. It does not eliminate phishing, vulnerable software, or insider misuse by itself, but it sharply reduces the ability of those events to become enterprise-wide crises.
