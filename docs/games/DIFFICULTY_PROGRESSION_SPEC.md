# Mind Wars Game Difficulty Progression Specification

**Last Updated:** April 2, 2026  
**Status:** Current Implementation Standard (All 15 games)

This document defines the standard 3-level difficulty progression for all Mind Wars games. All games now follow a consistent structure: **Level 1 (Easy) → Level 2 (Medium) → Level 3 (Hard) → Game Complete**

---

## Summary Table

| Game | Category | Level 1 | Level 2 | Level 3 | Completion |
|------|----------|---------|---------|---------|------------|
| **Anagram Attack** | Language | 6 words | 6 words | 6 words | After 3 rounds |
| **Code Breaker** | Logic | Single puzzle | — | — | When code cracked |
| **Color Rush** | Attention | 3 sec timer | 2 sec timer | 1 sec timer | Level > 3 |
| **Focus Finder** | Attention | 3 targets, 19 distractors | 4 targets, 18 distractors | 5 targets, 17 distractors | Level > 3 |
| **Logic Grid** | Logic | 3 positive clues | 2 positive + negatives | Strategic negatives | Level > 3 |
| **Memory Match** | Memory | Single session | — | — | All pairs matched |
| **Path Finder** | Spatial | 8×8 maze, 16 walls | 8×8 maze, 24 walls | 8×8 maze, 32 walls | Level > 3 |
| **Pattern Memory** | Memory | 4×4 grid, 5 cells | 4×4 grid, 7 cells | 5×5 grid, 10 cells | Level > 3 |
| **Puzzle Race** | Spatial | 3×3 grid, 100 shuffles | 4×4 grid, 120 shuffles | 4×4 grid, 150 shuffles | Level > 3 |
| **Rotation Master** | Spatial | 4 rotation options | 4 rotation options | 4 rotation options | Level > 3 |
| **Sequence Recall** | Memory | 4-item sequence | 5-item sequence | 6-item sequence | Level > 3 |
| **Spot Difference** | Attention | 5 differences | 7 differences | 9 differences | Level > 3 |
| **Sudoku Duel** | Logic | 4×4 grid, 6 blanks | 4×4 grid, 6 blanks | 4×4 grid, 6 blanks | Level > 3 |
| **Vocabulary Showdown** | Language | 10 questions | (adaptive) | (adaptive) | Session complete |
| **Word Builder** | Language | Timed challenge | — | — | Target words found |

---

## 1. Anagram Attack (Language / Memory)

**Mechanic:** Solve anagrams from a word pool  
**Category:** Language  
**Core Loop:** Unscramble → Submit → Next word → Level progression  

### Level Progression

| Level | Words Presented | Difficulty | Scoring |
|-------|-----------------|-----------|---------|
| 1 | 6 anagrams | Easy 6-letter words | +15 per word |
| 2 | 6 anagrams | Medium 7-8 letter words | +15 per word |
| 3 | 6 anagrams | Hard 8-10 letter words | +15 per word |

**Completion:** After solving 18 total words (6 per level)  
**Implementation Note:** Tracks solved word count; increments level every 6 words  

---

## 2. Code Breaker (Logic)

**Mechanic:** Deduce a 4-digit numeric code using clue feedback  
**Category:** Logic  
**Core Loop:** Guess → Receive feedback (correct position, wrong position) → Guess again → Code cracked  

### Difficulty Model

| Aspect | Implementation |
|--------|-----------------|
| Code Length | 4 digits |
| Digit Range | 1-6 (6 possible values) |
| Puzzle Type | Single-instance challenge |
| Completion | When correct code is entered |
| Scoring | +50 on successful crack |

**Completion:** Game ends when 4-digit code is correctly identified  
**Implementation Note:** No level progression; single challenge completion model  

---

## 3. Color Rush (Attention / Speed)

**Mechanic:** Match target color in a 4×4 grid under time pressure  
**Category:** Attention  
**Core Loop:** View target color → Search grid → Tap match → Timer resets for next round  

### Level Progression

