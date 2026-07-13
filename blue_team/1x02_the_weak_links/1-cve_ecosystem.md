# NVD CVE Research Report

## Selected CVEs

From the MedDefense Health Systems vulnerability scan report, the following three CVEs were selected:

| Severity | CVE | Vulnerability |
|---|---|---|
| Critical | CVE-2021-44790 | Apache HTTP Server mod_lua Buffer Overflow |
| High | CVE-2020-1938 | Apache Tomcat Ghostcat (AJP File Disclosure) |
| Medium | CVE-2021-43798 | Grafana Path Traversal |

---

# CVE Analysis 1 — Critical

## CVE ID
CVE-2021-44790

## NVD URL
https://nvd.nist.gov/vuln/detail/CVE-2021-44790

## Description
Apache HTTP Server contains a buffer overflow vulnerability in the `mod_lua` module's multipart request parsing functionality. A remote attacker can send a specially crafted HTTP request that may trigger memory corruption and potentially execute arbitrary code without authentication.

## Affected Products

Examples of affected products from NVD CPE data:

1. Apache HTTP Server 2.4.51 and earlier
2. Apache HTTP Server 2.4.x versions before 2.4.52
3. Apache HTTP Server installations with the vulnerable `mod_lua` module enabled

## CVSS v3.1 Vector String
