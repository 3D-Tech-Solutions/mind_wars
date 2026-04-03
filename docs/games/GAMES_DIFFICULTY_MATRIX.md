# Mind Wars Games: Difficulty & Progression Matrix

**Last Updated:** April 2, 2026  
**Scope:** All 15 Launch Games  
**Standard:** Unified 3-Level Progression Model

This matrix provides a single-source reference for difficulty progression across all Mind Wars games. For detailed mechanics per game, see [DIFFICULTY_PROGRESSION_SPEC.md](DIFFICULTY_PROGRESSION_SPEC.md) or individual game documentation.

---

## Quick Reference Matrix

```
GAME                    | CATEGORY   | LEVEL 1              | LEVEL 2              | LEVEL 3              | COMPLETION
------------------------+------------+----------------------+----------------------+----------------------+---------------------------
Anagram Attack          | Language   | 6 words (easy)       | 6 words (medium)     | 6 words (hard)       | After 18 words (3×6)
Code Breaker            | Logic      | 4-digit code puzzle  | —                    | —                    | Code cracked (single)
Color Rush              | Attention  | 3 sec timer          | 2 sec timer          | 1 sec timer          | Level > 3
Focus Finder            | Attention  | 3 targets, 19 dist   | 4 targets, 18 dist   | 5 targets, 17 dist   | Level > 3
Logic Grid              | Logic      | 3 pos clues          | 2 pos + neg clues    | Strategy clues       | Level > 3
Memory Match            | Memory     | 8 pairs (emoji)      | —                    | —                    | All pairs matched
Path Finder             | Spatial    | 8×8, 16 walls        | 8×8, 24 walls        | 8×8, 32 walls        | Level > 3
Pattern Memory          | Memory     | 4×4, 5 cells, 4 sec  | 4×4, 7 cells, 5 sec  | 5×5, 10 cells, 6 sec | Level > 3
Puzzle Race             | Spatial    | 3×3, 100 shuffles    | 4×4, 120 shuffles    | 4×4, 150 shuffles    | Level > 3
Rotation Master         | Spatial    | 4 rotation opts      | 4 rotation opts      | 4 rotation opts      | Level > 3
Sequence Recall         | Memory     | 4-item seq           | 5-item seq           | 6-item seq           | Level > 3
Spot the Difference     | Attention  | 5 differences        | 7 differences        | 9 differences        | Level > 3
Sudoku Duel             | Logic      | 4×4, 6 blanks        | 4×4, 6 blanks        | 4×4, 6 blanks        | Level > 3
Vocabulary Showdown     | Language   | 10 questions (adapt) | —                    | —                    | 10 questions answered
Word Builder            | Language   | 3×3 grid (timed)     | —                    | —                    | Target word count
```

---

## Progression Models

### Standard 3-Level Model (10 games)

Completion: **Level 1 → Level 2 → Level 3 → Level > 3 = Game Complete**

1. **Color Rush** — Time pressure scaling (3s → 2s → 1s)
2. **Focus Finder** — Clutter density scaling (3 targets → 4 → 5)
3. **Logic Grid** — Clue mix scaling (positive → mixed → strategic)
4. **Path Finder** — Maze complexity scaling (16 walls → 24 → 32)
5. **Pattern Memory** — Grid and cell count scaling (4×4/5 → 4×4/7 → 5×5/10)
6. **Puzzle Race** — Grid size and shuffle intensity (3×3/100 → 4×4/120 → 4×4/150)
7. **Rotation Master** — Streak-based advancement (constant mechanics, performance-driven)
8. **Sequence Recall** — Sequence length scaling (4 → 5 → 6 items)
9. **Spot the Difference** — Difference count scaling (5 → 7 → 9)
10. **Sudoku Duel** — Different puzzle sets (6 blanks across all levels)

### Round-Based Progression (1 game)

Completion: **Complete predefined number of rounds/words**

11. **Anagram Attack** — 3 rounds of 6 words each = 18 words total completion

### Single-Challenge Models (3 games)

Completion: **Specific objective completion, no levels**

12. **Code Breaker** — Crack the 4-digit code (single puzzle)
13. **Memory Match** — Match all 8 pairs (single session)
14. **Word Builder** — Reach target word count (session-based)

### Adaptive Session Model (1 game)

Completion: **Fixed question count with adaptive difficulty**

15. **Vocabulary Showdown** — Answer 10 questions with tier-based adaptive difficulty

---

## Difficulty Scaling Mechanics

### By Scaling Type

| Scaling Type | Games | Example |
|---|---|---|
| **Time Pressure** | Color Rush | 3s → 2s → 1s |
| **Quantity** | Focus Finder, Spot Difference | 3→4→5 targets; 5→7→9 diffs |
| **Grid/Space** | Path Finder, Puzzle Race, Pattern Memory | Grid density, size expansion |
| **Sequence Length** | Sequence Recall | 4→5→6 items |
| **Information Mix** | Logic Grid | Clue types and availability |
| **Streak/Performance** | Rotation Master | Constant mechanics, skill-based |
| **Adaptive Tier** | Vocabulary Showdown | Dynamic difficulty targeting 70% success |
| **Session Target** | Word Builder | Configurable word count goal |