| Level | Time Budget | Grid Size | Targets | Difficulty |
|-------|------------|----------|---------|-----------|
| 1 | 3 seconds | 16 items (4×4) | 2 identical colors | Generous time |
| 2 | 2 seconds | 16 items (4×4) | 2 identical colors | Moderate pressure |
| 3 | 1 second | 16 items (4×4) | 2 identical colors | High pressure |

**Scoring:** 5 + (combo × 2) per correct match  
**Completion:** When level > 3  
**Implementation Note:** Time pressure scales inversely; grid composition stays consistent  

---

## 4. Focus Finder (Attention)

**Mechanic:** Locate target items in a cluttered field  
**Category:** Attention  
**Core Loop:** View targets → Scan scene → Tap target → Found indicator → Continue until all found  

### Level Progression

| Level | Targets | Distractors | Total Items | Difficulty |
|-------|---------|------------|-------------|-----------|
| 1 | 3 | 19 | 22 | Low clutter |
| 2 | 4 | 18 | 22 | Moderate clutter |
| 3 | 5 | 17 | 22 | High clutter |

**Scoring:** +15 per target found  
**Completion:** When level > 3  
**Implementation Note:** Target count increases; distractor count decreases; total stays constant for balanced scaling  

---

## 5. Logic Grid (Logic)

**Mechanic:** Deduce relationships between attributes using logical clues  
**Category:** Logic  
**Core Loop:** Read clues → Deduce solution → Submit answers → Check correctness → Next puzzle  

### Level Progression

| Level | Grid | Clues | Difficulty | Algorithm |
|-------|------|-------|-----------|-----------|
| 1 | 3×3 (9 cells) | 3 positive | Easy deduction | All clues directly provide answers |
| 2 | 3×3 (9 cells) | 2 positive + negatives | Medium deduction | Mix of direct and elimination clues |
| 3 | 3×3 (9 cells) | Strategic negatives + 1 positive | Hard deduction | Requires logical chaining |

**Scoring:** +40 per puzzle solved  
**Completion:** When level > 3  
**Implementation Note:** Puzzle has guarantees unique solvability at each level; clue mix changes rather than grid size  

---

## 6. Memory Match (Memory)

**Mechanic:** Match pairs of cards by remembering positions  
**Category:** Memory  
**Core Loop:** Flip card → Flip second card → Check for match → Mark matched pairs → Continue until all matched  

### Difficulty Model

| Aspect | Implementation |
|--------|-----------------|
| Card Count | 16 cards (8 pairs) |
| Symbols | Emoji variety (constant) |
| Difficulty Scaling | Single flat difficulty |
| Completion | When all 8 pairs matched |
| Scoring | +10 per pair matched |

**Completion:** Game ends when all 8 pairs are successfully matched  
**Implementation Note:** No level progression; single difficulty, focuses on execution speed and memory accuracy  

---

## 7. Path Finder (Spatial)

**Mechanic:** Navigate through mazes by finding clear paths  
**Category:** Spatial  
**Core Loop:** Move player → Avoid walls → Reach exit → Next maze → Faster navigation = higher score  

### Level Progression

| Level | Grid Size | Wall Count | Maze Density | Difficulty |
|-------|-----------|-----------|-------------|-----------|
| 1 | 8×8 (64 cells) | 16 walls | ~25% blocked | Light maze |
| 2 | 8×8 (64 cells) | 24 walls | ~37% blocked | Moderate maze |
| 3 | 8×8 (64 cells) | 32 walls | ~50% blocked | Dense maze |

**Scoring:** 30 - (moves × 1), min 10 per maze  
**Completion:** When level > 3  
**Implementation Note:** Wall count scales; all mazes are guaranteed solvable via BFS validation  

---

## 8. Pattern Memory (Memory)

**Mechanic:** Memorize a pattern grid and recreate it  
**Category:** Memory  
**Core Loop:** View pattern → Timer counts down → Cells disappear → Tap cells to recreate → Submit → Evaluate  

### Level Progression

| Level | Grid Size | Filled Cells | View Time | Difficulty |
|-------|-----------|------------|----------|-----------|
| 1 | 4×4 (16 cells) | 5 filled | 4 sec | Simple pattern |
| 2 | 4×4 (16 cells) | 7 filled | 5 sec | Moderate pattern |
| 3 | 5×5 (25 cells) | 10 filled | 6 sec | Complex pattern |

