# Beta Testing Quick Start Guide 🚀

## Overview

This guide provides a quick reference for deploying Mind Wars backend infrastructure for beta testing in a Docker environment.

**Last Updated**: March 26, 2026  
**For Detailed Documentation**: See [BETA_TESTING_ARCHITECTURE.md](BETA_TESTING_ARCHITECTURE.md)

---

## Prerequisites

- Docker 24.0 or later installed
- Docker Compose v2 installed
- Domain name configured (e.g., beta.mindwars.app)
- Server with at least 4 CPU, 8GB RAM, 50GB SSD

---

## Quick Deploy (5 Steps)

### 1. Clone Repository
```bash
git clone https://github.com/tescolopio/mind-wars.git
cd mind-wars/backend
```

### 2. Configure Environment
```bash
# Copy environment template
cp .env.example .env.beta

# Edit environment variables
nano .env.beta
```

Required environment variables:
```bash
# Database
DB_PASSWORD=<strong-password>

# Redis
REDIS_PASSWORD=<strong-password>

# JWT
JWT_SECRET=<random-secret-key>

# Grafana
GRAFANA_PASSWORD=<admin-password>

# Domain
DOMAIN=beta.mindwars.app
```

### 3. Start Services

> **Note:**  
> The following uses the Docker Compose v2 syntax (`docker compose`).  
> If you have Docker Compose v1 (deprecated), use `docker-compose` (with a hyphen) instead.

```bash
# Start all containers
# Docker Compose v2 (recommended)
docker compose -f docker-compose.beta.yml up -d

# Docker Compose v1 (deprecated)
docker-compose -f docker-compose.beta.yml up -d
# Check service health
docker compose ps
```

### 4. Run Database Migrations
```bash
# Run initial schema migration
docker compose exec api-server npm run migrate
```

### 5. Verify Deployment
```bash
# Test API endpoint
curl https://beta.mindwars.app/api/health

# Test Socket.io endpoint
curl https://beta.mindwars.app/socket.io/health

# Access Grafana (admin only)
open https://beta.mindwars.app:3002
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│          Docker Compose Stack                │
├─────────────────────────────────────────────┤
│                                               │
│  Mobile Clients (iOS/Android)               │
│         ↓                                    │
│    Nginx (Load Balancer + SSL)              │
│         ↓                                    │
│  ┌──────────────┬──────────────┐            │
│  │  API Server  │ Socket.io    │            │
│  │  (REST)      │ (WebSocket)  │            │
│  └──────────────┴──────────────┘            │
│         ↓                                    │
│  ┌──────────────┬──────────────┐            │
│  │ PostgreSQL   │    Redis     │            │
│  │ (Database)   │   (Cache)    │            │
│  └──────────────┴──────────────┘            │
│         ↓                                    │
│  ┌──────────────┬──────────────┐            │
│  │ Prometheus   │   Grafana    │            │
│  │ (Metrics)    │  (Dashboards)│            │
│  └──────────────┴──────────────┘            │
│                                               │
└─────────────────────────────────────────────┘
```

---

## Beta Testing Phases

### Phase 1: Internal Beta (2-4 weeks)
- **Users**: 10-20 (development team + friends/family)
- **Infrastructure**: Single Docker host
- **Focus**: Core functionality, critical bugs

### Phase 2: Closed Beta (4-6 weeks)
- **Users**: 50-100 (invited testers from target personas)
- **Infrastructure**: Vertical scaling (larger host)
- **Focus**: User experience, performance under load

### Phase 3: Open Beta (4-8 weeks)
- **Users**: 500-1000 (public sign-up with approval)
- **Infrastructure**: Kubernetes cluster with horizontal scaling
- **Focus**: Scalability, edge cases, community feedback

---

## Recommended Rollout Order

<!-- [2026-03-26 Testing] Added a feature-by-feature beta rollout order so the team validates one application area at a time against user stories before widening scope. -->

Do not expose the full app surface to beta testers on day one.

Run beta in controlled waves and only expand once the current wave satisfies its user stories and acceptance criteria.

### Wave 0: Account Entry
- install
- registration
- login
- onboarding
- profile setup

**Goal**: prove that a tester can go from invitation to usable home screen without support.

### Wave 1: Lobby Readiness
- create lobby
- join lobby
- leave lobby
- ready state updates

**Goal**: prove that groups can form a playable session reliably.

### Wave 2: One Gameplay Slice
- game selection or voting
- one representative game
- turn submission
- scoring
- results

**Goal**: prove one complete multiplayer flow before opening the wider game catalog.

### Wave 3: Social and Progression
- chat
- reactions
- leaderboard
- badges
- profile progression

**Goal**: validate retention and social value after core play is stable.

### Wave 4: Reliability and Recovery
- reconnect behavior
- offline scenarios
- sync and retry
- app background and resume

**Goal**: prove that real-world interruptions do not break user trust.

### Wave 5: Catalog Expansion
- additional games
- broader device coverage
- higher concurrency scenarios

**Goal**: widen confidence without regressing earlier validated flows.

### Rule For Advancing To The Next Wave

Do not advance a wave until:

