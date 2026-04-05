# Mind Wars Multiplayer MVP Roadmap

**Last Updated:** 2026-04-05  
**Scope:** Async Mind Wars multiplayer MVP  
**Status:** Active execution roadmap aligned to current implementation

## Purpose

This document replaces the older Phase 1 planning notes with a roadmap that reflects the actual current codebase state.

It is intended to answer three questions clearly:

1. What is already implemented today?
2. What still must ship for the multiplayer MVP?
3. What are the go/no-go test gates before we move from development into broader validation?

This roadmap assumes the current product model is:

- Mind Wars are async by definition
- players can participate in multiple active Mind Wars simultaneously
- players can only be in one `waiting` planning lobby at a time
- game payloads should be deterministic, resumable, offline-first, and server-verifiable

---

## Current State Snapshot

### Implemented or mostly implemented

#### Multiplayer foundation
- Socket.io multiplayer service exists in [multiplayer_service.dart](/mnt/d/source/3D-Tech-Solutions/mind-wars/lib/services/multiplayer_service.dart)
- Dockerized local backend exists in [backend/docker-compose.yml](/mnt/d/source/3D-Tech-Solutions/mind-wars/backend/docker-compose.yml)
- LAN build/deploy flow exists in [deploy.sh](/mnt/d/source/3D-Tech-Solutions/mind-wars/scripts/deploy.sh)
- async Mind War architecture is documented in [ASYNC_GAME_CONTRACT.md](/mnt/d/source/3D-Tech-Solutions/mind-wars/docs/games/ASYNC_GAME_CONTRACT.md)

#### Lobby lifecycle
- create lobby
- join lobby by id
- join lobby by code
- leave lobby
- close lobby
- kick player
- transfer host
- open-capacity lobby support
- one-planning-lobby / multiple-active-wars rule implemented on backend
- multiplayer hub now has a `my mind wars` direction and bottom action layout in [multiplayer_hub_screen.dart](/mnt/d/source/3D-Tech-Solutions/mind-wars/lib/screens/multiplayer_hub_screen.dart)

#### Chat and presence
- lobby chat
- emoji reactions
- typing indicators
- chat history fetch
- profanity filtering / moderated storage path
- join/leave/system chat notice support

#### Deterministic competitive games
- Rotation Master sealed payload path implemented
- Path Finder sealed payload path implemented
- multiplayer screens can consume deterministic challenge sets

### Implemented but not fully validated

- real-time roster updates across devices
- multi-war hub behavior
- close lobby cleanup behavior
- duplicate display-name handling in shared lobby UI
- chat send/receive flow on physical devices after recent fixes
- cross-device resume flow from the hub

### Still missing or incomplete for MVP

- complete end-to-end multiplayer validation on real devices
- robust “my mind wars” lifecycle for `waiting`, `playing`, `completed`, and `closed`
- recovery and resume guarantees after reconnect/relaunch
- notifications for async play
- consistent server-authoritative validation for every competitive game included in MVP
- explicit compatibility/version gate between app build and backend contract

---

## MVP Definition For Multiplayer

The multiplayer MVP is complete when a user can:

1. Sign in on two or more devices
2. Create a Mind War
3. Join from another device
4. See accurate roster, host, and chat state on all devices
5. Configure and start the round
6. Play included async games from a sealed payload
7. Leave, close, resume, and recover Mind Wars reliably
8. Participate in more than one active Mind War without corrupting local state

The multiplayer MVP is not complete just because lobby creation works once.

---

## MVP Workstreams

## Workstream A: Lobby Reliability

### Goal
Make lobby creation, join, leave, transfer, kick, close, and resume fully reliable across devices and reconnects.

### Current state
- Core handlers exist
- several event payload mismatches were recently fixed
- real device validation is still incomplete

### Remaining implementation tasks
- ensure `player-joined`, `player-left`, `player-kicked`, `host-transferred`, `host-changed`, and `lobby-closed` payloads are consistent everywhere
- ensure closing a lobby removes stale membership state cleanly
- ensure waiting-lobby recovery is explicit and understandable in client UX
- ensure host reassignment is correct when the host leaves a waiting lobby

