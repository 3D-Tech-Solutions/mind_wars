---
name: Game Design Reference - Mind Wars 15-Game Catalog
description: Complete specifications for all 15 games including mechanics, scoring, difficulty progression, and implementation notes
type: project
---

# Games Reference: Mind Wars 15-Game Catalog

## Overview

**Sealed Payload Architecture:** All games use procedurally generated, seeded challenges. When a Mind War round starts, the backend generates identical challenge payloads for all players using the same seed. This prevents cheating and ensures fair competition.

**Scoring Philosophy:** Score = Accuracy + Speed. Both dimensions matter equally. A player can win by being more accurate (fewer mistakes) or faster, or both.

**Accessibility:** All games support 5"-12" screens with responsive UI. Touch-optimized controls. No time pressure should cause accessibility issues (e.g., color-blind players get alternative indicators in Color Rush).

---

## Memory Games (🧠)

### 1. Memory Match

**Category:** Short-term memory, visual recall

**Core Mechanic:**
- Grid of face-down cards (12, 20, or 30 depending on difficulty)
- Each card has a hidden image
- Player flips two cards; if they match, cards stay revealed and player gets a point
- If they don't match, cards flip back over and player must remember positions
- Goal: Match all pairs before time runs out

**Scoring:**
```
Score = (Pairs Matched / Total Pairs) × 1000 + Time Bonus
Time Bonus = (Remaining Seconds / Total Seconds) × 500
Penalties: -10 points per incorrect flip

Example:
- 6 pairs total, 5 matched, 45 seconds remaining out of 90
- Score = (5/6) × 1000 + (45/90) × 500 = 833 + 250 = 1083
```

**Difficulty Progression:**
| Level | Cards | Layout | Time | Difficulty |
|-------|-------|--------|------|------------|
| Easy | 12 (6 pairs) | 3×4 grid | 90 sec | Beginner |
| Medium | 20 (10 pairs) | 4×5 grid | 120 sec | Intermediate |
| Hard | 30 (15 pairs) | 5×6 grid | 150 sec | Advanced |

**Implementation Notes:**
- Cards should shuffle after each game
- Seed determines card positions for multiplayer fairness
- Images should be diverse (animals, objects, faces, landscapes) to prevent visual patterns
- Flip animation should be smooth (200-300ms)
- Sound effects optional but recommended (match success, mismatch)

**Accessibility:**
- Colorblind mode: add symbols to images
- High contrast mode for low-vision players
- No reliance on color alone

---

### 2. Sequence Recall

**Category:** Working memory, pattern recognition, auditory processing

**Core Mechanic:**
- Sequence of colors/sounds plays (4-12 items depending on difficulty)
- Player must reproduce the sequence by tapping buttons
- Sequence gets longer after each correct reproduction
- Goal: Reproduce the longest sequence possible

**Scoring:**
```
Score = (Sequence Length - 3) × 100 + Speed Bonus
Speed Bonus = (Avg Time Per Item / Max Expected Time) × 500
Penalties: -200 points for incorrect sequence

Example:
- Reached sequence length 8 (started at 4)
- Average 1.2 sec per item to reproduce
- Score = (8 - 3) × 100 + (1.2 / 3) × 500 = 500 + 200 = 700
```

**Difficulty Progression:**
| Level | Starting Length | Max Length | Speed | Colors | Time Limit |
|-------|---|---|---|---|---|
| Easy | 4 | 8 | Slow (1.5 sec per item) | 4 colors | 5 min |
| Medium | 5 | 11 | Medium (1.0 sec per item) | 5 colors | 7 min |
| Hard | 6 | 12+ | Fast (0.7 sec per item) | 6 colors + sounds | 8 min |

**Implementation Notes:**
- Use distinct colors (red, blue, yellow, green, purple, orange)
- Optional: Add sound effects to each color (musical tones recommended)
- Seed controls the sequence generation
- Allow player to replay the sequence before attempting
- Visual feedback on correct/incorrect taps

**Accessibility:**
- Support audio+visual for hard-of-hearing players
- High contrast mode for color-blind players

---

### 3. Pattern Memory

**Category:** Spatial memory, visual processing, mental imagery

