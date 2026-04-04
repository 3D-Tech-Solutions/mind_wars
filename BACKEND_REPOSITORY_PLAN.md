# Mind Wars Backend Repository - Production Plan

**Status:** Planning Phase  
**Target Timeline:** Post-Alpha (May-June 2026)  
**Priority:** High (Required for production deployment)

---

## Executive Summary

This document outlines the plan to create a **standalone, production-ready backend repository** (`mind-wars-backend`) separate from the Flutter mobile app. This enables:

- ✅ Independent backend deployment without frontend code
- ✅ Faster backend deployments (separate CI/CD)
- ✅ Team specialization (backend vs frontend developers)
- ✅ Multiple frontend clients (mobile, web, desktop)
- ✅ Production security best practices
- ✅ Clear API contracts and versioning

---

## Phase 1: Repository Structure (Week 1-2)

### New Repository: `3D-Tech-Solutions/mind-wars-backend`

```
mind-wars-backend/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml              # Tests on every push
│   │   ├── build.yml           # Build Docker images
│   │   ├── deploy-dev.yml      # Deploy to dev/staging
│   │   └── deploy-prod.yml     # Deploy to production
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── ISSUE_TEMPLATE/
├── src/
│   ├── api-server/             # Express REST API
│   │   ├── src/
│   │   │   ├── index.js
│   │   │   ├── routes/
│   │   │   │   ├── auth.js
│   │   │   │   ├── games.js
│   │   │   │   ├── lobbies.js
│   │   │   │   ├── users.js
│   │   │   │   └── leaderboard.js
│   │   │   ├── middleware/
│   │   │   │   ├── auth.js
│   │   │   │   ├── errorHandler.js
│   │   │   │   ├── rateLimit.js
│   │   │   │   └── requestLogger.js
│   │   │   ├── models/
│   │   │   │   ├── User.js
│   │   │   │   ├── Lobby.js
│   │   │   │   └── GameResult.js
│   │   │   ├── controllers/
│   │   │   │   ├── authController.js
│   │   │   │   └── gameController.js
│   │   │   ├── services/
│   │   │   │   ├── authService.js
│   │   │   │   ├── gameService.js
│   │   │   │   └── emailService.js
│   │   │   ├── utils/
│   │   │   │   ├── database.js
│   │   │   │   ├── logger.js
│   │   │   │   └── validators.js
│   │   │   └── config/
│   │   │       ├── database.js
│   │   │       └── environment.js
│   │   ├── tests/
│   │   │   ├── unit/
│   │   │   │   ├── auth.test.js
│   │   │   │   ├── games.test.js
│   │   │   │   └── lobbies.test.js
│   │   │   ├── integration/
│   │   │   │   ├── api.test.js
│   │   │   │   └── database.test.js
│   │   │   └── fixtures/
│   │   │       └── testData.js
│   │   ├── package.json
│   │   ├── .env.example
│   │   └── Dockerfile
│   ├── multiplayer-server/     # Socket.io Multiplayer
│   │   ├── src/
│   │   │   ├── index.js
│   │   │   ├── handlers/
│   │   │   │   ├── connectionHandler.js
│   │   │   │   ├── lobbyHandler.js
│   │   │   │   └── gameHandler.js
│   │   │   ├── services/
│   │   │   │   ├── lobbyService.js
│   │   │   │   └── gameService.js
│   │   │   └── utils/
│   │   │       ├── database.js
│   │   │       └── logger.js
│   │   ├── tests/
│   │   ├── package.json
│   │   ├── .env.example
│   │   └── Dockerfile
│   └── nginx/                  # Reverse Proxy & Gateway
│       ├── nginx.conf
│       └── Dockerfile
├── db/
│   ├── migrations/             # Database migrations (Flyway/Liquibase)
│   │   ├── V001__initial_schema.sql
│   │   ├── V002__add_badges.sql
│   │   └── V003__add_vote_to_skip.sql
│   ├── schema.sql              # Full schema (generated from migrations)
│   ├── seeds/
│   │   ├── development.sql
│   │   └── production.sql
│   └── scripts/
│       ├── backup.sh
│       ├── restore.sh
│       └── migrate.sh
├── docker-compose.yml          # Development environment
├── docker-compose.prod.yml     # Production environment
├── Makefile                    # Common commands
├── docs/
│   ├── API.md                  # API documentation
│   ├── ARCHITECTURE.md         # System architecture
│   ├── DEPLOYMENT.md           # Deployment procedures
│   ├── DEVELOPMENT.md          # Dev environment setup
│   ├── SECURITY.md             # Security guidelines
│   ├── DATABASE.md             # Database documentation
│   ├── TROUBLESHOOTING.md      # Common issues
│   └── CONTRIBUTING.md         # Contributing guidelines
├── scripts/
│   ├── deploy-dev.sh
│   ├── deploy-prod.sh
│   ├── backup.sh
│   └── health-check.sh
├── config/
│   ├── dev.env.example
│   ├── staging.env.example
│   └── prod.env.example
├── .dockerignore
├── .gitignore
├── .env.example
├── .env.development.local      # .gitignored
├── .env.production.local       # .gitignored
├── package.json                # Root workspace (optional, for monorepo tooling)
├── README.md                   # Project overview
├── LICENSE
├── CHANGELOG.md
└── VERSION
```

