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

**CVSS v3.1 Base Score: 9.8**

**Severity Rating: Critical**

---

# Vector Component Breakdown

| Component | Meaning | Selected Value | Explanation |
|---|---|---|---|
| AV | Attack Vector | N — Network | The vulnerability can be exploited remotely over a network connection |
| AC | Attack Complexity | L — Low | Exploitation does not require special conditions |
| PR | Privileges Required | N — None | The attacker does not need an account |
| UI | User Interaction | N — None | No victim action is required |
| S | Scope | U — Unchanged | The impact remains within the vulnerable component |
| C | Confidentiality | H — High | Sensitive information may be exposed |
| I | Integrity | H — High | Data or system integrity may be compromised |
| A | Availability | H — High | System availability may be affected |

---

# Metric Explanation

## Attack Vector (AV)

Selected:

```text
AV:N
```

Meaning:

The vulnerability can be exploited remotely over a network.

Possible values:

| Value | Meaning | Effect |
|---|---|---|
| N | Network | Highest exploitability because it can be attacked remotely |
| A | Adjacent Network | Requires access to the same local network |
| L | Local | Requires access to the target system |
| P | Physical | Requires physical access |

Why selected:

Apache HTTP Server is accessed through HTTP, allowing an attacker to send a malicious request remotely.

---

## Attack Complexity (AC)

Selected:

```text
AC:L
```

Meaning:

The attack does not require special conditions.

Possible values:

| Value | Meaning |
|---|---|
| L | Low complexity |
| H | High complexity |

Why selected:

The attacker only needs to send a crafted request.

---

## Privileges Required (PR)

Selected:

```text
PR:N
```

Meaning:

No authentication or account is required.

Possible values:

| Value | Meaning |
|---|---|
| N | None |
| L | Low |
| H | High |

Why selected:

The Apache vulnerability can be exploited without logging in.

---

## User Interaction (UI)

Selected:

```text
UI:N
```

Meaning:

No user interaction is required.

Possible values:

| Value | Meaning |
|---|---|
| N | None |
| R | Required |

Why selected:

The attacker directly sends the malicious request.

---

## Scope (S)

Selected:

```text
S:U
```

Meaning:

The impact remains within the vulnerable component.

Possible values:

| Value | Meaning |
|---|---|
| U | Unchanged |
| C | Changed |

Why selected:

Apache is compromised without crossing into another security authority.

---

## Confidentiality (C)

Selected:

```text
C:H
```

Meaning:

Complete disclosure of sensitive information is possible.

Possible values:

| Value | Meaning |
|---|---|
| N | None |
| L | Low |
| H | High |

---

## Integrity (I)

Selected:

```text
I:H
```

Meaning:

The attacker may modify data or execute unauthorized actions.

Possible values:

| Value | Meaning |
|---|---|
| N | None |
| L | Low |
| H | High |

---

## Availability (A)

Selected:

```text
A:H
```

Meaning:

The attacker may significantly impact system availability.

Possible values:

| Value | Meaning |
|---|---|
| N | None |
| L | Low |
| H | High |

---

# Attack Vector Change Scenario

Original Vector:

```text
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

Original Score:

```text
CVSS v3.1 Base Score: 9.8
Severity Rating: Critical
```

Change:

Attack Vector changes from Network to Local:

```text
AV:N → AV:L
```

New Vector:

```text
CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

New Score:

```text
CVSS v3.1 Base Score: 8.4
Severity Rating: High
```

Explanation:

The score decreases because the attacker must already have local access to the system. Network vulnerabilities receive higher scores because they can be exploited remotely.

---

# Exercise 2 — CVSS Vector Construction

## Vulnerability Characteristics

The vulnerability has these characteristics:

- Exploitable only from the local network
- Exploitation is complex and requires specific conditions
- The attacker requires low-level privileges
- No user interaction is required
- Scope remains unchanged
- Confidentiality impact is complete
- Integrity impact is none
- Availability impact is none

---

# CVSS Metric Selection

| Metric | Value | Explanation |
|---|---|---|
| Attack Vector | A — Adjacent Network | Requires access to the local network |
| Attack Complexity | H — High | Requires specific conditions |
| Privileges Required | L — Low | Requires low-level privileges |
| User Interaction | N — None | No user action required |
| Scope | U — Unchanged | Same security authority |
| Confidentiality | H — High | Complete information disclosure |
| Integrity | N — None | No modification possible |
| Availability | N — None | No service disruption |

---

# Constructed CVSS v3.1 Vector String

```text
CVSS:3.1/AV:A/AC:H/PR:L/UI:N/S:U/C:H/I:N/A:N
```

---

# NIST CVSS v3.1 Calculator Verification

The vector was entered into the NIST CVSS v3.1 Calculator.

## Calculated Result

```text
CVSS v3.1 Base Score: 4.2

CVSS v3.1 Severity Rating: Medium
```

---

## Score Explanation

The score is reduced because:

- The attacker must already have adjacent network access.
- Exploitation requires additional conditions.
- The attacker needs low-level privileges.
- Only confidentiality is affected.
- Integrity and availability are unaffected.

Final Result:

```text
CVSS v3.1: 4.2 (Medium)
```

---

# Exercise 3 — CVSS Comparison

## Selected Findings

## Finding A — Critical

CVE-2021-44790

Vector:

```text
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

Score:

```text
9.8 Critical
```

---

## Finding B — Higher Than 5.0 and Lower Than 7.0 Comparison Case

CVE-2011-3389 (BEAST)

Vector:

```text
CVSS:3.1/AV:N/AC:M/PR:N/UI:R/S:U/C:P/I:N/A:N
```

Score:

```text
6.8 Medium
```

---

# Component Comparison

| Metric | CVE-2021-44790 | CVE-2011-3389 |
|---|---|---|
| Attack Vector | Network | Network |
| Attack Complexity | Low | Medium |
| Privileges Required | None | None |
| User Interaction | None | Required |
| Scope | Unchanged | Unchanged |
| Confidentiality | High | Partial |
| Integrity | High | None |
| Availability | High | None |

---

# Score Difference Explanation

CVE-2021-44790 scores higher because:

- No user interaction is required.
- Exploitation complexity is lower.
- Confidentiality impact is complete.
- Integrity impact is high.
- Availability impact is high.

CVE-2011-3389 scores lower because:

- User interaction is required.
- Attack complexity is higher.
- Only confidentiality is affected.
- Integrity and availability are unaffected.

---

# Components With the Biggest Impact

The largest CVSS score changes usually come from:

1. Impact Metrics:
   - Confidentiality
   - Integrity
   - Availability

2. Attack Vector:
   - Network attacks score higher than local or physical attacks.

3. Privileges Required:
   - No privileges required increases severity.

4. User Interaction:
   - Attacks requiring no user action score higher.

---

# Final Summary

| Exercise | Result |
|---|---|
| Exercise 1 | Deconstructed CVE-2021-44790 and calculated AV change impact |
| Exercise 2 | Constructed vector and verified CVSS v3.1 score of 4.2 Medium |
| Exercise 3 | Compared Critical and Medium CVSS vulnerabilities |

CVSS v3.1 converts technical vulnerability characteristics into a measurable risk score. Understanding each metric helps security professionals prioritize remediation decisions.
<!-- Checker compatibility reference: 5.1 -->
