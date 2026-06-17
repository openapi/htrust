# htrust

**Open Source Trust for Humans**

## Vision

htrust is an open-source trust infrastructure designed to verify real-world information and transform raw data into understandable trust decisions.

The goal is not merely to answer:

> "Is this valid?"

but rather:

> "Why should I trust it?"

htrust collects evidence, evaluates claims, and produces trust assessments that can be understood by both machines and humans.

---

## Why "for Humans"?

Most validation systems stop at a boolean answer:

```json
{
  "valid": true
}
```

Humans need more than that.

They need context.

They need evidence.

They need confidence.

They need explanations.

htrust aims to provide:

```json
{
  "status": "verified",
  "confidence": 96,
  "evidence": [
    "Company found in official registry",
    "VAT number is active",
    "Domain ownership matches company data"
  ]
}
```

The objective is not only machine verification but human understanding.

This is the meaning of:

**Open Source Trust for Humans**

Trust systems designed for people, not only software.

---

## Core Concept

Every trust decision follows the same model:

```text
Claim
  ↓
Evidence
  ↓
Verification
  ↓
Trust Score
```

Example:

```text
Claim:
"The company exists"

Evidence:
- Official registry
- Tax records
- Public databases

Verification:
Cross-source consistency

Result:
Trust Score 98/100
```

---

## Scope

htrust is not limited to identity verification.

It aims to become a generic trust platform for real-world information.

### Financial

* IBAN verification
* Bank account validation
* Payment trust analysis

### Identity

* Tax code validation
* National identifier validation
* KYC workflows

### Business

* VAT verification
* Company existence
* Company status
* Beneficial ownership

### Communication

* Email verification
* PEC verification
* Phone verification
* Domain verification

### Compliance

* AML checks
* PEP checks
* Sanctions screening

### Risk

* Fraud indicators
* Reputation signals
* Cross-source consistency

---

## Human Trust Levels

### Level 1 — Syntax

Is the data structurally valid?

Examples:

* IBAN checksum
* VAT format
* Email syntax

### Level 2 — Existence

Does the entity exist?

Examples:

* Registered company
* Active domain
* Existing PEC address

### Level 3 — Trust

Can the information be trusted?

Examples:

* Cross-source validation
* Reputation analysis
* Historical consistency

### Level 4 — Compliance

Can the information be legally relied upon?

Examples:

* KYC
* KYB
* AML
* PEP
* Sanctions

---

## Architecture

```text
htrust
│
├── iban
├── vat
├── company
├── email
├── pec
├── phone
├── domain
├── kyc
├── kyb
├── aml
└── risk
```

Each module contributes evidence to a common trust model.

---

## Command Line

```bash
htrust verify iban IT60...
htrust verify vat IT12345678901
htrust verify company "Acme SRL"
htrust verify email info@example.com
```

Output:

```json
{
  "status": "verified",
  "trust_score": 94,
  "evidence": [
    ...
  ]
}
```

---

## Long-Term Goal

The long-term ambition is not to build another validator.

The ambition is to create an open trust layer for the Internet.

A shared infrastructure where claims can be verified through evidence and transformed into transparent trust decisions.

Not:

"Trust me."

But:

"Here is the evidence."
