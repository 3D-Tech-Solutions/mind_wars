# Mind Wars 🧠⚔️

**Mind Wars** is an async multiplayer cognitive games platform supporting 2-10 players per lobby with cross-platform support for iOS 14+ and Android 8+.

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
- **2-10 players** per lobby
- Turn-based gameplay system
- Real-time lobby management via Socket.io
- Automatic reconnection support
- Player status tracking (active/idle/disconnected)
- Async-first design: players can take turns hours apart

### 📱 Cross-Platform Support
- **iOS 14+** support
- **Android 8+** support
- Feature parity across platforms
- **Flutter** architecture for native performance

### 🎯 Game Variety
**12+ games across 5 cognitive categories:**

#### 🧠 Memory Games
- Memory Match - Match pairs of cards
- Sequence Recall - Remember and reproduce sequences
- Pattern Memory - Recreate visual patterns

#### 🧩 Logic Games
- Sudoku Duel - Competitive Sudoku solving
- Logic Grid - Deductive reasoning puzzles
- Code Breaker - Logical code-breaking challenges

#### 👁️ Attention Games
- Spot the Difference - Find differences quickly
- Color Rush - Match colors under pressure
- Focus Finder - Locate items in cluttered scenes

#### 🗺️ Spatial Games
- Puzzle Race - Complete jigsaw puzzles
- Rotation Master - Mentally rotate procedurally generated 2D/3D/4D wireframes to match the target pose under seeded, multiplayer-validated conditions
- Path Finder - Navigate mazes efficiently

#### 📚 Language Games
- Word Builder - Create words from letters
- Anagram Attack - Solve anagrams quickly
- Vocabulary Showdown - Test vocabulary knowledge

### 💬 Social Features
- **In-game chat** with real-time messaging
- **Emoji reactions** (👍 ❤️ 😂 🎉 🔥 👏 😮 🤔)
- **Vote-to-skip mechanics** for game progression
- **Game voting system** - Players vote on which games to play
  - Configurable points per player
  - Vote across multiple rounds
  - Democratic game selection
- Player presence indicators

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
- **Automatic sync** on reconnect with retry logic
- Sync queue for failed API calls
- Conflict resolution: Server wins for scoring, client preserves user input
- Progress tracking while offline

## Architecture

### Client-Server Model
- **Thin Client**: UI rendering, local game logic validation, offline caching
- **Authoritative Server**: Source of truth for game state, scoring, player matching
- **Rationale**: Prevents cheating; enables cross-device sync

### Offline Resilience
- Games stored locally in SQLite with sync queue
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
- **[USER_PERSONAS.md](docs/business/USER_PERSONAS.md)** - 8 detailed user personas (Family, Friends, Office/Colleagues)
- **[USER_STORIES.md](docs/business/USER_STORIES.md)** - Comprehensive user stories with acceptance criteria
- **[ALPHA_USER_STORIES.md](ALPHA_USER_STORIES.md)** - ⭐ Alpha testing user stories (Epics, Features, Tasks for pre-server testing)
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture and implementation analysis
- **[VALIDATION.md](docs/project/VALIDATION.md)** - Implementation validation checklist
- **[VOTING_SYSTEM.md](VOTING_SYSTEM.md)** - Game voting system documentation
- **[BETA_ADMIN_USER_STORIES.md](docs/project/BETA_ADMIN_USER_STORIES.md)** - ⭐ NEW: Beta testing admin requirements and workflows

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
