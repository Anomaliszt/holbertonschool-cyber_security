# Project: Linux Security Basics

## Project Summary

This project provided practical experience with fundamental Linux security concepts and command-line utilities within the Kali Linux environment. The focus was on monitoring system activity, managing network connections and firewall rules, and performing basic security audits. Through a series of concise Bash scripts, adhering to strict coding standards, I demonstrated the ability to apply theoretical security knowledge to real-world administrative and security tasks on a Linux system.

## Key Concepts Learned & Applied

Through this project, I gained practical understanding and application skills in:

*   **Linux Fundamentals:** Understanding the Linux operating system structure, essential commands, and the Filesystem Hierarchy Standard (FHS).
*   **System Monitoring & Auditing:**
    *   Tracking user login activity (`last`).
    *   Monitoring active network connections and listening services (`ss`, `netstat`).
    *   Identifying processes associated with network sockets.
    *   Performing automated system security audits (`lynis`).
*   **Network Security:**
    *   Understanding network sockets (TCP/UDP, listening vs. active).
    *   Basic network traffic analysis and packet capture (`tcpdump`).
    *   Network discovery and port scanning (`nmap`).
*   **Firewall Management:**
    *   Configuring firewall rules using `ufw` to control network access.
    *   Inspecting existing firewall rulesets (`iptables`).
*   **Privilege Management:** Executing security-sensitive commands requiring root/sudo privileges.
*   **Secure Scripting Practices:** Developing functional scripts within defined constraints.

## Technical Skills Demonstrated

*   **Bash Scripting:** Created concise (2-line limit) and functional Bash scripts to automate security and administrative tasks.
*   **Linux Command-Line Proficiency (Kali Linux):** Operated effectively within the Kali Linux terminal, utilizing standard utilities for system monitoring, network management, and security analysis.
*   **Core Security Tool Usage:**
    *   `last`: Viewing user login history.
    *   `ss` / `netstat`: Displaying network connections, listening ports, and associated processes (TCP/UDP).
    *   `ufw`: Managing the Uncomplicated Firewall (allowing specific traffic).
    *   `iptables`: Listing detailed firewall rules (verbose output).
    *   `lynis`: Executing system security audits.
    *   `tcpdump`: Capturing and analyzing network packets.
    *   `nmap`: Scanning networks/hosts to identify live systems and open ports.
*   **Problem Solving:** Interpreted specific security requirements and translated them into precise command-line operations and scripts.
*   **Adherence to Standards:** Followed strict project constraints including script length (exactly 2 lines), executable permissions, shebang usage (`#!/bin/bash`), and Betty coding style, demonstrating attention to detail and ability to work within specifications.

## Project Tasks & Implementations

The following practical exercises were completed by developing specific Bash scripts:

1.  **`0-login.sh` - User Login History:**
    *   **Objective:** Display the last 5 login sessions with timestamps.
    *   **Implementation:** A 2-line script utilizing the `last` command (e.g., `last -n 5 -F`) to retrieve and format recent login data. Requires privileged execution.
    *   **Relevance:** Essential for security auditing, tracking user access patterns, and identifying potential unauthorized login attempts.

2.  **`1-active-connections.sh` - Network Socket Display:**
    *   **Objective:** List all active and listening TCP network socket connections, showing numerical addresses and associated process information.
    *   **Implementation:** Script using the `ss` command (part of `iproute2`) with appropriate flags (e.g., `ss -tanp`) to display the required TCP socket details. Requires privileged execution.
    *   **Relevance:** Critical for understanding current network activity, identifying services, and troubleshooting connectivity issues.

3.  **`2-incoming_connections.sh` - Firewall Rule Configuration:**
    *   **Objective:** Configure the system firewall to allow only incoming TCP traffic on port 80 (HTTP).
    *   **Implementation:** Script employing the `ufw` command (e.g., `ufw allow 80/tcp`) to add a rule permitting specific incoming connections. Requires privileged execution.
    *   **Relevance:** Demonstrates fundamental firewall management for securing services by controlling network ingress points.

4.  **`3-firewall_rules.sh` - Firewall Rule Listing:**
    *   **Objective:** Display all current firewall rules in the security table with verbose output.
    *   **Implementation:** Script using `iptables` with flags for listing rules verbosely (e.g., `iptables -L -v`). Requires privileged execution.
    *   **Relevance:** Important for verifying firewall configuration, troubleshooting access problems, and auditing security posture.

5.  **`4-network_services.sh` - Listening Services Identification:**
    *   **Objective:** List all listening TCP and UDP services, including their ports, state, and associated PIDs/program names.
    *   **Implementation:** Script using `ss` with flags to show listening sockets for both TCP and UDP, numerical addresses, and process info (e.g., `ss -tulnp`). Requires privileged execution.
    *   **Relevance:** Key for identifying running network services on a system, verifying intended services are active, and spotting potentially unauthorized listeners.

6.  **`5-audit_system.sh` - System Security Audit:**
    *   **Objective:** Initiate a comprehensive system security audit using Lynis.
    *   **Implementation:** Script executing the `lynis audit system` command to perform a security scan and generate a report. Requires privileged execution.
    *   **Relevance:** Showcases the use of automated auditing tools for identifying security weaknesses, configuration issues, and compliance checks.

7.  **`6-capture_analyze.sh` - Network Traffic Capture:**
    *   **Objective:** Capture a small sample (5 packets) of network traffic passing through the system.
    *   **Implementation:** Script utilizing `tcpdump` with flags to capture on any interface and limit the packet count (e.g., `tcpdump -i any -c 5`). Requires privileged execution.
    *   **Relevance:** Demonstrates basic packet capture skills essential for network troubleshooting and security analysis (inspecting live traffic).

8.  **`7-scan.sh` - Network Host Discovery:**
    *   **Objective:** Scan a specified subnetwork or host ($1) to discover live hosts and potentially open ports.
    *   **Implementation:** Script using `nmap` to perform a network scan on the target provided as a command-line argument. Requires privileged execution for certain scan types.
    *   **Relevance:** Fundamental technique in network reconnaissance for mapping network topology and identifying potential targets or vulnerabilities.

*   **Author:** Xavier SANCHEZ
*   **LinkedIn:** https://www.linkedin.com/in/xavier-sanchez-