### Done when
- all lobby events update UI state correctly on every joined device
- no stale waiting lobbies block fresh creation unexpectedly
- closing a lobby removes it from hub and lobby screens without manual refresh hacks

---

## Workstream B: My Mind Wars Hub

### Goal
Make the multiplayer home screen the source of truth for a player’s current async competitions.

### Current state
- hub is being reshaped to list joined Mind Wars
- backend support for `list-my-lobbies` has been added in-progress

### Remaining implementation tasks
- finish and validate `list-my-lobbies`
- show joined wars grouped or labeled by status:
  - `waiting`
  - `playing`
  - `completed`
- ensure tapping a listed war resumes the correct lobby or round
- shrink and pin create/join actions to the bottom once the user has at least one war
- refresh list after create/join/leave/close

### Done when
- a user with one or more active wars sees them immediately on hub load
- a user can resume any listed war from the hub
- create/join actions remain available but no longer dominate the page once wars exist

---

## Workstream C: Chat and Social Presence

### Goal
Make Mind Wars feel like a shared async space instead of isolated screens.

### Current state
- chat backend and client are present
- history, reactions, and typing are implemented
- recent fixes addressed disconnected chat service usage and payload mismatches

### Remaining implementation tasks
- validate chat end-to-end after latest schema and handler fixes
- show reliable system messages for:
  - player joined
  - player left
  - host changed
  - lobby closed
- ensure avatars and duplicate-name formatting are consistent in lobby and chat contexts
- optionally add unread count or last-message preview to the hub later

### Done when
- two devices can exchange chat messages in the same lobby
- system notices appear for join/leave lifecycle changes
- duplicate display names are disambiguated with username where needed

---

## Workstream D: Async Lifecycle and Recovery

### Goal
Make Mind Wars resilient to reconnects, relaunches, and delayed play.

### Current state
- platform architecture is now defined as async/offline-first
- deterministic challenge payloads exist for Rotation Master and Path Finder

### Remaining implementation tasks
- verify reconnect and relaunch behavior for active Mind Wars
- ensure progress state is scoped correctly by `mindWarId + round + game + checksum`
- ensure player can leave the app and reopen without losing war visibility
- define and implement local progress restore expectations per included MVP game

### Done when
- a player can close and reopen the app and still find their active wars
- active game state resumes correctly from stored progress for supported games

---

## Workstream E: Competitive Integrity

### Goal
Ship only multiplayer games whose result integrity matches the async product promise.

### Current state
- Rotation Master sealed payloads implemented
- Path Finder sealed payloads implemented
- Puzzle Race redesign is planned but not yet the same integrity level

### Remaining implementation tasks
- validate server-side result verification paths for included MVP games
- exclude or clearly mark any multiplayer game that still relies on weak client-trust paths
- define the initial competitive MVP game list explicitly

### Done when
- every multiplayer-ranked or fairness-critical MVP game uses sealed payloads plus server validation

---

## Workstream F: Notifications and Time Windows

### Goal
Make async play practical for real users who are not online at the same time.

### Current state
- round model is async
- notification strategy is not yet implemented as a complete MVP feature

### Remaining implementation tasks
- define notification sources:
  - invited to a Mind War
  - player joined your planning lobby
  - voting/selection ready
  - round ready to play
  - round deadline reminder
  - results ready
- implement at least local or in-app notification indicators for MVP if push is not ready
- display round deadline and state clearly in UI

### Done when
- a player can understand what needs attention without manually opening every war

---

## Go / No-Go Gates

These gates are the decision points for moving forward.

## Gate 0: Build Integrity

### Go criteria
- `flutter analyze` passes on touched client multiplayer files
- backend handlers pass `node --check`
- Docker multiplayer stack builds and starts cleanly
- deploy script builds APK and installs to visible devices

### No-go examples
- analyzer errors
- backend syntax failures
- broken Docker rebuild
- install/build scripts failing on connected test devices

---

## Gate 1: Core Lobby Flow

### Test scenario
Two physical devices on LAN:
- Device A creates a Mind War
- Device B joins by code
- both devices show correct roster and host
- chat works
- leave and rejoin work

