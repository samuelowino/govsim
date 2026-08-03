# govsim

**Governance Simulator** — Turn-based executive decision game.

---

## Core Loop

1. Player receives a governance prompt (policy, crisis, budget, diplomacy)
2. Player chooses from 2-3 options
3. Effects apply to national metrics (some immediate, some delayed)
4. New prompts generate based on updated state
5. Term ends → re-election based on performance

---

## Metrics

| Category | Indicators |
|----------|------------|
| Economy | GDP, growth, debt |
| Social | Poverty, infrastructure, inequality |
| Education | Literacy, enrollment, quality |
| Health | Life expectancy, mortality, access |
| Foreign | Relations with 5 major powers, trade, aid |

---

## Decision Types

| Type | Example |
|------|---------|
| Policy | Sign education reform? |
| Budget | Increase health or defense? |
| Crisis | Flood response — evacuate or build barriers? |
| Diplomacy | Accept trade deal with conditions? |
| Personnel | Replace minister? |

---

## Game Modes

- **Campaign** — 4-year term, re-election at end
- **Crisis** — Start in emergency (pandemic, debt, conflict)
- **Sandbox** — No elections, unlimited turns

---

## Event System

- Crises triggered by low metrics
- Opportunities from high metrics or random chance
- Global events affect all players

---

## Scoring

- SDG alignment
- Economic growth
- Public approval
- International standing
- Overall development index

---

## Planned Expansions

- Historical scenarios
- Competing AI nations
- Multiplayer
- Regional alliances/blocs

---

## Code Coverage

<!-- COVERAGE_START -->
![Code Coverage](https://img.shields.io/badge/Coverage-56.00%25-red.svg)

**Overall Coverage: 56.00%**

*Last updated: Mon Aug  3 23:39:42 UTC 2026*
<!-- COVERAGE_END -->

## Code Coverage

<!-- COVERAGE_DETAIL_START -->
## Detailed Code Coverage Report

### Overall Coverage
![Coverage](https://img.shields.io/badge/Coverage-56.00%25-red.svg)

### Per-File Coverage Summary

| File | Line Coverage | Function Coverage | Branch Coverage |
|------|--------------|------------------|----------------|

### Missed Branches and Untested Code

Below are code snippets showing branches that were not fully covered by tests:

No missed branches detected! All branches are covered by tests.

---
*Coverage report generated on Mon Aug  3 23:46:18 UTC 2026*
<!-- COVERAGE_DETAIL_END -->
