# Shodan Reconnaissance Summary: holbertonschool.com

## Key Findings:

*   **IP Addresses Identified:**
    *   `35.180.27.154`
    *   `52.47.143.83`
*   **Hosting & Network:**
    *   Both IPs hosted on **Amazon Web Services (AWS)** EC2 in **Paris, France** (`eu-west-3` region).
    *   Likely belong to AWS ASN: **AS16509**. No specific Holberton ranges identified, only AWS ranges.
*   **Subdomains Found:**
    *   `yriry2.holbertonschool.com` (associated with `52.47.143.83`)
    *   `holbertonschool.com` (seen as redirect target from `35.180.27.154`)
*   **Technologies Observed:**
    *   **Web Server:** Nginx (`1.18.0`, `1.21.6`)
    *   **OS:** Ubuntu (inferred)
    *   **SSL:** Let's Encrypt certificate used for `yriry2.holbertonschool.com`.
    *   **Service:** A "Holberton School Level2 Forum" detected on `yriry2.holbertonschool.com`.
