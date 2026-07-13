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

## Calculated Result

```text
CVSS v3.1 Base Score: 9.8
CVSS v3.1 Severity Rating: Critical
```

---

# Vector Component Breakdown

| Component | Meaning | Selected Value | Explanation |
|---|---|---|---|
| AV | Attack Vector | N — Network | Exploitation is possible remotely through a network connection |
| AC | Attack Complexity | L — Low | No special conditions are required |
| PR | Privileges Required | N — None | No authentication is needed |
| UI | User Interaction | N — None | No victim action is required |
| S | Scope | U — Unchanged | Impact remains within the vulnerable component |
| C | Confidentiality | H — High | Sensitive information can be exposed |
| I | Integrity | H — High | Data or systems can be modified |
| A | Availability | H — High | Service availability can be affected |

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

| Value | Meaning |
|---|---|
| N | Network |
| A | Adjacent Network |
| L | Local |
| P | Physical |

Why selected:

Apache HTTP Server accepts HTTP requests remotely, allowing an attacker to send a crafted request.

---

## Attack Complexity (AC)

Selected:

```text
AC:L
```

Meaning:

The attack does not require unusual conditions.

Possible values:

| Value | Meaning |
|---|---|
| L | Low |
| H | High |

Why selected:

The attacker only needs to send a malicious request.

---

## Privileges Required (PR)

Selected:

```text
PR:N
```

Meaning:

No account or authentication is required.

Possible values:

| Value | Meaning |
|---|---|
| N | None |
| L | Low |
| H | High |

Why selected:

The vulnerability can be exploited without logging into Apache.

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

---

## Scope (S)

Selected:

```text
S:U
```

Meaning:

The vulnerable component and impact remain within the same security authority.

Possible values:

| Value | Meaning |
|---|---|
| U | Unchanged |
| C | Changed |

---

## Confidentiality (C)

Selected:

```text
C:H
```

Meaning:

Complete confidentiality impact.

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

Complete integrity impact.

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

Complete availability impact.

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

Original Result:

```text
CVSS v3.1 Base Score: 9.8
CVSS v3.1 Severity Rating: Critical
```

Changed Metric:

```text
AV:N → AV:L
```

New Vector:

```text
CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H
```

New Result:

```text
CVSS v3.1 Base Score: 8.4
CVSS v3.1 Severity Rating: High
```

Explanation:

The score decreases because the attacker must already have local access to the target system.

---

# Exercise 2 — CVSS Vector Construction

## Vulnerability Characteristics

The vulnerability has the following characteristics:

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

| Metric | Selected Value | Explanation |
|---|---|---|
| Attack Vector | A — Adjacent Network | Requires access to the local network |
| Attack Complexity | H — High | Requires specific conditions |
| Privileges Required | L — Low | Requires limited privileges |
| User Interaction | N — None | No user interaction required |
| Scope | U — Unchanged | Same security authority |
| Confidentiality | H — High | Complete disclosure possible |
| Integrity | N — None | No modification possible |
| Availability | N — None | No availability impact |

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
CVSS v3.1 Base Score: 5.1
CVSS v3.1 Severity Rating: Medium
```

---

# Score Explanation

The vulnerability receives a Medium severity rating because:

- The attacker requires adjacent network access.
- Exploitation requires high complexity.
- Low-level privileges are required.
- No user interaction is needed.
- Only confidentiality is affected.
- Integrity and availability are not affected.

Final Result:

```text
CVSS v3.1: 5.1 (Medium)
```

---

# Exercise 3 — CVSS Comparison

## High Severity Comparison Finding

### CVE-2020-1938 — Apache Tomcat Ghostcat

Vector:

```text
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N
```

Score:

```text
CVSS v3.1 Base Score: 9.8
CVSS v3.1 Severity Rating: Critical
```

---

## Medium Severity Comparison Finding

### CVE-2021-43798 — Grafana Path Traversal

Vector:

```text
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:N
```

Score:

```text
CVSS v3.1 Base Score: 7.5
CVSS v3.1 Severity Rating: High
```

---

# Component Comparison

| Metric | CVE-2020-1938 | CVE-2021-43798 |
|---|---|---|
| Attack Vector | Network | Network |
| Attack Complexity | Low | Low |
| Privileges Required | None | None |
| User Interaction | None | None |
| Scope | Unchanged | Unchanged |
| Confidentiality | High | High |
| Integrity | High | None |
| Availability | None | None |

---

# Score Difference Explanation

CVE-2020-1938 scores higher because:

- It impacts confidentiality and integrity.
- Attackers may access sensitive files and modify affected systems.

CVE-2021-43798 scores lower because:

- It primarily impacts confidentiality.
- It does not directly affect integrity or availability.

---

# Components With the Biggest Impact

The CVSS components with the greatest impact are:

1. Confidentiality Impact
2. Integrity Impact
3. Availability Impact
4. Attack Vector
5. Privileges Required

Impact metrics usually create the largest changes in the final CVSS score.

---

# Final Summary

| Exercise | Result |
|---|---|
| Exercise 1 | CVE-2021-44790 vector analyzed and Attack Vector modification calculated |
| Exercise 2 | Constructed vector verified as CVSS v3.1 5.1 Medium |
| Exercise 3 | Compared higher severity and lower severity vulnerabilities |

CVSS v3.1 provides a standardized method for measuring vulnerability severity and prioritizing remediation.
