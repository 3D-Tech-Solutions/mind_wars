# Backend Extraction Plan: Mind Wars → Standalone Service

**Date:** April 5, 2026
**Status:** Planning (Post-LAN Validation)
**Goal:** Extract embedded backend into reusable, production-ready service

## Current State Analysis

### Embedded Backend (Current)
```
mind-wars/
├── backend/
│   ├── api-server/          # Node.js Express API
│   ├── multiplayer-server/  # Socket.io server
│   ├── database/           # PostgreSQL schema
│   └── docker-compose.yml  # Local development
├── lib/services/           # Flutter app services
└── docs/                  # Mixed app + backend docs
```

**Issues:**
- Backend tightly coupled with Flutter app
- Alpha mode uses local SQLite (not backend)
- No production deployment pipeline
- Mixed concerns (game logic + social features)

### Target State (Standalone Backend)

```
mind-wars-backend/
├── api-server/             # REST API service
│   ├── src/
│   │   ├── auth/          # Authentication & users
│   │   ├── games/         # Game validation & data
│   │   ├── social/        # Lobbies, chat, multiplayer
│   │   ├── analytics/     # Data collection & insights
│   │   └── middleware/    # CORS, logging, validation
│   ├── Dockerfile
│   └── package.json
├── multiplayer-server/     # WebSocket service
│   ├── src/
│   │   ├── lobby/         # Lobby management
│   │   ├── game/          # Real-time game coordination
│   │   └── chat/          # Real-time messaging
│   ├── Dockerfile
│   └── package.json
├── database/              # Data layer
│   ├── migrations/        # Schema evolution
│   ├── seeds/            # Initial data
│   └── schema.sql        # Current schema
├── infrastructure/        # Deployment & monitoring
│   ├── docker-compose.yml
│   ├── nginx.conf        # Gateway configuration
│   ├── monitoring/       # Health checks, metrics
│   └── scripts/          # Build & deploy automation
├── docs/                 # API documentation
│   ├── api/              # REST API specs
│   ├── websocket/        # Socket.io events
│   ├── deployment/       # Infrastructure guides
│   └── integration/      # Client integration
└── tests/                # Comprehensive test suite
    ├── integration/      # API + WebSocket tests
    ├── load/            # Performance testing
    └── e2e/             # End-to-end scenarios
```

## Service Architecture

### 1. API Server (Port 3000)
**Purpose:** RESTful API for all non-real-time operations

#### Endpoints to Implement
```
POST   /api/auth/register          # User registration
POST   /api/auth/login             # User authentication
GET    /api/auth/me               # Get current user
PUT    /api/auth/profile          # Update profile

GET    /api/games                 # List available games
GET    /api/games/:id             # Game details & capabilities
POST   /api/games/:id/validate    # Server-side move validation

GET    /api/lobbies               # List public lobbies
POST   /api/lobbies               # Create lobby
GET    /api/lobbies/:id           # Get lobby details
PUT    /api/lobbies/:id           # Update lobby settings
DELETE /api/lobbies/:id           # Close lobby

GET    /api/leaderboards          # Get leaderboards
GET    /api/leaderboards/:game    # Game-specific rankings

POST   /api/analytics/events      # Track user actions
GET    /api/analytics/user/:id    # User statistics
```

#### Key Features
- **JWT Authentication:** Secure token-based auth
- **Rate Limiting:** Prevent abuse
- **Input Validation:** Comprehensive request validation
- **Error Handling:** Structured error responses
- **CORS:** Configurable cross-origin support

### 2. Multiplayer Server (Port 3001)
**Purpose:** WebSocket-based real-time communication

#### Socket.io Events
```javascript
// Connection & Authentication
connect                    # Client connects
disconnect                 # Client disconnects
authenticate              # Authenticate socket session

// Lobby Management
create-lobby              # Host creates lobby
join-lobby                # Player joins lobby
leave-lobby               # Player leaves lobby
lobby-updated             # Lobby state changed
player-joined             # New player joined
player-left               # Player left
player-status-changed     # Player ready/not ready

// Game Coordination
game-started              # Game begins
make-move                 # Player makes move
move-validated            # Server validates move
turn-changed              # Next player's turn
game-ended                # Game completed

// Social Features
chat-message              # Send chat message
message-received          # Receive chat message
typing-indicator          # Show typing status
```

#### Key Features
- **Room-based Architecture:** Lobbies as Socket.io rooms
- **Presence Tracking:** Real-time user status
- **Message Broadcasting:** Efficient event distribution
- **Connection Recovery:** Handle network interruptions

