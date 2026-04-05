# Mind Wars Game Index

This section contains one design and gameplay reference document per Mind Wars game.

## Shared Systems

- [Async Game Contract](ASYNC_GAME_CONTRACT.md): Platform-wide definition for how every Mind Wars game must behave as an async, offline-first, resumable, server-verifiable round task.
- [Mind Wars Ranking Specification](MIND_WARS_RANKING_SPEC.md): Shared definition for local Mind War placement, ranked-run eligibility, and Global / Regional / National leaderboard routing.
- [Mind War Battle Payload Specification](MIND_WAR_BATTLE_PAYLOAD_SPEC.md): Shared definition for how every player in the same Mind War receives the exact same deterministic content package and ruleset.
- [Sealed Payload Implementation Guide](SEALED_PAYLOAD_IMPLEMENTATION_GUIDE.md): Practical implementation contract for teams building server-verifiable deterministic game payloads like Rotation Master and Path Finder.
- Every canonical game doc should align with the async contract and include an `Exact Same Game Delivery Method` subsection describing how the platform should distribute one identical battle payload to all players in the same Mind War.

## Ranked Rollout Snapshot

| Game | Category | Ranking Methodology | Ranked Readiness | Primary Blocker |
| --- | --- | --- | --- | --- |
| [Memory Match](memory/memory-match.md) | Memory | Explicit local and public sections | Partial | Lock exact board payload and finalize server scoring |
| [Sequence Recall](memory/sequence-recall.md) | Memory | Explicit local and public sections | Partial | Reconcile widget and generator around one ranked sequence model |
| [Pattern Memory](memory/pattern-memory.md) | Memory | Explicit local and public sections | Partial | Choose one canonical ranked format and reveal payload model |
| [Sudoku Duel](logic/sudoku-duel.md) | Logic | Explicit local and public sections | Partial | Implement real ranked puzzle packages and validation |
| [Logic Grid](logic/logic-grid.md) | Logic | Explicit local and public sections | Partial | Build deterministic clue packages and solver-backed validation |
| [Code Breaker](logic/code-breaker.md) | Logic | Explicit local and public sections | Partial | Lock ranked rule package and enforce it server-side |
| [Spot the Difference](attention/spot-the-difference.md) | Attention | Explicit local and public sections | Partial | Deliver deterministic scene pairs and difference-map validation |
| [Color Rush](attention/color-rush.md) | Attention | Explicit local and public sections | Partial | Choose the final ranked design and timed payload model |
| [Focus Finder](attention/focus-finder.md) | Attention | Explicit local and public sections | Partial | Ship deterministic search-scene payloads and hit validation |
| [Puzzle Race](spatial/puzzle-race.md) | Spatial | Explicit local and public sections | Partial | Choose sliding versus jigsaw production model |
| [Rotation Master](spatial/rotation-master.md) | Spatial | Explicit local and public sections | Partial | Build deterministic ranked prompt packs with validated answers |
| [Path Finder](spatial/path-finder.md) | Spatial | Explicit local and public sections | Partial | Replace local maze behavior with authoritative ranked maze payloads |
| [Word Builder](language/word-builder.md) | Language | Explicit local and public sections | Strong foundation | Align the enhanced deterministic model with ranked routing |
| [Anagram Attack](language/anagram-attack.md) | Language | Explicit local and public sections | Partial | Choose between single-answer mode and `Anagram Sprint` |
| [Vocabulary Showdown](language/vocabulary-showdown.md) | Language | Explicit local and public sections | Strong foundation | Complete ranked routing and backend validation integration |

## Memory Games

- [Memory Match](memory/memory-match.md): Match pairs of cards by remembering their positions.
- [Sequence Recall](memory/sequence-recall.md): Remember and reproduce increasingly long sequences.
- [Pattern Memory](memory/pattern-memory.md): Study and recreate visual patterns.

## Logic Games

- [Sudoku Duel](logic/sudoku-duel.md): Solve Sudoku puzzles competitively under time pressure.
- [Logic Grid](logic/logic-grid.md): Use deduction and clue elimination to solve structured puzzles.
- [Code Breaker](logic/code-breaker.md): Infer hidden codes through feedback-driven logic.

## Attention Games

- [Spot the Difference](attention/spot-the-difference.md): Find visual differences as quickly as possible.
- [Color Rush](attention/color-rush.md): Match colors accurately under speed pressure.
- [Focus Finder](attention/focus-finder.md): Locate target items inside cluttered scenes.

## Spatial Games

- [Puzzle Race](spatial/puzzle-race.md): Complete jigsaw-style puzzles against the clock.
- [Rotation Master](spatial/rotation-master.md): Identify rotated or mirrored shapes.
- [Path Finder](spatial/path-finder.md): Navigate mazes efficiently and minimize wasted moves.

## Language Games

- [Word Builder](language/word-builder.md): Build words from letter tiles using high-value combinations.
- [Anagram Attack](language/anagram-attack.md): Unscramble words quickly and consistently.
- [Vocabulary Showdown](language/vocabulary-showdown.md): Answer vocabulary questions with speed and accuracy.

## Notes

- These documents are intended to be practical references for design, implementation, QA, and content planning.
- Category-scoped files under `memory/`, `logic/`, `attention/`, `spatial/`, and `language/` are the canonical game docs when a category version exists.
- Each game file separates current documented behavior from planned or target difficulty structure where the implementation is still evolving.
- Ranked-readiness status is intentionally conservative and reflects implementation needs, not just documentation completeness.
- Source references are drawn primarily from [lib/games/game_catalog.dart](../../lib/games/game_catalog.dart), [docs/branding.md](../branding.md), and any game-specific documents already present in the repo.
