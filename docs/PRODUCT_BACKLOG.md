# Mind Wars - Product Backlog 📋

## Document Purpose

This document provides a prioritized, actionable backlog of work for the Mind Wars mobile application development. It is organized by priority levels and development phases, with clear links to user personas and their needs.

**Last Updated**: November 12, 2025  
**Version**: 1.2  
**Status**: Phase 1 Complete ✅ | Phase 2 Planning | Beta Testing Architecture Defined

---

## Table of Contents

1. [Phase 1 Review Status](#phase-1-review-status-)
2. [Backlog Overview](#backlog-overview)
3. [Priority Definitions](#priority-definitions)
4. [Development Phases](#development-phases)
5. [Phase 1: MVP - Core Experience (Months 1-2)](#phase-1-mvp---core-experience-months-1-2)
6. [Phase 2: Social & Progression (Months 3-4)](#phase-2-social--progression-months-3-4)
7. [Phase 3: Polish & Scale (Months 5-6)](#phase-3-polish--scale-months-5-6)
8. [Beta Testing Phase: Server Infrastructure (Parallel to Phase 2-3)](#beta-testing-phase-server-infrastructure-parallel-to-phase-2-3)
9. [Phase 4: Advanced Features (Future)](#phase-4-advanced-features-future)
10. [MoSCoW Tagging](#moscow-tagging)
11. [Final Recommendations](#final-recommendations)
12. [Backlog Grooming Guidelines](#backlog-grooming-guidelines)
13. [Sprint Planning Recommendations](#sprint-planning-recommendations)

---

## Phase 1 Review Status ✅

**Completion Date**: November 10, 2025  
**Status**: ✅ PRODUCTION READY  
**Duration**: 8 weeks (as planned)

### Phase 1 Achievement Summary

| Epic | Story Points | Status | Completion |
|------|--------------|--------|------------|
| Epic 1: Authentication & Onboarding | 34 | ✅ COMPLETE | 100% |
| Epic 2: Lobby Management & Multiplayer | 47 | ✅ COMPLETE | 100% |
| Epic 3: Core Gameplay Experience | 55 | ✅ COMPLETE | 100% |
| Epic 4: Cross-Platform & Reliability | 48 | ✅ COMPLETE | 100% |
| **TOTAL** | **183** | **✅ COMPLETE** | **100%** |

### Key Deliverables Completed
- ✅ **15 games** across 5 cognitive categories (Memory, Logic, Attention, Spatial, Language)
- ✅ **Full authentication system** with JWT, registration, login, and profile setup
- ✅ **Complete multiplayer lobby system** with Socket.io integration
- ✅ **Turn-based gameplay** with server validation and unified scoring
- ✅ **iOS 14+ and Android 8+ support** with responsive UI (5"-12" screens)
- ✅ **Robust offline mode** with SQLite persistence and automatic sync
- ✅ **126 tests** with 100% pass rate across all epics
- ✅ **~18,100 lines of production code** ready for deployment

### Documentation Delivered
- ✅ [PHASE_1_COMPLETE.md](docs/project/PHASE_1_COMPLETE.md) - Complete achievement summary
- ✅ [PROJECT_STATUS.md](docs/project/PROJECT_STATUS.md) - Detailed status report
- ✅ [EPICS_1-4_VERIFICATION.md](docs/project/EPICS_1-4_VERIFICATION.md) - Code verification report
- ✅ Epic implementation summaries for all 4 epics

### Next Steps
**Phase 2** (Social & Progression) is now ready to begin with estimated duration of 5-6 weeks (3 sprints) to deliver 112 story points.

---

## Backlog Overview

### Core Philosophy
Mind Wars is designed for private group competitions called **"Mind Wars"** - multi-game, multi-round, async competitions between specific groups:
1. **Family Mind Wars**: Multi-generational family competitions (Grade 6+, ages 11-70+)
2. **Friends Mind Wars**: Social competitions with close friends
3. **Office/Colleagues Mind Wars**: Team-building and competitive challenges at work
4. **Mixed Mind Wars**: Any combination of family, friends, and colleagues

### Key Personas (8 Total)
1. **The Competitive Sibling** (Alex, 24) - Family rivalry & bragging rights
2. **The Family Connector** (Maria, 42) - Extended family bonding
3. **The Grandparent Gamer** (Dr. James, 68) - Intergenerational connection & cognitive health
4. **The Parent-Child Bond Builder** (Sarah, 38) - Quality time across schedules
5. **The Teen Squad Leader** (Emma, 16) - Friend groups & family games
6. **The Middle Schooler** (Jordan, 12) - Cousin groups & skill building
7. **The Friend Circle Competitor** (Marcus, 28) - Friends staying connected
8. **The Office Team Builder** (Jennifer, 35) - Team-building & morale

### Backlog Statistics
- **Total Epics**: 13 (9 active in Phases 1-3, 3 future, 1 cloud migration)
- **Total Features**: 53+ (35 in Phases 1-3, 13 in Cloud Migration, 5+ future)
- **Total Tasks**: 190+ (150+ app development, 40+ cloud migration)
- **Total Story Points**: 529 (Phase 1: 183, Phase 2: 112, Phase 3: 90, Cloud Migration: 144)
- **Estimated MVP Duration**: 2-2.5 months (Phase 1)
- **Estimated Full v1.0**: 5-6 months (Phases 1-3)
- **Estimated Production Launch**: 7-8 months (including Cloud Migration)

---

## Priority Definitions

### Priority Levels

**P0 - Critical (Launch Blockers)**
- Must have for initial launch
- Blocks other high-priority work
- Core user flows depend on it
- Affects all personas

**P1 - High (Launch Important)**
- Important for launch quality
- Enhances core value proposition
- Affects majority of personas
- Should be in MVP if possible

**P2 - Medium (Post-Launch)**
- Nice to have for launch
- Enhances user experience
- Affects specific personas
- Can be delivered after MVP

**P3 - Low (Future Enhancement)**
- Future improvement
- Optimization or polish
- Affects niche use cases
- Backlog for later phases

### Story Point Scale (Fibonacci)
- **1 point**: Trivial change (< 2 hours)
- **2 points**: Simple task (2-4 hours)
- **3 points**: Small feature (1 day)
- **5 points**: Medium feature (2-3 days)
- **8 points**: Large feature (1 week)
- **13 points**: Complex feature (2 weeks)
- **21 points**: Epic-level work (break down further)

---

## Development Phases

### Phase 1: MVP - Core Experience (Months 1-2) ✅
**Goal**: Launch-ready core multiplayer cognitive games platform with offline support  
**Team Velocity Target**: 40-50 story points per 2-week sprint  
**Total Story Points**: 183 points  
**MoSCoW**: Must Have  
**Status**: COMPLETE ✅

### Phase 2: Social & Progression (Months 3-4)
**Goal**: Rich social experience with retention hooks and enhanced scoring  
**Team Velocity Target**: 40-50 story points per 2-week sprint  
**Total Story Points**: 112 points  
**MoSCoW**: Should Have

### Phase 3: Polish & Scale (Months 5-6)
**Goal**: Production-grade reliability, analytics, and optimization  
**Team Velocity Target**: 40-50 story points per 2-week sprint  
**Total Story Points**: 90 points  
**MoSCoW**: Could Have

### Phase 4: Production Cloud Migration (Months 7-8)
**Goal**: Deploy to production cloud infrastructure and launch to users  
**Team Velocity Target**: 35-40 story points per 2-week sprint  
**Total Story Points**: 144 points  
**MoSCoW**: Should Have (for production launch)  
**Documentation**: [CLOUD_MIGRATION_PLAN.md](docs/project/CLOUD_MIGRATION_PLAN.md)

**Migration Phases**:
- Weeks 1-2: Cloud Foundation Setup (34 pts)
- Weeks 3-4: Backend Services Deployment (42 pts)
- Weeks 5-6: Data Migration & Testing (34 pts)
- Weeks 7-8: Production Launch (34 pts)

### Phase 5: Advanced Features (Future)
**Goal**: Competitive differentiation and scaling  
**MoSCoW**: Won't Have (Post-Launch)  
**Total Story Points**: TBD

---

## Phase 1: MVP - Core Experience (Months 1-2)

### Epic 1: User Onboarding & Authentication
**Epic Priority**: P0 - Critical  
**Business Value**: Enable user acquisition and secure account management  
**Personas**: All personas  
**Epic Story Points**: 34 points

#### Feature 1.1: User Registration ⭐ P0
**Story**: As a new user, I want to quickly create an account so that I can start playing Mind Wars

**Story Points**: 8  
**Acceptance Criteria**:
- User can register with email and password
- Email validation is performed
- Password meets security requirements (8+ chars, mixed case, numbers)
- Account creation takes < 60 seconds
- User receives confirmation email

**Tasks**:
- [x] **Task 1.1.1**: Implement registration API endpoint (3 pts) ✅
  - Server-side validation of email format
  - Password strength validation
  - Check for duplicate emails
  - Generate JWT token on success
  
- [x] **Task 1.1.2**: Create registration UI screen (3 pts) ✅
  - Email input field with validation
  - Password input with strength indicator
  - Confirm password field
  - Register button with loading state
  
- [x] **Task 1.1.3**: Implement client-side validation (1 pt) ✅
  - Real-time email format validation
  - Password strength meter
  - Form validation before submission
  
- [x] **Task 1.1.4**: Add error handling (1 pt) ✅
  - Display server error messages
  - Network error retry logic

#### Feature 1.2: User Login ⭐ P0
**Story**: As a returning user, I want to securely log into my account so that I can access my game progress and data

**Story Points**: 5  
**Acceptance Criteria**:
- User can login with email/password
- JWT token is stored securely
- Auto-login on app relaunch (if enabled)
- Login takes < 5 seconds

**Tasks**:
- [x] **Task 1.2.1**: Implement login API endpoint (2 pts) ✅
- [x] **Task 1.2.2**: Create login UI screen (2 pts) ✅
- [x] **Task 1.2.3**: Implement secure token storage (1 pt) ✅

#### Feature 1.3: Onboarding Tutorial ⭐ P1
**Story**: As a new user, I want a quick tutorial so that I understand how to play Mind Wars

**Story Points**: 13  
**Personas**: Especially important for Grandparent Gamer, Parent-Child Builder  
**Acceptance Criteria**:
- Tutorial is shown only once for new users
- Tutorial can be skipped
- Tutorial covers: lobby creation, game selection, taking turns, chat
- Tutorial takes < 2 minutes

**Tasks**:
- [x] **Task 1.3.1**: Design tutorial flow (3 pts) ✅
- [x] **Task 1.3.2**: Implement tutorial UI (5 pts) ✅
- [x] **Task 1.3.3**: Add tutorial state management (2 pts) ✅
- [x] **Task 1.3.4**: Create interactive demo (3 pts) ✅

#### Feature 1.4: Profile Setup ⭐ P1
**Story**: As a new user, I want to set up my profile so that I can personalize my gaming experience

**Story Points**: 8  
**Personas**: Especially important for Middle Schooler, Teen Squad Leader  
**Acceptance Criteria**:
- User can set display name
- User can choose avatar (from preset options)
- Profile is visible to other players
- Changes sync across devices

**Tasks**:
- [x] **Task 1.4.1**: Create profile setup UI (3 pts) ✅
- [x] **Task 1.4.2**: Implement profile API endpoints (2 pts) ✅
- [x] **Task 1.4.3**: Add profile validation (2 pts) ✅
- [x] **Task 1.4.4**: Implement profile sync (1 pt) ✅

---

### Epic 2: Game Lobby & Multiplayer Management
**Epic Priority**: P0 - Critical  
**Business Value**: Core multiplayer experience driving engagement  
**Personas**: All personas  
**Epic Story Points**: 47 points

#### Feature 2.1: Lobby Creation ⭐ P0
**Story**: As a user, I want to create a private game lobby so that I can invite family and friends to play together

**Story Points**: 13  
**Personas**: Critical for all "Mind War" organizers (Family Connector, Friend Circle Competitor, Office Team Builder)  
**Acceptance Criteria**:
- User can create lobby with 2-10 players
- Lobby has unique shareable code for easy family invites
- Creator is designated as host
- Private lobbies are default (public is optional)
- Easy sharing of lobby code via family group chats

**Tasks**:
- [x] **Task 2.1.1**: Implement lobby creation API (3 pts) ✅
  - Generate memorable lobby code (e.g., "FAMILY42")
  - Default to private lobby
  - Return shareable lobby details
  
- [x] **Task 2.1.2**: Create lobby creation UI (5 pts) ✅
  - Max players selector (2-10)
  - Lobby name input (e.g., "Smith Family Game Night")
  - Privacy toggle: Private (default) / Public (optional)
  - Prominent display of lobby code
  - "Share Code" button for messaging apps
  
- [x] **Task 2.1.3**: Implement Socket.io connection (3 pts) ✅
  - Connect to multiplayer server
  - Emit `create-lobby` event
  - Handle connection errors
  
- [x] **Task 2.1.4**: Add lobby configuration options (2 pts) ✅
  - Number of rounds selector
  - Voting points per player

#### Feature 2.2: Lobby Discovery & Joining ⭐ P0
**Story**: As a user, I want to find and join lobbies so that I can play with family/friends or explore public games

**Story Points**: 13  
**Acceptance Criteria**:
- User can join private lobbies via invite code (primary use case)
- User can view list of public lobbies (alternative/optional)
- User can search lobbies by code
- Real-time updates of lobby status
- Private/family lobbies are prominent

**Tasks**:
- [x] **Task 2.2.1**: Implement lobby list API (3 pts) ✅
  - Filter by status and privacy
  - Prioritize private lobby joining via code
  
- [x] **Task 2.2.2**: Create lobby browser UI (5 pts) ✅
  - Prominent "Join with Code" input
  - Optional public lobby list (secondary section)
  - Scrollable list of lobbies
  
- [x] **Task 2.2.3**: Implement join lobby functionality (3 pts) ✅
  - Emit `join-lobby` Socket.io event
  - Validate lobby capacity
  
- [x] **Task 2.2.4**: Add real-time lobby updates (2 pts) ✅
  - Listen for player-joined/left events

#### Feature 2.3: Lobby Management ⭐ P0
**Story**: As a lobby host, I want to manage my lobby so that I can control the game experience

**Story Points**: 13  
**Personas**: Critical for Family Connector, Friend Circle Competitor, Office Team Builder  
**Acceptance Criteria**:
- Host can start the game when ready
- Host can kick players if needed
- Host can change lobby settings
- Host can close the lobby
- Host role can be transferred

**Tasks**:
- [x] **Task 2.3.1**: Implement lobby management APIs (3 pts) ✅
- [x] **Task 2.3.2**: Create host controls UI (5 pts) ✅
- [x] **Task 2.3.3**: Implement lobby state management (3 pts) ✅
- [x] **Task 2.3.4**: Add Socket.io events (2 pts) ✅

#### Feature 2.4: Player Presence & Status ⭐ P1
**Story**: As a player, I want to see who is online and active so that I know who I'm playing with

**Story Points**: 8  
**Personas**: Especially important for Family Connector, Office Team Builder  
**Acceptance Criteria**:
- Players show as active/idle/disconnected
- Real-time status updates
- Last seen timestamp for offline players
- Active turn indicator
- Typing indicators in chat

**Tasks**:
- [x] **Task 2.4.1**: Implement presence tracking (3 pts) ✅
- [x] **Task 2.4.2**: Create presence UI components (2 pts) ✅
- [x] **Task 2.4.3**: Add real-time presence updates (2 pts) ✅
- [x] **Task 2.4.4**: Implement typing indicators (1 pt) ✅

---

### Epic 3: Core Gameplay Experience
**Epic Priority**: P0 - Critical  
**Business Value**: Core product value proposition  
**Personas**: All personas  
**Epic Story Points**: 55 points

#### Feature 3.1: Game Catalog & Selection ⭐ P0
**Story**: As a player, I want to choose from a variety of cognitive games so that I can enjoy diverse challenges

**Story Points**: 13  
**Personas**: All personas, especially important for multi-generational play  
**Acceptance Criteria**:
- 12+ games available across 5 categories
- Games organized by cognitive category
- Game descriptions and rules available
- Difficulty indicators shown
- Games suitable for current player count

**Tasks**:
- [x] **Task 3.1.1**: Implement game catalog system (COMPLETED ✅)
- [x] **Task 3.1.2**: Create game selection UI (5 pts) ✅
- [x] **Task 3.1.3**: Implement game filtering (3 pts) ✅
- [x] **Task 3.1.4**: Add game preview/demo (3 pts) ✅

#### Feature 3.2: Democratic Game Voting ⭐ P0
**Story**: As a player, I want to vote on which games to play so that everyone enjoys the session

**Story Points**: 13  
**Personas**: Critical for Family Connector, Office Team Builder - ensures inclusive experience  
**Acceptance Criteria**:
- Players receive voting points (configurable by host)
- Can allocate points across multiple games
- Can change votes before voting ends
- Top voted games are selected
- Real-time vote count updates

**Tasks**:
- [x] **Task 3.2.1**: Implement voting service (COMPLETED ✅)
- [x] **Task 3.2.2**: Create voting UI with point allocation (5 pts) ✅
- [x] **Task 3.2.3**: Add voting Socket.io events (3 pts) ✅
- [x] **Task 3.2.4**: Implement multi-round voting logic (3 pts) ✅

#### Feature 3.3: Turn-Based Gameplay ⭐ P0
**Story**: As a player, I want to take my turn when convenient so that I can play on my schedule

**Story Points**: 13  
**Personas**: Critical for Parent-Child Builder, Friend Circle Competitor - async is core value  
**Acceptance Criteria**:
- Clear indication of whose turn it is
- Turn can be taken anytime (async)
- Turn data validated server-side
- Other players notified of turn completion
- Turn history visible

**Tasks**:
- [x] **Task 3.3.1**: Implement turn management system (5 pts) ✅
- [x] **Task 3.3.2**: Create turn UI components (3 pts) ✅
- [x] **Task 3.3.3**: Add server-side turn validation (3 pts) ✅
- [x] **Task 3.3.4**: Implement turn notifications (2 pts) ✅

#### Feature 3.4: Game Scoring System ⭐ P0
**Story**: As a player, I want fair and transparent scoring so that I know how I'm performing

**Story Points**: 8  
**Personas**: Critical for Competitive Sibling - prevents cheating  
**Acceptance Criteria**:
- Unified scoring system across all games
- Base score + time bonus + accuracy
- Streak multipliers applied (up to 2.0x)
- Server-side score calculation
- Real-time score updates

**Tasks**:
- [x] **Task 3.4.1**: Implement unified scoring algorithm (COMPLETED ✅)
- [x] **Task 3.4.2**: Create scoring API (3 pts) ✅
- [x] **Task 3.4.3**: Design score display UI (3 pts) ✅
- [x] **Task 3.4.4**: Add anti-cheating validation (2 pts) ✅

#### Feature 3.5: Game State Management ⭐ P1
**Story**: As a player, I want my game state saved automatically so that I can resume anytime

**Story Points**: 8  
**Personas**: Important for Parent-Child Builder - resume across interruptions  
**Acceptance Criteria**:
- Game state saved after each action
- State persists across app restarts
- Synchronized across devices
- Handles offline state changes
- Conflict resolution (server wins)

**Tasks**:
- [x] **Task 3.5.1**: Implement game state models (2 pts) ✅
- [x] **Task 3.5.2**: Create state persistence in SQLite (3 pts) ✅
- [x] **Task 3.5.3**: Implement state synchronization (2 pts) ✅
- [x] **Task 3.5.4**: Add state recovery (1 pt) ✅

#### Feature 3.6: Game Content Seed ⭐ P0
**Story**: As a player, I want 12+ launch games so MVP is playable

**Story Points**: 13  
**MoSCoW**: Must  
**Acceptance Criteria**:
- 3 Word, 3 Logic, 3 Math, 3 Puzzle games ready
- Local generation for offline play
- Difficulty tiers (Easy, Medium, Hard)
- Games validated and tested

**Tasks**:
- [x] **Task 3.6.1**: Generate 12 puzzles across categories (5 pts) `[TDD §5.2]` ✅
- [x] **Task 3.6.2**: Implement hint system with penalties (5 pts) ✅
- [x] **Task 3.6.3**: Add daily challenge rotation (3 pts) ✅

---

### Epic 4: Cross-Platform & Reliability
**Epic Priority**: P0 - Critical  
**Business Value**: Market reach, reliability, and offline support  
**MoSCoW**: Must  
**Personas**: All personas - mixed device families/groups  
**Epic Story Points**: 48 points  
*(Replaces old Epic 7 + parts of 6)*

#### Feature 4.1: iOS/Android Parity ⭐ P0
**Story**: As a user, I want full feature parity across iOS and Android so that I get the complete Mind Wars experience on any device

**Story Points**: 26 points (13 iOS + 13 Android)  
**MoSCoW**: Must  
**Acceptance Criteria**:
- iOS supports 14.0+, Android supports 8.0+ (API 26)
- Native platform design patterns (iOS: Human Interface Guidelines, Android: Material Design 3)
- Platform-specific optimizations
- App Store and Google Play compliant
- No feature gaps between platforms
- Cross-platform multiplayer works seamlessly

**Tasks**:
- [x] **Task 4.1.1**: Configure iOS build and deployment (2 pts) ✅
- [x] **Task 4.1.2**: Implement iOS-specific features and optimizations (5 pts) ✅
- [x] **Task 4.1.3**: Optimize for iOS devices and prepare for App Store (3 pts) ✅
- [x] **Task 4.1.4**: Configure Android build and deployment (2 pts) ✅
- [x] **Task 4.1.5**: Implement Android-specific features and optimizations (5 pts) ✅
- [x] **Task 4.1.6**: Optimize for Android fragmentation and prepare for Google Play (3 pts) ✅
- [x] **Task 4.1.7**: Test cross-platform compatibility (3 pts) ✅

#### Feature 4.2: Responsive UI ⭐ P1
**Story**: As a player, I want the app to work well on different screen sizes so that I have a good experience

**Story Points**: 8  
**MoSCoW**: Must  
**Personas**: Critical for Grandparent Gamer (accessibility), multi-device families  
**Acceptance Criteria**:
- Supports 5" to 12" screens
- Portrait and landscape modes
- Tablet-optimized layouts
- Minimum 48dp touch targets
- Adaptive font sizes

**Tasks**:
- [x] **Task 4.2.1**: Implement responsive layouts (3 pts) ✅
- [x] **Task 4.2.2**: Test on various device sizes (2 pts) ✅
- [x] **Task 4.2.3**: Optimize touch targets (2 pts) ✅
- [x] **Task 4.2.4**: Handle orientation changes (1 pt) ✅

#### Feature 4.3: Offline Core ⭐ P1
**Story**: As a player, I want core turns to work offline so that I can play without reliable internet

**Story Points**: 14  
**MoSCoW**: Must  
**Acceptance Criteria**:
- Queue moves locally when offline
- Sync automatically on reconnect
- Conflict resolution: server wins
- Offline indicator clearly visible
- Local puzzle solver for single-player practice

**Tasks**:
- [x] **Task 4.3.1**: Implement SQLite turn queue (5 pts) ✅
- [x] **Task 4.3.2**: Add sync on reconnect with conflict resolution (3 pts) ✅
- [x] **Task 4.3.3**: Create offline mode indicator UI (3 pts) ✅
- [x] **Task 4.3.4**: Implement local puzzle solver (3 pts) ✅

---

---

### Phase 1 Summary
**Total Story Points**: 183 points  
**Estimated Duration**: 8-9 weeks (4-5 sprints)  
**Key Deliverable**: Functional multiplayer cognitive games app with core gameplay and offline support

**Critical Path**:
1. Authentication & Onboarding (Week 1-2)
2. Lobby Management & Multiplayer (Week 3-4)
3. Core Gameplay & Game Catalog (Week 5-6)
4. Cross-Platform Support & Offline Core (Week 7-8)
5. Testing & Bug Fixes (Week 9)

---

## Phase 2: Social & Progression → **112 pts** (was 96)

### Epic 5: Social Features → **50 pts** (was 42 pts)
**Epic Priority**: P1 - High  
**Business Value**: Increases engagement and creates social bonds  
**MoSCoW**: Should  
**Personas**: Social Player, College Student, Competitive Gamer, Teen Squad Leader  
**Epic Story Points**: 50 points

#### Feature 4.1: In-Game Chat ⭐ P1
**Story**: As a player, I want to chat with other players so that I can communicate during games

**Story Points**: 13  
**Personas**: Critical for Teen Squad Leader, Friend Circle Competitor - social interaction  
**Acceptance Criteria**:
- Real-time text messaging
- Messages visible to all lobby members
- Chat history persists during session
- Character limit per message (500 chars)
- Profanity filter applied

**Tasks**:
- [ ] **Task 4.1.1**: Implement chat backend (COMPLETED ✅)
- [ ] **Task 4.1.2**: Create chat UI component (5 pts)
- [ ] **Task 4.1.3**: Add real-time chat updates (3 pts)
- [ ] **Task 4.1.4**: Implement profanity filter (3 pts)

#### Feature 5.2: Emoji Reactions ⭐ P1
**Story**: As a player, I want to send quick emoji reactions so that I can express emotions easily

**Story Points**: 8  
**Personas**: Important for Family Connector - simple cross-generational communication  
**Acceptance Criteria**:
- 8 emoji options available (👍 ❤️ 😂 🎉 🔥 👏 😮 🤔)
- Reactions shown in real-time
- Reactions tied to game events or messages
- Animation when reaction sent
- Reaction count visible

**Tasks**:
- [ ] **Task 5.2.1**: Implement reaction system (COMPLETED ✅)
- [ ] **Task 5.2.2**: Create reaction UI (3 pts)
- [ ] **Task 5.2.3**: Add real-time animations (3 pts)
- [ ] **Task 5.2.4**: Handle reaction contexts (2 pts)

#### Feature 5.3: Vote-to-Skip+ ⭐ P1
**Story**: As a player, I want to vote to skip inactive players so that games progress smoothly

**Story Points**: 13 (enhanced from 8)  
**Acceptance Criteria** (enhanced):
- Any player can initiate skip vote
- Requires majority (50%+1) to pass
- Auto-skip after 48h idle
- Skipped player loses 10 pts penalty
- Max 3 skips per game
- Vote status visible to all players
- Countdown timer shown
- Emoji vote animation

**Tasks**:
- [ ] **Task 5.3.1**: Implement vote-to-skip (COMPLETED ✅)
- [ ] **Task 5.3.2**: Create skip vote UI with emoji animations (3 pts)
- [ ] **Task 5.3.3**: Add Socket.io vote events (2 pts)
- [ ] **Task 5.3.4**: Implement idle detection and auto-skip (3 pts)
- [ ] **Task 5.3.5**: Add skip penalty system (3 pts)
- [ ] **Task 5.3.6**: Implement max skip limit tracking (2 pts)

#### Feature 5.4: Player Blocking & Reporting ⭐ P2
**Story**: As a player, I want to block or report disruptive players so that I maintain a positive experience

**Story Points**: 13  
**Personas**: Important for Parent-Child Builder - safety controls  
**Acceptance Criteria**:
- Can block players from future lobbies
- Can report players for violations
- Reporting includes reason selection
- Blocked players list manageable
- Reports reviewed by moderation team

**Tasks**:
- [ ] **Task 5.4.1**: Implement blocking API (3 pts)
- [ ] **Task 5.4.2**: Create blocking UI (3 pts)
- [ ] **Task 5.4.3**: Implement reporting system (5 pts)
- [ ] **Task 5.4.4**: Create reporting UI (2 pts)

#### Feature 5.5: Daily Challenge ⭐ P1
**Story**: As a player, I want a daily puzzle so I return regularly

**Story Points**: 5  
**MoSCoW**: Should  
**Acceptance Criteria**:
- Shared daily puzzle across all lobbies
- Available for 24 hours
- Streak bonus for consecutive days
- Leaderboard for daily challenge scores
- Notification for new daily challenge

**Tasks**:
- [ ] **Task 5.5.1**: Implement daily challenge generator (2 pts)
- [ ] **Task 5.5.2**: Create daily challenge UI (2 pts)
- [ ] **Task 5.5.3**: Add streak tracking and notifications (1 pt)

---

### Epic 6: Progression & Achievement System
**Epic Priority**: P1 - High  
**Business Value**: Increases retention and long-term motivation  
**Personas**: Competitive Gamer, Brain Trainer, Middle Schooler  
**Epic Story Points**: 62 points (was 54 points)

#### Feature 6.1: Weekly Leaderboards ⭐ P1
**Story**: As a player, I want to compete on leaderboards so that I can see my rank among other players

**Story Points**: 13  
**Personas**: Critical for Competitive Sibling, Friend Circle Competitor  
**Acceptance Criteria**:
- Weekly leaderboard resets every Monday
- Rankings based on total score
- Top 100 players shown
- Player's rank always visible
- Friends' ranks highlighted

**Tasks**:
- [ ] **Task 6.1.1**: Implement leaderboard API (COMPLETED ✅)
- [ ] **Task 6.1.2**: Create leaderboard UI (5 pts)
- [ ] **Task 6.1.3**: Add filtering (3 pts)
- [ ] **Task 6.1.4**: Implement rewards (3 pts)

#### Feature 6.2: Badge & Achievement System ⭐ P1
**Story**: As a player, I want to earn badges for accomplishments so that I can showcase my achievements

**Story Points**: 13  
**Personas**: Critical for Middle Schooler, Teen Squad Leader - visible progress  
**Acceptance Criteria**:
- 15+ badges available
- Badges organized by category
- Progress tracking for each badge
- Badges displayed on player profile
- Notification when badge earned

**Tasks**:
- [ ] **Task 6.2.1**: Implement badge system (COMPLETED ✅)
- [ ] **Task 6.2.2**: Create badge UI grid (5 pts)
- [ ] **Task 6.2.3**: Add badge categories (3 pts)
- [ ] **Task 6.2.4**: Implement unlock notifications (3 pts)

#### Feature 6.3: Streak Tracking System ⭐ P1
**Story**: As a player, I want to maintain daily play streaks so that I stay motivated to play regularly

**Story Points**: 8  
**Personas**: Important for Grandparent Gamer - daily routine  
**Acceptance Criteria**:
- Streak counts consecutive days played
- Streak multipliers up to 2.0x
- Streak freeze available (1 per week)
- Streak displayed prominently
- Loss of streak sends notification

**Tasks**:
- [ ] **Task 6.3.1**: Implement streak tracking (COMPLETED ✅)
- [ ] **Task 6.3.2**: Create streak UI (3 pts)
- [ ] **Task 6.3.3**: Add progressive multipliers (2 pts)
- [ ] **Task 6.3.4**: Implement notifications (3 pts)

#### Feature 6.4: Level & XP System ⭐ P2
**Story**: As a player, I want to level up based on my performance so that I see my overall progress

**Story Points**: 13  
**Acceptance Criteria**:
- XP gained from all activities
- Clear level progression (1-100+)
- XP required increases per level
- Level shown on profile
- Level-up celebration

**Tasks**:
- [ ] **Task 6.4.1**: Implement XP calculation (3 pts)
- [ ] **Task 6.4.2**: Create level UI (3 pts)
- [ ] **Task 6.4.3**: Add XP rewards (5 pts)
- [ ] **Task 6.4.4**: Implement level-up animations (2 pts)

#### Feature 6.5: Personal Statistics Dashboard ⭐ P2
**Story**: As a player, I want detailed statistics about my performance so that I can track improvement

**Story Points**: 13  
**Personas**: Important for Grandparent Gamer - cognitive health tracking  
**Acceptance Criteria**:
- Total games played
- Win/loss ratio
- Average score per game
- Category performance breakdown
- Performance trends over time

**Tasks**:
- [ ] **Task 6.5.1**: Implement statistics backend (5 pts)
- [ ] **Task 6.5.2**: Create statistics dashboard (5 pts)
- [ ] **Task 6.5.3**: Add detailed analytics (3 pts)
- [ ] **Task 6.5.4**: Implement data export (2 pts)

#### Feature 6.6: Enhanced Scoring System ⭐ P0
**Story**: As a player, I want a unified, fair scoring formula across all games so that I can track my performance consistently

**Story Points**: 8 (moved and enhanced from Feature 3.4)  
**MoSCoW**: Must  
**Acceptance Criteria**:
- Unified scoring formula: `Score = (90 - seconds) + (20 × noHints) + (15 × perfect) - (5 × hints) + (streak × 0.1)`
- Applied consistently across all game types
- Time bonus: max 90 points (completed in <90 seconds)
- Hint penalty: -5 points per hint used
- Perfect bonus: +15 points for flawless completion
- No-hint bonus: +20 points
- Streak multiplier: +0.1 points per current streak day
- Server-side score calculation to prevent cheating
- Real-time score updates

**Tasks**:
- [ ] **Task 6.6.1**: Implement unified scoring algorithm (3 pts)
- [ ] **Task 6.6.2**: Create scoring API with validation (3 pts)
- [ ] **Task 6.6.3**: Update score display UI with formula breakdown (2 pts)

---

### Phase 2 Summary
**Total Story Points**: 112 points (was 96 points)  
**Estimated Duration**: 5-6 weeks (3 sprints)  
**Key Deliverable**: Rich social experience with long-term progression hooks and enhanced scoring

---

## Phase 3: Polish & Scale → **90 pts** (was 89)

### Epic 7: Offline & Analytics → **52 pts**
**Epic Priority**: P2 - Medium  
**Business Value**: Critical for users with unreliable connections and data-driven decisions  
**MoSCoW**: Could  
**Personas**: Brain Trainer, Busy Parent, Remote Worker, Grandparent Gamer  
**Epic Story Points**: 52 points  
*(Merged: Offline Mode features + Analytics)*

#### Feature 7.1: Offline Game Storage ⭐ P1
**Story**: As a player, I want to save games locally so that I can play without internet

**Story Points**: 8 (reduced from 13)  
**Personas**: Critical for Parent-Child Builder, Grandparent Gamer - unreliable connectivity  
**Acceptance Criteria**:
- All game data stored in SQLite
- Games playable completely offline
- Local puzzle generation
- Offline moves queued for sync
- No feature loss when offline

**Tasks**:
- [ ] **Task 7.1.1**: Implement SQLite schema (COMPLETED ✅)
- [ ] **Task 7.1.2**: Create offline service layer (3 pts)
- [ ] **Task 7.1.3**: Implement local puzzle generation (3 pts)
- [ ] **Task 7.1.4**: Add offline mode indicators (2 pts)

#### Feature 7.2: Automatic Data Sync ⭐ P1
**Story**: As a player, I want my offline progress synced automatically so that I don't lose data

**Story Points**: 8 (reduced from 13)  
**Acceptance Criteria**:
- Auto-sync on network reconnection
- Sync queue processes failed requests
- Max 5 retry attempts per request
- Sync status visible to user
- Conflict resolution: server wins

**Tasks**:
- [ ] **Task 7.2.1**: Implement sync queue (COMPLETED ✅)
- [ ] **Task 7.2.2**: Create auto-sync on reconnection (3 pts)
- [ ] **Task 7.2.3**: Add sync API endpoints (COMPLETED ✅)
- [ ] **Task 7.2.4**: Implement conflict resolution (3 pts)

#### Feature 7.3: Offline Caching Strategy ⭐ P2
**Story**: As a player, I want frequently used data cached so that the app works smoothly offline

**Story Points**: 6 (reduced from 8)  
**Acceptance Criteria**:
- Game definitions cached locally
- User profile cached
- Recent game history cached
- Images and assets cached
- Cache refreshes on app launch (if online)

**Tasks**:
- [ ] **Task 7.3.1**: Implement cache management (2 pts)
- [ ] **Task 7.3.2**: Add cache refresh logic (2 pts)
- [ ] **Task 7.3.3**: Optimize cache performance (1 pt)
- [ ] **Task 7.3.4**: Handle cache failures (1 pt)

#### Feature 7.4: Network State Management ⭐ P2
**Story**: As a player, I want clear indication of network status so that I understand app behavior

**Story Points**: 6 (reduced from 8)  
**Acceptance Criteria**:
- Network status visible in UI
- Smooth transition online ↔ offline
- Warning before data-heavy actions offline
- Queue status indicator
- Connectivity tests performed

**Tasks**:
- [ ] **Task 7.4.1**: Implement network detection (2 pts)
- [ ] **Task 7.4.2**: Create network status UI (2 pts)
- [ ] **Task 7.4.3**: Add smooth transitions (1 pt)
- [ ] **Task 7.4.4**: Implement data-saving mode (1 pt)

#### Feature 7.5: Event Tracking ⭐ P2
**Story**: As a product manager, I want to track user events so that I can understand user behavior

**Story Points**: 8  
**Personas**: Indirect benefit for all personas, direct value for Office Team Builder (analytics)  
**Acceptance Criteria**:
- Track all major user actions
- Events sent to analytics backend
- Event properties include context
- Privacy-compliant tracking
- Opt-out available for users

**Tasks**:
- [ ] **Task 7.5.1**: Implement analytics service (COMPLETED ✅)
- [ ] **Task 7.5.2**: Add event tracking calls (3 pts)
- [ ] **Task 7.5.3**: Implement event properties (2 pts)
- [ ] **Task 7.5.4**: Add privacy controls (2 pts)

#### Feature 7.6: A/B Testing Framework ⭐ P2
**Story**: As a product manager, I want to run A/B tests so that I can validate feature changes

**Story Points**: 8 (reduced from 13)  
**Acceptance Criteria**:
- Support for multiple concurrent tests
- Random assignment to variants
- Consistent variant per user
- Track variant performance
- Easy test configuration

**Tasks**:
- [ ] **Task 7.6.1**: Implement A/B test service (COMPLETED ✅)
- [ ] **Task 7.6.2**: Create test configuration (3 pts)
- [ ] **Task 7.6.3**: Add variant handling (3 pts)
- [ ] **Task 7.6.4**: Analyze test results (2 pts)

#### Feature 7.7: Performance Monitoring ⭐ P2
**Story**: As a developer, I want to monitor app performance so that I can identify and fix issues

**Story Points**: 8  
**Acceptance Criteria**:
- Track app launch time
- Monitor API response times
- Track frame rates (FPS)
- Detect crashes and errors
- Alert on performance degradation

**Tasks**:
- [ ] **Task 7.7.1**: Implement performance tracking (3 pts)
- [ ] **Task 7.7.2**: Add error tracking (2 pts)
- [ ] **Task 7.7.3**: Create performance dashboard (2 pts)
- [ ] **Task 7.7.4**: Optimize based on data (1 pt)

---

### Epic 8: Cross-Platform Support (Complete)
**Epic Priority**: P1 - High  
**Story Points**: 13 points

#### Feature 8.1: Cross-Platform Multiplayer ⭐ P1
**Story**: As a player, I want to play with friends regardless of their device

**Story Points**: 13  
**Personas**: Essential for all group types - mixed device families/friend groups  
**Acceptance Criteria**:
- iOS and Android users in same lobbies
- Feature parity between platforms
- Consistent game experience
- Cross-platform friend lists
- Synced data across devices

**Tasks**:
- [ ] **Task 8.1.1**: Ensure protocol compatibility (3 pts)
- [ ] **Task 8.1.2**: Test iOS-Android lobbies (3 pts)
- [ ] **Task 8.1.3**: Handle platform UI differences (5 pts)
- [ ] **Task 8.1.4**: Add platform indicators (2 pts)

---

### Epic 9: User Feedback & Quality
**Epic Priority**: P3 - Low  
**Business Value**: Direct user insights improve retention  
**Epic Story Points**: 5 points

#### Feature 9.1: User Feedback System ⭐ P3
**Story**: As a user, I want to provide feedback so that I can help improve the app

**Story Points**: 5  
**Acceptance Criteria**:
- In-app feedback form
- Rating prompt (after positive experience)
- Bug report functionality
- Feature request submission
- Response from team (for bugs)

**Tasks**:
- [ ] **Task 9.1.1**: Create feedback UI (2 pts)
- [ ] **Task 9.1.2**: Implement feedback API (1 pt)
- [ ] **Task 9.1.3**: Add smart rating prompt (1 pt)
- [ ] **Task 9.1.4**: Create feedback dashboard (1 pt)

---

### Phase 3 Summary
**Total Story Points**: 90 points (was 89 points)  
**Estimated Duration**: 5 weeks (3 sprints)  
**Key Deliverable**: Production-ready app with offline capabilities, analytics, and cross-platform support

---

## Beta Testing Phase: Server Infrastructure (Parallel to Phase 2-3)

### Overview
The Beta Testing Phase runs in parallel with Phases 2-3 and focuses on deploying backend infrastructure to enable beta testers to play together in a controlled Docker environment. This phase establishes the server-side architecture needed for multiplayer gameplay, user authentication, and game session management.

**Duration**: 6-8 weeks (3-4 sprints)  
**Total Story Points**: 147 points  
**Team**: DevOps + Backend team (can run parallel to frontend Phase 2-3 work)  
**Goal**: Deploy production-ready backend infrastructure for beta testing

### Beta Testing Phases
1. **Internal Beta** (2-4 weeks): Development team + friends/family (10-20 users)
2. **Closed Beta** (4-6 weeks): Invited testers from target personas (50-100 users)
3. **Open Beta** (4-8 weeks): Public sign-up with approval (500-1000 users)

### Epic 13: Beta Testing Infrastructure
**Epic Priority**: P0 - Critical  
**Business Value**: Enables beta testing environment for controlled rollout  
**Epic Story Points**: 60 points  
**Dependencies**: Phase 1 completion (Epics 1-4)

**Features**:
- **Feature 13.1**: Docker Environment Setup (13 pts) - Multi-container architecture with Docker Compose
- **Feature 13.2**: Backend API Server Implementation (13 pts) - Node.js 18.x/Express REST API
- **Feature 13.3**: Socket.io Multiplayer Server (13 pts) - Real-time WebSocket communication
- **Feature 13.4**: Database Schema & Migrations (8 pts) - PostgreSQL with persistence
- **Feature 13.5**: Load Balancing & SSL Configuration (8 pts) - Nginx with Let's Encrypt SSL
- **Feature 13.6**: Email Service Configuration (5 pts) - SendGrid/AWS SES for transactional emails

**Technology Stack**:
- Docker 24+ & Docker Compose for containerization
- Node.js 18.x + Express for REST API
- Socket.io for real-time multiplayer
- PostgreSQL 15+ for primary database
- Redis 7+ for session cache
- Nginx for load balancing & SSL termination

### Epic 14: Beta User Authentication & Management
**Epic Priority**: P0 - Critical  
**Business Value**: Enables secure user access for beta testers  
**Epic Story Points**: 34 points  
**Dependencies**: Epic 13 (Infrastructure)

**Features**:
- **Feature 14.1**: Beta Tester Registration System (8 pts) - Invitation code-based registration
- **Feature 14.2**: JWT Token Authentication (8 pts) - Secure token-based auth
- **Feature 14.3**: Beta Tester Role Management (8 pts) - Admin, moderator, tester roles
- **Feature 14.4**: Session Management & Rate Limiting (5 pts) - Security controls
- **Feature 14.5**: Beta Tester Profile Management (5 pts) - User profiles and preferences

**Key Capabilities**:
- Invitation code system for controlled beta access
- JWT tokens (15 min access, 7 day refresh)
- Role-based access control
- Session management with Redis
- Rate limiting to prevent abuse

### Epic 15: Beta Lobby & Game Session Management
**Epic Priority**: P0 - Critical  
**Business Value**: Core multiplayer functionality for beta testing  
**Epic Story Points**: 34 points  
**Dependencies**: Epic 13 (Infrastructure), Epic 14 (Authentication)

**Features**:
- **Feature 15.1**: Game Lobby Creation & Discovery (8 pts) - Create/join lobbies with unique codes
- **Feature 15.2**: Lobby Host Controls (8 pts) - Start game, kick players, transfer host
- **Feature 15.3**: Game Session State Management (8 pts) - Track turns, disconnections, timeouts
- **Feature 15.4**: Turn-Based Gameplay Flow (5 pts) - Submit, validate, and broadcast turns
- **Feature 15.5**: Game Voting System (5 pts) - Democratic game selection

**Key Capabilities**:
- Private lobbies with shareable codes (e.g., "FAMILY42")
- Support for 2-10 players per lobby
- Real-time lobby updates via Socket.io
- Server-side turn validation
- Game voting with point allocation

### Epic 16: Beta Monitoring & Analytics
**Epic Priority**: P1 - High  
**Business Value**: Insights for improving beta and production  
**Epic Story Points**: 21 points  
**Dependencies**: Epic 13 (Infrastructure)

**Features**:
- **Feature 16.1**: Application Metrics & Monitoring (8 pts) - Prometheus + Grafana
- **Feature 16.2**: Centralized Logging (8 pts) - ELK stack (Elasticsearch, Logstash, Kibana)
- **Feature 16.3**: User Analytics & Events (5 pts) - Track user behavior

**Key Capabilities**:
- Real-time metrics for API, Socket.io, database
- Centralized logging with searchable logs
- User behavior analytics
- Alert rules for critical issues
- Dashboards for system health

### Beta Testing Pipeline

**User Journey**: Registration → Lobby → Game
```
1. Beta tester receives invitation code
2. Registers via mobile app with invitation code
3. Creates or joins lobby with shareable code
4. Votes on games to play
5. Plays games in turn-based fashion
6. Server validates moves and calculates scores
7. Leaderboards and badges update
```

**Infrastructure**:
```
Mobile Clients (iOS/Android)
         ↓
    Load Balancer (Nginx + SSL)
         ↓
    ┌────────────────────┐
    │  API Server        │  Socket.io Server
    │  (REST)            │  (WebSocket)
    └────────────────────┘
         ↓
    ┌────────────────────┐
    │  PostgreSQL        │  Redis
    │  (Database)        │  (Cache)
    └────────────────────┘
         ↓
    Monitoring (Prometheus + Grafana)
```

### Deployment Strategy

**Phase 1: Single-Host Deployment** (Internal Beta, 10-20 users)
- Single Docker host (4 CPU, 8GB RAM)
- All containers on one host
- Local database storage

**Phase 2: Vertical Scaling** (Closed Beta, 50-100 users)
- Larger host (8 CPU, 16GB RAM)
- Optimized database with connection pooling
- Redis caching

**Phase 3: Horizontal Scaling** (Open Beta, 500-1000 users)
- Kubernetes cluster (3+ nodes)
- Multiple API/Socket.io replicas
- Database read replicas
- Redis cluster

### Security Considerations
- SSL/TLS encryption (Let's Encrypt)
- JWT token authentication
- Server-side game validation (anti-cheat)
- Rate limiting per IP and user
- Role-based access control
- Invitation code system for beta access

### Success Metrics
- **Uptime**: >99% during beta period
- **API Latency**: p95 <500ms
- **Lobby Completion Rate**: >70%
- **Crash Rate**: <0.5%
- **User Satisfaction**: >4.0/5.0

### Documentation
For comprehensive details on beta testing architecture, Docker deployment, and infrastructure setup, see:
- **[BETA_TESTING_ARCHITECTURE.md](BETA_TESTING_ARCHITECTURE.md)** - Complete beta testing infrastructure guide with detailed Epics, Features, and Tasks

---

## Phase 4: Advanced Features (Future)

### Epic 10: Advanced Social Features
**Epic Priority**: P3 - Low (Future)  
**Story Points**: TBD

#### Feature 10.1: Voice Chat ⭐ P3
**Story**: As a player, I want voice chat during games so that I can communicate naturally
- Real-time voice communication
- Mute/unmute controls
- Voice quality optimization
- Low latency requirements

#### Feature 10.2: Friend System ⭐ P3
**Story**: As a player, I want to add friends so that I can easily find and play with them
- Send/accept friend requests
- Friends list management
- See friends' online status
- Invite friends to lobbies
- Friends-only leaderboards

#### Feature 10.3: Clans/Teams ⭐ P3
**Story**: As a player, I want to join a clan so that I can be part of a community
- Create/join clans
- Clan chat
- Clan leaderboards
- Clan vs. clan competitions

---

### Epic 11: Advanced Progression
**Epic Priority**: P3 - Low (Future)  
**Story Points**: TBD

#### Feature 11.1: Tournaments ⭐ P3
**Story**: As a competitive player, I want to enter tournaments so that I can win prizes
- Weekly/monthly tournaments
- Tournament brackets
- Prize pools
- Tournament history

#### Feature 11.2: Seasonal Content ⭐ P3
**Story**: As a player, I want seasonal events so that I have fresh content
- Holiday-themed games
- Seasonal badges
- Limited-time events
- Seasonal leaderboards

#### Feature 11.3: AI Practice Mode ⭐ P2
**Story**: As a player, I want to practice against AI so that I can improve my skills
- Single-player practice mode
- AI difficulty levels (Easy, Medium, Hard)
- Practice statistics dashboard
- No impact on competitive stats
- Available offline

**Story Points**: 13  
**Priority**: P2 (moved from P3)  
**Phase**: Phase 3 (added to Polish & Scale)

---

### Epic 12: Monetization
**Epic Priority**: P3 - Low (Future)  
**Story Points**: TBD

#### Feature 12.1: Premium Teaser ⭐ P2
**Story**: As a player, I want to see premium features so that I understand the value proposition

**Story Points**: 5  
**Priority**: P2  
**Phase**: Phase 2 (added to Social & Progression)  
**Acceptance Criteria**:
- Locked premium badge visible in profile
- "Premium" tag on exclusive features
- Preview of premium benefits
- Clear call-to-action for upgrade
- Non-intrusive placement

**Tasks**:
- [ ] **Task 12.1.1**: Design premium teaser UI (2 pts)
- [ ] **Task 12.1.2**: Implement locked badge display (2 pts)
- [ ] **Task 12.1.3**: Add premium benefits modal (1 pt)

#### Feature 12.2: Premium Subscription ⭐ P3
**Story**: As a player, I want premium features so that I get enhanced experience
- Ad-free experience
- Exclusive badges and avatars
- Priority matchmaking
- Advanced statistics
- Family/group plans

#### Feature 12.3: Cosmetic Store ⭐ P3
**Story**: As a player, I want to customize my profile so that I express my personality
- Avatar customization
- Profile themes
- Badge frames
- Chat emojis
- Victory animations

---

### Epic 13: Production Cloud Migration
**Epic Priority**: P1 - High (Post Phase 1)  
**Business Value**: Enable production launch and scalability  
**Epic Story Points**: 144 points (8 weeks)  
**MoSCoW**: Should Have (for production launch)  
**Personas**: All personas (indirect - enables platform)

This epic covers the complete migration from local Docker deployment to a production cloud environment. See [CLOUD_MIGRATION_PLAN.md](docs/project/CLOUD_MIGRATION_PLAN.md) for detailed planning.

#### Migration Phases Overview

**Phase 1: Cloud Foundation Setup (Weeks 1-2) - 34 pts**
- Feature 13.1: Cloud Account & Project Setup (8 pts)
- Feature 13.2: Database Infrastructure (13 pts)
- Feature 13.3: CI/CD Pipeline Foundation (13 pts)

**Phase 2: Backend Services Deployment (Weeks 3-4) - 42 pts**
- Feature 13.4: RESTful API Deployment (13 pts)
- Feature 13.5: Socket.io Server Deployment (13 pts)
- Feature 13.6: Cloud Functions Deployment (8 pts)
- Feature 13.7: Authentication Integration (8 pts)

**Phase 3: Data Migration & Testing (Weeks 5-6) - 34 pts**
- Feature 13.8: Data Migration Strategy (13 pts)
- Feature 13.9: Load Testing & Performance Optimization (13 pts)
- Feature 13.10: Comprehensive Testing (8 pts)

**Phase 4: Production Launch (Weeks 7-8) - 34 pts**
- Feature 13.11: Production Deployment (13 pts)
- Feature 13.12: Monitoring & Alerting Setup (13 pts)
- Feature 13.13: Documentation & Knowledge Transfer (8 pts)

**Success Criteria**:
- 99.9% uptime SLA achieved
- API response time < 500ms (p95)
- Support 10,000+ concurrent users
- Zero data loss during migration
- Mobile apps approved and published
- Comprehensive monitoring operational

**For detailed Epic breakdown, Features, and Tasks, see**: [CLOUD_MIGRATION_PLAN.md](docs/project/CLOUD_MIGRATION_PLAN.md)

---

## MoSCoW Tagging

| Tag | Meaning | Priority Level |
|-----|---------|---------------|
| **Must** | MVP blocker - required for launch | P0-P1 |
| **Should** | High ROI - important for success | P1-P2 |
| **Could** | Polish - enhances experience | P2-P3 |
| **Won't** | Post-v1 - future consideration | P3 |

### MoSCoW Applied to Epics

**Phase 1 (Must Have)**:
- Epic 1: User Onboarding & Authentication - **Must**
- Epic 2: Game Lobby & Multiplayer Management - **Must**
- Epic 3: Core Gameplay Experience - **Must**
- Epic 4: Cross-Platform & Reliability - **Must**

**Phase 2 (Should Have)**:
- Epic 5: Social Features - **Should**
- Epic 6: Progression & Achievement System - **Should**

**Phase 3 (Could Have)**:
- Epic 7: Offline & Analytics - **Could**
- Epic 8: Cross-Platform Support (Complete) - **Should**
- Epic 9: User Feedback & Quality - **Could**

**Beta Testing Phase (Must Have - Parallel to Phases 2-3)**:
- Epic 13: Beta Testing Infrastructure - **Must**
- Epic 14: Beta User Authentication & Management - **Must**
- Epic 15: Beta Lobby & Game Session Management - **Must**
- Epic 16: Beta Monitoring & Analytics - **Should**

**Phase 4 (Won't Have - Post-Launch)**:
- Epic 10: Advanced Social Features - **Won't**
- Epic 11: Advanced Progression - **Won't**
- Epic 12: Monetization - **Won't**
- Epic 13: Production Cloud Migration - **Should** (Post Phase 1)

---

## Final Recommendations

### 1. Next Grooming Focus
**Priority Items for Next Sprint Planning**:
- **Feature 3.6: Game Content Seed** (13 pts) - Critical for MVP playability
  - Ensure 12+ puzzles across 4 categories are ready
  - Test difficulty tiers with target personas
  - Validate hint system penalties don't frustrate casual players
  
- **Feature 6.6: Enhanced Scoring Formula** (8 pts) - Unified scoring essential
  - Formula: `Score = (90 - seconds) + (20 × noHints) + (15 × perfect) - (5 × hints) + (streak × 0.1)`
  - Validate formula with Competitive Sibling persona
  - Ensure server-side calculation prevents cheating

### 2. Spike Needed
**Technical Research Required**:
- **"Go Board Async Sync"** (8 pts) - Spike story
  - Research board state compression techniques
  - Evaluate real-time sync vs. turn-based sync trade-offs
  - Test with 10-player lobbies for performance
  - Deliverable: Technical design document with recommendation

### 3. Import to Tool
**Jira/Azure DevOps Setup**:
- Use Epic → Feature → Task hierarchy
- Tag all items with MoSCoW priority
- Link features to personas in description
- Set up custom fields: Story Points, MoSCoW Tag, Phase
- Create sprint boards for each phase

### 4. Beta Plan
**After Phase 1 (Week 9)**:
- Test with 3 family groups (your nieces/nephews)
- Focus on multi-generational play (ages 11-70+)
- Collect feedback on:
  - Lobby creation and invite flow
  - Game selection and voting experience
  - Async play patterns
  - Cross-platform compatibility
- Run for 2 weeks minimum
- Success metrics:
  - 70%+ lobby completion rate
  - 3+ sessions per user per week
  - <1% crash rate
  - 4.0+ user satisfaction rating

### 5. Risk Mitigation
**High-Risk Items Requiring Extra Attention**:
- **Feature 4.3: Offline Core** - Sync conflicts can be complex
  - Add buffer: multiply estimate by 1.5x
  - Pair programming recommended
  - Early testing with poor network conditions
  
- **Feature 4.1: iOS/Android Parity** - Platform differences challenging
  - Start early in Phase 1
  - Dedicate specialist per platform
  - Weekly cross-platform testing

### 6. Velocity Tracking
**Expected Sprint Velocity**:
- Sprint 1-2: 30-40 pts (team ramping up)
- Sprint 3+: 40-50 pts (full velocity)
- Adjust for holidays, team changes

**Phase Estimates**:
- Phase 1: 183 pts = 4-5 sprints (9-10 weeks)
- Phase 2: 112 pts = 3 sprints (6 weeks)
- Phase 3: 90 pts = 2-3 sprints (5-6 weeks)

---

## Backlog Grooming Guidelines

### Weekly Backlog Refinement
**Cadence**: Every Wednesday, 1 hour  
**Participants**: Product Owner, Scrum Master, Tech Lead, 2-3 Engineers

**Agenda**:
1. Review upcoming sprint items (15 min)
   - Clarify acceptance criteria
   - Identify dependencies
   - Estimate story points
   
2. Groom future backlog items (30 min)
   - Break down large stories (>13 points)
   - Add technical details to tasks
   - Update priorities based on learnings
   
3. Persona alignment check (10 min)
   - Verify features serve target personas
   - Ensure balance across persona needs
   - Identify gaps in persona coverage
   
4. Dependencies and blockers (5 min)
   - Identify technical dependencies
   - Flag external dependencies
   - Update BLOCKED status

### Story Refinement Checklist
Before a story enters a sprint, ensure:
- [ ] Clear acceptance criteria defined
- [ ] Linked to at least one persona
- [ ] Story points estimated (team consensus)
- [ ] Tasks broken down (if >8 points)
- [ ] Dependencies identified
- [ ] Technical approach validated
- [ ] UI/UX designs available (if needed)
- [ ] Test scenarios outlined

### Definition of Ready
A backlog item is "Ready" when:
1. ✅ User story format complete ("As a... I want... so that...")
2. ✅ Acceptance criteria clearly defined (testable)
3. ✅ Linked to target persona(s)
4. ✅ Story points estimated by team
5. ✅ Dependencies identified and resolved
6. ✅ Technical feasibility validated
7. ✅ Design assets available (if UI work)
8. ✅ Team understands and can commit

### Definition of Done
A backlog item is "Done" when:
1. ✅ All tasks completed and code merged
2. ✅ Unit tests written (>80% coverage)
3. ✅ Integration tests passing
4. ✅ Tested on iOS and Android
5. ✅ Code reviewed and approved
6. ✅ Performance meets targets
7. ✅ Security review passed (if applicable)
8. ✅ Documentation updated
9. ✅ Product owner approval
10. ✅ Deployed to staging environment

---

## Sprint Planning Recommendations

### Sprint Structure
- **Sprint Duration**: 2 weeks
- **Sprint Velocity Target**: 40-50 story points
- **Team Size**: 5-7 engineers (full-stack)
- **Sprint Ceremonies**:
  - Sprint Planning: Monday, 2 hours
  - Daily Standup: Every day, 15 minutes
  - Sprint Review: Friday (Week 2), 1 hour
  - Sprint Retrospective: Friday (Week 2), 1 hour

### Sprint Planning Process

#### Part 1: What to Build (1 hour)
1. **Review Sprint Goal** (10 min)
   - Product owner presents sprint objective
   - Aligns with phase/epic goals
   - Focuses on persona value delivery

2. **Story Selection** (30 min)
   - Select highest priority "Ready" items
   - Team capacity: 40-50 points
   - Must support sprint goal
   - Balance between new features and technical debt

3. **Story Walkthrough** (20 min)
   - Product owner explains each story
   - Team asks clarifying questions
   - Acceptance criteria reviewed
   - Success metrics defined

#### Part 2: How to Build (1 hour)
1. **Task Breakdown** (30 min)
   - Engineering team breaks down stories
   - Identify technical tasks
   - Estimate individual tasks
   - Assign owners (tentative)

2. **Dependency Mapping** (15 min)
   - Identify blockers
   - External dependencies flagged
   - Order of execution planned
   - Risk mitigation strategies

3. **Capacity Check** (15 min)
   - Verify total points vs. capacity
   - Account for holidays, meetings
   - Buffer for unknowns (10-20%)
   - Commit to sprint backlog

### Sprint Velocity Tracking
- **Phase 1 Target**: 40-50 points/sprint (170 points over 4-5 sprints)
- **Phase 2 Target**: 40-50 points/sprint (96 points over 2-3 sprints)
- **Phase 3 Target**: 40-50 points/sprint (89 points over 2-3 sprints)

**Velocity Adjustments**:
- First 2 sprints: Establish baseline
- Sprint 3+: Use 3-sprint average
- Adjust for team changes, holidays
- Account for technical debt sprints

### Story Point Calibration
**Reference Stories** (use for comparison):
- **1 point**: Update button text, fix typo
- **2 points**: Add new UI component (reusable)
- **3 points**: Implement simple API endpoint
- **5 points**: Create new screen with basic logic
- **8 points**: Implement complex feature with state management
- **13 points**: Build complete user flow (auth, lobby creation)

### Risk Management
**High-Risk Items** (need extra attention):
- New technology/library integration
- Cross-platform compatibility issues
- Real-time multiplayer edge cases
- Offline sync conflict resolution
- Security-critical features

**Mitigation**:
- Add buffer points (multiply estimate by 1.5x)
- Spike stories for unknowns
- Pair programming on complex items
- Early integration testing
- Frequent demos to stakeholders

---

## Persona-Feature Matrix

### Critical Features by Persona

| Feature | Competitive Sibling | Family Connector | Grandparent Gamer | Parent-Child Builder | Teen Squad Leader | Middle Schooler | Friend Circle | Office Team Builder |
|---------|---------------------|------------------|-------------------|----------------------|-------------------|-----------------|---------------|---------------------|
| **Private Lobbies** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Async Multiplayer** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Game Voting** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Chat & Emoji** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Fair Scoring** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Badges** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Leaderboards** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Offline Mode** | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐ |
| **Accessibility** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| **Cross-Platform** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

⭐⭐⭐ = Critical | ⭐⭐ = Important | ⭐ = Nice to have

---

## Success Metrics & KPIs

### User Acquisition Metrics
- **Target**: 10,000 registered users in first 3 months
- **DAU (Daily Active Users)**: Track daily engagement
- **WAU (Weekly Active Users)**: Track weekly engagement
- **Organic Growth Rate**: 20% month-over-month target

### Engagement Metrics
- **Average Session Length**: Target > 15 minutes
- **Sessions Per User Per Week**: Target 3+
- **7-Day Streak Maintenance**: Target 50%+ of users
- **Lobby Completion Rate**: Target 70%+ complete all games

### Retention Metrics
- **Day 1 Retention**: Target > 40%
- **Day 7 Retention**: Target > 25%
- **Day 30 Retention**: Target > 15%
- **6-Month Retention**: Target > 5%

### Social Metrics
- **Average Lobby Size**: Target 4 players
- **Friend Play Rate**: Target 30%+ play with friends
- **Messages Per Lobby**: Target 50+ average
- **Game Voting Usage**: Target 80%+ of lobbies

### Quality Metrics
- **App Crash Rate**: Target < 1%
- **App Rating**: Target > 4.5 stars
- **API Response Time**: Target < 500ms (p95)
- **Multiplayer Uptime**: Target 99.9%

### Persona-Specific Metrics
- **Family Mind Wars**: % of lobbies with 3+ generation age gap
- **Friends Mind Wars**: % of lobbies with repeat players
- **Office Mind Wars**: % of lobbies created during work hours
- **Multi-Generational Usage**: % of lobbies with ages 11-70+

---

## Backlog Health Indicators

### Healthy Backlog Characteristics
- ✅ Top 2 sprints worth of items are "Ready"
- ✅ Next 4 sprints have rough estimates
- ✅ Clear prioritization (P0 > P1 > P2 > P3)
- ✅ Balanced persona coverage across phases
- ✅ Technical debt < 20% of capacity
- ✅ Dependencies identified and tracked
- ✅ Regular grooming sessions held

### Red Flags (Requires Attention)
- ⚠️ Multiple P0 items blocked
- ⚠️ Large stories (>13 pts) not broken down
- ⚠️ Acceptance criteria missing
- ⚠️ Velocity trending downward
- ⚠️ Technical debt accumulating
- ⚠️ Persona needs unbalanced
- ⚠️ Grooming sessions skipped

---

## Complete Project Timeline

### Overall Timeline Visualization

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    MIND WARS COMPLETE DEVELOPMENT ROADMAP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Months 1-2      Months 3-4      Months 5-6      Months 7-8       Month 9+
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐    ┌──────────┐
│ PHASE 1  │   │ PHASE 2  │   │ PHASE 3  │   │ PHASE 4  │    │ PHASE 5  │
│   MVP    │   │  Social  │   │  Polish  │   │  Cloud   │    │ Advanced │
│   Core   │   │   & Pro  │   │  & Scale │   │Migration │    │ Features │
└──────────┘   └──────────┘   └──────────┘   └──────────┘    └──────────┘
✅ COMPLETE       Planned        Planned        Planned         Future

183 pts        112 pts         90 pts         144 pts          TBD
4-5 sprints    3 sprints       2-3 sprints    4 sprints
```

### Detailed Timeline

| Phase | Duration | Story Points | Key Milestones | Status |
|-------|----------|--------------|----------------|--------|
| **Phase 1: MVP** | Months 1-2 | 183 pts | Authentication, Lobbies, Core Games, Cross-Platform | ✅ COMPLETE |
| **Phase 2: Social** | Months 3-4 | 112 pts | Chat, Badges, Leaderboards, Streaks | 📋 Planned |
| **Phase 3: Polish** | Months 5-6 | 90 pts | Offline Mode, Analytics, Optimization | 📋 Planned |
| **Phase 4: Cloud** | Months 7-8 | 144 pts | Cloud Infrastructure, Production Deployment | 📋 Planned |
| **Phase 5: Advanced** | Month 9+ | TBD | Voice Chat, Tournaments, Premium Features | 🔮 Future |

### Production Launch Path

**To Production Launch (8 months)**:
```
Phase 1 (2 months) → Phase 2 (2 months) → Phase 3 (2 months) → Phase 4 (2 months)
     ✅                   📋                   📋                   📋
   COMPLETE            Planned              Planned              Planned
```

**Critical Path to Launch**:
1. ✅ **Months 1-2**: Build core application (Phase 1) - COMPLETE
2. 📋 **Months 3-4**: Add social features (Phase 2)
3. 📋 **Months 5-6**: Polish and optimize (Phase 3)
4. 📋 **Months 7-8**: Deploy to production cloud (Phase 4)
5. 🚀 **Month 8**: Production Launch to 10,000+ users

**Post-Launch Enhancement**:
- Month 9+: Advanced features (Phase 5)
- Continuous: Optimization, monitoring, user feedback

---

## Appendix

### Related Documents
- [USER_PERSONAS.md](docs/business/USER_PERSONAS.md) - Detailed user personas (8 personas)
- [USER_STORIES.md](USER_STORIES.md) - Complete user stories with Epics, Features, Tasks
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical architecture
- [README.md](README.md) - Project overview and setup
- [VALIDATION.md](VALIDATION.md) - Implementation validation checklist
- [VOTING_SYSTEM.md](VOTING_SYSTEM.md) - Game voting system details
- [CLOUD_MIGRATION_PLAN.md](docs/project/CLOUD_MIGRATION_PLAN.md) - ⭐ NEW: Detailed cloud migration planning

### Glossary
- **Epic**: Large body of work (1-2 months, multiple features)
- **Feature**: User-facing functionality (1-2 weeks, multiple tasks)
- **Task**: Technical implementation item (hours to days)
- **Story Points**: Relative effort estimation (Fibonacci scale)
- **Sprint**: 2-week development iteration
- **Velocity**: Story points completed per sprint
- **Mind War**: Private group competition (Family/Friends/Colleagues)
- **Persona**: Representative user archetype
- **MVP**: Minimum Viable Product (Phase 1)
- **Cloud Migration**: Moving from local Docker to production cloud infrastructure

### Change Log
| Date | Version | Changes | Author |
|------|---------|---------|--------|
| Nov 2025 | 1.0 | Initial backlog creation based on updated personas | Product Team |
| Nov 10, 2025 | 1.1 | Updated with Phase 1 completion status - all 183 story points marked complete | Product Team |
| Nov 12, 2025 | 1.2 | Added Epic 13: Production Cloud Migration (144 pts, 8 weeks) | Product Team |

---

**Document Status**: Phase 1 Complete ✅ | Phase 2 Planning | Cloud Migration Planning  
**Next Review**: After Phase 2 Sprint 1  
**Owner**: Product Manager  
**Contributors**: Engineering Team, Design Team, Persona Research Team, DevOps Team

---

*This backlog is a living document and should be updated regularly based on:*
- *Sprint retrospective learnings*
- *User feedback and analytics*
- *Technical discoveries and constraints*
- *Market and competitive changes*
- *Persona validation and evolution*
- *Cloud infrastructure and deployment insights*
