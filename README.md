# Mind Wars 🧠⚔️

**Mind Wars** is an async multiplayer cognitive games platform with cross-platform support for iOS 14+ and Android 8+. Designed as a family-first experience where parents have full visibility and control. A Mind War requires at least 2 players, supports an admin-defined upper player limit, and also supports solo local practice outside of Mind Wars.

## Development Philosophy

### Mobile-First 📱
Designed for 5" touch screens, then scales up. All UI elements are touch-optimized with minimum 48dp touch targets.

### Offline-First 📴
All games playable without connectivity. SQLite-based local storage with automatic sync queue and retry logic.

### API-First 🌐
RESTful design enables potential web version. Clean separation between client and server.

### Security-First 🔒
Server-side validation for all game logic. Client is thin client; server is authoritative source of truth.

### Data-Driven 📊
Instrumented analytics for A/B testing. Event-driven architecture for scalability.

### Progressive Enhancement 🚀
Core features first, polish iteratively. Optimistic updates with server confirmation.

## Features

### 🎮 Async Multiplayer
- **2+ players** per Mind War, with the upper limit defined by the host or admin configuration
- Round-based async gameplay system
- Real-time lobby management via Socket.io
- Automatic reconnection support
- Player status tracking (active/idle/disconnected)
- Async-first design: players complete sealed game slots at their own pace during the round window
- Players may participate in multiple Mind Wars at the same time across friends, family, and matchmaking groups
- Players may only be in one planning lobby at a time, while active Mind War participation is capped at 10 concurrent wars
- Solo play is supported locally for practice, but a Mind War itself starts at 2 players

### 📱 Cross-Platform Support
- **iOS 14+** support
- **Android 8+** support
- Feature parity across platforms
- **Flutter** architecture for native performance

### 🎯 Game Variety
**15 games across 5 cognitive categories, designed for competitive async play with family.**

All games use **sealed payloads** — every player in a Mind War gets the exact same challenge, validated server-side to prevent cheating. Games score based on accuracy and speed.

**See [GAMES_REFERENCE.md](docs/GAMES_REFERENCE.md) for complete specifications:** mechanics, scoring algorithms, difficulty progression, seeded challenge generation, and accessibility features for all 15 games.

---

#### 🧠 Memory Games

**Memory Match**
- **How it works:** Classic flip-card memory game. Cards are face-down; flip pairs and memorize their positions. Match all pairs before time runs out.
- **Cognitive benefits:** Short-term memory, visual recall, attention to detail
- **Competitive aspect:** Score = pairs matched + time bonus. Faster completion = higher score. 90 second time limit per game.
- **Difficulty:** 3 levels (12, 20, 30 cards) with adjustable speed

**Sequence Recall**
- **How it works:** Watch a sequence of colors/sounds play. Sequence gets longer each round. Reproduce the sequence by tapping buttons in correct order.
- **Cognitive benefits:** Working memory, pattern recognition, auditory processing, concentration under pressure
- **Competitive aspect:** Score = length of sequence recalled × difficulty multiplier. Both players get the same sequence; whoever recalls more steps wins.
- **Difficulty:** 3 levels (starting at 4 steps, up to 12+)

**Pattern Memory**
- **How it works:** Grid of tiles displays a visual pattern briefly (2-3 sec), then tiles disappear. Recreate the pattern by tapping tiles in the correct positions.
- **Cognitive benefits:** Spatial memory, pattern recognition, visual processing, mental imagery
- **Competitive aspect:** Score = accuracy % × time bonus. Fewer mistakes = higher score. 45 second time limit per pattern.
- **Difficulty:** 3 levels (4×4 to 6×6 grids, 3-12 tile patterns)

---

#### 🧩 Logic Games

**Sudoku Duel**
- **How it works:** Standard 9×9 Sudoku grid. Procedurally generated with seeded difficulty. Players solve competitively; score based on speed and accuracy.
- **Cognitive benefits:** Logical reasoning, constraint satisfaction, planning, systematic problem-solving
- **Competitive aspect:** Score = (cells filled correctly / total cells) × time bonus. Both players get identical puzzle; faster solve = higher score. 15-minute time limit.
- **Difficulty:** 3 levels (easy 40 clues, medium 30 clues, hard 20 clues)

**Logic Grid**
- **How it works:** Deductive reasoning puzzle. Given clues, determine which attributes belong to which entities (e.g., "Alice is not wearing red; Bob is older than Charlie"). Fill in the grid correctly.
- **Cognitive benefits:** Deductive reasoning, logical elimination, constraint reasoning, systematic thinking
- **Competitive aspect:** Score = (correct cells / total cells) × time bonus. Both players solve identical puzzle; accuracy + speed determines winner. 10-minute time limit.
- **Difficulty:** 3 levels (3×3 with 6 clues, 4×4 with 12 clues, 5×5 with 20 clues)

