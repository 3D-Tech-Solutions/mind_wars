# Mind War Admin Pipeline - Phase 1 Implementation Roadmap

**Last Updated:** 2026-04-04

## Current State Assessment

### ✅ Already Implemented
1. **LobbyCreationScreen** (`lib/screens/lobby_creation_screen.dart`)
   - Lobby name input (3-50 chars)
   - Private/public toggle
   - Number of rounds slider (1-10)
   - Voting points slider (5-20)
   - Calls `multiplayerService.createLobby()`
   - **Gap:** No game type, difficulty, or hint policy config

2. **LobbyManagementScreen** (`lib/screens/lobby_screen.dart`)
   - Player list display
   - Real-time player join/leave events
   - Typing indicators
   - Host transfer capability
   - Player kick capability (from code)
   - Chat integration ready
   - Game voting screen integration
   - **Gap:** No config locking, no start confirmation, no ranked toggle

3. **GameLobby Model** (`lib/models/models.dart`)
   - Basic fields: id, name, hostId, players, maxPlayers, status
   - Lobby code generation
   - Private/public flag
   - numberOfRounds, votingPointsPerPlayer
   - skipRule, skipTimeLimitHours
   - currentGame reference
   - Timestamps: createdAt
   - **Gap:** No MindWarConfiguration, no startedAt, no completedAt, no finalResults

4. **SkipRule Enum** (in models.dart)
   - majority, unanimous, time_based options already exist

### ⚠️ Needs Enhancement/Creation

#### Models (lib/models/models.dart)

**1. MindWarConfiguration Class (NEW)**
```dart
enum Difficulty { easy, medium, hard }
enum HintPolicy { disabled, enabled, custom }
enum ScoringMode { accuracy, speed, balanced }

class MindWarConfiguration {
  final String gameId;
  final Difficulty difficulty;
  final HintPolicy hintPolicy;
  final bool isRanked;
  final int? guessCap;
  final bool includeTimeInScore;
  final ScoringMode scoringMode;
  final Map<String, dynamic> gameSpecificConfig;
  final DateTime lockedAt;
  final String payloadVersion;
  
  // toJson, fromJson, copyWith...
}
```

**2. Extend GameLobby Model**
- Add `MindWarConfiguration? configuration;` (null until locked)
- Add `DateTime? startedAt;`
- Add `DateTime? completedAt;`
- Add `List<MindWarResult>? finalResults;`
- Add `Map<String, int>? finalScores;`

**3. MindWarResult Class (NEW)**
```dart
class MindWarResult {
  final String mindWarId;
  final String playerId;
  final String playerUsername;
  final int placement;
  final int finalScore;
  final Map<String, dynamic> gameMetrics;
  final bool isRanked;
  final DateTime completedAt;
  // toJson, fromJson, copyWith...
}
```

---

#### Screens

**1. MindWarConfigurationModal (NEW)**
- File: `lib/screens/mind_war_configuration_modal.dart`
- Purpose: Allow host to select game type, difficulty, hint policy, ranked status
- Inputs:
  - Game type dropdown (pull from GameCatalog)
  - Difficulty radio (Easy/Medium/Hard)
  - Hint policy radio (Disabled/Enabled/Custom)
  - Custom hints checkboxes (game-dependent)
  - Ranked toggle
  - Scoring mode dropdown (optional)
- Outputs: `MindWarConfiguration` object
- Called from: `LobbyManagementScreen._configureGame()`

**2. StartMindWarConfirmationModal (NEW)**
- File: `lib/screens/start_mind_war_confirmation_modal.dart`
- Purpose: Final confirmation before locking rules immutably
- Displays: Config summary (game, difficulty, hint policy, ranked flag, player count)
- Warning text: "Once started, these rules cannot be changed"
- Action: "Start Mind War" (destructive button)
- Called from: `LobbyManagementScreen._startMindWar()`
- On confirm: Calls `multiplayerService.startMindWar(lobbyId, config)`