---

## Phase 2: Code Organization (Week 2-3)

### 2.1 Copy & Restructure from mind-wars

**From:** `/mnt/d/source/3D-Tech-Solutions/mind-wars/backend/`  
**To:** `3D-Tech-Solutions/mind-wars-backend/src/`

**What to copy:**
- ✅ `api-server/` → `src/api-server/`
- ✅ `multiplayer-server/` → `src/multiplayer-server/`
- ✅ `database/` → `db/` (rename, restructure for migrations)
- ✅ `nginx.conf` → `src/nginx/`
- ✅ Docker configurations

**What NOT to copy:**
- ❌ Flutter/mobile code
- ❌ Assets specific to frontend
- ❌ Frontend build artifacts

### 2.2 Code Organization Improvements

**API Server Refactoring:**

```
# Before (monolithic)
src/api-server/src/
├── index.js
├── routes/
└── utils/

# After (organized)
src/api-server/src/
├── index.js
├── config/              # Configuration loading
├── routes/              # Request handlers
├── middleware/          # Reusable middleware
├── controllers/         # Business logic dispatch
├── services/            # Business logic implementation
├── models/              # Database models/schemas
├── utils/               # Helper functions
├── errors/              # Custom error classes
└── constants/           # Application constants
```

**Benefits:**
- Clear separation of concerns
- Easier testing
- Better team collaboration
- Easier to scale

### 2.3 Testing Setup

**Jest Configuration:**

```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'node',
  coveragePathIgnorePatterns: ['/node_modules/'],
  testMatch: ['**/?(*.)+(spec|test).js'],
  collectCoverageFrom: ['src/**/*.js'],
};
```

**Test Coverage Targets:**
- Controllers: 90%+
- Services: 85%+
- Utils: 80%+
- Overall: 80%+

**Test Types:**
- Unit tests (individual functions)
- Integration tests (API endpoints)
- Database tests (migrations, queries)
- Load tests (concurrent connections)

---

## Phase 3: CI/CD Pipeline (Week 3-4)

### 3.1 GitHub Actions Workflows

**File: `.github/workflows/ci.yml`**

```yaml
name: CI - Test & Lint

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
      redis:
        image: redis:7
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npm run lint
      - run: npm run test:unit
      - run: npm run test:integration
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/coverage-final.json
```

**File: `.github/workflows/build.yml`**