### Go criteria
- player count updates on both devices
- display names and avatars render correctly
- join/leave notifications appear
- chat messages deliver successfully on both devices

### No-go criteria
- stale `0/x` roster state
- join succeeds but roster does not update
- chat fails or only works one way
- host or player state diverges between devices

---

## Gate 2: Lobby Administration

### Test scenario
Two devices:
- host updates settings
- host transfers host
- host kicks a player
- host closes the lobby

### Go criteria
- all admin actions reflect across devices
- closed lobbies disappear from active views
- kicked player is removed cleanly
- host transfer updates UI and control ownership

### No-go criteria
- admin action succeeds on server but not in UI
- closed lobbies remain resumable
- kicked player still appears active
- host controls remain assigned to old host

---

## Gate 3: Multi-War Participation

### Test scenario
Single user account:
- create or join a first Mind War
- create or join another active Mind War after the first has moved out of planning
- confirm hub shows both active wars
- resume each from hub

### Go criteria
- multiple active wars appear correctly on hub
- one waiting-lobby-only rule is enforced correctly
- no progress or identity leakage between wars

### No-go criteria
- active wars overwrite each other
- hub loses one war after joining another
- planning-lobby rule blocks valid multi-war participation

---

## Gate 4: Async Resume

### Test scenario
- join a war
- exit app
- relaunch
- reconnect on same device
- resume from hub

### Go criteria
- war still appears
- lobby or game resumes correctly
- no duplicate membership rows are created

### No-go criteria
- war disappears after relaunch
- relaunch creates inconsistent lobby state
- user must manually reconstruct state or rejoin incorrectly

---

## Gate 5: Competitive Game Integrity

### Test scenario
Use included multiplayer MVP games.

### Go criteria
- sealed payload delivered consistently
- all players receive the same challenge
- server verifies the result path for each included game

### No-go criteria
- clients generate divergent puzzles
- game outcome depends on unverified client trust

---

## Recommended Development Order

1. Finish lobby/admin event consistency
2. Finish and validate `my mind wars` hub
3. Run physical-device Gate 1 and Gate 2 tests
4. Validate multi-war participation and hub resume
5. Validate async resume/relaunch behavior
6. Lock initial MVP multiplayer game list to games with sealed payload support
7. Add minimal notification/time-window UX
8. Re-test full flow before broader beta

---

## Current Recommended MVP Game Set

### Safe to keep in multiplayer validation path
- Rotation Master
- Path Finder

### Do not treat as integrity-complete multiplayer MVP until upgraded
- Puzzle Race
- any other game still using weak client-side trust or non-sealed payloads

---

## Test Execution Checklist

### Development checks
- [ ] `flutter analyze`
- [ ] focused Flutter tests for touched deterministic engines
- [ ] `node --check` for touched backend handlers
- [ ] Docker rebuild succeeds
- [ ] APK deploy succeeds on connected devices

### Manual multiplayer checks
- [ ] create lobby
- [ ] join lobby by code
- [ ] roster updates on both devices
- [ ] chat message send/receive
- [ ] typing / reaction / system notices
- [ ] transfer host
- [ ] kick player
- [ ] close lobby
- [ ] hub lists joined wars
- [ ] resume listed war from hub
- [ ] multiple active wars visible for one user where valid
- [ ] relaunch app and resume existing war

### Competitive integrity checks
- [ ] same puzzle payload on all devices
- [ ] server validates submitted result
- [ ] no score accepted from tampered or mismatched payload

---

## Out of Scope For This MVP Pass

- voice chat
- tournaments
- rich friend graph
- advanced analytics dashboards
- full backend extraction to separate repository
- Puzzle Race full sealed jigsaw system unless promoted into MVP scope later

---

## Definition of MVP Go

The multiplayer MVP is a go when all of the following are true:

- Gate 0 through Gate 4 pass on real devices
- at least one sealed-payload multiplayer game is validated end-to-end
- hub accurately represents active Mind Wars
- players can create, join, leave, close, and resume wars reliably
- multi-war participation behaves correctly for active wars

If any of those fail, multiplayer remains in development validation mode rather than MVP-ready.
