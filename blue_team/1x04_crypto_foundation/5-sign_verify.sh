Goal: Sign and verify files with OpenSSL, then connect the cryptographic properties of digital signatures to real-world healthcare requirements where non-repudiation is legally mandated.

Context: A digital signature simultaneously provides three properties: integrity (the content has not been modified), authentication (the signer is who they claim to be) and non-repudiation (the signer cannot deny having signed). In healthcare, these properties are not optional. Electronic prescriptions, clinical trial consent forms and audit logs all require digital signatures to be legally valid under HIPAA and the ESIGN Act.

Instructions:

Part 1 - Sign and Verify

Using your RSA key pair from T2:

Create a file prescription.txt with content: Patient: John Smith | MRN: MED-10042 | Rx: Metoprolol 50mg | Prescriber: Dr. Patel

Sign the file with SHA-256 and your RSA private key. Document the command.

Verify the signature with the public key. Document the command and output.

Modify one character in prescription.txt. Verify again. Document the failure output.

Part 2 - The Signing Script

Write a script 5-sign_verify.sh that:

Accepts a mode argument: sign or verify

In sign mode: takes a file path and a private key path, produces a .sig signature file

In verify mode: takes a file path, a signature file path and a public key path, outputs the verification result

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 5-sign_verify.sh