**Code Breaker**
- **How it works:** Guess a hidden code (sequence of colored pegs). Each guess gives feedback: black peg = correct color in correct position, white peg = correct color in wrong position. Minimize guesses to break the code.
- **Cognitive benefits:** Hypothesis testing, logical deduction, pattern matching, strategic thinking
- **Competitive aspect:** Score = 1000 - (guesses used × 100). Fewer guesses = higher score. Both players crack identical codes. Typical: 4 pegs, 6 colors, 4-8 guesses needed.
- **Difficulty:** 3 levels (3 pegs, 4 pegs, 5 pegs)

---

#### 👁️ Attention Games

**Spot the Difference**
- **How it works:** Two nearly identical images displayed side-by-side. Find all differences (typically 5-8 per image pair). Tap differences to mark them; 60-second time limit.
- **Cognitive benefits:** Visual attention, detail orientation, rapid scanning, visual comparison
- **Competitive aspect:** Score = differences found × time bonus. Both players see identical image pairs; fastest to find all = winner. Accuracy penalty: marking wrong spot loses 50 points.
- **Difficulty:** 3 levels (5 diffs in simple scenes, 7 diffs in complex scenes, 10 diffs in detailed photos)

**Color Rush**
- **How it works:** Screen displays colored words in mismatched colors (e.g., the word "RED" printed in blue ink). Tap the word that matches the color name. Speed increases each round.
- **Cognitive benefits:** Selective attention, cognitive inhibition (Stroop effect), color recognition, reaction time
- **Competitive aspect:** Score = correct answers × speed multiplier. Mistakes reset multiplier. Both players get identical sequences; whoever maintains streak longer = higher score. 60-second time limit.
- **Difficulty:** 3 levels (slow 1 sec/item, moderate 0.7 sec/item, fast 0.4 sec/item)

**Focus Finder**
- **How it works:** Cluttered scene with hidden target object (like "Where's Waldo"). Tap on the target to find it. Time limit; multiple targets per round.
- **Cognitive benefits:** Visual search, sustained attention, detail recognition, spatial awareness
- **Competitive aspect:** Score = targets found × time bonus. Both players search identical scenes; faster find = higher score. Typical: 3-5 targets per scene, 90-second time limit.
- **Difficulty:** 3 levels (obvious objects in busy scenes, subtle objects, 20+ distractors)

---

#### 🗺️ Spatial Games

**Puzzle Race**
- **How it works:** Jigsaw puzzle with procedurally generated pieces. Drag pieces to correct positions. Snap-to-grid aids placement. Beat the clock.
- **Cognitive benefits:** Spatial reasoning, visual-spatial problem-solving, pattern matching, fine motor coordination
- **Competitive aspect:** Score = (pieces placed correctly / total pieces) × time bonus. Both players solve identical puzzle; accuracy + speed = winner. 5-minute time limit.
- **Difficulty:** 3 levels (20 pieces, 35 pieces, 50 pieces)

**Rotation Master**
- **How it works:** 3D wireframe object displayed in a target orientation. Player must mentally rotate a given object to match the target. Player rotates on-screen 3D model via touch; tap "Done" when matched. Server validates rotation against tolerance (±5°).
- **Cognitive benefits:** Spatial visualization, mental rotation, 3D reasoning, spatial orientation, fine motor control
- **Competitive aspect:** Score = accuracy % × speed bonus. Both players get identical rotation challenges (seeded); fewer errors + faster solve = higher score. 5 items per game, 90-second time limit per item.
- **Difficulty:** 3 levels (2D shapes, simple 3D objects, complex 4D projections)

**Path Finder**
- **How it works:** Maze from start to exit. Player traces path by tapping/swiping. Shortest, fastest path wins. Multiple obstacles: moving walls, narrow passages, dead ends.
- **Cognitive benefits:** Spatial planning, pathfinding, visual-spatial reasoning, goal-directed navigation
- **Competitive aspect:** Score = path efficiency % × time bonus. Both players get identical mazes (seeded); fastest with minimal wrong turns = winner. Typical: 3-5 minute time limit.
- **Difficulty:** 3 levels (simple 10×10 maze, complex 20×20 maze, advanced with moving obstacles)

---

#### 📚 Language Games

