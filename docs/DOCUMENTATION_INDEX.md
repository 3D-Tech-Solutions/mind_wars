# Mind Wars Documentation Index

**Last Updated:** 2026-04-05  
**Status:** Active - MVP Phase (Gate 0/1 Testing)

---

## 📋 Quick Links (Most Important)

### Current Testing
- **[Gate 0 & 1 Test Checklist](./GATE_0_AND_1_TEST_CHECKLIST.md)** — Start here for physical device testing
- **[Phase 1 Implementation Roadmap](./PHASE1_IMPLEMENTATION_ROADMAP.md)** — Overall MVP roadmap and gate criteria

### Architecture & Design
- **[Async Game Contract](./games/ASYNC_GAME_CONTRACT.md)** — How multiplayer games work deterministically
- **[Sealed Payload Implementation Guide](./games/SEALED_PAYLOAD_IMPLEMENTATION_GUIDE.md)** — Server-verifiable game challenges
- **[Technical Architecture](./project/TECHNICAL_ARCHITECTURE.md)** — System design and data flow

### Games
- **[Games Difficulty Matrix](./games/GAMES_DIFFICULTY_MATRIX.md)** — Scaling challenges across 15 games
- **[Path Finder](./games/spatial/path-finder.md)** — Deterministic maze generation
- **[Rotation Master](./games/spatial/rotation-master.md)** — Sealed challenge system

### Operations & Deployment
- **[Network Bridge Summary](./NETWORK_BRIDGE_SUMMARY.md)** — Local WiFi gateway setup
- **[LAN Multiplayer Testing Guide](./LAN_MULTIPLAYER_TESTING_GUIDE.md)** — Device-to-server connection

### Backend & API
- **[API Documentation](./project/API_DOCUMENTATION.md)** — REST endpoints
- **[Chat Infrastructure](./CHAT_INFRASTRUCTURE_QUICK_REFERENCE.md)** — Socket.io events

---

## 📁 Directory Structure

```
docs/
├── DOCUMENTATION_INDEX.md          ← You are here
├── GATE_0_AND_1_TEST_CHECKLIST.md
├── PHASE1_IMPLEMENTATION_ROADMAP.md
├── README.md
│
├── games/                          # Game design & implementation
│   ├── ASYNC_GAME_CONTRACT.md
│   ├── SEALED_PAYLOAD_IMPLEMENTATION_GUIDE.md
│   ├── GAMES_DIFFICULTY_MATRIX.md
│   ├── DETERMINISTIC_GENERATION_SPEC.md
│   ├── README.md
│   ├── memory/ (Memory Match, Sequence Recall, Pattern Memory)
│   ├── logic/ (Sudoku Duel, Logic Grid, Code Breaker)
│   ├── attention/ (Spot Difference, Color Rush, Focus Finder)
│   ├── spatial/ (Path Finder, Puzzle Race, Rotation Master)
│   └── language/ (Word Builder, Anagram Attack, Vocabulary Showdown)
│
├── project/                        # Project management & status
│   ├── PROJECT_STATUS.md
│   ├── TECHNICAL_ARCHITECTURE.md
│   ├── API_DOCUMENTATION.md
│   ├── EPIC_1_SUMMARY.md through EPIC_4_*
│   ├── TESTING_STRATEGY.md
│   └── DEVELOPER_ONBOARDING.md
│
├── business/                       # Business strategy & personas
│   ├── STRATEGY_OVERVIEW.md
│   ├── USER_PERSONAS.md
│   ├── MARKET_ANALYSIS.md
│   ├── MONETIZATION_STRATEGY.md
│   ├── USER_ACQUISITION.md
│   └── data_strategy/
│
├── research/                       # Research & analysis
│   ├── BRAIN_TRAINING_GAMES.md
│   └── COMPETITIVE-ASYNC-MPG.md
│
├── social/                         # Community & moderation
│   ├── COMMUNITY_GUIDELINES.md
│   └── SOCIAL_MEDIA_STRATEGY.md
│
├── NETWORK_BRIDGE_SUMMARY.md       # Local WiFi gateway
├── NETWORK_BRIDGE_QUICKSTART.md
├── LAN_MULTIPLAYER_TESTING_GUIDE.md
├── CHAT_INFRASTRUCTURE_QUICK_REFERENCE.md
├── BUILD_GUIDE.md
├── ENDPOINT_VERIFICATION_GUIDE.md
├── MVP_DOCUMENT.md
│
└── _archive/                       # Obsolete / reference docs
    ├── alpha/ (alpha testing docs)
    ├── beta/ (beta testing docs)
    ├── complete-features/ (Vocabulary Showdown, Vote to Skip, completed phases)
    ├── network-bridge/ (old network docs)
    ├── branding/ (branding assets & strategies)
    └── research/ (archived research)
```