```yaml
name: Build Docker Images

on:
  push:
    branches: [main]
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: docker/setup-buildx-action@v2
      - uses: docker/build-push-action@v4
        with:
          context: ./src/api-server
          push: ${{ github.ref == 'refs/heads/main' }}
          tags: ghcr.io/${{ github.repository }}/api:${{ github.sha }}
```

**File: `.github/workflows/deploy-prod.yml`**

```yaml
name: Deploy to Production

on:
  release:
    types: [published]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Fly.io
        uses: superfly/flyctl-actions/setup-flyctl@master
      - run: flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
```

### 3.2 Deployment Environments

**Development (Continuous)**
- On every push to `develop` branch
- Auto-deployed to dev.api.mindwars.dev
- Run full test suite first

**Staging (Manual)**
- On demand, from `main` branch
- Deployed to staging.api.mindwars.dev
- Run smoke tests after deploy

**Production (Release)**
- Only on tagged releases (v1.0.0)
- Deployed to api.mindwars.com
- Blue-green deployment
- Automatic rollback on failure

---

## Phase 4: Production Infrastructure (Week 4-6)

### 4.1 Fly.io Setup

**File: `fly.toml`**

```toml
app = "mind-wars-api"
primary_region = "sjc"

[env]
NODE_ENV = "production"
API_PORT = 3000

[build]
dockerfile = "src/api-server/Dockerfile"

[[services]]
internal_port = 3000
protocol = "tcp"

[services.http_checks]
interval = 30000
timeout = 5000
path = "/health"
```

**Commands:**

```bash
# Create app
flyctl apps create mind-wars-api

# Create database
flyctl postgres create
flyctl postgres attach

# Create Redis
flyctl redis create
flyctl redis attach

# Deploy
flyctl deploy

# Monitor
flyctl logs --follow
flyctl status
flyctl metrics
```

### 4.2 AWS Setup (Alternative)

**Services:**
- ECS Fargate (container orchestration)
- RDS PostgreSQL (managed database)
- ElastiCache Redis (managed cache)
- Application Load Balancer
- CloudWatch (logging & monitoring)

### 4.3 Database Migrations

**Tool: Flyway** (SQL-based, simple)

```
db/migrations/
├── V001__initial_schema.sql
├── V002__add_badges.sql
├── V003__add_voting.sql
└── V004__optimize_indexes.sql
```

**Deploy:**

```bash
# Check status
flyway info

# Migrate
flyway migrate

# Validate
flyway validate
```

---

## Phase 5: Documentation (Week 6)

### 5.1 API Documentation

**Tool: OpenAPI/Swagger**

```yaml
# docs/openapi.yaml
openapi: 3.0.0
info:
  title: Mind Wars API
  version: 1.0.0
servers:
  - url: https://api.mindwars.com
paths:
  /api/auth/register:
    post:
      summary: Register new user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                email:
                  type: string
                password:
                  type: string
```

**Generated from code:**

```bash
npm run docs:generate  # Creates docs/openapi.yaml
npm run docs:serve    # Opens Swagger UI at localhost:8080
```

### 5.2 Architecture Documentation

**File: `docs/ARCHITECTURE.md`**

- System design diagrams
- Data flow
- Service dependencies
- API contracts
- Database schema

### 5.3 Deployment Documentation

**File: `docs/DEPLOYMENT.md`**

- Step-by-step Fly.io setup
- AWS ECS setup
- Health checks
- Monitoring
- Troubleshooting

---

## Phase 6: Monitoring & Logging (Week 7)

### 6.1 Structured Logging

**File: `src/api-server/src/utils/logger.js`**

```javascript
const winston = require('winston');

const logger = winston.createLogger({
  format: winston.format.json(),
  transports: [
    new winston.transports.Console(),
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});
```

**Log Format:**

```json
{
  "timestamp": "2026-04-04T12:34:56Z",
  "level": "info",
  "service": "api-server",
  "message": "User registered",
  "userId": "uuid",
  "duration": 145,
  "traceId": "xxx"
}
```