- no P0 or P1 blocker remains in that area
- the target stories can be completed consistently by testers
- telemetry confirms successful completion of the target flow
- feedback from that wave has been reviewed and the critical fixes are deployed

---

## Android Device-First Validation

<!-- [2026-03-26 Testing] Added an Android phone-first beta validation path so the team can prove installability, first launch, and hosted connectivity on a real device before widening beta scope. -->

Yes, an Android phone is a valid and recommended first beta test device.

It is the right way to validate two separate concerns:

1. **Install and launch validation**: can the APK be delivered, installed, opened, and updated successfully on a real device?
2. **Hosted beta validation**: can the installed app reach the deployed backend and complete the current wave's user stories over real mobile networking?

### What Your Phone Can Prove Immediately

- the APK can be installed outside the development machine
- the app launches correctly on real Android hardware
- permissions, networking, and rendering work on-device
- the app can reach a public API and WebSocket server from cellular or Wi-Fi

### Important Limitation

Your phone can only validate the beta environment if the backend is reachable from the phone.

That means one of these must be true:

- the backend is deployed to a public host or domain
- the backend is exposed on your local network using a reachable machine IP
- you use a secure tunnel or equivalent external access path

If the backend only runs on `localhost` on your laptop, the phone cannot reach it directly.

### Recommended First Android Test Sequence

#### Step 1: Build the Android package

Use the existing Android build path:

```bash
flutter build apk --flavor alpha --release --dart-define=FLAVOR=alpha
```

You can also use the existing GitHub Actions workflow in [.github/workflows/build-alpha.yml](/mnt/d/source/3D-Tech-Solutions/mind-wars/.github/workflows/build-alpha.yml) to generate a tester APK artifact or prerelease.

#### Step 2: Install on your phone

- transfer the APK to the device
- enable installation from unknown sources if needed
- install the APK
- confirm the app icon, app name, and launch behavior are correct

#### Step 3: Validate Wave 0 on-device

Start with the first wave only:

- app opens successfully
- splash screen appears
- registration works
- login works
- onboarding works
- profile setup completes
- home screen becomes reachable without support

#### Step 4: Validate hosted connectivity

Once the backend is deployed and reachable:

- disable any device-side assumptions that only work on emulator or localhost
- test over Wi-Fi first
- test again over cellular if possible
- verify API-backed flows and multiplayer socket connectivity

#### Step 5: Promote to the next wave only if Wave 0 passes

Do not begin lobby or gameplay beta validation until account entry is stable on the real device.

### Android Smoke Checklist

- APK installs successfully
- app launches from the launcher icon
- cold start reaches the expected first screen
- registration or login succeeds
- app survives background and resume during first session
- backend requests succeed from the phone
- socket connection succeeds from the phone
- uninstall and reinstall behavior is understood
- upgrading from one APK build to the next works as expected

### Current Project Note

The current app already targets externally reachable endpoints in the runtime service initialization in [lib/main.dart](/mnt/d/source/3D-Tech-Solutions/mind-wars/lib/main.dart), which means Android phone testing is feasible as long as that environment is live and healthy.

---

## User Journey Pipeline

### 1. Registration
```
Beta tester receives invitation code
   ↓
Opens Mind Wars app
   ↓
Enters invitation code + email + password
   ↓
Account created with JWT tokens
```

### 2. Lobby Creation
```
User clicks "Create Lobby"
   ↓
Configures lobby settings (name, max players, rounds)
   ↓
Lobby created with unique code (e.g., "FAMILY42")
   ↓
User shares code with friends/family
```

### 3. Joining Lobby
```
Other users receive lobby code
   ↓
Click "Join Lobby" and enter code
   ↓
Real-time lobby updates via Socket.io
   ↓
All players see each other in lobby
```

### 4. Game Selection
```
Host starts voting
   ↓
Players allocate points to preferred games
   ↓
Real-time vote counts displayed
   ↓
Host ends voting, top games selected
```

### 5. Gameplay
```
Game starts with turn order
   ↓
Current player takes turn
   ↓
Server validates move and calculates score
   ↓
Turn result broadcast to all players
   ↓
Next player notified
   ↓
Continue until all rounds complete
```

---

## Key Endpoints

### REST API (Port 443)
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/lobbies` - Create lobby
- `GET /api/lobbies` - List lobbies
- `POST /api/lobbies/:id/join` - Join lobby
- `POST /api/games/:id/turn` - Submit turn
- `POST /api/games/:id/validate` - Validate move
- `GET /api/leaderboard/weekly` - Get leaderboard

### Socket.io Events (Port 443/socket.io)
- `create-lobby` - Create new lobby
- `join-lobby` - Join existing lobby
- `leave-lobby` - Leave lobby
- `start-game` - Host starts game
- `make-turn` - Submit turn
- `chat-message` - Send chat message
- `emoji-reaction` - Send emoji reaction
- `vote-game` - Vote on game
- `vote-skip` - Vote to skip inactive player

---

## Monitoring & Debugging

### View Container Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api-server
docker compose logs -f socket-server
```

### Check Container Health
```bash
# All containers
docker compose ps

# Inspect specific container
docker compose exec api-server curl localhost:3000/health
```