**Word Builder**
- **How it works:** Given a set of 7-10 letters, form as many valid English words as possible within 3-minute time limit. Longer words = more points. Minimum word length: 3 letters.
- **Cognitive benefits:** Vocabulary, linguistic flexibility, pattern recognition, spelling, word recall
- **Competitive aspect:** Score = (sum of word lengths) × unique words found. Both players get identical letter sets (seeded); whoever finds more/longer words = higher score.
- **Difficulty:** 3 levels (common letters like AEIORTNS, mixed letter frequency, advanced with Q, X, Z)

**Anagram Attack**
- **How it works:** Given a scrambled word, unscramble it. Hints available but cost points. Each correct answer in 60 seconds. 10 anagrams per game.
- **Cognitive benefits:** Spelling, word recognition, pattern analysis, vocabulary
- **Competitive aspect:** Score = (10 - anagrams_skipped) × avg_time_per_solve. Both players get identical anagrams (seeded); fewest wrong + fastest solve = winner.
- **Difficulty:** 3 levels (4-letter words, 7-letter words, 10+ letter words and proper nouns)

**Vocabulary Showdown**
- **How it works:** Multiple-choice vocabulary quiz. 10 questions with 4 options each. Timed per question (20 seconds). Score based on accuracy and speed.
- **Cognitive benefits:** Vocabulary breadth, reading comprehension, knowledge recall, cognitive speed
- **Competitive aspect:** Score = correct answers × time multiplier. Both players get identical questions (seeded from question bank); accuracy + speed = winner. Penalty: wrong answer costs 50 points.
- **Difficulty:** 3 levels (elementary 5,000-word range, intermediate 10,000-word range, advanced 15,000-word range with archaic/technical terms)

### 💬 Social Features
- **Mind War Activity Hub** — Unified feed combining player chat, game events, and admin notifications
  - Real-time player messages with family-friendly chat
  - Game completion events with scores and rankings
  - Admin setting changes visible to all players
  - Accessible from any game screen via chat icon
  - Configurable notifications (game completions, admin changes, chat messages, quiet hours)
- **In-game chat** with real-time messaging
- **Emoji reactions** (👍 ❤️ 😂 🎉 🔥 👏 😮 🤔)
- **Vote-to-skip mechanics** for game progression
- **Game voting system** - Players vote on which games to play
  - Configurable points per player
  - Vote across multiple rounds
  - Democratic game selection
- Player presence indicators

### 👨‍👩‍👧‍👦 Family-First Safety & Parental Controls
**Mind Wars is designed for families. Kids play with their family, not with strangers.**

#### Parent-Linked Child Accounts (Under 13)
- **COPPA Compliant** — Full parental consent mechanism with verifiable parent approval
- **Linked Accounts** — Child accounts must be linked to a parent/guardian account
- **Parental Visibility** — Parents can see all child activity, scores, and game history
- **Family-Only Play** — Children under 13 can only play in Mind Wars where their parent/guardian is also participating
- **Content Control** — Parents set time limits, approve connections, and manage content access

#### Parental Dashboard
- **Activity Monitoring** — View child's game history, scores, playtime, and learning progress
- **Time Management** — Set daily/weekly playtime limits with notifications
- **Connection Control** — Approve or block new players before they can play with your child
- **Chat Review** — Full transparency into all messages (parents can read all chat)
- **Safety Reports** — Get flagged for any inappropriate behavior or attempted contact from unknown players
- **Transition Settings** — Manage graduation to independent account at age 13+

#### Child-Mode Safety Features
- **Aggressive Profanity Filter** — Enhanced word filter tuned for child safety (not just swear words, but condescending/inappropriate language)
- **Restricted Messaging** — Children cannot initiate contact with players outside their approved family group
- **Message Moderation** — All child messages visible to parent; flagged messages reviewed by moderation team
- **No External Tracking** — Disabled analytics, ads, and behavioral tracking for child accounts
- **Screen Time Guidance** — App recommends age-appropriate playtime (e.g., 30-60 min/day)
- **Safe Game Content** — All 15 games rated for children; no violent, suggestive, or scary content

#### Registration Flow for Families
1. **Parent creates account** — Normal registration (email, password, display name)
2. **Parent invites family** — "I want to play with my child/family members"
3. **Generates family code** — Shareable invite code or QR for linking
4. **Child registers** — Selects "I'm under 13" during signup; enters parent email + family code
5. **Parent approves** — Gets notification on their device; approves child account with one tap
6. **Child account created** — Linked to parent; restricted to family Mind Wars only
7. **Parent dashboard** — Immediate access to child's activity and controls

