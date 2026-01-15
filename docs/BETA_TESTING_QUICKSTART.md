# Beta Testing Quick Start Guide 🚀

## Overview

This guide provides a quick reference for deploying Mind Wars backend infrastructure for beta testing in a Docker environment.

**Last Updated**: November 12, 2025  
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
