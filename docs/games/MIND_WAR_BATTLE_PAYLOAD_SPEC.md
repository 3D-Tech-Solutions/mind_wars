# Mind War Battle Payload Specification

**Version:** v1.0 (Draft)  
**Last Updated:** 2026-03-15  
**Applies To:** All Mind Wars games that require identical deterministic content for every player  
**Scope:** Battle payload creation, client delivery, offline caching, and server validation

---

## 1. Purpose

This document defines how Mind Wars must deliver the exact same game to every player inside a sealed Mind War.

This answers:

> What must be locked, distributed, cached, replayed, and validated so every player is solving the same game under the same rules?

This specification complements:

- [MIND_WARS_RANKING_SPEC.md](MIND_WARS_RANKING_SPEC.md)
- each game's `Exact Same Game Delivery Method` subsection

---

## 2. Core Requirement

Every Mind War must distribute one immutable battle payload for that war.

That payload is the source of truth for:

- the deterministic content package
- the scoring ruleset version
- the hint and assistance policy
- the timing model
- the ranked eligibility metadata

Clients may cache this payload and render it locally, but they must not mutate the competitive rules or content package.

---

## 3. Delivery Principles

### 3.1 Immutable Per Battle

Once a Mind War is created, its payload must not change for some players and not others.

Allowed behavior:

- retrying payload download
- local caching for offline continuation
- server re-delivery of the same payload

Disallowed behavior:

- client-side reshuffling
- per-device prompt reordering
- local difficulty drift inside the sealed battle
- different hint rules for different players in the same war

### 3.2 Deterministic Or Explicit

The payload may define identical content in one of two ways:

1. **Explicit payload**: full content is shipped directly, such as a clue board, scene layout, or question set.
2. **Deterministic seed plus rules**: content is generated from a locked seed and a locked generation algorithm version.

If deterministic generation is used, the server must still be able to replay the exact content package during validation.

### 3.3 Server Authority

The server remains authoritative for:

- battle creation
- payload identity
- rule version
- validation replay
- final ranked eligibility

Clients are rendering and input-capture systems, not the authority for ranked outcomes.

---

## 4. Required Payload Fields

Every Mind War battle payload should include these top-level fields.

| Field | Purpose |
| --- | --- |
| `mindWarId` | Unique identifier for the sealed battle |
| `gameId` | Game identifier such as `vocabulary_showdown` or `path_finder` |
| `payloadVersion` | Version of the battle payload contract |
| `contentVersion` | Version of the content-generation rules or content pack |
| `ranked` | Whether the war is eligible for persistent leaderboard routing |
| `difficulty` | Difficulty tier or equivalent locked difficulty package |
| `hintPolicy` | Disabled, Enabled, or game-specific assistance mode |
| `scoringModelVersion` | Exact scoring formula version |
| `timeModel` | Time handling rules, budgets, and timer behavior |
| `attemptPolicy` | Guess caps, retry rules, submission caps, or other relevant limits |
| `contentPayload` | Explicit content package or deterministic seed and generation metadata |
| `validationRequirements` | The required event or state log that the client must submit |

---

## 5. Content Payload Rules

### 5.1 Explicit Content Payload

Use explicit payloads when the content is heavy, visual, or hard to reproduce safely on-device.

Examples:

- Sudoku clue board plus canonical solution
- Spot the Difference scene pair plus difference map
- Focus Finder scene layout plus target positions
- Puzzle Race board layout plus piece arrangement

### 5.2 Deterministic Seed Payload

Use deterministic seeds only when generation can be replayed safely and identically across platforms.

Seed-based payloads must also lock:

- generator version
- content pack version
- content ordering rules
- answer ordering rules when relevant

Examples:

- Vocabulary Showdown seeded question session
- Word Builder seeded board and refill stream
- Sequence Recall seeded prompt sequence

### 5.3 No Client Drift

If any generated result can differ by device, locale, library version, or floating-point behavior, then the content must be shipped explicitly instead of relying only on a seed.

---

## 6. Client Responsibilities

Each client must:

- download the battle payload for the Mind War
- cache it locally for offline-first continuity
- render gameplay only from that payload
- log the player interaction history needed for validation
- submit the interaction log and outcome summary to the server

Clients must not:

- substitute local content
- reorder prompts or answers
- silently widen hitboxes or input rules for one player only
- alter timers or scoring behavior based on device state

---

## 7. Validation Replay

The server should be able to reconstruct the run from:

1. The immutable battle payload.
2. The submitted player event log or final state.
3. The scoring model version.

Validation should confirm:

- the player solved the same content package distributed to everyone else
- the submitted interactions were legal under the battle rules
- the score was computed from the locked scoring model
- the hint and assistance class was recorded correctly

---

## 8. Offline-First Requirements

Offline-first support is valid only if the client keeps using the same immutable payload that was assigned to the battle.

That means:

- players may continue a cached battle offline
- the client may queue event logs locally
- the server must validate the queued run against the original battle payload after sync

Offline mode must not regenerate battle content independently once a ranked or shared Mind War payload has already been assigned.

---

## 9. Per-Game Delivery Mapping

Every canonical game doc must define its exact-same-game delivery method using this spec.

Typical payload shapes by game family:

| Game Family | Typical Payload Shape |
| --- | --- |
| Memory | board layout, pattern package, or sequence package |
| Logic | puzzle board, clue package, hidden-code package |
| Attention | prompt sequence, scene pair, search scene, target map |
| Spatial | maze layout, puzzle arrangement, rotation prompt pack |
| Language | seeded question session, scrambled letter package, deterministic board stream |

---

## 10. Minimum QA Checks

Before a game can be considered ranked-ready, QA should confirm:

1. Two players in the same Mind War receive byte-equivalent or replay-equivalent battle payloads.
2. Reopening the battle on the same device does not change the content package.
3. Offline continuation does not regenerate or mutate the battle payload.
4. Server replay of the submitted run reproduces the same score and outcome.
5. Hint usage and ranked eligibility classification are consistent between client and server.

---

## 11. Implementation Guidance

Recommended data flow:

1. Create Mind War on the server.
2. Freeze the battle payload and metadata.
3. Deliver the payload to every participant.
4. Cache the payload locally.
5. Capture deterministic interaction logs.
6. Submit logs for validation.
7. Compute local placement.
8. If ranked and valid, route the run to compatible leaderboard buckets.

This keeps local competition, offline-first behavior, and ranked fairness aligned under one delivery contract.