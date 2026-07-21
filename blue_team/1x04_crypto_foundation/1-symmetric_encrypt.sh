Goal: Master symmetric encryption through hands-on OpenSSL operations, comparing modes, measuring performance and building an automation script.

Context: Symmetric encryption is the workhorse of modern cryptography. Every file encrypted at rest, every database field protected, every VPN tunnel carrying data between MedDefense sites uses symmetric encryption at its core. AES is the standard. But "use AES" is not a complete answer. AES-128 or AES-256 ? CBC or GCM mode ? What are the performance implications ?

You are going to find out by doing it.

Instructions:

Part 1 - AES Encryption and Decryption

Create a test file containing the text: Patient: Jane Doe | DOB: 1985-03-14 | MRN: MED-50421 | Diagnosis: Atrial Fibrillation

Encrypt this file using OpenSSL with three different configurations and document the exact command for each:

AES-256-CBC (the traditional mode)

AES-256-GCM (the authenticated encryption mode)

AES-128-CBC (reduced key length)

Part 2 - The Performance Measurement

Create a 100MB test file: dd if=/dev/urandom of=testfile bs=1M count=100

Part 3 - The Script

Write a script 1-symmetric_encrypt.sh that takes three arguments: an input file, an output file and a mode (cbc or gcm). The script should encrypt the input file with AES-256 in the specified mode and output the result.

Dépôt:

Dépôt GitHub: holbertonschool-cyber_security
Répertoire: blue_team/1x04_crypto_foundation
Fichier: 1-symmetric_encrypt.sh