**Core Mechanic:**
- Grid of tiles appears (4×4, 5×5, or 6×6)
- Pattern of tiles lights up for 2-3 seconds
- Tiles turn blank
- Player reproduces the pattern by tapping tiles in order
- Multiple patterns per game

**Scoring:**
```
Score = (Correct Patterns / Total Patterns) × 1000 + Accuracy Bonus
Accuracy Bonus = (Mistakes / Total Moves) × -100
Time Bonus = (Remaining Time / Total Time) × 500

Example:
- 3 patterns, all correct, 0 mistakes, 35 sec remaining out of 45
- Score = (3/3) × 1000 + 0 - 100 = 1000 + (35/45) × 500 = 1000 + 389 = 1389
```

**Difficulty Progression:**
| Level | Grid Size | Pattern Length | Patterns | Time Per Pattern | Total Time |
|-------|-----------|---|---|---|---|
| Easy | 4×4 | 3-4 | 3 | 15 sec | 45 sec |
| Medium | 5×5 | 5-6 | 4 | 15 sec | 60 sec |
| Hard | 6×6 | 7-8 | 5 | 20 sec | 100 sec |

**Implementation Notes:**
- Use animated tile-lighting (smooth fade in/out)
- Seed determines pattern sequences
- Tiles should have clear feedback on tap (visual + audio)
- Highlight tiles being tapped to prevent mis-taps
- Show progress bar (X of Y patterns completed)

**Accessibility:**
- High contrast tiles
- Optional audio cues for tile selection
- Clear visual feedback on correct/incorrect

---

## Logic Games (🧩)

### 4. Sudoku Duel

**Category:** Logical reasoning, constraint satisfaction, planning

**Core Mechanic:**
- Standard 9×9 Sudoku grid with clues (starting numbers)
- Player fills empty cells with digits 1-9
- Each row, column, and 3×3 box must contain digits 1-9 exactly once
- Goal: Complete the puzzle before time runs out

**Scoring:**
```
Score = (Correct Cells / 81) × 1000 + Time Bonus + Accuracy Bonus
Time Bonus = (Remaining Time / Total Time) × 500
Accuracy Bonus = (Completed Without Errors / Total Moves) × 300
Penalties: -10 per incorrect cell at end

Example:
- Completed 70/81 cells correctly, 8 minutes remaining out of 15
- Score = (70/81) × 1000 + (8/15) × 500 = 864 + 267 = 1131
```

**Difficulty Progression:**
| Level | Clues | Avg Difficulty | Time Limit | Typical Solve |
|-------|-------|---|---|---|
| Easy | 40-45 | Beginner-friendly | 15 min | 5-8 min |
| Medium | 30-35 | Requires logic chains | 15 min | 8-12 min |
| Hard | 20-25 | Multiple logical techniques | 15 min | 12-15 min |

**Implementation Notes:**
- Use sudoku generation library with seeding
- Validate uniqueness (one solution only)
- Show conflicts in real-time (invalid entries highlighted)
- Hint system: reveal one random empty cell (costs 50 points)
- Pencil marks optional (player can note candidates in cells)
- Auto-save progress (if player returns)

**Accessibility:**
- Large font option (font size 16+)
- High contrast mode
- No reliance on color (use numbers + symbols)

---

### 5. Logic Grid

**Category:** Deductive reasoning, constraint satisfaction, systematic thinking

**Core Mechanic:**
- Grid puzzle where attributes must be matched to entities
- Given clues (e.g., "Alice is not wearing red", "Bob is older than Charlie")
- Player marks cells in grid to indicate which attributes belong to which entities
- Goal: Correctly match all attributes

**Scoring:**
```
Score = (Correct Cells / Total Cells) × 1000 + Time Bonus
Time Bonus = (Remaining Time / Total Time) × 500
Penalties: -5 per incorrect cell at end

Example:
- 12×12 grid, 110/144 cells correct, 4 min remaining out of 10
- Score = (110/144) × 1000 + (4/10) × 500 = 764 + 200 = 964
```