### 6.2 Monitoring Stack

**Option 1: Datadog**

```yaml
# src/api-server/Dockerfile
ENV DD_TRACE_ENABLED=true
ENV DD_SERVICE=api-server
ENV DD_VERSION=1.0.0
```

**Option 2: New Relic**

```javascript
// src/api-server/src/index.js
require('newrelic');
```

**Option 3: Open Source (Prometheus + Grafana)**

```javascript
const prometheus = require('prom-client');
const httpRequestDuration = new prometheus.Histogram(...);
app.use((req, res) => {
  httpRequestDuration.observe({...});
});
```

### 6.3 Alerting

**High Priority:**
- API response time > 1s
- Error rate > 1%
- Database connection pool exhausted
- WebSocket disconnections > 5%

**Medium Priority:**
- Memory usage > 80%
- CPU > 70%
- Log errors (not in filters)

---

## Phase 7: Team Handoff (Week 8)

### 7.1 Team Training

- [ ] Backend devs understand repository structure
- [ ] Devops understands CI/CD pipeline
- [ ] QA understands test procedures
- [ ] Frontend devs understand API contracts

### 7.2 Documentation Checklist

- [ ] README.md complete
- [ ] CONTRIBUTING.md ready
- [ ] API documentation published
- [ ] Architecture documented
- [ ] Deployment procedures tested
- [ ] Troubleshooting guide ready

### 7.3 Go-Live Preparation

- [ ] Staging environment tested
- [ ] Load testing passed (100+ concurrent)
- [ ] Security audit completed
- [ ] Backup procedures tested
- [ ] Rollback procedures documented
- [ ] On-call procedures established

---

## Timeline & Milestones

| Phase | Duration | Completion |
|-------|----------|------------|
| Phase 1: Repository Setup | Weeks 1-2 | May 1 |
| Phase 2: Code Organization | Weeks 2-3 | May 8 |
| Phase 3: CI/CD Pipeline | Weeks 3-4 | May 15 |
| Phase 4: Infrastructure | Weeks 4-6 | May 29 |
| Phase 5: Documentation | Week 6 | June 1 |
| Phase 6: Monitoring | Week 7 | June 8 |
| Phase 7: Handoff | Week 8 | June 15 |

**Total Timeline:** 8 weeks (May - June 2026)

---

## Success Criteria

✅ **Code Quality**
- Test coverage > 80%
- Zero critical security findings
- All code reviewed by 2+ engineers

✅ **Infrastructure**
- Automatic deployments working
- <5 min deployment time
- 99.9% uptime in staging

✅ **Documentation**
- API docs auto-generated
- Architecture documented
- Deployment guide tested

✅ **Team Readiness**
- All team members trained
- On-call rotations established
- Runbooks prepared

---

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Database migration issues | High | Test migrations on staging first |
| Breaking API changes | High | Semantic versioning, API deprecation |
| Team coordination | Medium | Clear PR process, code review |
| Infrastructure costs | Medium | Monitor usage, set up budgets |

---

## Post-Launch Roadmap

**Month 1:** Stability
- Monitor production metrics
- Fix any bugs found
- Optimize performance

**Month 2:** Scaling
- Load test to 10k concurrent
- Optimize database queries
- Add caching layer

**Month 3:** Features
- API versioning (v2)
- GraphQL endpoint
- Webhook system

---

## Related Documents

- [Backend Deployment Guide](./BACKEND_DEPLOYMENT.md) — Current state
- [Production Deployment](./PRODUCTION_DEPLOYMENT.md) — Manual deployment
- [System Architecture](./docs/system_architrecture.md) — Current design

---

**Document Status:** Planning Phase  
**Last Updated:** April 4, 2026  
**Owner:** Architecture Team  
**Approval:** Pending CTO Review

**Next Action:** Approval → Begin Phase 1 (Repository Setup)
