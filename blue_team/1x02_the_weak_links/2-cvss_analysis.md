# CVSS v3.1 Scoring Analysis Report

## Tool Used

NIST CVSS v3.1 Calculator:

https://www.first.org/cvss/calculator/3.1

---

# Exercise 1 — CVSS Vector Deconstruction

## Source Vector

Finding 001 — CVE-2021-44790 (Apache HTTP Server mod_lua Buffer Overflow)

```text
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

## Final Score

**CVSS Base Score: 9.8**

**Severity: Critical**

---

# Vector Component Breakdown

| Component | Meaning | Selected Value | Explanation |
|---|---|---|---|
| AV | Attack Vector | N — Network | The vulnerability can be exploited remotely over a network connection |
| AC | Attack Complexity | L — Low | Exploitation does not require special conditions or complicated steps |
| PR | Privileges Required | N — None | The attacker does not need authentication or an account |
| UI | User Interaction | N — None | The victim does not need to perform any action |
| S | Scope | U — Unchanged | The vulnerable component and impact remain within the same security authority |
| C | Confidentiality | H — High | Successful exploitation can expose sensitive information |
| I | Integrity | H — High | Successful exploitation can allow modification or control of data |
| A | Availability | H — High | Successful exploitation can affect system availability |

---

# Metric Explanation

## Attack Vector (AV)

### Selected:

```
AV:N
```

Meaning:

The vulnerability can be exploited remotely through a network connection.

Possible values:

| Value | Meaning | Effect on Score |
|---|---|---|
| N | Network | Highest impact because remote attackers can exploit it |
| A | Adjacent Network | Requires access to the same local network |
| L | Local | Requires local system access |
| P | Physical | Requires physical access |

Why Network was selected:

Apache HTTP Server is exposed through HTTP. An attacker only needs to send a malicious HTTP request over the network.

---

## Attack Complexity (AC)

### Selected:

```
AC:L
```

Meaning:

The attack is straightforward and does not require unusual conditions.

Possible values:

| Value | Meaning |
|---|---|
| L | Low complexity |
| H | High complexity |

Why Low was selected:

The attacker only needs to craft a malicious request. No special timing, race conditions, or environmental preparation are required.

---

## Privileges Required (PR)

### Selected:

```
PR:N
```

Meaning:

The attacker does not need any account or authentication.

Possible values:

| Value | Meaning |
|---|---|
| N | None |
| L | Low privileges |
| H | High privileges |

Why None was selected:

The vulnerability can be exploited without logging into the Apache server.

---

## User Interaction (UI)

### Selected:

```
UI:N
```

Meaning:

No victim interaction is required.

Possible values:

| Value | Meaning |
|---|---|
| N | None |
| R | Required |

Why None was selected:

The attacker directly sends the malicious request to Apache.

---

## Scope (S)

### Selected:

```
S:U
```

Meaning:

The vulnerable component and affected resources are under the same security authority.

Possible values:

| Value | Meaning |
|---|---|
| U | Unchanged |
| C | Changed |

Why Unchanged was selected:

Apache itself is compromised; exploitation does not require crossing into another security authority.

---

## Confidentiality (C)

### Selected:

```
C:H
```

Meaning:

A successful attack can expose all sensitive information.

Possible values:

| Value | Meaning |
|---|---|
| N | None |
| L | Limited |
| H | High |

---

## Integrity (I)

### Selected:

```
I:H
```

Meaning:

The attacker may modify or execute unauthorized actions.

Possible values:

| Value | Meaning |
|---|---|
| N | None |
| L | Limited |
| H | High |

---

## Availability (A)

### Selected:

```
A:H
```

Meaning:

The attacker can significantly impact service availability.

Possible values:

| Value | Meaning |
|---|---|
| N | None |
| L | Limited |
| H | High |

---

# Attack Vector Change Scenario

Original:

```text
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

Score:

```
9.8 Critical
```

Change:

```
AV:N → AV:L
```

New vector:

```text
CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

## New Score

**8.4 — High**

## Explanation

The score decreases because the vulnerability is no longer remotely exploitable.

Network vulnerabilities receive a higher score because attackers can exploit them without needing access to the target machine. A Local attack requires the attacker to already have access to the system, reducing exploitability.

---

# Exercise 2 — CVSS Vector Construction

## Vulnerability Characteristics

Given:

- Exploitable only from the local network
- Exploitation requires specific conditions
- Requires low-level privileges
- No user interaction
- Scope unchanged
- Complete confidentiality impact
- No integrity impact
- No availability impact

---

# Metric Selection

| Metric | Value | Reason |
|---|---|---|
| Attack Vector | A | Adjacent network access required |
| Attack Complexity | H | Requires specific conditions |
| Privileges Required | L | Low-level privileges required |
| User Interaction | N | No user action required |
| Scope | U | Same security authority |
| Confidentiality | H | Complete information disclosure |
| Integrity | N | No modification possible |
| Availability | N | No service impact |

---

# Constructed Vector

```text
CVSS:3.1/AV:A/AC:H/PR:L/UI:N/S:U/C:H/I:N/A:N
```

---

# NIST Calculator Result

## Base Score

**4.2**

## Severity Rating

**Medium**

---

# Explanation

The score is reduced compared with a critical vulnerability because:

- The attacker must already be on the adjacent network
- Exploitation requires additional conditions
- The attacker needs low-level privileges
- Only confidentiality is impacted

The lack of integrity and availability impact significantly lowers the score.

---

# Exercise 3 — CVSS Comparison

## Selected Findings

### Finding A — Critical

CVE-2021-44790

Vector:

```text
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

Score:

```
9.8 Critical
```

---

### Finding B — Medium Range

CVE-2021-43798 (Grafana Path Traversal)

Vector:

```text
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N
```

Score:

```
7.5 High
```

---

# Component Comparison

| Metric | CVE-2021-44790 | CVE-2021-43798 |
|---|---|---|
| Attack Vector | Network | Network |
| Attack Complexity | Low | Low |
| Privileges Required | None | None |
| User Interaction | None | None |
| Scope | Unchanged | Unchanged |
| Confidentiality | High | High |
| Integrity | High | None |
| Availability | High | None |

---

# Why the Scores Differ

The biggest difference is impact.

## CVE-2021-44790

Has:

- Confidentiality impact: High
- Integrity impact: High
- Availability impact: High

This means successful exploitation can:

- Read sensitive information
- Modify system data
- Disrupt services

Result:

```
9.8 Critical
```

---

## CVE-2021-43798

Has:

- Confidentiality impact: High
- Integrity impact: None
- Availability impact: None

This means the attacker can read files but cannot directly modify data or disrupt availability.

Result:

```
7.5 High
```

---

# Components With the Biggest Impact

The largest score changes usually come from:

1. **Impact Metrics**
   - Confidentiality
   - Integrity
   - Availability

2. **Attack Vector**
   - Network attacks score higher than Local or Physical attacks

3. **Privileges Required**
   - No privileges required increases severity

4. **Scope**
   - Changed scope increases severity because the impact crosses security boundaries

---

# Final Summary

| Exercise | Result |
|---|---|
| Exercise 1 | CVE-2021-44790 analyzed; changing AV:N to AV:L reduces score from 9.8 to 8.4 |
| Exercise 2 | Constructed vector: `CVSS:3.1/AV:A/AC:H/PR:L/UI:N/S:U/C:H/I:N/A:N` → 4.2 Medium |
| Exercise 3 | Compared critical RCE-style vulnerability against confidentiality-only path traversal |

CVSS is not just a severity label. It is a decision-making framework that explains why vulnerabilities receive their scores and helps prioritize remediation efforts.