### By Category

**Attention Games:**
- Color Rush: Time pressure
- Focus Finder: Clutter density
- Spot the Difference: Difference count

**Memory Games:**
- Memory Match: Single difficulty (constant)
- Pattern Memory: Grid expansion + cell count
- Sequence Recall: Sequence length
- Anagram Attack: Word pool difficulty

**Logic Games:**
- Code Breaker: Single challenge
- Logic Grid: Clue mix strategy
- Sudoku Duel: Puzzle set variance

**Spatial Games:**
- Path Finder: Wall density
- Puzzle Race: Grid size + shuffle intensity
- Rotation Master: Shape memorization

**Language Games:**
- Anagram Attack: Word length/complexity
- Vocabulary Showdown: Adaptive question difficulty
- Word Builder: Time and tile complexity

---

## Completion Thresholds

### Level-Based Completion (10 games)
```
_level = 1 (initial)
if (puzzle_solved) _level++
if (_level > 3) completeGame()
```

### Word-Count Completion (1 game)
```
solved_words = 0
if (anagram_solved) solved_words++
if (solved_words >= 18) completeGame()
```

### Pair-Matching Completion (1 game)
```
matched_pairs = 0
if (pair_found) matched_pairs++
if (matched_pairs == 8) completeGame()
```

### Target-Word Completion (1 game)
```
found_words = []
if (word_valid) found_words.add(word)
if (found_words.length >= target) completeGame()
```

### Session-Complete (1 game)
```
answers = []
if (question_answered) answers.add(answer)
if (answers.length >= 10) completeGame()
```

### Single-Puzzle Completion (1 game)
```
if (code_correct) completeGame()
```

---

## Key Implementation Standards

All games must follow these rules:

### 1. Level Tracking
- Initialize `_level = 1` in `initState()`
- Increment `_level++` only on puzzle/round completion
- Check `if (_level > 3) completeGame()` before advancing
- Display current level in UI

### 2. Difficulty Consistency
- Level 2 must be demonstrably harder than Level 1
- Level 3 must be demonstrably harder than Level 2
- Difficulty should scale smoothly, not abruptly

### 3. Scoring
- Award points per action (find, match, solve, etc.)
- Apply level-based multipliers if desired
- Never allow negative scores
- Show point increments immediately

### 4. Messaging
- Display "Level X" in header card
- Show progression message on level advance
- Announce game completion
- Provide clear feedback on correctness

### 5. State Management
- Reset `_level` on game restart
- Preserve score across levels
- Clear level-specific state when advancing
- Validate solvability before advancing

---

## Game Documentation Structure

Each individual game has:

1. **Quick Reference** — Category, players, mechanic, skills
2. **Current Implementation** — Widget state, behavior snapshot
3. **Difficulty Structure** — Level-by-level breakdown
4. **Winning & Scoring** — Rules, formulas, progression
5. **Link to Matrix** — This document for standard reference

See [DIFFICULTY_PROGRESSION_SPEC.md](DIFFICULTY_PROGRESSION_SPEC.md) for full per-game details.

---

## Testing All Games

Use this checklist for each game:

### Level Progression
- [ ] Game initializes at Level 1
- [ ] Completing puzzle advances to Level 2
- [ ] Completing puzzle advances to Level 3
- [ ] Completing puzzle when at Level 3 triggers game completion

### Difficulty Scaling
- [ ] Level 1 is noticeably easier than Level 2
- [ ] Level 2 is noticeably easier than Level 3
- [ ] Difficulty mechanism is clearly visible (time, count, grid, etc.)

### Scoring & UI
- [ ] Score increments on correct action
- [ ] Current level displays correctly
- [ ] Progression message appears on level advance
- [ ] Completion message appears when `completeGame()` triggers

### Edge Cases
- [ ] Game can be restarted and plays from Level 1 again
- [ ] No crashes on level advance
- [ ] Timer/counter mechanics work correctly at each level

---

## Future Extensibility

To extend progression beyond 3 levels:

1. Change completion condition to `if (_level > N)` where N > 3
2. Add scaling logic for each new level
3. Update documentation with new thresholds
4. Test difficulty curve smoothness

To add difficulty selectors:

1. Add game-start difficulty choice UI
2. Modify `_generatePuzzle()` to use selected difficulty
3. Adjust level thresholds per difficulty (Easy: 2 levels, Normal: 3, Hard: 4)

---

**Document Version:** 1.0  
**Last Implementation Update:** April 2, 2026  
**Next Review:** Upon next game balance or feature update