### 3. Database Layer
**Purpose:** Persistent data storage with migrations

#### Schema Evolution
```sql
-- Users & Authentication
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    username VARCHAR(50) UNIQUE,
    display_name VARCHAR(100),
    password_hash VARCHAR(255),
    created_at TIMESTAMP,
    last_active TIMESTAMP
);

-- Games & Validation
CREATE TABLE games (
    id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    config JSONB,
    created_at TIMESTAMP
);

-- Social Features
CREATE TABLE lobbies (
    id UUID PRIMARY KEY,
    name VARCHAR(100),
    host_id UUID REFERENCES users(id),
    game_id VARCHAR(50) REFERENCES games(id),
    max_players INTEGER,
    is_private BOOLEAN,
    lobby_code VARCHAR(10) UNIQUE,
    status VARCHAR(20), -- 'waiting', 'in-progress', 'completed'
    created_at TIMESTAMP
);

-- Analytics & Leaderboards
CREATE TABLE game_sessions (
    id UUID PRIMARY KEY,
    lobby_id UUID REFERENCES lobbies(id),
    game_id VARCHAR(50) REFERENCES games(id),
    players JSONB,
    result JSONB,
    started_at TIMESTAMP,
    completed_at TIMESTAMP
);
```

### 4. Infrastructure & Deployment

#### Docker Compose (Production)
```yaml
version: '3.8'
services:
  api:
    build: ./api-server
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://...
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis

  multiplayer:
    build: ./multiplayer-server
    environment:
      - NODE_ENV=production
      - REDIS_URL=redis://redis:6379
    ports:
      - "3001:3001"
    depends_on:
      - redis

  nginx:
    image: nginx:alpine
    ports:
      - "4000:4000"  # REST API
      - "4001:4001"  # WebSocket
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - api
      - multiplayer

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_DB=mindwars
      - POSTGRES_USER=mindwars
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
```

#### Nginx Gateway Configuration
```
# REST API (port 4000)
location /api/ {
    proxy_pass http://api:3000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}

# WebSocket (port 4001)
location /socket.io/ {
    proxy_pass http://multiplayer:3001;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```

## Migration Strategy

### Phase 1: Repository Setup
1. Create `mind-wars-backend` repository
2. Copy existing backend code
3. Set up new project structure
4. Configure CI/CD pipeline

### Phase 2: Service Extraction
1. **API Server:** Extract REST endpoints from current api-server
2. **Multiplayer Server:** Extract Socket.io logic
3. **Database:** Migrate schema and add migrations
4. **Infrastructure:** Create production Docker setup

### Phase 3: Feature Enhancement
1. **Authentication:** Implement full JWT-based auth
2. **Validation:** Add comprehensive input validation
3. **Analytics:** Implement data collection
4. **Monitoring:** Add health checks and metrics

### Phase 4: Client Integration
1. Update Mind Wars app to use new backend
2. Remove embedded backend from main repo
3. Update build configurations
4. Test end-to-end functionality

### Phase 5: Production Deployment
1. Set up cloud infrastructure (Azure/AWS/GCP)
2. Configure monitoring and logging
3. Implement backup and recovery
4. Set up scaling policies

## Success Metrics

### Technical Metrics
- **API Response Time:** <100ms for 95% of requests
- **WebSocket Latency:** <50ms for real-time events
- **Uptime:** 99.9% availability
- **Concurrent Users:** Support 1000+ simultaneous players

### Business Metrics
- **User Registration:** Seamless auth flow
- **Game Validation:** 100% server-side validation
- **Data Accuracy:** Complete game result tracking
- **Social Features:** Real-time multiplayer coordination

## Risk Mitigation

### Technical Risks
- **Data Migration:** Comprehensive testing of data transfer
- **API Compatibility:** Maintain backward compatibility during transition
- **Real-time Performance:** Monitor WebSocket performance at scale

### Operational Risks
- **Downtime:** Zero-downtime deployment strategy
- **Data Loss:** Backup and recovery procedures
- **Security:** Implement proper authentication and authorization

## Timeline

- **Week 1-2:** Repository setup and basic service extraction
- **Week 3-4:** Authentication and user management
- **Week 5-6:** Game validation and analytics
- **Week 7-8:** Client integration and testing
- **Week 9-10:** Production deployment and monitoring

## Dependencies

- **Node.js 18+:** Runtime for both services
- **PostgreSQL 15+:** Primary database
- **Redis 7+:** Caching and session storage
- **Docker:** Containerization
- **nginx:** API gateway and load balancing