#### Data Handling for Children Under 13
- **Minimal Collection** — Only essential data (name, birthday, game scores)
- **No Targeting** — No ads, behavioral tracking, or third-party data sharing
- **Parental Access** — Parents can export or delete all child data at any time
- **Retention Policy** — Child account data deleted upon request or account closure
- **Security** — All child data encrypted at rest; HTTPS for transit; no cookies without explicit consent

### 🏆 Progression System
- **Weekly leaderboards** with rankings
- **15+ badges** to unlock:
  - First Victory 🏆
  - Streak badges (3, 7, 30 days) 🔥
  - Games played milestones
  - Category mastery badges
  - Social achievements
- **Streak tracking** with multipliers (up to 2.0x)
- **Unified scoring system** across all games
- Level progression based on total score

### 📴 Offline Mode
- **All games playable offline** (Offline-First)
- Local puzzle solving with SQLite storage
- Per-Mind-War progress snapshots so multiple active rounds do not overwrite each other
- **Automatic sync** on reconnect with retry logic
- Sync queue for failed API calls
- Conflict resolution: Server wins for scoring, client preserves user input
- Progress tracking while offline

## Architecture

### Client-Server Model
- **Thin Client**: UI rendering, local game logic validation, offline caching
- **Authoritative Server**: Source of truth for game state, scoring, player matching
- **Sealed Payload Model**: each Mind War round locks one identical challenge package per game slot for every player
- **Rationale**: Prevents cheating; enables cross-device sync

### Offline Resilience
- Games stored locally in SQLite with sync queue
- Games restore from scoped progress snapshots keyed to the specific Mind War round and challenge
- Automatic retry logic for failed API calls (max 5 retries)
- Conflict resolution: Server wins for scoring validation
- Optimistic updates with server confirmation

### Microservices-Lite via Cloud Functions
- Modular functions for:
  - Authentication
  - Game logic validation
  - Notifications
  - Scoring & leaderboards
- Independent deployment and scaling
- Event-driven architecture
- Future-proof for containerized services

## Tech Stack

- **Flutter 3.0+** - Cross-platform mobile framework
- **Dart** - Type-safe development
- **Socket.io** - Real-time multiplayer communication
- **SQLite** - Local data persistence (Offline-First)
- **HTTP** - RESTful API communication
- **Provider** - State management

## Documentation

### 🎯 Getting Started (READ FIRST)
- **[GAMES_EVALUATION_AND_ROADMAP.md](docs/games/GAMES_EVALUATION_AND_ROADMAP.md)** - ⭐ NEW: Game prioritization and implementation roadmap
- **[BACKLOG_GUIDE.md](docs/project/BACKLOG_GUIDE.md)** - Quick reference guide to navigate all documentation
- **[docs/README.md](docs/README.md)** - ⭐ NEW: Complete documentation hub and navigation

### 📋 Planning & Strategy
- **[PRODUCT_BACKLOG.md](PRODUCT_BACKLOG.md)** - Prioritized backlog with Epics, Features, and Tasks (P0-P3)
- **[ROADMAP.md](ROADMAP.md)** - Visual 6-month roadmap with milestones and success metrics
- **[SPRINT_TEMPLATES.md](docs/project/SPRINT_TEMPLATES.md)** - Sprint planning, standup, review, and retrospective templates
- **[CLOUD_MIGRATION_PLAN.md](docs/project/CLOUD_MIGRATION_PLAN.md)** - ⭐ NEW: Production cloud migration strategy (Epic 13)

### 📚 Product Documentation

**Games & Core Mechanics:**
- **[GAMES_REFERENCE.md](docs/GAMES_REFERENCE.md)** - ⭐ Complete specifications for all 15 games: mechanics, scoring, difficulty progression, seeded challenge generation, accessibility features
- **[VOTING_SYSTEM.md](VOTING_SYSTEM.md)** - Game voting system documentation

**Product & Strategy:**
- **[USER_PERSONAS.md](docs/business/USER_PERSONAS.md)** - 8 detailed user personas (Family, Friends, Office/Colleagues)
- **[USER_STORIES.md](docs/business/USER_STORIES.md)** - Comprehensive user stories with acceptance criteria
- **[ALPHA_USER_STORIES.md](ALPHA_USER_STORIES.md)** - ⭐ Alpha testing user stories (Epics, Features, Tasks for pre-server testing)

**Technical & Architecture:**
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture and implementation analysis
- **[MIND_WAR_ACTIVITY_HUB.md](docs/MIND_WAR_ACTIVITY_HUB.md)** - ⭐ Chat + Activity feed system (player messages, game events, admin notifications)
- **[FAMILY_SAFETY_ROADMAP.md](docs/FAMILY_SAFETY_ROADMAP.md)** - ⭐ COPPA compliance, parental controls, and child account implementation
- **[VALIDATION.md](docs/project/VALIDATION.md)** - Implementation validation checklist
- **[BETA_ADMIN_USER_STORIES.md](docs/project/BETA_ADMIN_USER_STORIES.md)** - ⭐ Beta testing admin requirements and workflows