---

## 🎯 What To Read When

### You're a Developer (First Time)
1. [Developer Onboarding](./project/DEVELOPER_ONBOARDING.md)
2. [Technical Architecture](./project/TECHNICAL_ARCHITECTURE.md)
3. [Build Guide](./BUILD_GUIDE.md)
4. [API Documentation](./project/API_DOCUMENTATION.md)

### You're Testing (Physical Devices)
1. [Gate 0 & 1 Test Checklist](./GATE_0_AND_1_TEST_CHECKLIST.md)
2. [Network Bridge Quickstart](./NETWORK_BRIDGE_QUICKSTART.md)
3. [LAN Multiplayer Testing Guide](./LAN_MULTIPLAYER_TESTING_GUIDE.md)

### You're Adding a Game
1. [Async Game Contract](./games/ASYNC_GAME_CONTRACT.md)
2. [Sealed Payload Implementation Guide](./games/SEALED_PAYLOAD_IMPLEMENTATION_GUIDE.md)
3. Pick your game category folder and read the template

### You're Debugging a Game
1. [Deterministic Generation Spec](./games/DETERMINISTIC_GENERATION_SPEC.md)
2. [Games Difficulty Matrix](./games/GAMES_DIFFICULTY_MATRIX.md)
3. Your specific game's folder (e.g., `games/spatial/path-finder.md`)

### You're Setting Up the Backend
1. [Technical Architecture](./project/TECHNICAL_ARCHITECTURE.md)
2. [Network Bridge Summary](./NETWORK_BRIDGE_SUMMARY.md)
3. [API Documentation](./project/API_DOCUMENTATION.md)

### You're Preparing for Launch
1. [Phase 1 Implementation Roadmap](./PHASE1_IMPLEMENTATION_ROADMAP.md)
2. [Project Status](./project/PROJECT_STATUS.md)
3. [Strategy Overview](./business/STRATEGY_OVERVIEW.md)

---

## 🗂️ Archived Documents

Obsolete documentation has been moved to `_archive/`:

- **alpha/** — Alpha testing readiness docs (superseded by Phase 1 roadmap)
- **beta/** — Beta testing plans (not yet active)
- **complete-features/** — Documentation for completed features (Vocabulary Showdown, Vote to Skip, Phase 1-2)
- **network-bridge/** — Old network configuration docs (keep SUMMARY for reference)
- **branding/** — Branding assets and strategy (not MVP critical)

To access archived docs:
```bash
ls docs/_archive/
```

---

## 📊 Document Maintenance

**How to keep docs organized:**

1. **During development**: Create new docs in appropriate subfolder
   - Games → `docs/games/<category>/`
   - Project → `docs/project/`
   - Operations → `docs/` root

2. **When feature is complete**: Move docs to `_archive/complete-features/`

3. **When creating variant docs**: Use subfolder, don't duplicate in root

4. **Keep README.md in project root only**

---

## 📝 Active Files Summary

| Category | Files | Purpose |
|----------|-------|---------|
| **Testing** | 1 | GATE_0_AND_1_TEST_CHECKLIST.md |
| **Roadmap** | 1 | PHASE1_IMPLEMENTATION_ROADMAP.md |
| **Games** | 20+ | Game designs, specs, implementations |
| **Project** | 20+ | Architecture, epics, status, testing |
| **Business** | 5 | Strategy, personas, market analysis |
| **Operations** | 5 | Network, chat, build, endpoints |

**Total active docs: ~60 files** (down from 120+ before organization)

---

## 🔄 Last Reorganization

**Date:** 2026-04-05  
**Changes:**
- Moved root-level .md files to appropriate subdirectories
- Created `_archive/` for obsolete documents
- Consolidated network bridge docs (kept summary, archived old versions)
- Archived alpha/beta testing docs (roadmap is source of truth now)
- Kept only README.md in project root

**Result:** Cleaner structure, easier to navigate, archived docs still accessible.

---

**Need help finding something?** Check the directory tree above, or search:
```bash
find docs -name "*.md" | grep -i <search-term>
```