**Difficulty Progression:**
| Level | Grid Size | Clues | Reasoning Depth | Time Limit |
|-------|-----------|-------|---|---|
| Easy | 3×3 (3 entities, 3 attrs) | 6-8 | Direct matching | 5 min |
| Medium | 4×4 (4 entities, 4 attrs) | 12-15 | Multi-step deduction | 8 min |
| Hard | 5×5 (5 entities, 5 attrs) | 20-25 | Complex chains | 10 min |

**Implementation Notes:**
- Generate puzzles with seeding (ensure one unique solution)
- Allow players to mark cells (X = no, ✓ = yes, blank = unknown)
- Show deduction chains (player can learn from solving)
- Optional: Show "possible values" for each cell based on current constraints
- Time pressure but not excessive (should allow logical thinking)

**Accessibility:**
- High contrast grid
- Large text for clues
- Audio clue option (read clues aloud)

---

### 6. Code Breaker

**Category:** Hypothesis testing, logical deduction, pattern matching

**Core Mechanic:**
- Hidden code: sequence of colored pegs (4-5 pegs, 6-8 color options)
- Player guesses the code
- After each guess, feedback given:
  - Black peg: correct color in correct position
  - White peg: correct color in wrong position
  - Nothing: color not in code
- Goal: Break the code in fewest guesses

**Scoring:**
```
Score = (10 - Guesses Used) × 200 + Bonus
Bonus = (Attempts Remaining / Max Attempts) × 300

Example:
- 4-peg code, cracked in 4 guesses out of 10 possible
- Score = (10 - 4) × 200 + (6/10) × 300 = 1200 + 180 = 1380
```

**Difficulty Progression:**
| Level | Pegs | Colors | Duplicates | Typical Guesses | Max Guesses |
|-------|------|--------|---|---|---|
| Easy | 3 | 4 | Not allowed | 2-3 | 8 |
| Medium | 4 | 6 | Allowed | 4-6 | 10 |
| Hard | 5 | 8 | Allowed | 6-8 | 12 |