### 🧪 Testing & Quality Assurance
- **[ALPHA_TESTING.md](ALPHA_TESTING.md)** - Alpha testing guide for local builds and early testing
- **[BETA_TESTING_USER_STORIES.md](BETA_TESTING_USER_STORIES.md)** - ⭐ NEW: Beta testing program with epics, features, tasks, and user journeys

### 🎯 Epic Implementation Summaries (NEW)
- **[EPIC_1_SUMMARY.md](docs/project/EPIC_1_SUMMARY.md)** - Authentication & Onboarding implementation
- **[EPIC_2_SUMMARY.md](docs/project/EPIC_2_SUMMARY.md)** - Lobby Management & Multiplayer implementation
- **[EPIC_3_IMPLEMENTATION.md](docs/project/EPIC_3_IMPLEMENTATION.md)** - Core Gameplay Experience implementation
- **[EPIC_4_IMPLEMENTATION.md](docs/project/EPIC_4_IMPLEMENTATION.md)** - ⭐ NEW: Cross-Platform & Reliability implementation

### 🗂️ Organized Documentation (NEW)
Comprehensive documentation is now organized in the `docs/` directory:
- **[docs/business/](docs/business/)** - Business strategy, market analysis, monetization
- **[docs/project/](docs/project/)** - Project management, technical specs, onboarding
- **[docs/social/](docs/social/)** - Social media, community, marketing strategy
- **[docs/games/](docs/games/)** - Game design documents and templates
- **[docs/research/](docs/research/)** - Research archives and analysis

Key documents:
- [Business Strategy Overview](docs/business/STRATEGY_OVERVIEW.md)
- [Market Analysis](docs/business/MARKET_ANALYSIS.md)
- [Developer Onboarding](docs/project/DEVELOPER_ONBOARDING.md)
- [Social Media Strategy](docs/social/SOCIAL_MEDIA_STRATEGY.md)
- [Game Design Template](docs/games/GAME_DESIGN_TEMPLATE.md)
- [Async Game Contract](docs/games/ASYNC_GAME_CONTRACT.md)
- [Sealed Payload Implementation Guide](docs/games/SEALED_PAYLOAD_IMPLEMENTATION_GUIDE.md)

### 🔬 Research Archives
Extensive research on game design and cognitive training:
- [Competitive Async MPG Research](docs/research/COMPETITIVE-ASYNC-MPG.md) - 25+ competitive games
- [Brain Training Games Research](docs/research/BRAIN_TRAINING_GAMES.md) - 18 cognitive games

## Project Structure

```
mind-wars/
├── lib/
│   ├── models/              # Data models
│   │   └── models.dart      # All app models
│   ├── services/            # Business logic services
│   │   ├── api_service.dart          # RESTful API client
│   │   ├── multiplayer_service.dart  # Multiplayer functionality
│   │   ├── offline_service.dart      # Offline mode & sync with SQLite
│   │   ├── progression_service.dart  # Leaderboards & badges
│   │   └── voting_service.dart       # Game voting system
│   ├── games/               # Game implementations
│   │   └── game_catalog.dart         # Game catalog (12+ games)
│   ├── screens/             # Screen widgets
│   ├── widgets/             # Reusable UI widgets
│   └── main.dart            # Main app entry point
├── test/                    # Test files
├── pubspec.yaml             # Dependencies
├── docs/                    # Documentation directory
│   ├── business/            # Business documentation
│   │   ├── USER_PERSONAS.md # User personas
│   │   └── USER_STORIES.md  # User stories
│   ├── project/             # Project management docs
│   └── games/               # Game design docs
└── README.md
```

## Installation

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Xcode 14+ (for iOS development)
- Android Studio (for Android development)

### Setup

```bash
# Install Flutter dependencies
flutter pub get

# Run on iOS simulator (macOS only)
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Build for production
flutter build apk          # Android
flutter build ios          # iOS
```

### Local Development with Backend Services

For local testing with a full backend stack, start the Docker services:

```bash
# Navigate to backend directory
cd backend

# Start all services (PostgreSQL, Redis, API, Multiplayer, Nginx)
docker compose up -d

# Verify services are running
docker compose ps

# Check API health
curl http://localhost:3002/health
```

