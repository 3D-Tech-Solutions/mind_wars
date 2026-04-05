# LAN Multiplayer Testing Guide

**Date:** April 5, 2026
**Goal:** Verify 2+ Android devices can connect to LAN server and use multiplayer features

## Prerequisites

### 1. Server Setup (Host Machine: 172.16.0.4)
```bash
# Ensure backend is running
cd /mnt/d/source/3D-Tech-Solutions/mind-wars/backend
docker-compose up -d

# Verify services are healthy
docker-compose ps
curl http://localhost:3000/health
```

### 2. Network Configuration
- **Host Machine:** Connected to LAN at `172.16.0.4`
- **Test Devices:** Must be on same WiFi network (172.16.0.0/24)
- **Firewall:** Ensure ports 3000 (API) and 4001 (WebSocket) are accessible

## Testing Steps

### Step 1: Build LAN-Compatible APK
```bash
cd /mnt/d/source/3D-Tech-Solutions/mind-wars
./scripts/deploy.sh local 172.16.0.4 debug
```

### Step 2: Install on Multiple Devices
1. Connect Device A via USB → Install APK
2. Connect Device B via USB → Install APK
3. Disconnect USB cables (devices must use WiFi for LAN testing)

### Step 3: Test Scenarios

#### Scenario A: Basic Connectivity
- **Device A:** Open app → Should see "Backend health check passed"
- **Device B:** Open app → Should see "Backend health check passed"
- **Expected:** Both devices connect to server without timeout errors

#### Scenario B: Lobby Creation
- **Device A:** Login → Multiplayer → "Create a Mind War"
- **Device A:** Create lobby "Test Lobby" with 2-4 players
- **Expected:** Lobby created successfully, shows shareable code

#### Scenario C: Lobby Joining
- **Device B:** Login → Multiplayer → "Join Existing Lobby"
- **Device B:** Enter lobby code from Device A
- **Expected:** Device B joins lobby, both devices see each other in player list

#### Scenario D: Real-time Communication
- **Device A:** Send chat message
- **Expected:** Device B receives message instantly
- **Device B:** Change ready status
- **Expected:** Device A sees status change in real-time

#### Scenario E: Game Flow (if implemented)
- **Both devices:** Mark ready
- **Device A (host):** Start Mind War
- **Expected:** Both devices transition to game screen, can take turns

## Success Criteria

✅ **Connectivity:** Both devices pass health checks
✅ **Lobby Management:** Create/join lobbies works
✅ **Real-time Sync:** Player status, chat, lobby updates sync across devices
✅ **Game Flow:** Turn-based gameplay works (if implemented)
✅ **Error Handling:** Graceful handling of network issues

## Troubleshooting

### Issue: "Backend unhealthy" on devices
- Check if devices are on same WiFi network
- Verify host IP is still 172.16.0.4
- Test: `curl http://172.16.0.4:3000/health` from host

### Issue: Cannot join lobby
- Verify lobby code is correct
- Check WebSocket connection (port 4001)
- Look for Socket.io connection errors in device logs

### Issue: Real-time updates not working
- Check WebSocket connectivity
- Verify both devices are on same network
- Test: `telnet 172.16.0.4 4001` from devices

## Data Collection During Testing

Record observations:
- Connection stability
- Latency between actions
- Error messages
- Battery/network impact
- UI responsiveness

## Next Phase: Backend Extraction

Once LAN testing validates the infrastructure, extract backend into standalone repo:

### New Repository: `mind-wars-backend`
```
mind-wars-backend/
├── api-server/          # REST API (auth, data, validation)
├── multiplayer-server/  # Socket.io (real-time multiplayer)
├── database/           # Schema, migrations, seeds
├── docker-compose.yml  # Container orchestration
├── docs/              # API docs, deployment guides
└── scripts/           # Build, deploy, monitoring
```

### Services to Extract
1. **Authentication Service**
   - User registration/login
   - Session management
   - Profile management

2. **Game Data Service**
   - Game definitions and validation
   - Battle payload management
   - Server-side move validation

3. **Social Service**
   - Lobby management
   - Chat system
   - Friend relationships

4. **Analytics Service**
   - Game results collection
   - Leaderboard calculations
   - User progress tracking

### Integration Points
- **Mind Wars App:** Connects via REST API + WebSocket
- **Deployment:** Docker containers with nginx gateway
- **Scaling:** Redis for caching, PostgreSQL for persistence
- **Monitoring:** Health checks, logs, metrics

### Migration Plan
1. ✅ Validate current LAN multiplayer works
2. 🔄 Extract backend services to new repo
3. 🔄 Update main app to use extracted backend
4. 🔄 Add proper authentication flow
5. 🔄 Implement data persistence and analytics
6. 🔄 Add monitoring and deployment automation