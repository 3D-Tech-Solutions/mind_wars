# Beta Testing Architecture - Mind Wars 🧠⚔️

## Document Purpose

This document outlines the architecture, infrastructure, and backlog items required for beta testing Mind Wars in a controlled Docker environment. It provides a comprehensive set of Epics, Features, and Tasks needed to deploy servers, manage user authentication, handle game lobbies, and support beta testers playing together.

**Last Updated**: November 12, 2025  
**Version**: 1.0  
**Status**: Planning Phase

---

## Table of Contents

1. [Beta Testing Overview](#beta-testing-overview)
2. [Architecture Overview](#architecture-overview)
3. [Docker Deployment Strategy](#docker-deployment-strategy)
4. [Beta Testing Backlog](#beta-testing-backlog)
   - [Epic 13: Beta Testing Infrastructure](#epic-13-beta-testing-infrastructure)
   - [Epic 14: Beta User Authentication & Management](#epic-14-beta-user-authentication--management)
   - [Epic 15: Beta Lobby & Game Session Management](#epic-15-beta-lobby--game-session-management)
   - [Epic 16: Beta Monitoring & Analytics](#epic-16-beta-monitoring--analytics)
5. [Beta Testing Pipeline](#beta-testing-pipeline)
6. [Network Architecture](#network-architecture)
7. [Security Considerations](#security-considerations)
8. [Scaling Strategy](#scaling-strategy)
9. [Deployment Checklist](#deployment-checklist)

---

## Beta Testing Overview

### Goals
- Deploy Mind Wars backend services in a **controlled Docker environment**
- Enable **beta testers to play together** with real multiplayer functionality
- Test the complete **authentication → lobby creation → gameplay pipeline**
- Gather performance metrics and user feedback before production launch
- Validate server-side game validation and anti-cheating measures

### Beta Testing Phases

#### Phase 1: Internal Beta (2-4 weeks)
- **Team**: Development team + close friends/family (10-20 users)
- **Focus**: Core functionality, critical bug identification
- **Infrastructure**: Single Docker host, minimal monitoring

#### Phase 2: Closed Beta (4-6 weeks)
- **Team**: Invited testers from target personas (50-100 users)
- **Focus**: User experience, performance under load, feature validation
- **Infrastructure**: Multi-container setup, comprehensive monitoring

#### Phase 3: Open Beta (4-8 weeks)
- **Team**: Public sign-up with approval (500-1000 users)
- **Focus**: Scalability, edge cases, community feedback
- **Infrastructure**: Orchestrated containers, auto-scaling, full observability

---

## Architecture Overview

### System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                         Beta Testing Environment                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │   Mobile     │    │   Mobile     │    │   Mobile     │      │
│  │   Client     │───▶│   Client     │───▶│   Client     │      │
│  │  (iOS/Android) │  │  (iOS/Android) │  │  (iOS/Android) │    │
│  └──────────────┘    └──────────────┘    └──────────────┘      │
│         │                    │                    │              │
│         └────────────────────┼────────────────────┘              │
│                              │                                   │
│                    ┌─────────▼─────────┐                         │
│                    │   Load Balancer   │                         │
│                    │   (nginx/traefik) │                         │
│                    └─────────┬─────────┘                         │
│                              │                                   │
│         ┌────────────────────┼────────────────────┐              │
│         │                    │                    │              │
│  ┌──────▼──────┐    ┌────────▼────────┐   ┌──────▼──────┐      │
│  │  REST API   │    │  Socket.io      │   │  Analytics  │      │
│  │  Server     │    │  Server         │   │  Service    │      │
│  │  (Node.js)  │    │  (Node.js)      │   │  (Node.js)  │      │
│  └──────┬──────┘    └────────┬────────┘   └──────┬──────┘      │
│         │                    │                    │              │
│         └────────────────────┼────────────────────┘              │
│                              │                                   │
│                    ┌─────────▼─────────┐                         │
│                    │    PostgreSQL     │                         │
│                    │    (Primary DB)   │                         │
│                    └───────────────────┘                         │
│                              │                                   │
│                    ┌─────────▼─────────┐                         │
│                    │      Redis        │                         │
│                    │  (Session Cache)  │                         │
│                    └───────────────────┘                         │
│                                                                   │
│  ┌──────────────────────────────────────────────────────┐       │
│  │              Docker Compose / Kubernetes              │       │
│  │          (Orchestration & Container Management)       │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Technology Stack for Beta

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Container Runtime** | Docker 24.x | Containerization platform |
| **Orchestration** | Docker Compose (Phase 1-2), Kubernetes (Phase 3) | Service orchestration |
| **Load Balancer** | Nginx or Traefik | Traffic distribution & SSL termination |
| **REST API** | Node.js 18.x + Express | RESTful endpoints for game logic |
| **WebSocket Server** | Node.js 18.x + Socket.io | Real-time multiplayer communication |
| **Database** | PostgreSQL 15.x | Primary data store |
| **Cache** | Redis 7.x | Session storage & real-time data |
| **Monitoring** | Prometheus + Grafana | Metrics & visualization |
| **Logging** | ELK Stack (Elasticsearch, Logstash, Kibana) | Centralized logging |
| **File Storage** | MinIO or S3-compatible | User uploads & game assets |

---

## Docker Deployment Strategy

### Multi-Container Architecture

#### Container 1: API Server
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY . .
EXPOSE 3000
CMD ["node", "src/api-server.js"]
```

**Responsibilities:**
- User authentication (JWT)
- Game lobby CRUD operations
- Score validation
- Leaderboard queries
- Sync operations for offline mode

#### Container 2: Socket.io Server
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY . .
EXPOSE 3001
CMD ["node", "src/socket-server.js"]
```

**Responsibilities:**
- Real-time multiplayer events
- Lobby management
- Turn notifications
- Chat & emoji reactions
- Vote-to-skip mechanics

#### Container 3: PostgreSQL Database
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: mindwars_beta
      POSTGRES_USER: mindwars
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    # ports:
    #   - "5432:5432"
```

**Schema:**
- users (authentication, profiles)
- lobbies (game sessions)
- games (game state, scores)
- leaderboards (rankings, badges)
- analytics_events (telemetry)

#### Container 4: Redis Cache
```yaml
redis:
  image: redis:7-alpine
  command: redis-server --requirepass ${REDIS_PASSWORD}
  volumes:
    - redis_data:/data
```

**Use Cases:**
- Session storage (JWT tokens)
- Real-time lobby state
- Rate limiting
- Leaderboard caching

#### Container 5: Nginx Load Balancer
```nginx
upstream api_backend {
    server api-server:3000;
}

upstream socket_backend {
    server socket-server:3001;
}

server {
    listen 80;
    server_name beta.mindwars.app;

    location /api/ {
        proxy_pass http://api_backend;
    }

    location /socket.io/ {
        proxy_pass http://socket_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

---

## Beta Testing Backlog

### Total Beta Testing Story Points: 147 points
**Estimated Duration**: 6-8 weeks (3-4 sprints)

---

## Epic 13: Beta Testing Infrastructure

**Epic Priority**: P0 - Critical  
**Business Value**: Enables beta testing environment for controlled rollout  
**Epic Story Points**: 60 points  
**Dependencies**: Phase 1 completion (Epics 1-4)

### Feature 13.1: Docker Environment Setup ⭐ P0

**Story**: As a DevOps engineer, I want to set up a Docker-based deployment environment so that we can deploy backend services for beta testing

**Story Points**: 13  
**Acceptance Criteria**:
- Docker and Docker Compose installed on beta server
- Multi-container architecture defined
- Container networking configured
- Volume mounts for data persistence
- Environment variables managed securely
- Health checks configured for all services
- Containers restart automatically on failure

**Tasks**:
- [ ] **Task 13.1.1**: Set up Docker host environment (2 pts)
  - Install Docker Engine 24+
  - Install Docker Compose v2
  - Configure Docker daemon settings
  - Set up log rotation
  - Configure resource limits (CPU, memory)

- [ ] **Task 13.1.2**: Create Docker Compose configuration (5 pts)
  - Define all services (API, Socket.io, PostgreSQL, Redis, Nginx)
  - Configure container networking (bridge network)
  - Set up volume mounts for persistence
  - Define health checks for each service
  - Configure restart policies
  - Set resource constraints

- [ ] **Task 13.1.3**: Create Dockerfiles for custom services (3 pts)
  - API server Dockerfile
  - Socket.io server Dockerfile
  - Multi-stage builds for optimization
  - Security hardening (non-root user)

- [ ] **Task 13.1.4**: Configure environment variables (2 pts)
  - Create `.env.beta` template
  - Set up secret management (Docker secrets or env files)
  - Document all required environment variables
  - Implement environment validation on startup

- [ ] **Task 13.1.5**: Test container orchestration (1 pt)
  - Test `docker compose up`
  - Verify inter-container communication
  - Test container restart behavior
  - Validate volume persistence

### Feature 13.2: Backend API Server Implementation ⭐ P0

**Story**: As a backend developer, I want to implement the REST API server so that mobile clients can communicate with the backend

**Story Points**: 13  
**Acceptance Criteria**:
- Node.js 18.x/Express server running in Docker
- All required endpoints implemented (auth, lobbies, games, leaderboards, sync)
- JWT authentication middleware
- Request validation and error handling
- Rate limiting configured
- CORS configured for mobile clients
- API documentation available

**Tasks**:
- [ ] **Task 13.2.1**: Set up Express.js server (3 pts)
  - Initialize Node.js project
  - Configure Express with middleware
  - Set up routing structure
  - Configure CORS for mobile clients
  - Add request logging

- [ ] **Task 13.2.2**: Implement authentication endpoints (3 pts)
  - POST /api/auth/register
  - POST /api/auth/login
  - POST /api/auth/logout
  - POST /api/auth/refresh
  - JWT token generation and validation
  - Password hashing with bcrypt

- [ ] **Task 13.2.3**: Implement game lobby endpoints (3 pts)
  - GET /api/lobbies (list lobbies)
  - POST /api/lobbies (create lobby)
  - GET /api/lobbies/:id (get lobby details)
  - PUT /api/lobbies/:id (update lobby)
  - DELETE /api/lobbies/:id (close lobby)
  - POST /api/lobbies/:id/join
  - POST /api/lobbies/:id/leave

- [ ] **Task 13.2.4**: Implement game validation endpoints (2 pts)
  - POST /api/games/:id/submit (submit score)
  - POST /api/games/:id/validate-move (validate move)
  - GET /api/games/:id/state (get game state)

- [ ] **Task 13.2.5**: Implement sync and leaderboard endpoints (2 pts)
  - POST /api/sync/game (sync offline game)
  - POST /api/sync/batch (batch sync)
  - GET /api/leaderboard/weekly
  - GET /api/leaderboard/all-time
  - GET /api/users/:id/progress

### Feature 13.3: Socket.io Multiplayer Server ⭐ P0

**Story**: As a backend developer, I want to implement the Socket.io server so that players can interact in real-time

**Story Points**: 13  
**Acceptance Criteria**:
- Socket.io server running in separate container
- All multiplayer events handled (lobby, turns, chat, voting)
- Player presence tracking
- Automatic reconnection support
- Room-based communication (lobby isolation)
- Event validation and error handling
- Connection rate limiting

**Tasks**:
- [ ] **Task 13.3.1**: Set up Socket.io server (3 pts)
  - Initialize Socket.io with Express
  - Configure connection middleware
  - Set up namespace and room management
  - Configure CORS for mobile clients
  - Add connection logging

- [ ] **Task 13.3.2**: Implement lobby events (3 pts)
  - `create-lobby` event handler
  - `join-lobby` event handler
  - `leave-lobby` event handler
  - `start-game` event handler
  - Lobby state synchronization
  - Player list updates

- [ ] **Task 13.3.3**: Implement game events (3 pts)
  - `make-turn` event handler
  - `game-ended` event handler
  - Turn validation
  - Score updates
  - Game state broadcasts

- [ ] **Task 13.3.4**: Implement social events (2 pts)
  - `chat-message` handler
  - `emoji-reaction` handler
  - `vote-skip` handler
  - Profanity filtering for chat
  - Message rate limiting

- [ ] **Task 13.3.5**: Implement voting system events (2 pts)
  - `start-voting` handler
  - `vote-game` handler
  - `remove-vote` handler
  - `end-voting` handler
  - Real-time vote count updates

### Feature 13.4: Database Schema & Migrations ⭐ P0

**Story**: As a backend developer, I want to set up the PostgreSQL database schema so that we can persist game data

**Story Points**: 8  
**Acceptance Criteria**:
- PostgreSQL container running with persistent storage
- Database schema created for all entities
- Migration scripts for schema versioning
- Indexes optimized for query performance
- Foreign key constraints configured
- Connection pooling configured
- Backup strategy defined

**Tasks**:
- [ ] **Task 13.4.1**: Design database schema (2 pts)
  - users table (authentication, profiles)
  - lobbies table (game sessions)
  - lobby_players table (many-to-many)
  - games table (game instances)
  - game_scores table (player scores)
  - leaderboards table (rankings)
  - badges table (achievements)
  - analytics_events table (telemetry)

- [ ] **Task 13.4.2**: Create migration scripts (2 pts)
  - Initial schema migration
  - Set up migration tool (e.g., node-pg-migrate)
  - Create up/down migrations
  - Document migration process

- [ ] **Task 13.4.3**: Optimize indexes (2 pts)
  - Index on users.email (login)
  - Index on lobbies.code (join by code)
  - Index on leaderboards.score (rankings)
  - Composite indexes for common queries
  - Analyze query performance

- [ ] **Task 13.4.4**: Configure connection pooling (1 pt)
  - Set up pg-pool with optimal settings
  - Configure connection limits
  - Add connection error handling
  - Monitor connection pool usage

- [ ] **Task 13.4.5**: Set up automated backups (1 pt)
  - Configure pg_dump scheduled backups
  - Store backups in persistent volume
  - Test restore procedure
  - Document backup/restore process

### Feature 13.5: Load Balancing & SSL Configuration ⭐ P1

**Story**: As a DevOps engineer, I want to configure a load balancer with SSL so that traffic is distributed and secure

**Story Points**: 8  
**Acceptance Criteria**:
- Nginx or Traefik container running as reverse proxy
- SSL/TLS certificates configured (Let's Encrypt)
- HTTP to HTTPS redirect
- WebSocket proxying for Socket.io
- Static asset caching
- Security headers configured
- Rate limiting per IP

**Tasks**:
- [ ] **Task 13.5.1**: Set up Nginx/Traefik container (2 pts)
  - Add to Docker Compose
  - Configure upstream servers
  - Set up proxy_pass rules
  - Configure logging

- [ ] **Task 13.5.2**: Configure SSL certificates (2 pts)
  - Set up Let's Encrypt with Certbot
  - Configure auto-renewal
  - Redirect HTTP to HTTPS
  - Configure SSL protocols and ciphers

- [ ] **Task 13.5.3**: Configure WebSocket proxying (2 pts)
  - Enable WebSocket upgrade headers
  - Configure sticky sessions for Socket.io
  - Test WebSocket connections through proxy
  - Add WebSocket-specific timeouts

- [ ] **Task 13.5.4**: Add security configurations (2 pts)
  - Security headers (HSTS, CSP, X-Frame-Options)
  - Rate limiting per IP
  - Request size limits
  - DDoS protection basics

### Feature 13.6: Email Service Configuration ⭐ P0

**Story**: As a DevOps engineer, I want to configure an email service so that the system can send transactional emails to beta testers

**Story Points**: 5  
**Acceptance Criteria**:
- Email service provider configured (SendGrid, AWS SES, or SMTP)
- API keys/credentials stored securely in environment variables
- Email templates for transactional emails defined
- Email sending functionality tested
- Bounce and complaint handling configured
- Email rate limits understood and documented
- Fallback SMTP option available

**Tasks**:
- [ ] **Task 13.6.1**: Select and configure email service provider (2 pts)
  - Evaluate options (SendGrid, AWS SES, Mailgun, SMTP)
  - Create account and obtain API keys
  - Configure domain verification (SPF, DKIM records)
  - Set up sender email address (e.g., noreply@mindwars.app)
  
- [ ] **Task 13.6.2**: Configure email service in backend (2 pts)
  - Install email service SDK (e.g., @sendgrid/mail, aws-sdk)
  - Add email service credentials to environment variables
  - Create email service wrapper module
  - Implement retry logic for failed sends
  - Add email sending to API server configuration

- [ ] **Task 13.6.3**: Test email delivery and configure monitoring (1 pt)
  - Test welcome email sending
  - Set up bounce and complaint handling webhooks
  - Configure email sending rate limits
  - Add email delivery metrics to monitoring
  - Document email service configuration and troubleshooting

---

## Epic 14: Beta User Authentication & Management

**Epic Priority**: P0 - Critical  
**Business Value**: Enables secure user access for beta testers  
**Epic Story Points**: 34 points  
**Dependencies**: Epic 13 (Infrastructure)

### Feature 14.1: Beta Tester Registration System ⭐ P0

**Story**: As a beta tester, I want to register for an account so that I can participate in beta testing

**Story Points**: 8  
**Acceptance Criteria**:
- Beta invitation code required for registration
- Email validation before account activation
- Password strength requirements enforced
- Duplicate email detection
- Registration rate limiting
- Welcome email sent on successful registration
- User profile created automatically

**Tasks**:
- [ ] **Task 14.1.1**: Implement invitation code system (3 pts)
  - Generate unique invitation codes
  - Store codes in database with usage limits
  - Validate codes during registration
  - Track code usage and redemptions

- [ ] **Task 14.1.2**: Implement registration validation (2 pts)
  - Email format validation
  - Password strength validation (8+ chars, mixed case, numbers, special characters)
  - Duplicate email check
  - Invitation code validation

- [ ] **Task 14.1.3**: Create user accounts (2 pts)
  - Hash passwords with bcrypt
  - Create user record in database
  - Generate default profile
  - Assign default settings

- [ ] **Task 14.1.4**: Send welcome email (1 pt)
  - Email template for beta welcome
  - Include beta testing guidelines
  - Link to support channels
  - Send via email service (SendGrid/SES)

### Feature 14.2: JWT Token Authentication ⭐ P0

**Story**: As a developer, I want JWT-based authentication so that API requests are secure and stateless

**Story Points**: 8  
**Acceptance Criteria**:
- JWT tokens generated on login
- Access tokens (15 min expiry)
- Refresh tokens (7 day expiry)
- Token validation middleware
- Token blacklisting for logout
- Token stored securely in Redis
- Automatic token refresh on client

**Tasks**:
- [ ] **Task 14.2.1**: Implement JWT generation (2 pts)
  - Generate access tokens (15 min expiry)
  - Generate refresh tokens (7 day expiry)
  - Include user ID and role in payload
  - Sign with secret key (from env)

- [ ] **Task 14.2.2**: Create authentication middleware (2 pts)
  - Validate JWT from Authorization header
  - Extract user info from token
  - Attach user to request object
  - Handle expired tokens

- [ ] **Task 14.2.3**: Implement token refresh flow (2 pts)
  - POST /api/auth/refresh endpoint
  - Validate refresh token
  - Issue new access token
  - Rotate refresh token

- [ ] **Task 14.2.4**: Implement token blacklisting (2 pts)
  - Store invalidated tokens in Redis
  - Check blacklist during validation
  - Clean up expired blacklist entries
  - Implement logout (add token to blacklist)

### Feature 14.3: Beta Tester Role Management ⭐ P1

**Story**: As an admin, I want to manage beta tester roles so that I can control access levels

**Story Points**: 8  
**Acceptance Criteria**:
- Three roles: admin, moderator, tester
- Role-based permissions defined
- Admins can assign/revoke roles
- Role checked in authorization middleware
- Audit log for role changes
- Default role is 'tester'

**Tasks**:
- [ ] **Task 14.3.1**: Define role schema (2 pts)
  - Add role column to users table
  - Define role enum (admin, moderator, tester)
  - Create permissions mapping
  - Set default role to 'tester'

- [ ] **Task 14.3.2**: Implement role assignment (2 pts)
  - Admin endpoint to assign roles
  - Validation for role changes
  - Prevent self-demotion for admins
  - Return updated user with role

- [ ] **Task 14.3.3**: Create authorization middleware (2 pts)
  - Check user role for protected routes
  - requireRole() middleware function
  - Return 403 for insufficient permissions
  - Log unauthorized access attempts

- [ ] **Task 14.3.4**: Add role audit logging (2 pts)
  - Log all role changes
  - Include who changed, when, and what
  - Store in audit_log table
  - Create admin view for audit logs

### Feature 14.4: Session Management & Rate Limiting ⭐ P1

**Story**: As a developer, I want to manage user sessions and rate limits so that the system is protected from abuse

**Story Points**: 5  
**Acceptance Criteria**:
- Active sessions tracked in Redis
- Max 3 concurrent sessions per user
- Login rate limiting (5 attempts per 15 min)
- API rate limiting (100 req/min per user)
- Session invalidation on password change
- Session list viewable by user

**Tasks**:
- [ ] **Task 14.4.1**: Implement session tracking (2 pts)
  - Store active sessions in Redis
  - Key: user_id, value: list of session tokens
  - Limit to 3 sessions per user
  - Expire oldest session if limit exceeded

- [ ] **Task 14.4.2**: Implement login rate limiting (1 pt)
  - Track failed login attempts per email
  - Block after 5 failures in 15 minutes
  - Reset counter on successful login
  - Return clear error message when blocked

- [ ] **Task 14.4.3**: Implement API rate limiting (1 pt)
  - Use Redis for rate limit counters
  - 100 requests per minute per user
  - Return 429 status when exceeded
  - Include retry-after header

- [ ] **Task 14.4.4**: Implement session management endpoints (1 pt)
  - GET /api/auth/sessions (list active sessions)
  - DELETE /api/auth/sessions/:id (revoke session)
  - DELETE /api/auth/sessions/all (revoke all sessions)

### Feature 14.5: Beta Tester Profile Management ⭐ P1

**Story**: As a beta tester, I want to manage my profile so that I can personalize my experience

**Story Points**: 5  
**Acceptance Criteria**:
- Display name editable
- Avatar selection (preset options)
- Email change with verification
- Password change with current password
- Profile visible to other players
- Profile sync across devices

**Tasks**:
- [ ] **Task 14.5.1**: Implement profile update endpoint (2 pts)
  - PUT /api/users/:id/profile
  - Validate display name (3-20 chars)
  - Update user record
  - Return updated profile

- [ ] **Task 14.5.2**: Implement avatar selection (1 pt)
  - Provide list of preset avatars
  - Store avatar ID in user profile
  - Serve avatar images from static assets
  - Default avatar assigned on registration

- [ ] **Task 14.5.3**: Implement email change flow (1 pt)
  - Request email change with verification
  - Send verification email to new address
  - Confirm with verification token
  - Update email in database

- [ ] **Task 14.5.4**: Implement password change (1 pt)
  - Require current password for verification
  - Validate new password strength
  - Hash new password
  - Invalidate all sessions on password change

---

## Epic 15: Beta Lobby & Game Session Management

**Epic Priority**: P0 - Critical  
**Business Value**: Core multiplayer functionality for beta testing  
**Epic Story Points**: 34 points  
**Dependencies**: Epic 13 (Infrastructure), Epic 14 (Authentication)

### Feature 15.1: Game Lobby Creation & Discovery ⭐ P0

**Story**: As a beta tester, I want to create and join game lobbies so that I can play with other testers

**Story Points**: 8  
**Acceptance Criteria**:
- Create lobby with unique code
- Max 10 players per lobby
- Private lobbies (default) and public lobbies
- Lobby code shareable via text/messaging apps
- Search lobbies by code
- Browse public lobbies
- Real-time lobby list updates

**Tasks**:
- [ ] **Task 15.1.1**: Implement lobby creation (2 pts)
  - POST /api/lobbies endpoint
  - Generate unique 6-digit lobby code
  - Set creator as host
  - Default to private lobby
  - Store in database

- [ ] **Task 15.1.2**: Implement lobby discovery (2 pts)
  - GET /api/lobbies (list lobbies)
  - Filter by status (waiting, in-progress, completed)
  - Filter by privacy (public only for discovery)
  - Paginate results
  - Return lobby metadata

- [ ] **Task 15.1.3**: Implement lobby join by code (2 pts)
  - POST /api/lobbies/join with code
  - Validate lobby exists and not full
  - Add player to lobby
  - Emit join event via Socket.io
  - Return lobby details

- [ ] **Task 15.1.4**: Real-time lobby updates (2 pts)
  - Emit `lobby-updated` event on changes
  - Emit `player-joined` event
  - Emit `player-left` event
  - Update lobby state in clients

### Feature 15.2: Lobby Host Controls ⭐ P0

**Story**: As a lobby host, I want to manage my lobby so that I can control the game experience

**Story Points**: 8  
**Acceptance Criteria**:
- Start game when ready
- Kick players if needed
- Transfer host role
- Change lobby settings (player count, rounds)
- Close/delete lobby
- Only host can perform these actions

**Tasks**:
- [ ] **Task 15.2.1**: Implement start game action (2 pts)
  - POST /api/lobbies/:id/start endpoint
  - Validate only host can start
  - Validate minimum 2 players
  - Change lobby status to 'in-progress'
  - Emit `game-started` event

- [ ] **Task 15.2.2**: Implement kick player action (2 pts)
  - POST /api/lobbies/:id/kick with player ID
  - Validate only host can kick
  - Remove player from lobby
  - Emit `player-kicked` event
  - Notify kicked player

- [ ] **Task 15.2.3**: Implement host transfer (2 pts)
  - POST /api/lobbies/:id/transfer-host
  - Validate only current host can transfer
  - Update host in database
  - Emit `host-changed` event
  - Notify all players

- [ ] **Task 15.2.4**: Implement lobby settings update (2 pts)
  - PUT /api/lobbies/:id/settings
  - Validate only host can update
  - Allow changing max players, rounds
  - Validate constraints (2-10 players, 1-10 rounds)
  - Emit `settings-updated` event

### Feature 15.3: Game Session State Management ⭐ P0

**Story**: As a developer, I want to manage game session state so that turns and scoring work correctly

**Story Points**: 8  
**Acceptance Criteria**:
- Track current game round
- Track whose turn it is
- Validate turn order
- Store game state in database
- Handle player disconnections
- Resume game on reconnection
- Game timeout after 48h inactivity

**Tasks**:
- [ ] **Task 15.3.1**: Implement game state storage (2 pts)
  - Create games table with state JSON
  - Store current round, turn order, scores
  - Update state on each turn
  - Index on lobby_id for fast queries

- [ ] **Task 15.3.2**: Implement turn management (2 pts)
  - Calculate next player in turn order
  - Validate current player before accepting turn
  - Update turn counter
  - Emit `turn-changed` event
  - Notify next player

- [ ] **Task 15.3.3**: Handle disconnections/reconnections (2 pts)
  - Mark player as disconnected on socket disconnect
  - Resume game state on reconnection
  - Send full game state to reconnected player
  - Continue game if player disconnects briefly

- [ ] **Task 15.3.4**: Implement game timeout (2 pts)
  - Background job to check game age
  - Auto-end games inactive >48 hours
  - Notify all players of timeout
  - Calculate partial scores
  - Update lobby status to 'completed'

### Feature 15.4: Turn-Based Gameplay Flow ⭐ P0

**Story**: As a beta tester, I want to take my turn so that the game progresses

**Story Points**: 5  
**Acceptance Criteria**:
- Submit turn data from client
- Validate turn on server
- Calculate score for turn
- Broadcast turn result to all players
- Advance to next player
- Handle invalid turns gracefully

**Tasks**:
- [ ] **Task 15.4.1**: Implement turn submission (2 pts)
  - POST /api/games/:id/turn endpoint
  - Validate player's turn
  - Validate turn data structure
  - Store turn in database
  - Return validation result

- [ ] **Task 15.4.2**: Implement turn validation (2 pts)
  - Server-side game logic validation
  - Check move validity for game type
  - Prevent cheating (time, accuracy)
  - Return detailed error for invalid turns

- [ ] **Task 15.4.3**: Broadcast turn results (1 pt)
  - Emit `turn-completed` event to lobby
  - Include player ID, score, next player
  - Update real-time lobby state
  - Trigger next player notification

### Feature 15.5: Game Voting System ⭐ P0

**Story**: As a beta tester, I want to vote on which games to play so that everyone enjoys the session

**Story Points**: 5  
**Acceptance Criteria**:
- Vote on multiple games with point allocation
- Change votes before voting ends
- Host can start/end voting
- Top voted games selected for play
- Real-time vote count updates

**Tasks**:
- [ ] **Task 15.5.1**: Implement voting session (2 pts)
  - POST /api/lobbies/:id/voting/start (host only)
  - Store voting session with available games
  - Allocate points to each player (e.g., 10 points)
  - Set voting deadline

- [ ] **Task 15.5.2**: Implement vote casting (1 pt)
  - POST /api/lobbies/:id/voting/vote
  - Validate total points not exceeded
  - Allow changing votes
  - Store votes in database
  - Emit `vote-cast` event

- [ ] **Task 15.5.3**: Implement voting results (2 pts)
  - POST /api/lobbies/:id/voting/end (host only)
  - Calculate top N games by points
  - Store selected games
  - Emit `voting-ended` event with results
  - Start game with selected games

---

## Epic 16: Beta Monitoring & Analytics

**Epic Priority**: P1 - High  
**Business Value**: Insights for improving beta and production  
**Epic Story Points**: 21 points  
**Dependencies**: Epic 13 (Infrastructure)

### Feature 16.1: Application Metrics & Monitoring ⭐ P1

**Story**: As a DevOps engineer, I want to monitor application health so that I can detect and resolve issues quickly

**Story Points**: 8  
**Acceptance Criteria**:
- Prometheus metrics endpoint on all services
- Grafana dashboards for visualization
- Metrics for API requests, latency, errors
- Socket.io connection metrics
- Database query performance metrics
- Alert rules configured for critical issues

**Tasks**:
- [ ] **Task 16.1.1**: Set up Prometheus (2 pts)
  - Add Prometheus container to Docker Compose
  - Configure scraping targets (API, Socket.io)
  - Set up persistent storage for metrics
  - Configure retention policies

- [ ] **Task 16.1.2**: Add metrics to services (2 pts)
  - Install prom-client in Node.js services
  - Expose /metrics endpoint
  - Track HTTP request metrics (count, duration, status)
  - Track Socket.io connections (active, total)
  - Track database query metrics

- [ ] **Task 16.1.3**: Set up Grafana (2 pts)
  - Add Grafana container to Docker Compose
  - Configure Prometheus as data source
  - Create system overview dashboard
  - Create API performance dashboard
  - Create database dashboard

- [ ] **Task 16.1.4**: Configure alerting (2 pts)
  - Set up Alertmanager
  - Define alert rules (high error rate, high latency, service down)
  - Configure notification channels (email, Slack)
  - Test alert delivery

### Feature 16.2: Centralized Logging ⭐ P1

**Story**: As a developer, I want centralized logging so that I can debug issues efficiently

**Story Points**: 8  
**Acceptance Criteria**:
- All container logs forwarded to central location
- Elasticsearch for log storage
- Kibana for log visualization
- Structured JSON logging
- Log levels configurable
- Log retention policy (30 days)

**Tasks**:
- [ ] **Task 16.2.1**: Set up ELK stack (3 pts)
  - Add Elasticsearch container
  - Add Logstash container for log processing
  - Add Kibana container for visualization
  - Configure log ingestion pipeline

- [ ] **Task 16.2.2**: Configure structured logging (2 pts)
  - Use winston or pino in Node.js services
  - Log as JSON with consistent fields (timestamp, level, message, context)
  - Include request ID for tracing
  - Log errors with stack traces

- [ ] **Task 16.2.3**: Forward logs to Logstash (2 pts)
  - Configure Docker logging driver
  - Or use Filebeat to forward logs
  - Test log flow from services to Kibana
  - Create index patterns in Kibana

- [ ] **Task 16.2.4**: Create log dashboards (1 pt)
  - Dashboard for errors and exceptions
  - Dashboard for authentication events
  - Dashboard for game events
  - Set up log-based alerts

### Feature 16.3: User Analytics & Events ⭐ P1

**Story**: As a product manager, I want to track user behavior so that I can understand how beta testers use the app

**Story Points**: 5  
**Acceptance Criteria**:
- Track key events (registration, login, lobby creation, game completion)
- Store events in analytics_events table
- Event properties include context (user, session, device)
- Privacy-compliant (no PII in events)
- Export events for analysis
- Aggregate metrics available via API

**Tasks**:
- [ ] **Task 16.3.1**: Define event schema (1 pt)
  - Create analytics_events table
  - Define event types and properties
  - Include user_id, session_id, timestamp, event_type, properties (JSON)

- [ ] **Task 16.3.2**: Implement event tracking (2 pts)
  - POST /api/analytics/track endpoint
  - Validate event structure
  - Store in database asynchronously
  - Batch events to reduce DB load

- [ ] **Task 16.3.3**: Create analytics dashboards (1 pt)
  - Daily active users (DAU)
  - Lobby creation rate
  - Game completion rate
  - Average session duration
  - Funnel analysis (registration → game)

- [ ] **Task 16.3.4**: Implement event export (1 pt)
  - GET /api/analytics/events endpoint (admin only)
  - Filter by date range, event type
  - Export as CSV or JSON
  - Aggregate data before export

---

## Beta Testing Pipeline

### User Journey: Registration → Lobby → Game

```
┌──────────────────────────────────────────────────────────────────┐
│                  Beta Testing User Journey                        │
└──────────────────────────────────────────────────────────────────┘

1. Registration Phase
   ┌─────────────────┐
   │ Beta tester     │
   │ receives        │──▶ Invitation code
   │ invitation      │    (via email/admin)
   └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ Open Mind Wars  │
   │ mobile app      │──▶ First launch
   │ (Alpha/Beta)    │
   └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ Registration    │
   │ screen          │──▶ Enter invitation code
   │                 │──▶ Enter email & password
   │                 │──▶ Create profile (name, avatar)
   └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ Account created │──▶ JWT tokens issued
   │ & logged in     │──▶ Welcome screen shown
   └─────────────────┘

2. Lobby Creation Phase
   ┌─────────────────┐
   │ Home screen     │──▶ "Create Lobby" button
   └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ Lobby creation  │──▶ Configure settings:
   │ screen          │     - Lobby name
   │                 │     - Max players (2-10)
   │                 │     - Number of rounds
   │                 │     - Private/Public
   └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ Lobby created   │──▶ Unique code generated
   │                 │──▶ Share code with friends
   │                 │──▶ WebSocket connection established
   └─────────────────┘

3. Joining Lobby Phase
   ┌─────────────────┐
   │ Other testers   │──▶ Receive lobby code
   │                 │    (via text, messaging app)
   └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ Home screen     │──▶ "Join Lobby" button
   │                 │──▶ Enter lobby code
   └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ Joined lobby    │──▶ See other players
   │                 │──▶ Real-time updates
   │                 │──▶ Chat available
   └─────────────────┘

4. Game Selection Phase
   ┌─────────────────┐
   │ Host starts     │──▶ "Start Voting" button
   │ voting          │
   └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ All players     │──▶ View available games
   │ vote on games   │──▶ Allocate points (e.g., 10 points)
   │                 │──▶ Real-time vote counts
   └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ Host ends       │──▶ Top games selected
   │ voting          │──▶ Game queue created
   └─────────────────┘

5. Gameplay Phase
   ┌─────────────────┐
   │ Game starts     │──▶ First game loads
   │                 │──▶ Turn order determined
   └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ Player's turn   │──▶ Play game (e.g., Memory Match)
   │                 │──▶ Submit answer
   │                 │──▶ Server validates & scores
   └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ Turn completed  │──▶ Score displayed
   │                 │──▶ Next player notified
   │                 │──▶ Leaderboard updates
   └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ All players     │──▶ Continue until all turns taken
   │ take turns      │──▶ Move to next game
   └─────────────────┘
           │
           ▼
   ┌─────────────────┐
   │ Game completed  │──▶ Final scores calculated
   │                 │──▶ Winner announced
   │                 │──▶ Update leaderboards & badges
   └─────────────────┘
```

### Docker Container Startup Sequence

```
Docker Compose Up
       │
       ├─▶ 1. PostgreSQL
       │      - Wait for DB ready
       │      - Run migrations
       │
       ├─▶ 2. Redis
       │      - Wait for Redis ready
       │
       ├─▶ 3. API Server
       │      - Connect to PostgreSQL
       │      - Connect to Redis
       │      - Start Express server
       │      - Health check: /health
       │
       ├─▶ 4. Socket.io Server
       │      - Connect to PostgreSQL
       │      - Connect to Redis
       │      - Start Socket.io server
       │      - Health check: /health
       │
       ├─▶ 5. Nginx Load Balancer
       │      - Wait for API & Socket.io ready
       │      - Start nginx
       │      - Health check: /
       │
       ├─▶ 6. Prometheus (Monitoring)
       │      - Start scraping metrics
       │
       └─▶ 7. Grafana (Visualization)
              - Connect to Prometheus
              - Load dashboards
```

---

## Network Architecture

### Container Networking

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Bridge Network                    │
│                     (mindwars-beta-network)                  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Nginx (80, 443)                                             │
│    │                                                          │
│    ├──▶ API Server (3000) ──┐                               │
│    │                          │                               │
│    └──▶ Socket.io (3001) ────┼──▶ PostgreSQL (5432)         │
│                               │                               │
│                               └──▶ Redis (6379)              │
│                                                               │
│  Prometheus (9090) ──▶ API & Socket.io metrics              │
│  Grafana (3002) ──▶ Prometheus                              │
│                                                               │
└─────────────────────────────────────────────────────────────┘

External Access:
- Port 80: HTTP (redirects to HTTPS)
- Port 443: HTTPS (API + WebSocket)
- Port 3002: Grafana (admin only, VPN/IP whitelist)

Internal Communication:
- All services on bridge network
- Service discovery via container names
- No direct external access to PostgreSQL/Redis
```

### Port Mapping

| Service | Internal Port | External Port | Purpose |
|---------|--------------|---------------|---------|
| Nginx | 80, 443 | 80, 443 | Public access (HTTPS) |
| API Server | 3000 | - | Internal only |
| Socket.io Server | 3001 | - | Internal only |
| PostgreSQL | 5432 | - | Internal only |
| Redis | 6379 | - | Internal only |
| Prometheus | 9090 | - | Internal only |
| Grafana | 3002 | 3002* | Admin access (VPN/whitelist) |

*Grafana external access restricted to admin IPs

---

## Security Considerations

### 1. Network Security
- **Firewall**: Only ports 80, 443, and 3002 (Grafana, restricted) open to internet
- **VPN**: Admin tools (Grafana, Prometheus) accessible only via VPN or IP whitelist
- **Container Isolation**: Services on internal bridge network, no direct internet access
- **Rate Limiting**: Per-IP and per-user rate limits on all endpoints

### 2. Authentication & Authorization
- **JWT Tokens**: Short-lived access tokens (15 min), refresh tokens (7 days)
- **Password Security**: Bcrypt hashing with salt (12 rounds, per [OWASP recommendation](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html) for improved security)
- **Session Management**: Max 3 concurrent sessions per user
- **Role-Based Access**: Admin, moderator, tester roles with permission checks
- **Invitation Codes**: Beta registration requires valid invitation code

### 3. Data Security
- **SSL/TLS**: All traffic encrypted (Let's Encrypt certificates)
- **Database Encryption**: Encrypt sensitive fields (passwords, tokens)
- **Environment Secrets**: Managed via Docker secrets or .env files (not committed)
- **Backup Encryption**: Database backups encrypted at rest
- **PII Protection**: No personally identifiable information logged

### 4. API Security
- **Input Validation**: All inputs validated and sanitized
- **SQL Injection Protection**: Parameterized queries only
- **XSS Protection**: Output escaping, Content Security Policy headers
- **CORS**: Restricted to mobile app origins
- **CSRF Protection**: Token-based for state-changing operations

### 5. Server-Side Validation
- **Game Logic**: All game moves validated server-side (client is untrusted)
- **Score Calculation**: Server-side only, prevents cheating
- **Turn Order**: Enforced on server, clients cannot skip turns
- **Anti-Cheat**: Time limits, move validation, anomaly detection

### 6. Monitoring & Incident Response
- **Security Alerts**: Failed login attempts, unusual traffic patterns
- **Audit Logging**: All administrative actions logged
- **Intrusion Detection**: Monitor for suspicious patterns
- **Incident Response Plan**: Documented procedures for security incidents

---

## Scaling Strategy

### Phase 1: Single-Host Deployment (Internal Beta, 10-20 users)
- **Infrastructure**: Single Docker host (4 CPU, 8GB RAM, 50GB SSD)
- **Services**: All containers on one host
- **Database**: PostgreSQL with local storage
- **Expected Load**: <10 concurrent users, <100 API requests/min

### Phase 2: Vertical Scaling (Closed Beta, 50-100 users)
- **Infrastructure**: Upgrade to larger host (8 CPU, 16GB RAM, 100GB SSD)
- **Database**: Optimized indexes, connection pooling
- **Caching**: Redis for sessions, leaderboards
- **Expected Load**: 20-50 concurrent users, <500 API requests/min

### Phase 3: Horizontal Scaling (Open Beta, 500-1000 users)
- **Infrastructure**: Kubernetes cluster (3+ nodes)
- **API Server**: 2-3 replicas behind load balancer
- **Socket.io Server**: 2-3 replicas with sticky sessions
- **Database**: PostgreSQL with read replicas
- **Caching**: Redis cluster (3 nodes)
- **Expected Load**: 100-300 concurrent users, <5000 API requests/min

### Scaling Metrics to Monitor
- **CPU Usage**: Scale up if >70% sustained
- **Memory Usage**: Scale up if >80%
- **API Latency**: Keep p95 <500ms
- **Socket.io Connections**: Monitor connection limits per server
- **Database Connections**: Monitor pool utilization
- **Queue Depth**: Redis queue depth (for async tasks)

### Auto-Scaling Rules (Phase 3)
- **API Server**: Scale up if CPU >70% for 5 minutes
- **Socket.io Server**: Scale up if connections >1000 per instance
- **Database**: Add read replica if read query latency >200ms
- **Redis**: Scale to cluster if memory >80%

---

## Deployment Checklist

### Pre-Deployment
- [ ] Docker and Docker Compose installed on host
- [ ] SSL certificates obtained (Let's Encrypt)
- [ ] Domain name configured (beta.mindwars.app)
- [ ] Environment variables defined in .env file
- [ ] Database backup strategy tested
- [ ] Monitoring and logging configured
- [ ] Security review completed

### Initial Deployment
- [ ] Clone repository to server
- [ ] Create .env file with secrets
- [ ] Run database migrations
- [ ] Start containers: `docker compose up -d`
- [ ] Verify all services healthy
- [ ] Test API endpoints
- [ ] Test WebSocket connections
- [ ] Test mobile app connectivity

### Post-Deployment Validation
- [ ] Register test user account
- [ ] Create test lobby
- [ ] Join lobby from second account
- [ ] Play test game end-to-end
- [ ] Verify scores and leaderboards
- [ ] Test offline sync (disconnect/reconnect)
- [ ] Check monitoring dashboards (Grafana)
- [ ] Review logs for errors (Kibana)

### Ongoing Maintenance
- [ ] Daily: Check service health, review logs
- [ ] Weekly: Review metrics, check disk space, review security logs
- [ ] Monthly: Apply security patches, review performance, backup verification
- [ ] On incidents: Follow incident response plan, post-mortem

---

## Success Metrics for Beta

### Technical Metrics
- **Uptime**: >99% during beta period
- **API Latency**: p95 <500ms
- **Error Rate**: <1% of requests
- **WebSocket Stability**: >95% connections stable

### User Engagement Metrics
- **Registration Conversion**: >80% of invited users register
- **Lobby Completion Rate**: >70% of lobbies complete all games
- **DAU/MAU Ratio**: >30% (users active 9+ days per month)
- **Average Session Length**: >15 minutes

### Quality Metrics
- **Crash Rate**: <0.5% of sessions
- **Critical Bugs**: 0 (bugs blocking core gameplay)
- **User Satisfaction**: >4.0/5.0 rating
- **Support Tickets**: <10% of users submit tickets

---

## Related Documents

- [PRODUCT_BACKLOG.md](PRODUCT_BACKLOG.md) - Main product backlog (Epics 1-12)
- [ALPHA_TESTING.md](ALPHA_TESTING.md) - Alpha testing guide for mobile builds
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical architecture overview
- [README.md](README.md) - Project overview and setup
- [docs/project/API_DOCUMENTATION.md](docs/project/API_DOCUMENTATION.md) - API endpoint documentation

---

## Appendix: Docker Compose Example

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: eskienterprises-postgres
    environment:
      POSTGRES_DB: mindwars_beta
      POSTGRES_USER: mindwars
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - mindwars-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U mindwars"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: eskienterprises-redis
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - mindwars-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  api-server:
    build:
      context: ./backend
      dockerfile: Dockerfile.api
    container_name: eskienterprises-mindwars-api
    environment:
      NODE_ENV: production
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: mindwars_beta
      DB_USER: mindwars
      DB_PASSWORD: ${DB_PASSWORD}
      REDIS_HOST: redis
      REDIS_PORT: 6379
      REDIS_PASSWORD: ${REDIS_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - mindwars-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 10s
      timeout: 5s
      retries: 5

  socket-server:
    build:
      context: ./backend
      dockerfile: Dockerfile.socket
    container_name: mindwars-socket
    environment:
      NODE_ENV: production
      DB_HOST: postgres
      DB_PORT: 5432
      DB_NAME: mindwars_beta
      DB_USER: mindwars
      DB_PASSWORD: ${DB_PASSWORD}
      REDIS_HOST: redis
      REDIS_PORT: 6379
      REDIS_PASSWORD: ${REDIS_PASSWORD}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - mindwars-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001/health"]
      interval: 10s
      timeout: 5s
      retries: 5

  nginx:
    image: nginx:alpine
    container_name: mindwars-nginx
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      api-server:
        condition: service_healthy
      socket-server:
        condition: service_healthy
    networks:
      - mindwars-network

  prometheus:
    image: prom/prometheus:latest
    container_name: mindwars-prometheus
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    networks:
      - mindwars-network

  grafana:
    image: grafana/grafana:latest
    container_name: mindwars-grafana
    environment:
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards:ro
    ports:
      - "3002:3000"
    depends_on:
      - prometheus
    networks:
      - mindwars-network

networks:
  mindwars-network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
  prometheus_data:
  grafana_data:
```

---

## Related Documents

- [PRODUCT_BACKLOG.md](PRODUCT_BACKLOG.md) - Main product backlog (Epics 1-12) and Beta Testing Phase (Epics 13-16)
- [BETA_TESTING_QUICKSTART.md](BETA_TESTING_QUICKSTART.md) - Quick start guide for deploying beta infrastructure
- [ALPHA_TESTING.md](ALPHA_TESTING.md) - Alpha testing guide for mobile builds
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical architecture overview
- [README.md](README.md) - Project overview and setup
- [docs/project/API_DOCUMENTATION.md](docs/project/API_DOCUMENTATION.md) - API endpoint documentation

---

**Document Status**: Planning Phase  
**Next Review**: After Epic 13 completion  
**Owner**: DevOps Team & Backend Team  
**Contributors**: Product Manager, Security Team

---

*This document is a living document and should be updated as the beta testing progresses and requirements evolve.*