**Service Ports (Host):**
- PostgreSQL: `5433` (internal: 5432)
- Redis: `6380` (internal: 6379)
- API Server: `3002` (internal: 3000)
- Multiplayer (Socket.io): `3003` (internal: 3001)
- Nginx Gateway: `4001` (routes to API + Socket.io)

**Running on Physical Device:**

Update your device's IP address and run:

```bash
# Replace 172.16.0.4 with your machine's local network IP
flutter run --dart-define=FLAVOR=local --dart-define=LOCAL_HOST=172.16.0.4
```

The app will automatically connect to:
- REST API: `http://172.16.0.4:3002`
- WebSocket: `http://172.16.0.4:3003`

## Alpha Builds

Alpha builds allow you to test the app on your personal device before release.

**📖 For Alpha Testers**: See **[ALPHA_USER_STORIES.md](ALPHA_USER_STORIES.md)** for comprehensive user stories, testing workflows, and acceptance criteria specific to Alpha testing without backend servers.

### Building Alpha Versions Locally

Use the provided build script:

```bash
# Build Android alpha APK
./build-alpha.sh android

# Build iOS alpha (macOS only)
./build-alpha.sh ios

# Build both platforms
./build-alpha.sh both
```

The Android APK will be available at: `build/app/outputs/flutter-apk/mind-wars-v{version}-alpha.apk`

### Using GitHub Actions

Alpha builds can be automatically generated via GitHub Actions:

1. Go to the **Actions** tab in the repository
2. Select **"Build Alpha APK"** workflow
3. Click **"Run workflow"**
4. Download the generated APK from the workflow artifacts

### Installing Alpha Builds

**Android:**
1. Transfer the APK to your Android device
2. Enable "Install from unknown sources" in your device settings
3. Open the APK file to install
4. The app will appear as "Mind Wars Alpha" with package ID `com.mindwars.app.alpha`

**iOS:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing with your Apple Developer account
3. Connect your device and select it as the target
4. Click "Run" or use Product > Archive for distribution
5. Alternatively, use TestFlight for distributing to testers

### Alpha vs Production

Alpha builds have:
- Different bundle ID (`com.mindwars.app.alpha`) - can install alongside production
- Version suffix `-alpha` (e.g., `1.0.0-alpha`)
- Useful for testing new features without affecting production installs

## Beta Testing

Beta testing validates production readiness with real users in a controlled environment. See **[BETA_TESTING_USER_STORIES.md](BETA_TESTING_USER_STORIES.md)** for:

- **Beta Testing Program**: Complete epics, features, and tasks for beta testing infrastructure
- **Beta Tester Journey**: Detailed user journey from invitation through launch
- **Testing Campaigns**: Structured testing scenarios and focus areas
- **Feedback Collection**: In-app feedback, surveys, and analytics
- **Success Metrics**: KPIs and targets for beta testing program

### Beta vs Alpha

| Aspect | Alpha | Beta |
|--------|-------|------|
| **Environment** | Local builds, dev servers | Hosted production-like servers |
| **Distribution** | Manual APK, TestFlight | TestFlight + Google Play Beta Track |
| **User Base** | Internal team, close contacts | Invited external users (50-100+) |
| **Duration** | 1-2 weeks | 4-6 weeks |
| **Focus** | Core functionality | Real-world usage, UX, edge cases |
| **Monitoring** | Basic logging | Full analytics, crash reporting, APM |

## Development

```bash
# Run the app
flutter run

# Run the app with alpha flavor (Android)
flutter run --flavor alpha

# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## API Requirements

The app expects the following backend endpoints:

### Multiplayer Server (Socket.io)
- WebSocket connection support
- Events: `create-lobby`, `join-lobby`, `leave-lobby`, `start-game`, `make-turn`
- Chat events: `chat-message`, `emoji-reaction`
- Vote events: `vote-skip`
- Voting events: `start-voting`, `vote-game`, `remove-vote`, `end-voting`
- Voting notifications: `voting-started`, `vote-cast`, `voting-update`, `voting-ended`

### REST API (Server-Side Validation)
Authentication:
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `POST /auth/logout` - Logout user

Game Management:
- `GET /lobbies` - Get available lobbies
- `POST /lobbies` - Create lobby
- `GET /lobbies/:id` - Get lobby details
- `GET /games` - Get available games
- `POST /games/:id/submit` - Submit game result (with validation)
- `POST /games/:id/validate-move` - Validate game move

Progression:
- `GET /leaderboard/weekly` - Get weekly leaderboard
- `GET /leaderboard/all-time` - Get all-time leaderboard
- `GET /users/:id` - Get user profile
- `GET /users/:id/progress` - Get user progress

Sync (Offline-First):
- `POST /sync/game` - Sync offline game data
- `POST /sync/progress` - Sync user progress
- `POST /sync/batch` - Batch sync multiple games

Analytics:
- `POST /analytics/track` - Track event
- `GET /ab-test/:name` - Get A/B test variant

## Configuration

Configure the API endpoint in your app:

```dart
// lib/main.dart
final apiService = ApiService(
  baseUrl: 'https://api.mindwars.app', // Your API endpoint
);

