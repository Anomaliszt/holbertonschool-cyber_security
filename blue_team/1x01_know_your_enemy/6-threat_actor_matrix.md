# Threat Actor Matrix — MedDefense

This matrix consolidates threat actor likelihood, capability, motivation, attack methods, primary targets, and specific MedDefense security gaps.

---

| Actor Type | Likelihood | Capability | Primary Motivation | Preferred Vector | Primary Target | MedDefense Exposure (Gap IDs) |
|---|---|---|---|---|---|---|
| **Ransomware Groups (Organized Crime / RaaS)** | **Critical** — Healthcare is one of the most targeted ransomware sectors. MedDefense is an ideal target due to its 350-bed hospital profile, HIPAA-regulated patient data, clinical urgency, and current security gaps. | **High** — Professional RaaS operations use Initial Access Brokers, ransomware affiliates, credential theft, privilege escalation, data exfiltration, and double-extortion techniques. | Financial gain through ransom payments, patient data extortion, and resale of stolen information. | Phishing campaigns, exposed VPN services, vulnerable public-facing applications, stolen credentials, compromised vendors. | EHR servers, patient databases, file servers, domain controllers, backup systems, identity infrastructure. | **G1:** Unpatched public-facing systems<br>**G2:** Flat network architecture<br>**G3:** Lack of SIEM/EDR monitoring<br>**G4:** Non-isolated backups<br>**G5:** Excessive vendor access |
| **Nation-State APT** | **Low** — MedDefense is a regional healthcare provider and lacks major pharmaceutical research programs, government contracts, or strategic intelligence value. | **Very High** — State-sponsored groups use zero-days, custom malware, advanced persistence, supply-chain compromise, and long-term covert operations. | Strategic intelligence collection, intellectual property theft, geopolitical advantage, and espionage. | Spear phishing, zero-day exploitation, supply-chain compromise, credential theft, trusted third-party access. | Executive communications, research data, sensitive patient information, intellectual property. | **G1:** Legacy systems<br>**G3:** Limited security monitoring<br>**G5:** Third-party access exposure<br>**G6:** Weak identity controls |
| **Insider (Malicious)** | **High** — Healthcare employees and contractors have legitimate access to valuable patient and operational data. MedDefense has exposure through shared accounts, weak monitoring, and access lifecycle issues. | **Medium** — Requires limited technical capability because attackers abuse legitimate access, privileges, and internal knowledge. | Financial gain, revenge, sabotage, unauthorized disclosure, identity theft. | Credential misuse, privilege abuse, unauthorized database access, data theft, administrative account misuse. | Patient records, billing systems, EHR databases, administrative systems, financial information. | **G7:** Shared accounts<br>**G8:** Weak access monitoring<br>**G9:** Poor employee offboarding<br>**G10:** Excessive privileges |
| **Insider (Negligent)** | **High** — Healthcare employees frequently operate under time pressure and prioritize patient care, increasing the likelihood of security mistakes. | **Low–Medium** — Does not require advanced skills; risk comes from mistakes, policy violations, and unsafe workflows. | Convenience, productivity shortcuts, lack of awareness, accidental disclosure. | Phishing interaction, password sharing, shadow IT, accidental exposure, insecure data handling. | Email accounts, patient information, cloud storage, medical systems, shared documents. | **G7:** Shadow IT exposure<br>**G8:** Insufficient security awareness<br>**G11:** Weak credential practices<br>**G12:** Poor data handling controls |
| **Hacktivist** | **Low** — MedDefense has limited political visibility and is unlikely to be specifically selected, although healthcare organizations may experience collateral attacks. | **Low–Medium** — Hacktivists typically rely on publicly available tools, DDoS attacks, website defacement, and leaked credentials. | Political messaging, ideological activism, publicity, disruption. | Website exploitation, DDoS attacks, social engineering, credential abuse. | Public website, patient portals, social media platforms, public-facing services. | **G1:** Internet-facing vulnerabilities<br>**G13:** Weak web security controls<br>**G14:** Limited DDoS protection |
| **Unskilled / Opportunistic Attacker** | **High** — Automated attackers continuously scan healthcare networks for exposed systems and known vulnerabilities. MedDefense has already demonstrated exposure through prior opportunistic exploitation. | **Low** — Uses automated scanners, exploit kits, default credentials, and publicly available malware rather than custom capabilities. | Cryptocurrency mining, automated monetization, experimentation, opportunistic compromise. | Internet scanning, unpatched vulnerabilities, exposed services, default credentials. | Public-facing servers, endpoints, medical devices, exposed applications. | **G1:** Unpatched systems<br>**G11:** Weak credential controls<br>**G15:** Asset inventory and vulnerability management gaps |

---

# Top 3 Threat Actor Priority Ranking

## 1. Ransomware Groups (Organized Crime / RaaS) — CRITICAL

Ransomware groups represent the greatest threat to MedDefense because they combine the highest likelihood with the highest operational impact. Healthcare organizations are specifically targeted because downtime threatens patient care and creates pressure to restore operations quickly. MedDefense’s current weaknesses directly align with common ransomware attack paths: exposed services, flat networks, limited monitoring, weak backup isolation, and extensive vendor access.

A successful ransomware attack could result in:

- Loss of EHR availability
- Patient care disruption
- Exposure of protected health information (PHI)
- Regulatory penalties
- Financial losses
- Long-term reputational damage

---

## 2. Insider (Malicious) — HIGH

Malicious insiders represent the second-highest risk because they begin with trusted access and can bypass many external security controls. Healthcare environments contain large amounts of valuable personal information, making employees, contractors, and administrators attractive targets.

MedDefense exposure increases this risk through:

- Shared accounts
- Excessive privileges
- Weak monitoring
- Poor access removal procedures

A malicious insider could steal patient data, manipulate records, or sabotage critical systems while appearing to perform legitimate activities.

---

## 3. Insider (Negligent) — HIGH

Negligent insiders rank third because human error remains one of the most common causes of healthcare security incidents. The healthcare environment creates unique conditions that increase risk: urgent workflows, large numbers of users, rotating shifts, and pressure to maintain availability.

Common outcomes include:

- Successful phishing compromise
- Credential disclosure
- Shadow IT introduction
- Accidental patient data exposure
- Misconfigured systems

Although negligent insiders do not intend harm, their actions frequently provide the initial access path used by ransomware groups and other external attackers.

---

# Board-Level Conclusion

MedDefense is primarily threatened by adversaries who can exploit existing operational weaknesses rather than only the most technically advanced attackers. The highest-risk actors are ransomware groups and trusted-access threats because they align directly with MedDefense’s current vulnerabilities.

The priority should be:

1. Reduce ransomware attack paths through patching, segmentation, EDR, and protected backups.
2. Control privileged access for employees and vendors.
3. Improve security awareness and verification procedures.
4. Increase visibility through centralized monitoring and logging.
