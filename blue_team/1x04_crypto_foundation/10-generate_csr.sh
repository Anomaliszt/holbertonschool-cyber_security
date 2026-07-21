Goal: Generate a Certificate Signing Request for the MedDefense patient portal, making every field decision deliberately and documenting the reasoning.

Context: The patient portal certificate expires in 18 days. James Chen has approved the renewal. You are generating the CSR that will be submitted to the Certificate Authority. Every field in the CSR becomes a field in the certificate, and every field matters. A wrong Common Name locks out patients. A missing SAN entry breaks mobile access. A weak key algorithm undermines the entire purpose.

Instructions:

Part 1 - Key Generation Decision

Before generating the CSR, decide: RSA-2048, RSA-4096 or ECC P-256 for the private key ?

Write a 3-4 sentence justification for your choice. Consider: security level, performance impact on the web server handling 800 patient connections per day, compatibility with older browsers/devices and the recommendations from your Algorithm Reference Table (T6).

Generate the key with your chosen algorithm. Document the command.

Part 2 - CSR Generation

Generate the CSR with appropriate fields for MedDefense's patient portal:

openssl req -new -key portal_key.pem -out portal.csr -config openssl.cnf
You will need to create an openssl.cnf file (or use command-line options) to include:

Common Name: portal.meddefense.local

Organization: MedDefense Health Systems

Organizational Unit: Information Technology

Locality, State, Country: appropriate for MedDefense

Subject Alternative Names: include both portal.meddefense.local and any other hostnames patients might use

Document the complete CSR generation process.

Part 3 - CSR Inspection

Inspect your CSR:

openssl req -text -noout -in portal.csr
Verify that every field is correct. Document the output. Confirm the SAN entries are present.

Part 4 - The Full Lifecycle

Write a step-by-step description (not a script, but a procedure document) of the complete certificate lifecycle from this point:

CSR generated (done)

Submission to CA (which CA ? Let's Encrypt via ACME or a commercial CA ?)

Validation process (what the CA verifies)

Certificate issuance

Installation on the web server

Verification that the new certificate is serving correctly

Decommission of the old certificate

Monitoring for the next renewal

Write a script 10-generate_csr.sh that automates steps 1-3 of the key generation and CSR creation process.

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 10-generate_csr.sh, 10-csr_workshop.md
