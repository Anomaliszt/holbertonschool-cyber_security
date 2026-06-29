# MedDefense Health Systems: Incident & Vulnerability Assessment Report

## 1. Process Identification: What `kworker` is Actually Doing

The process disguised as `kworker` (PID 8834) is an active, **malicious cryptocurrency miner** (specifically configured to mine Monero, a privacy-focused cryptocurrency). 

* **The Disguise:** True `kworker` processes are legitimate Linux kernel threads responsible for handling system tasks. Authentic kernel processes always run under the `root` user and appear enclosed in brackets (e.g., `[kworker]`) in system process logs. This malicious process runs under the standard web server user account (**`www-data`**), executes directly out of a hidden directory in the web root (`/var/www/html/.cache/kworker`), and accepts custom command-line arguments.
* **The `stratum+tcp://pool.monero.org` Link:** The `stratum+tcp` prefix denotes the specialized network mining protocol used to coordinate work between a client and a server. This connection string proves that the compromised server has been joined to a public Monero mining pool (`pool.monero.org`), where it receives cryptographic hashing tasks and uploads the completed computations.
* **The Purpose:** The underlying purpose of this process is **cryptojacking**. An external attacker has successfully exploited the web architecture to hijack MedDefense's hardware assets, stealing CPU processing cycles to generate digital currency for their own personal wallet. The severe performance degradation is a direct operational byproduct of this resource theft.

---

## 2. Real Compromise Classification: The Primary Security Violations

The immediate operational symptom is a degradation of Availability (unresponsive billing applications). However, before the server's availability collapsed, **Confidentiality** and **Integrity** were thoroughly compromised:

### Confidentiality (Compromised First)
An external threat actor managed to bypass external boundary security controls and penetrate the billing server's filesystem. By executing an unauthorized remote exploit (likely leveraging a known Remote Code Execution vulnerability in the unpatched Apache 2.4.29 web server), the attacker was able to inspect directories, view system configurations, and locate writeable file paths. This unauthorized exposure and access represents a complete breach of Confidentiality.

### Integrity (Compromised Second)
Following the initial intrusion, the attacker modified the structural configuration and state of the system. They created a hidden repository (`.cache`), injected malicious foreign binary code (`kworker`), and planted an unauthorized configuration file (`config.json`). Furthermore, they manipulated system process execution bounds—hijacking core processor allocation away from legitimate medical billing functions to execute a crypto-mining utility. This unauthorized alteration of files and system behavior constitutes a direct breach of Integrity.

---

## 3. Why the Sysadmin’s Solution Fails

The sysadmin's recommendation to migrate `billing-srv-01` to an upgraded virtual machine with 16GB of RAM and 8 vCPUs **fails completely because it mistakes a critical security breach for a routine hardware capacity limitation.** If MedDefense acts on this recommendation without cleaning the infection:

1. **The Miner Will Automatically Scale Up:** The malicious `config.json` file is explicitly hardcoded to use a specific number of threads and priority configurations. If migrated to a more robust machine, the binary will either immediately consume the newly added processing power, or the attacker will simply modify the configuration file to leverage all 8 vCPUs. MedDefense would ultimately be paying increased cloud/hardware overhead to subsidize the attacker's mining efficiency.
2. **The Security Vulnerability Remains Wide Open:** Allocating raw hardware specs does absolutely nothing to remediate the underlying compromise. The server remains fundamentally breached, continuing to maintain live outbound connections to public mining pools.
3. **Escalation Risk:** The attacker retains active, persistent remote access to the production system as `www-data`. At any moment, they can pivot from quiet background mining to executing lateral network attacks, exfiltrating patient data, or deploying devastating ransomware across the internal network.

---

## 4. Connecting to the January Incident

The occurrence of a major ransomware attack in January followed by a cryptojacking compromise on the exact same server highlights a **fatally flawed remediation process and an exposed internal security posture.**

### What This Suggests About Security Posture
* **Flawed Incident Remediation:** When the server was "rebuilt" following the January ransomware attack, the IT team treated the event purely as a data restoration exercise rather than a forensic security recovery. They likely restored data back into the environment without identifying the initial vector of compromise or patching the software vulnerabilities that allowed the attack to occur in the first place.
* **Absence of Vulnerability Management:** The production asset is running a highly obsolete, End-of-Life operating system (Ubuntu 18.04 LTS) and a vulnerable web server application (Apache 2.4.29) with well-documented Remote Code Execution (RCE) flaws. 

### Critical Questions to Address Immediately
* *"Did we reconstruct this server using the exact same vulnerable operating system images, software versions, and configuration files that allowed the ransomware to compromise us in January?"*
* *"What specific lack of internal firewall controls allowed a server deep inside our 10.10.0.0/16 production network to initiate unmonitored outbound network connections to untrusted public internet IPs over non-standard mining ports (4443, 8080, 3333) without being dropped by our FortiGate 100F firewall?"*