// Connect to multiplayer
await multiplayerService.connect(
  'wss://multiplayer.mindwars.app',
  playerId,
);

// Sync offline data (automatic on reconnect)
await offlineService.syncWithServer(
  'https://api.mindwars.app',
  userId,
);
```

## Platform Requirements

### iOS
- iOS 14.0 or higher
- Xcode 14.0 or higher (for development)

### Android
- Android 8.0 (API level 26) or higher
- Android Studio 2022.1+ (for development)
- Gradle 7.5+

## Features Implementation Status

### Epic 1: Authentication & Onboarding ✅
- ✅ User registration and login
- ✅ Profile creation and customization
- ✅ Onboarding flow with tutorial
- ✅ Password validation and security

### Epic 2: Lobby Management & Multiplayer ✅
- ✅ Async multiplayer (2-10 players)
- ✅ Lobby creation and joining
- ✅ Real-time communication via Socket.io
- ✅ Player presence tracking
- ✅ In-game chat with emoji reactions
- ✅ Vote-to-skip mechanics
- ⏳ **Mind War Activity Hub** (Phase 1: Core UI + state management, Phase 2: Full notification system)

### Epic 3: Core Gameplay Experience ✅
- ✅ 15+ games across 5 cognitive categories
- ✅ Game voting system (democratic game selection)
- ✅ Turn-based gameplay
- ✅ Unified scoring system with bonuses
- ✅ Game state persistence
- ✅ Hint system and daily challenges

### Epic 4: Cross-Platform & Reliability ✅ (NEW)
- ✅ **iOS 14+ and Android 8+ (API 26) full support**
- ✅ **Native platform configurations (Info.plist, AndroidManifest.xml)**
- ✅ **Platform service with iOS/Android feature parity**
- ✅ **Responsive UI supporting 5" to 12" screens**
- ✅ **Portrait and landscape orientation support**
- ✅ **Minimum 48dp touch targets (accessibility)**
- ✅ **Enhanced offline mode with turn queue**
- ✅ **Automatic sync on reconnect with conflict resolution**
- ✅ **Offline mode indicator UI with status tracking**
- ✅ **Local puzzle solver for single-player practice**
- ✅ **Material Design 3 (Android) and Human Interface Guidelines (iOS)**

### Progression & Social ✅
- ✅ Progression system (leaderboards, badges, streaks)
- ✅ Weekly and all-time leaderboards
- ✅ 15+ badge achievements
- ✅ Streak tracking with multipliers

### Architecture & Infrastructure Status
- ✅ Offline-first architecture with SQLite
- ✅ Sync queue with retry logic (max 5 retries)
- ✅ Conflict resolution (server wins)
- ⏳ RESTful API with partial server-side validation (score validation implemented; full move validation and public release hardening in progress)
- ⏳ Security-first posture (baseline server-side validation in place; advanced anti-cheating and real-time turn validation in progress)
- ✅ Mobile-first design (5" touch screens scaling to 12" tablets)
- ✅ Analytics instrumentation

## Trust & Legal Compliance

### COPPA & Child Privacy (US Law, Similar Globally)

Mind Wars is compliant with the **Children's Online Privacy Protection Act (COPPA)** and similar child privacy laws (GDPR Article 8, LGPD Article 14, etc.).

**Key Principles:**
- ✅ **No targeting of children under 13** — No ads, behavioral tracking, or data sales
- ✅ **Verifiable parental consent** — Parents explicitly approve child accounts with email verification
- ✅ **Minimal data collection** — Only essential info for gameplay (name, birthday, scores)
- ✅ **Parental access & control** — Parents can view, modify, and delete all child data
- ✅ **Reasonable security** — Encryption, secure storage, regular audits
- ✅ **No third-party sharing** — Child data never shared with advertisers, analytics, or external services

### Why This Matters

1. **Legal Risk** — COPPA violations carry fines of $40,000+ per violation. A single non-consenting child account can create liability for your entire app.
2. **Trust** — Families won't let their kids play an app that spies on them or shows ads. Transparency builds loyalty.
3. **Differentiation** — No major mobile game takes child privacy seriously. Being the "trusted family game" is a rare moat.
4. **Sustainability** — Countries are tightening child privacy laws. Building compliance now = future-proof.

### Implementation Roadmap

**Phase 1 (MVP):**
- [ ] Age verification at signup (ask for child's birthday)
- [ ] Parental consent flow (email verification, checkbox, parent approval required)
- [ ] Child account linking (backend support for parent-child relationships)
- [ ] Child-mode restrictions (children can only see/join family Mind Wars)

**Phase 2 (Beta):**
- [ ] Parental dashboard (view child activity, set time limits, approve connections)
- [ ] Enhanced profanity filter for child accounts
- [ ] Chat logging & moderation (parent visibility, flag inappropriate behavior)
- [ ] Privacy policy & ToS (COPPA-specific language, data handling)

**Phase 3 (Production):**
- [ ] Third-party COPPA audit (e.g., TRUSTe, Privo for official certification)
- [ ] Moderation team training on child safety
- [ ] Data deletion API (parents can request all data deleted)
- [ ] Annual compliance review & policy updates

### Messaging to App Stores

**iOS App Store:**
> "Mind Wars is a family-first cognitive games platform. Children under 13 require parental approval to play. Parents have full visibility into their child's activity, scores, and all communications. No ads, tracking, or external data sharing for child accounts."

**Google Play Store:**
> Same messaging; flag as "Contains ads" only if parents see ads (child accounts exclude). Age rating: PEGI 3 / USK 0 / IARC 3+.

### Compliance Checklist

- **Legal Documents**
  - [ ] COPPA-compliant Privacy Policy (separate section for children)
  - [ ] COPPA-compliant Terms of Service (parental consent language)
  - [ ] Data Processing Agreement (for any processors)
  - [ ] Record of parental consents (audit trail)

- **Technical Implementation**
  - [ ] Age verification at signup
  - [ ] Parental consent mechanism (email + verification)
  - [ ] Child account restrictions enforced server-side
  - [ ] No cookies/tracking for child accounts
  - [ ] No third-party SDKs for analytics/ads on child accounts
  - [ ] Encrypted storage for personally identifiable information (PII)
  - [ ] Data deletion API for parents

- **Product Design**
  - [ ] Parental dashboard
  - [ ] Time limit enforcement
  - [ ] Connection approval workflows
  - [ ] Enhanced profanity filter
  - [ ] Age-appropriate content (all games rated for 6+)

- **Operational**
  - [ ] Moderation team trained on child safety
  - [ ] Process for handling reports of inappropriate behavior
  - [ ] Response plan for potential COPPA violations
  - [ ] Annual privacy & compliance audit

---

## Production Deployment

### Current Status
<!-- [2026-03-13 Documentation] Clarified that the shipped repository baseline differs from the public v1.0 launch requirements and linked the new requirements source of truth. -->
Phase 1 frontend development is complete (✅), including the shipped 15-game catalog, offline-first client flows, and iOS 14+ / Android 8+ support. Backend services (RESTful API, full server-side move validation, and Socket.io multiplayer turn handling) are implemented in an early/stub form and still require production-ready hardening. The March 2026 public-release acceptance baseline now lives in [docs/project/V1_0_RELEASE_REQUIREMENTS.md](docs/project/V1_0_RELEASE_REQUIREMENTS.md); until those launch requirements are met, the repository should be treated as **pre-public-v1.0**. Public v1.0 still requires backend deployment, end-to-end beta validation, and App Store / Play Store release work before launch.

### Cloud Migration Plan
See **[CLOUD_MIGRATION_PLAN.md](docs/project/CLOUD_MIGRATION_PLAN.md)** for comprehensive production deployment strategy:

**Epic 13: Production Cloud Migration** (144 story points, 8 weeks)
- **Phase 1**: Cloud Foundation Setup (Weeks 1-2)
- **Phase 2**: Backend Services Deployment (Weeks 3-4)
- **Phase 3**: Data Migration & Testing (Weeks 5-6)
- **Phase 4**: Production Launch (Weeks 7-8)

**Target Infrastructure**: Google Cloud Platform (GCP) with Firebase
- Cloud Run for API and Socket.io servers
- Cloud Firestore for database
- Firebase Authentication for OAuth
- Redis Memorystore for caching
- Cloud Functions for microservices
- Full monitoring and alerting

**Success Criteria**:
- 99.9% uptime SLA
- API response time < 500ms (p95)
- Support 10,000+ concurrent users
- App Store and Play Store approved

For detailed deployment procedures, architecture diagrams, and migration tasks, see the [Cloud Migration Plan](docs/project/CLOUD_MIGRATION_PLAN.md).

## License

MIT

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

---

Built with ❤️ using Flutter