**Scoring:** 20 + (level × 5) for perfect accuracy  
**Accuracy Requirement:** 100% for advancement; ≥75% for bonus points  
**Completion:** When level > 3  
**Implementation Note:** Grid expansion at level 3; view time increases slightly; cell count scales with grid  

---

## 9. Puzzle Race (Spatial)

**Mechanic:** Solve sliding puzzles against the clock  
**Category:** Spatial  
**Core Loop:** Scrambled grid → Slide tiles → Solve puzzle → Next puzzle → Fewer moves = higher score  

### Level Progression

| Level | Grid | Shuffle Passes | Difficulty | Scaling |
|-------|------|---------------|-----------|---------|
| 1 | 3×3 (9 tiles) | 100 random moves | Easy puzzle | Smaller grid |
| 2 | 4×4 (16 tiles) | 120 random moves | Moderate puzzle | Larger grid |
| 3 | 4×4 (16 tiles) | 150 random moves | Hard puzzle | More shuffling |

**Scoring:** 40 - (moves × 1), min 10 per puzzle  
**Completion:** When level > 3  
**Implementation Note:** Grid size increases at level 2; shuffle intensity increases at level 3  

---

## 10. Rotation Master (Spatial)

**Mechanic:** Identify rotated versions of a target shape  
**Category:** Spatial  
**Core Loop:** See target shape → View 4 rotated options → Select matching rotation → Next shape → Streak tracking  

### Level Progression

| Level | Shape Pool | Rotations | Difficulty | Streak Bonus |
|-------|-----------|-----------|-----------|-------------|
| 1 | 8 shapes (letters) | 4 (0°, 90°, 180°, 270°) | Shape memorization | +2 per combo |
| 2 | 8 shapes (letters) | 4 (0°, 90°, 180°, 270°) | Shape memorization | +2 per combo |
| 3 | 8 shapes (letters) | 4 (0°, 90°, 180°, 270°) | Shape memorization | +2 per combo |

**Scoring:** 10 + (streak × 2) per correct match  
**Completion:** When level > 3  
**Implementation Note:** Shape pool constant; difficulty via visual similarity learning over repeated attempts  

---

## 11. Sequence Recall (Memory)

**Mechanic:** Remember and reproduce increasingly long sequences  
**Category:** Memory  
**Core Loop:** Watch sequence flash → Sequence hides → Tap sequence in order → Verify → Next sequence  

### Level Progression

| Level | Sequence Length | Button Count | Flash Speed | Difficulty |
|-------|-----------------|------------|-----------|-----------|
| 1 | 4 items | 4 buttons | 600ms flash, 300ms pause | Moderate pace |
| 2 | 5 items | 4 buttons | 600ms flash, 300ms pause | Memory extension |
| 3 | 6 items | 4 buttons | 600ms flash, 300ms pause | High memory demand |

**Scoring:** 10 × level per sequence completed  
**Completion:** When level > 3  
**Implementation Note:** Sequence length = 3 + level; flash timing constant; pure memorization challenge  

---

## 12. Spot the Difference (Attention)

**Mechanic:** Find differences between two similar patterns  
**Category:** Attention  
**Core Loop:** View two patterns side-by-side → Tap differences → Mark found → Complete when all found  

### Level Progression

| Level | Grid Size | Differences | Difficulty | Clutter |
|-------|-----------|------------|-----------|---------|
| 1 | 6×6 | 5 differences | Clear patterns | Low |
| 2 | 6×6 | 7 differences | Mixed patterns | Moderate |
| 3 | 6×6 | 9 differences | Complex patterns | High |

**Scoring:** +10 per difference found  
**Completion:** When level > 3  
**Implementation Note:** Grid constant; difference count increases; requires more careful attention  

---

## 13. Sudoku Duel (Logic)

**Mechanic:** Solve small Sudoku puzzles  
**Category:** Logic  
**Core Loop:** Select blank cell → Enter number → Validate → Continue until solved → Score for speed  

### Level Progression