**3. Enhance LobbyManagementScreen**
- File: `lib/screens/lobby_screen.dart`
- Add new sections:
  - **Configuration Panel** (if config not locked):
    - Game type display (or dropdown to change if not locked)
    - Edit difficulty button → modal
    - Edit hint policy button → modal
    - Ranked toggle
    - "Save Configuration" button (doesn't lock yet)
  - **Host-only Controls**:
    - "Lock & Start Mind War" button (when config valid & min 2 players ready)
    - "Configure More" button → opens `MindWarConfigurationModal`
    - "Kick Player" button per player
    - "Transfer Host" button (optional)
  - **Status Indicators**:
    - Show "Configuration Complete" or "needs configuration" badge
    - Show "Ready to Start" or "Waiting for ..." message

---

#### Services

**1. Enhance MultiplayerService** (`lib/services/multiplayer_service.dart`)
- New methods:
  - `Future<void> saveConfiguration(String lobbyId, MindWarConfiguration config)` 
    - Emits 'config-updated' event to all players
  - `Future<void> startMindWar(String lobbyId, MindWarConfiguration config)` 
    - Locks configuration immutably on server
    - Distributes battle payload to all players
    - Sets lobby.status = 'in-progress'
    - Sets lobby.startedAt = now
    - Emits 'mind-war-started' event
  - Add property: `MindWarConfiguration? get currentConfig` 
    - Returns locked config from currentLobby if available

**2. Enhance MultiplayerService Event Listeners**
- Add listener for 'config-updated' event
- Add listener for 'mind-war-started' event
- Add listener for 'configuration-locked' event

---

#### Routes (lib/main.dart)

- Already has `/lobby` route
- May need enhancement to pass configuration state through arguments if not stored in service

---

## Implementation Sequence (Recommended Order)

### Phase 1a: Models (Update + New Classes)
1. Add `MindWarConfiguration` class to models.dart
2. Add `MindWarResult` class to models.dart
3. Extend `GameLobby` with new fields (configuration, startedAt, completedAt, finalResults, finalScores)
4. Add `Difficulty`, `HintPolicy`, `ScoringMode` enums
5. Update `GameLobby.toJson/fromJson/copyWith` to include new fields
6. **Compile & validate**

### Phase 1b: Service Methods
1. Add `saveConfiguration()` method to `MultiplayerService`
2. Add `startMindWar()` method to `MultiplayerService`
3. Add event listeners for config/start events
4. Add `currentConfig` getter
5. **Validate compiles**

### Phase 1c: UI Screens
1. Create `MindWarConfigurationModal` with game/difficulty/hint selection
2. Create `StartMindWarConfirmationModal` with summary & confirmation
3. Enhance `LobbyManagementScreen` with:
   - Config panel (game type, difficulty, hints, ranked toggle)
   - Host-only "Lock & Start" button
   - "Configure More" button linking to modal
   - Status badges
4. **Compile & test**

### Phase 1d: Integration Testing
1. Test end-to-end on Android devices:
   - Host creates lobby with game/difficulty config
   - Players see config summary
   - Host clicks "Lock & Start Mind War"
   - All players transition to next screen (turn management)
   - Config is immutable on client (can't edit after start)

---

## API Integration Points (Backend Expectations)

These backend endpoints/events must exist or be implemented:

1. **Socket.io Event**: `lock-and-start-mind-war`
   - Payload: `{lobbyId, configuration, payloadVersion}`
   - Server response: Confirms lock, distributes battle payload to all players
   - Emits: `mind-war-started` to all players

2. **Socket.io Event (Server → Client)**: `mind-war-started`
   - Payload: `{lobbyId, configuration, battlePayload, turnOrder}`
   - Client receives battle payload (game content locked)

3. **RESTful Endpoint** (Optional): `POST /api/lobbies/{lobbyId}/lock-config`
   - Request: `{ configuration: MindWarConfiguration }`
   - Response: `{ success: true, battlePayload: {...} }`

---

## Compile Checks & Validation

After each phase:
- [ ] `flutter analyze` passes (no errors)
- [ ] `flutter build apk --flavor alpha` succeeds
- [ ] No unused imports
- [ ] All model serialization round-trips: `Model.fromJson(model.toJson())`
- [ ] Service methods typed correctly (no dynamic where not needed)

---

## File Checklist for Phase 1

### Modify (Existing Files)
- [ ] `lib/models/models.dart` - Add new models/enums and extend GameLobby
- [ ] `lib/services/multiplayer_service.dart` - Add 3 new methods + event listeners
- [ ] `lib/screens/lobby_screen.dart` - Add config panel, host controls, status badges

### Create (New Files)
- [ ] `lib/screens/mind_war_configuration_modal.dart` - Game/difficulty/hint selection
- [ ] `lib/screens/start_mind_war_confirmation_modal.dart` - Final confirmation UI

### Test (Unchanged but Verify)
- [ ] `lib/screens/lobby_creation_screen.dart` - Works with new lobby model
- [ ] `lib/main.dart` - Routes still wire correctly
- [ ] `lib/services/game_catalog.dart` - Game list available for dropdown