### Access Grafana Dashboard
```
URL: https://beta.mindwars.app:3002
Username: admin
Password: <GRAFANA_PASSWORD from .env>

Dashboards:
- System Overview
- API Performance
- Database Metrics
- Socket.io Connections
```

### Access PostgreSQL
```bash
# Connect to database
docker compose exec postgres psql -U mindwars -d mindwars_beta

# View tables
\dt

# Query users
SELECT id, email, created_at FROM users LIMIT 10;
```

### Access Redis
```bash
# Connect to Redis
docker compose exec redis redis-cli -a <REDIS_PASSWORD>

# Check active sessions
KEYS session:*

# Get session data
GET session:<session_id>
```

---

## Common Issues & Solutions

### Issue: Containers won't start
```bash
# Check Docker daemon
sudo systemctl status docker

# Check logs
docker compose logs

# Restart Docker
sudo systemctl restart docker
```

### Issue: Database connection errors
```bash
# Verify PostgreSQL is running
docker compose ps postgres

# Check database logs
docker compose logs postgres

# Recreate database
docker compose down -v
docker compose up -d
```

### Issue: SSL certificate errors
```bash
# Verify domain DNS
dig beta.mindwars.app

# Renew Let's Encrypt certificate
docker compose exec nginx certbot renew

# Restart nginx
docker compose restart nginx
```

### Issue: High memory usage
```bash
# Check container resource usage
docker stats

# Restart specific container
docker compose restart api-server

# Scale down if needed
docker compose scale api-server=1
```

---

## Security Checklist

- [ ] SSL/TLS certificates configured (Let's Encrypt)
- [ ] Strong passwords in .env file
- [ ] Firewall configured (only ports 80, 443, 3002 open)
- [ ] PostgreSQL and Redis not exposed to internet
- [ ] Rate limiting enabled on API
- [ ] JWT tokens properly secured
- [ ] Server-side validation for all game logic
- [ ] Regular security updates applied

---

## Scaling Guide

### Vertical Scaling (Phase 2)
```bash
# Upgrade server to 8 CPU, 16GB RAM
# Restart containers with new resource limits

docker compose down
# Edit docker-compose.yml to increase resource limits
docker compose up -d
```

### Horizontal Scaling (Phase 3)
```bash
# Migrate to Kubernetes
# Use Kubernetes manifests in k8s/ directory

kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/redis.yaml
kubectl apply -f k8s/api-server.yaml
kubectl apply -f k8s/socket-server.yaml
kubectl apply -f k8s/nginx.yaml

# Scale API servers
kubectl scale deployment api-server --replicas=3

# Scale Socket.io servers
kubectl scale deployment socket-server --replicas=3
```

---

## Backup & Recovery

### Backup Database
```bash
# Create backup
docker compose exec postgres pg_dump -U mindwars mindwars_beta > backup-$(date +%Y%m%d).sql

# Compress backup
gzip backup-*.sql
```

### Restore Database
```bash
# Stop services
docker compose stop api-server socket-server

# Restore from backup
cat backup-20251112.sql | docker compose exec -T postgres psql -U mindwars mindwars_beta

# Restart services
docker compose start api-server socket-server
```

---

## Success Metrics

### Technical Metrics
- **Uptime**: >99% during beta period
- **API Latency**: p95 <500ms
- **Error Rate**: <1% of requests
- **WebSocket Stability**: >95% connections stable

### User Engagement Metrics
- **Registration Conversion**: >80% of invited users register
- **Lobby Completion Rate**: >70% of lobbies complete all games
- **DAU/MAU Ratio**: >30%
- **Average Session Length**: >15 minutes

---

## Next Steps

1. **Review Full Documentation**: [BETA_TESTING_ARCHITECTURE.md](BETA_TESTING_ARCHITECTURE.md)
2. **Check Product Backlog**: [PRODUCT_BACKLOG.md](PRODUCT_BACKLOG.md) - See Epics 13-16
3. **Review Alpha Testing**: [ALPHA_TESTING.md](ALPHA_TESTING.md) - Mobile app builds
4. **Set Up Monitoring**: Configure Grafana dashboards and alerts
5. **Invite Beta Testers**: Generate invitation codes and distribute

---

## Support & Resources

- **Documentation**: [BETA_TESTING_ARCHITECTURE.md](BETA_TESTING_ARCHITECTURE.md)
- **Product Backlog**: [PRODUCT_BACKLOG.md](PRODUCT_BACKLOG.md)
- **Architecture Overview**: [ARCHITECTURE.md](ARCHITECTURE.md)
- **Alpha Testing**: [ALPHA_TESTING.md](ALPHA_TESTING.md)
- **GitHub Issues**: Report bugs and feature requests
- **Team Chat**: For quick questions and discussions

---

**Document Status**: Ready for Internal Beta  
**Last Updated**: November 12, 2025  
**Maintained By**: DevOps Team

---

*For comprehensive details on all Epics, Features, and Tasks, refer to [BETA_TESTING_ARCHITECTURE.md](BETA_TESTING_ARCHITECTURE.md)*