| Level | Grid | Blanks | Solutions | Difficulty |
|-------|------|--------|-----------|-----------|
| 1 | 4×4 | 6 blanks | 5 pre-shuffled | Easy solving |
| 2 | 4×4 | 6 blanks | 5 pre-shuffled | Medium solving |
| 3 | 4×4 | 6 blanks | 5 pre-shuffled | Hard solving |

**Scoring:** +50 per puzzle solved  
**Completion:** When level > 3  
**Implementation Note:** Grid size and blank count constant; different solution sets provide variance  

---

## 14. Vocabulary Showdown (Language)

**Mechanic:** Answer vocabulary questions (MCQ, fill-in-blank, synonym) under time pressure  
**Category:** Language  
**Core Loop:** Read question → Answer → Receive feedback + score → Next question → Session complete  

### Difficulty Model

| Aspect | Implementation |
|--------|-----------------|
| Question Count | 10 per session |
| Question Types | MCQ (4 options), fill-in-blank, synonym/antonym |
| Difficulty Adaptation | Tier-based adaptive difficulty targeting ~70% success |
| Time Budget | Per-question timer with difficulty multiplier |
| Scoring Model | Hybrid: 70% accuracy + 30% speed |

**Completion:** After 10 questions answered  
**Implementation Note:** Adaptive difficulty tier system; session completes on question count, not levels  

---

## 15. Word Builder (Language)

**Mechanic:** Build words from a Boggle-style cascading grid  
**Category:** Language  
**Core Loop:** Select adjacent letters → Form words → Submit → Score based on word length & rarity → Continue timed challenge  

### Difficulty Model

| Aspect | Implementation |
|--------|-----------------|
| Grid | 3×3 cascade-chain grid |
| Special Tiles | Anchor, golden, locked tiles scale with difficulty |
| Target | Find target word count per session |
| Completion | When target word count reached |
| Scoring | Length² × rarity multiplier + pattern bonuses |

**Difficulty Scaling:** Via special tile frequency and word difficulty distribution  
**Completion:** When configured word count target is reached  
**Implementation Note:** Session-based challenge; word-builder specific difficulty system  

---

## Implementation Standards

### All Games Must Have

1. **Clear Level Cap** — All games end after reaching level > 3 (except single-challenge games)
2. **Difficulty Scaling** — Each level meaningfully increases one or more mechanics
3. **Consistent Scoring** — Points awarded per-action; bonus for completion
4. **Completion Logic** — Explicit condition that triggers `completeGame()`
5. **State Management** — Level tracked as `_level` variable; reset on game init

### Difficulty Scaling Patterns

Games use one or more of these patterns:

- **Quantity Scaling:** More objects, items, or targets (Focus Finder, Spot Difference)
- **Constraint Scaling:** Time limits, grid density, or puzzle complexity (Color Rush, Path Finder)
- **Grid Expansion:** Larger playing area (Pattern Memory, Puzzle Race)
- **Sequence Length:** Longer patterns to remember (Sequence Recall)
- **Clue Mix:** Different clue types and amounts (Logic Grid)

### Games Without Level Progression

Three games use alternative completion models:

- **Code Breaker** — Single puzzle challenge; complete when code cracked
- **Memory Match** — Single difficulty; complete when all pairs matched
- **Word Builder / Vocabulary Showdown** — Session-based; complete on specific target achievement

---

## Testing Checklist

For each game, verify:

- [ ] Level 1 loads and progresses correctly
- [ ] Level 2 is demonstrably harder than Level 1
- [ ] Level 3 is demonstrably harder than Level 2
- [ ] Game completes when level > 3
- [ ] Score increments appropriately per action
- [ ] Bonus/penalty logic applies correctly
- [ ] UI displays current level
- [ ] Progression message appears on level advancement

---

## Future Enhancement: Beyond 3 Levels

If extended difficulty progression is needed:

1. **Extended Levels (4-5):** Add two more difficulty tiers; adjust game completion to level > 5
2. **Adaptive Difficulty:** Track player performance; dynamically adjust scaling
3. **Difficulty Modes:** Offer Easy/Normal/Hard selectable at game start (instead of auto-progression)
4. **Seasonal Difficulty:** Rotate hard variants through seasonal challenges

---

**Document Status:** Approved and implemented (April 2, 2026)  
**Next Review:** Upon next game balance update
