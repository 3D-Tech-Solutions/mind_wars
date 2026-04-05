# Sealed Payload Implementation Guide

This guide is the handoff contract for any team building or upgrading a Mind Wars game for fair competitive play.

## Goal

Every player in the same Mind War must receive and play the exact same puzzle package, with server-verifiable results.

Use this model for games like Path Finder, Puzzle Race, Rotation Master, and any future deterministic competitive game.

## Required Delivery Pattern

Each competitive game must use a **sealed payload** with these properties:

1. The backend generates the canonical challenge during payload lock.
2. The payload stores explicit puzzle primitives, not just a seed.
3. The client renders from that payload without mutating puzzle content.
4. The client submits a compact result transcript plus a canonical hash.
5. The server replays or verifies the transcript against the same payload.

## What To Put In The Payload

Every game payload should include:

- `schemaVersion`
- `challengeKey`
- `canonicalChecksum`
- `difficulty`
- `hintPolicy`
- explicit puzzle content
- any scoring-critical hidden metadata the server needs for validation

### Good

- full maze grid
- start and goal positions
- cargo/object coordinates
- answer ordering
- precomputed quantized geometry
- canonical prompt checksums

### Avoid

- client-only random generation rules with no stored output
- floating-point-only transform state when integer or quantized output can be stored
- timestamps in the canonical puzzle payload
- relying on platform render differences to derive gameplay state

## Client Rules

The client must:

1. Render from the sealed payload exactly as delivered.
2. Never reshuffle answers locally.
3. Never regenerate puzzle geometry from ad hoc randomness in ranked play.
4. Record only player interaction data such as moves, selections, and timings.
5. Build a canonical submission hash from the final transcript.

## Server Rules

The server must:

1. Generate the payload at lock time.
2. Persist the full challenge in `mind_war_payloads`.
3. Verify `challengeChecksum` and `submissionHash` on submit.
4. Recompute correctness and score from the transcript.
5. Reject submissions whose transcript does not match the sealed payload.

## Path Finder Team Handoff

Tell the Path Finder team to move from **seed-only fairness** to **payload-first fairness**.

Their target payload should include:

- serialized maze grid
- start position
- goal position
- cargo positions
- wall count or topology metadata if used for scoring
- optimal path length
- optimal path checksum or canonical route metadata
- challenge checksum

Their client submission should include:

- move history or final traversed path
- collected cargo list
- total time
- hints used
- challenge checksum
- submission hash

Their server validation should:

1. Load the sealed maze payload for that round.
2. Replay the submitted movement history against the stored maze.
3. Verify wall collisions, bounds, cargo pickups, and goal completion.
4. Recompute score from validated movement data.
5. Reject mismatched hashes or impossible movement transcripts.

## Path Finder Specific Warnings

- Do not let the client generate maze walls during ranked play.
- Do not use `DateTime.now()` in deterministic puzzle construction.
- Do not allow recursive regeneration that silently changes the effective puzzle identity after payload lock.
- Do not trust client-reported solved state, path length, or score.

## Recommended Migration Order

1. Freeze a canonical Path Finder payload shape.
2. Generate and persist that payload on the backend during Mind War lock.
3. Update the client to render only from the payload.
4. Add transcript hashing and server replay validation.
5. Add deterministic tests for same payload, same checksum, same validated result.