**Implementation Notes:**
- Seed determines the hidden code
- Real-time feedback on each guess (don't wait for game end)
- UI: show all previous guesses and feedback
- Hint system optional (reveal one peg, costs points)
- Mathematical interest: players can use optimal strategies (Minimax)

**Accessibility:**
- Support symbol combinations (not just colors)
- Colorblind mode: use symbols + colors
- Clear distinction between feedback (black vs white pegs)

---

## Attention Games (👁️)

### 7. Spot the Difference

**Category:** Visual attention, detail orientation, rapid scanning

**Core Mechanic:**
- Two images displayed side-by-side
- Images are nearly identical with 5-10 differences
- Player taps on differences
- Goal: Find all differences before time runs out

**Scoring:**
```
Score = Differences Found × 100 + Time Bonus
Time Bonus = (Remaining Time / Total Time) × 500
Penalties: -50 per incorrect tap (marking non-difference as difference)

Example:
- 7 differences, found all 7, 1 incorrect tap, 25 sec remaining out of 60
- Score = 7 × 100 - 50 + (25/60) × 500 = 700 - 50 + 208 = 858
```

**Difficulty Progression:**
| Level | Image Complexity | Differences | Time | Size |
|-------|---|---|---|---|
| Easy | Simple cartoon scenes | 5 | 60 sec | Large obvious differences |
| Medium | Realistic illustrations | 7 | 90 sec | Medium subtle differences |
| Hard | Complex detailed photos | 10 | 120 sec | Small hard-to-spot differences |

**Implementation Notes:**
- Seed determines which differences
- Zoom support (pinch to zoom on images)
- Highlight found differences (visual confirmation)
- Show progress: "X of 7 differences found"
- Difference locations should be spread across image (not clustered)
- Hint system: show next difference location (costs 100 points)

**Accessibility:**
- High contrast mode
- Magnification zoom
- Optional: Verbal description of differences
- Colorblind mode: mark differences with symbols + highlights

---

### 8. Color Rush

**Category:** Selective attention, cognitive inhibition (Stroop effect), reaction time

**Core Mechanic:**
- Word displayed in mismatched color (e.g., "BLUE" printed in red ink)
- Player must select the word that matches the COLOR, not the word itself
- Speed increases each correct answer (difficulty ramps)
- Goal: Maintain accuracy while speed increases

**Scoring:**
```
Score = Correct Answers × Speed Multiplier × 100
Speed Multiplier = Current Speed Level (1.0 to 5.0)
Penalties: -100 per wrong answer, resets speed multiplier to 1.0

Example:
- 8 correct answers, reaches speed level 2.5, 2 wrong answers
- Score = 8 × 2.5 × 100 = 2000 (then reset when made mistake)
```

**Difficulty Progression:**
| Level | Colors | Starting Speed | Max Speed | Time Limit |
|-------|--------|---|---|---|
| Easy | 4 (red, blue, yellow, green) | 1.0 sec/item | 2.0 | 60 sec |
| Medium | 5 (+ purple) | 0.8 sec/item | 3.5 | 90 sec |
| Hard | 6 (+ orange) | 0.6 sec/item | 5.0 | 120 sec |

**Implementation Notes:**
- Use clear, distinct colors (no similar hues)
- Font size: large enough to read quickly
- Multiple-choice UI: show 4 color options, player taps the color word represents
- Seed determines the word-color pairings
- Real-time feedback: green checkmark for correct, red X for wrong
- Speed increases after 3-5 consecutive correct answers

**Accessibility:**
- Colorblind mode: use patterns/symbols instead of colors
- High contrast text
- Audio cues for correct/incorrect (not just visual)

---

### 9. Focus Finder

**Category:** Visual search, sustained attention, spatial awareness

**Core Mechanic:**
- Cluttered scene with 3-5 hidden target objects
- Player taps to find each target
- Each target found reveals next target location hint
- Goal: Find all targets before time runs out

**Scoring:**
```
Score = Targets Found × 200 + Time Bonus
Time Bonus = (Remaining Time / Total Time) × 500
Penalties: -10 per incorrect tap

Example:
- 4 targets in scene, found all 4, 1 incorrect tap, 45 sec remaining out of 120
- Score = 4 × 200 - 10 + (45/120) × 500 = 800 - 10 + 188 = 978
```

**Difficulty Progression:**
| Level | Scene Complexity | Targets | Distractors | Time | Hint Strength |
|-------|---|---|---|---|---|
| Easy | Simple, 5-10 objects | 3 | 5-10 | 90 sec | Strong (highlight area) |
| Medium | Realistic, 15-20 objects | 4 | 15-25 | 120 sec | Medium (show quadrant) |
| Hard | Very complex, 30+ objects | 5 | 30+ | 150 sec | Weak (general direction only) |

**Implementation Notes:**
- Seed determines target locations
- Zoom support on cluttered scenes
- Show progress: "2 of 4 targets found"
- Hints optional: reveal target area (costs 100 points)
- Visual feedback on found targets (mark with checkmark or fade)
- Scenes should be thematic (e.g., beach scene, forest, kitchen)

**Accessibility:**
- High contrast mode
- Magnification zoom
- Audio hints ("look left", "look down")
- Colorblind-friendly images

---

## Spatial Games (🗺️)

### 10. Puzzle Race

**Category:** Spatial reasoning, visual-spatial problem-solving, fine motor control

**Core Mechanic:**
- Jigsaw puzzle with 20-50 pieces depending on difficulty
- Pieces displayed in scattered layout
- Player drags pieces to correct positions
- Snap-to-grid helps placement
- Goal: Complete puzzle before time runs out

**Scoring:**
```
Score = (Pieces Placed / Total Pieces) × 1000 + Time Bonus + Accuracy
Time Bonus = (Remaining Time / Total Time) × 500
Accuracy = (Pieces Placed Without Correction) / Total Pieces × 300

Example:
- 35 pieces, 30 placed correctly, 3 minutes remaining out of 5
- Score = (30/35) × 1000 + (3/5) × 500 = 857 + 300 = 1157
```

**Difficulty Progression:**
| Level | Pieces | Image Type | Complexity | Time | Snap Assist |
|-------|--------|---|---|---|---|
| Easy | 20 | Cartoon / simple | Large pieces | 5 min | Strong (large snap zone) |
| Medium | 35 | Realistic scene | Medium pieces | 6 min | Medium (standard snap) |
| Hard | 50+ | Complex detailed | Small pieces | 7 min | Weak (precise placement) |

**Implementation Notes:**
- Seed determines piece generation and positions
- Pieces should have clear visual edges (high contrast with background)
- Snap-to-grid prevents frustration with precision placement
- Show progress: "15 of 35 pieces placed"
- Piece rotation optional (adds complexity)
- Show preview image (helps player visualize goal)

**Accessibility:**
- Adjustable piece size (zoom)
- High contrast pieces
- Audio feedback on successful placements

---

### 11. Rotation Master

**Category:** Spatial visualization, mental rotation, 3D reasoning

**Core Mechanic:**
- 3D wireframe object shown in target orientation
- Player receives a 3D model that can be rotated
- Player must rotate their model to match the target orientation
- Server validates rotation within tolerance (±5°)
- Multiple challenges per game

**Scoring:**
```
Score = (Correct Rotations / Total Challenges) × 1000 + Accuracy Bonus + Speed Bonus
Accuracy Bonus = (Average Error / Max Error) × -200
Speed Bonus = Avg Time Per Rotation × -50

Example:
- 5 challenges, 4 correct (1 off by 8°), avg 45 sec per rotation
- Score = (4/5) × 1000 - 50 + (45 × 50) = 800 - 50 = 750
```

**Difficulty Progression:**
| Level | Object Type | Rotations Needed | Tolerance | Time Per Item | Challenges |
|-------|---|---|---|---|---|
| Easy | 2D shapes, simple 3D | 1-2 axes | ±10° | 90 sec | 3 |
| Medium | Complex 3D objects | 2-3 axes | ±5° | 60 sec | 4 |
| Hard | 4D projections, complex | 3 axes + 4D | ±3° | 45 sec | 5 |

**Implementation Notes:**
- Use real 3D rendering (Three.js or similar)
- Seed determines object types and target orientations
- Rotation interface: intuitive touch gestures (two-finger drag for rotation)
- Show current rotation angles (X, Y, Z)
- Show target orientation alongside player's rotation
- Validation: use quaternion rotation and compare to target with tolerance

**Accessibility:**
- Large touch targets for rotation controls
- Haptic feedback on success
- Audio cues for correct rotation
- Alternative: 2D rotation for players with spatial difficulties

---

### 12. Path Finder

**Category:** Spatial planning, pathfinding, goal-directed navigation

**Core Mechanic:**
- Maze from start (top-left) to exit (bottom-right)
- Player traces path by tapping adjacent cells or swiping
- Shortest path wins; efficiency matters
- Multiple mazes per game (or one large maze)

**Scoring:**
```
Score = (Path Efficiency / Optimal Path) × 1000 + Time Bonus
Path Efficiency = Optimal Steps / Actual Steps
Time Bonus = (Remaining Time / Total Time) × 500

Example:
- Optimal path: 25 steps, player used 27 steps, 2 min remaining out of 5
- Score = (25/27) × 1000 + (2/5) × 500 = 926 + 200 = 1126
```

**Difficulty Progression:**
| Level | Maze Size | Complexity | Obstacles | Time | Typical Optimal |
|-------|-----------|---|---|---|---|
| Easy | 10×10 | Simple paths | None | 3 min | 15-20 steps |
| Medium | 20×20 | Multiple branches | 1-2 static obstacles | 5 min | 30-40 steps |
| Hard | 30×30 | Complex branching | 3-5 moving obstacles | 7 min | 50-70 steps |

**Implementation Notes:**
- Seed determines maze layout (use standard maze generation algorithm)
- Use A* algorithm to compute optimal path for scoring
- Visualization: show current path in different color
- Obstacles: moving walls, locked doors (costs time/points to unlock)
- Show progress: current position, distance to exit
- Hint system: show next optimal step (costs points)

**Accessibility:**
- High contrast maze walls
- Clear start/exit markers
- Audio cues for successful navigation
- Option: show path guidance (faint optimal path)

---

## Language Games (📚)

### 13. Word Builder

**Category:** Vocabulary, linguistic flexibility, pattern recognition, spelling

**Core Mechanic:**
- Given 7-10 letters (with one used multiple times, e.g., "AEIORSTN")
- Player forms as many valid English words as possible
- Minimum word length: 3 letters
- Scoring based on word length and uniqueness
- 3-minute time limit

**Scoring:**
```
Score = Sum of Word Lengths × Unique Words Found × 10
Length Bonus: 7+ letter words = 2× multiplier

Example:
- Found: "CAT" (3), "SATIN" (5), "RATIONS" (7), "TRAIN" (5), "RAIN" (4)
- Sum = 3 + 5 + 7 + 5 + 4 = 24
- Score = 24 × 5 unique × 10 × (1 + 1 for 7-letter) = 2400
```

**Difficulty Progression:**
| Level | Letter Set | Common Letters | Total Words Possible | Time |
|-------|---|---|---|---|
| Easy | AEIORSTN | High frequency | 50-80 | 3 min |
| Medium | ELRTONID | Mixed frequency | 80-120 | 3 min |
| Hard | QUVWXYZ | Low frequency | 30-50 | 3 min |

**Implementation Notes:**
- Seed determines letter set
- Use standard English dictionary for validation (60,000+ words)
- Show letter frequencies (to help players find words)
- Show found words as player enters them (prevent duplicates)
- Hint system: suggest next word (costs 50 points)
- Countdown timer visible (3 minutes)

**Accessibility:**
- Large, clear letter display
- High contrast background
- Audio option: read word aloud to confirm spelling
- Dyslexia-friendly font option

---

### 14. Anagram Attack

**Category:** Spelling, word recognition, pattern analysis

**Core Mechanic:**
- Given scrambled word, unscramble it
- 10 anagrams per game
- Hints available but cost points
- Speed bonuses for quick answers
- 60-second time limit total (6 sec per anagram average)

**Scoring:**
```
Score = (10 - Skipped) × 100 + Accuracy Bonus + Speed Bonus
Accuracy Bonus = Correct × 50
Speed Bonus = Avg Time × -5

Example:
- 8 correct, 1 skipped, 1 wrong, avg 4 sec per solve
- Score = (10 - 1) × 100 + 8 × 50 + 4 × -5 = 900 + 400 - 20 = 1280
```

**Difficulty Progression:**
| Level | Word Length | Word Type | Hint Cost | Time Per Word |
|-------|---|---|---|---|
| Easy | 4-5 letters | Common words | Free | 8 sec |
| Medium | 6-8 letters | Mixed words + names | -50 pts | 6 sec |
| Hard | 8-10 letters | Technical + archaic | -100 pts | 5 sec |

**Implementation Notes:**
- Seed determines anagram selections and order
- Show unscrambled letters clearly
- Input method: text field or letter tapping
- Hint button: reveal first letter or vowels (costs points)
- Show progress: "3 of 10" anagrams solved
- Countdown timer (60 sec total)

**Accessibility:**
- Large input field
- Text-to-speech for anagrams
- High contrast display
- Dyslexia-friendly font option

---

### 15. Vocabulary Showdown

**Category:** Vocabulary breadth, reading comprehension, knowledge recall

**Core Mechanic:**
- Multiple-choice vocabulary quiz
- 10 questions with 4 options each
- Each question has time limit (20 seconds)
- Score based on accuracy and speed

**Scoring:**
```
Score = Correct Answers × 100 + Time Bonus + Difficulty Bonus
Time Bonus = (Remaining Time / Total Time) × 30
Difficulty Bonus = Correct Answers on Hard Terms × 50

Example:
- 8 correct, avg 12 sec per question (20 sec limit), 3 were hard terms
- Score = 8 × 100 + (12/20) × 30 + 3 × 50 = 800 + 18 + 150 = 968
```

**Difficulty Progression:**
| Level | Vocabulary Range | Word Type | Question Set Size | Avg Difficulty |
|-------|---|---|---|---|
| Easy | 5,000 most common words | Everyday vocabulary | 50 questions | Elementary |
| Medium | 10,000 mid-frequency words | Educated vocabulary | 100 questions | High School |
| Hard | 15,000 advanced words | Archaic, technical terms | 150 questions | Advanced/PhD |

**Implementation Notes:**
- Seed determines question selection from question bank
- Question format: "What does [WORD] mean?" with 4 options
- One correct answer, three plausible distractors
- 20-second timer per question (countdown visible)
- Show progress: "5 of 10"
- Optional: Show definition after correct answer (learning opportunity)

**Accessibility:**
- Large, readable text
- High contrast options
- Audio option: read questions aloud
- Extended time option (30 sec per question) for accessible mode

---

## Cross-Game Mechanics

### Seeded Challenge Generation

All games use seeds to ensure fairness in multiplayer:

```javascript
// Backend example
const seed = generateSeedFromMindWarRound(mindWarId, roundNumber);
const challenge = generateChallenge(gameType, difficulty, seed);
// Same seed = same challenge for all players
```

**Benefits:**
- ✅ No player gets easier version
- ✅ No cheating via problem knowledge
- ✅ Reproducible (can re-verify results)
- ✅ Audit trail (seed logged with score)

### Difficulty Progression

All games support three difficulty tiers:
- **Easy:** New players, learning mode
- **Medium:** Competitive play, skill development
- **Hard:** Expert players, high scores

Players can choose difficulty when joining a Mind War.

### Scoring Philosophy

**Consistent across all games:**
- Accuracy (getting answers right) + Speed (finishing fast) = Score
- No single dimension dominates (both matter equally)
- Time bonuses encourage completion but don't overpower accuracy
- Penalties prevent guessing/rushing without thinking

### Accessibility Standards

All games support:
- **Vision:** High contrast, large text, colorblind modes, zoom
- **Motor:** Alternative input methods, adjustable difficulty, no timed pressure for accessibility mode
- **Cognitive:** Clear instructions, progress indicators, optional hints
- **Hearing:** Visual feedback, haptics, captions where audio is used

---

## Implementation Checklist

For each game, developers should:
- [ ] Implement core game mechanics
- [ ] Implement seeded challenge generation
- [ ] Implement scoring algorithm
- [ ] Add all 3 difficulty levels
- [ ] Implement UI for mobile (responsive, 48dp+ touch targets)
- [ ] Add server-side validation (prevent cheating)
- [ ] Add accessibility features (contrast, zoom, alt modes)
- [ ] Add tutorial/onboarding
- [ ] Add sounds/haptics (optional)
- [ ] Test with real players (balancing, fun factor)
- [ ] Document in-game help/rules

---

## Game Balance Notes

**Cognitive Load Distribution:**
- Memory games: High pattern recognition, moderate time pressure
- Logic games: High reasoning, flexible time pressure
- Attention games: High speed/reaction, moderate cognitive load
- Spatial games: High visualization, moderate physical skill
- Language games: High knowledge, moderate speed requirement

**Victory Paths:**
Each game supports multiple victory strategies:
- **Memory Match:** Visual recall vs. systematic approach
- **Sequence Recall:** Auditory vs. visual processing
- **Pattern Memory:** Spatial memory vs. systematic mapping
- **Sudoku Duel:** Speed solving vs. careful analysis
- **Logic Grid:** Deductive chains vs. brute-force elimination
- **Code Breaker:** Systematic strategy vs. intuitive guessing
- **Spot the Difference:** Systematic scanning vs. pattern-matching
- **Color Rush:** Speed reactions vs. color recognition
- **Focus Finder:** Rapid scanning vs. systematic search
- **Puzzle Race:** Visual matching vs. spatial reasoning
- **Rotation Master:** Mental rotation vs. trial-and-error
- **Path Finder:** A* optimal vs. quick exploration
- **Word Builder:** Vocabulary depth vs. rapid word formation
- **Anagram Attack:** Spelling knowledge vs. pattern recognition
- **Vocabulary Showdown:** Knowledge breadth vs. quick reasoning

This diversity ensures different cognitive styles can succeed.

---

## Future Game Additions

Potential new games for post-MVP:
- **Music Recall:** Remember melodies/rhythms
- **Visual Estimation:** Estimate quantities, sizes, distances
- **Strategic Planning:** Chess-like tactical puzzles
- **Typing Speed:** Accuracy + speed typing challenge
- **Story Completion:** Narrative-based language game
- **Math Challenges:** Quick arithmetic or geometry problems
- **Trivia Masters:** Themed knowledge questions

---

**Document Version:** 1.0  
**Last Updated:** April 6, 2026  
**Owner:** Game Design / Product  
**Status:** Reference Complete

