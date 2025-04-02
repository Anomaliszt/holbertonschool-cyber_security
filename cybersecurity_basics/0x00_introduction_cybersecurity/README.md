# Project: Introduction to Cyber Security Fundamentals

## Project Summary

This project provided hands-on experience with fundamental cybersecurity concepts and essential command-line tools within the Kali Linux environment. The focus was on understanding core security principles, identifying common threats, and implementing basic security-related tasks through practical Bash scripting exercises. This project solidified my understanding of theoretical concepts through direct application.

## Key Concepts Learned & Applied

Through this project, I gained practical understanding and application skills in:

*   **Core Security Principles:** Understanding and articulating the CIA Triad (Confidentiality, Integrity, Availability) as the bedrock of information security.
*   **Cybersecurity Landscape:** Defining cybersecurity, identifying different types of threats (malware like viruses/worms, social engineering), and understanding the importance of risk management.
*   **Essential Security Mechanisms:**
    *   **Encryption:** Recognizing its role in protecting data confidentiality.
    *   **Hashing:** Applying SHA256 for file integrity verification.
    *   **Authentication:** Generating SSH key pairs for secure access and understanding the value of Multi-Factor Authentication (MFA).
    *   **Access Control:** Grasping the importance of controlling user permissions.
*   **Security Programs & Frameworks:** Understanding the purpose of security policies, frameworks (like NIST, CISA), and resources like the OWASP Top Ten in guiding organizational security posture.
*   **System Interaction & Monitoring:** Using command-line tools for basic system information gathering and process monitoring.

## Technical Skills Demonstrated

*   **Bash Scripting:** Developed concise and functional Bash scripts ( adhering to strict line limits) to automate security-related tasks.
*   **Linux Command-Line Proficiency (Kali Linux):** Operated effectively within the Kali Linux environment, utilizing standard utilities for system interaction and security tasks.
*   **Core Security Tool Usage:**
    *   `lsb_release`: System identification.
    *   `/dev/urandom`, `tr`, `head`: Secure random password generation.
    *   `sha256sum`: File integrity checking via cryptographic hashing.
    *   `ssh-keygen`: Generating RSA key pairs for secure authentication.
    *   `ps`, `grep`: Basic process monitoring and filtering.
*   **Problem Solving:** Interpreted requirements and translated them into functional scripts within specific constraints.
*   **Adherence to Standards:** Followed specified coding style guidelines (Betty style) and scripting constraints, demonstrating attention to detail and ability to work within defined parameters.

## Project Tasks & Implementations

The following practical exercises were completed:

1.  **`0-release.sh` - System Identification:**
    *   **Objective:** Programmatically identify the Linux distribution.
    *   **Implementation:** A single-line Bash script using `lsb_release` to output the distribution ID ("Kali").
    *   **Relevance:** Essential for environment awareness in scripting and operations.

2.  **`1-gen_password.sh` - Secure Password Generation:**
    *   **Objective:** Create strong, randomized passwords of a specified length.
    *   **Implementation:** Script utilizing `/dev/urandom` piped through `tr` to filter for alphanumeric characters (`[:alnum:]`) and `head` to limit length based on user input (`$1`).
    *   **Relevance:** Demonstrates understanding of secure random data sources and password complexity best practices.

3.  **`2-sha256_validator.sh` - File Integrity Verification:**
    *   **Objective:** Validate if a file matches a known SHA256 checksum.
    *   **Implementation:** Script calculating the SHA256 hash of a file (`$1`) using `sha256sum` and comparing it to a provided hash (`$2`), outputting "OK" or "FAILED".
    *   **Relevance:** Practical application of cryptographic hashing for ensuring data integrity, crucial for detecting tampering.

4.  **`3-gen_key.sh` - SSH Key Pair Generation:**
    *   **Objective:** Automate the creation of RSA SSH key pairs for secure authentication.
    *   **Implementation:** Script using `ssh-keygen` to generate a 4096-bit RSA key pair, saving the private and public keys to files named after the input argument (`$1`).
    *   **Relevance:** Fundamental practice for securing remote access and automating secure connections.

5.  **`4-root_process.sh` - User Process Monitoring:**
    *   **Objective:** List active processes run by a specific user (e.g., 'root').
    *   **Implementation:** Script using `ps aux` piped to `grep` to filter processes by username (`$1`), excluding certain low-level processes using `grep -v`.
    *   **Relevance:** Basic technique for system monitoring, auditing user activity, and identifying potentially unauthorized processes.



*   **Author:** [Xavier SANCHEZ]
*   **LinkedIn:** [https://www.linkedin.com/in/xavier-sanchez-]