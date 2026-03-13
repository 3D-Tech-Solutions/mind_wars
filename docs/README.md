# Mind Wars Documentation 📚

**Welcome to the Mind Wars documentation hub!**

This directory contains all project documentation organized by domain: business strategy, project management, social/community development, game design, and research archives.

---

## Documentation Structure

```
docs/
├── README.md (this file)
├── business/           # Business strategy, market analysis, monetization
├── project/            # Project management, sprints, technical specs
├── social/             # Community, marketing, social media strategy
├── games/              # Individual game design documents
└── research/           # Research archives and analysis
```

---

## Quick Navigation

### 🎯 Getting Started
- **New to the project?** Start with [Business Strategy Overview](business/STRATEGY_OVERVIEW.md)
- **Developer onboarding?** See [Project Documentation](project/DEVELOPER_ONBOARDING.md)
- **Marketing team?** Go to [Social Media Strategy](social/SOCIAL_MEDIA_STRATEGY.md)
- **Game designer?** Check [Game Design Process](games/DESIGN_PROCESS.md)

### 📊 Business Documentation
Located in: `docs/business/`

Essential business documents for strategy, planning, and market analysis:
- [Strategy Overview](business/STRATEGY_OVERVIEW.md) - Core business strategy and vision
- [Market Analysis](business/MARKET_ANALYSIS.md) - Competitive landscape and opportunities
- [Monetization Strategy](business/MONETIZATION_STRATEGY.md) - Revenue models and pricing
- [User Acquisition](business/USER_ACQUISITION.md) - Growth and marketing plans
- [User Personas](business/USER_PERSONAS.md) - Target user personas and profiles
- [User Stories](business/USER_STORIES.md) - Comprehensive user stories with acceptance criteria

**Alpha Testing:**
- [Alpha User Stories](../ALPHA_USER_STORIES.md) - ⭐ User stories for alpha testing without backend servers (Epics, Features, Tasks)
- [Alpha Testing Guide](../ALPHA_TESTING.md) - Alpha build process and installation
- [Alpha Testing Quickstart](../ALPHA_TESTING_QUICKSTART.md) - Quick start guide for testers
- [Alpha Auth Setup](../ALPHA_AUTH_SETUP.md) - Technical authentication setup
- [Alpha Mode Config](../ALPHA_MODE_CONFIG.md) - Configuration and mode switching
- [Alpha Build Setup](../ALPHA_BUILD_SETUP.md) - Build setup guide

### 🚀 Project Documentation
Located in: `docs/project/`

Project management, technical specifications, and development processes:
- [Developer Onboarding](project/DEVELOPER_ONBOARDING.md) - Getting started guide
- [Technical Architecture](project/TECHNICAL_ARCHITECTURE.md) - System design and infrastructure
- [API Documentation](project/API_DOCUMENTATION.md) - Backend API reference
- [Testing Strategy](project/TESTING_STRATEGY.md) - QA and testing approach

**Epic Implementation Documents:**
- [Epic 1 Summary](project/EPIC_1_SUMMARY.md) - Authentication & Onboarding
- [Epic 1 Implementation](project/EPIC_1_IMPLEMENTATION.md) - Detailed implementation guide
- [Epic 1 Screens](project/EPIC_1_SCREENS.md) - Screen specifications
- [Epic 2 Summary](project/EPIC_2_SUMMARY.md) - Lobby Management & Multiplayer
- [Epic 2 Implementation](project/EPIC_2_IMPLEMENTATION.md) - Detailed implementation guide
- [Epic 2 Validation](project/EPIC_2_VALIDATION.md) - Validation checklist
- [Epic 3 Implementation](project/EPIC_3_IMPLEMENTATION.md) - Core Gameplay Experience
- [Epic 4 Implementation](project/EPIC_4_IMPLEMENTATION.md) - Cross-Platform & Reliability
- [Epic 4 Testing](project/EPIC_4_TESTING.md) - Comprehensive testing report
- [Epic 4 Checklist](project/EPIC_4_CHECKLIST.md) - Complete feature checklist

**Project Management:**
<!-- [2026-03-13 Documentation] Added the public v1.0 release requirements document to the project docs index. -->
- [Project Status](project/PROJECT_STATUS.md) - Current project status and progress
- [v1.0 Release Requirements](project/V1_0_RELEASE_REQUIREMENTS.md) - March 2026 public-release acceptance baseline
- [Phase 1 Complete](project/PHASE_1_COMPLETE.md) - Phase 1 completion summary
- [Sprint Templates](project/SPRINT_TEMPLATES.md) - Sprint planning and retrospective templates
- [Backlog Guide](project/BACKLOG_GUIDE.md) - Guide to navigating project documentation
- [Validation](project/VALIDATION.md) - Implementation validation checklist

**Beta Testing:**
- [Beta Admin User Stories](project/BETA_ADMIN_USER_STORIES.md) - ⭐ NEW: Admin environment requirements and workflows for beta testing

### 📱 Social & Community Documentation
Located in: `docs/social/`

Community management, marketing, and social media strategies:
- [Social Media Strategy](social/SOCIAL_MEDIA_STRATEGY.md) - Platform-specific strategies
- [Community Guidelines](social/COMMUNITY_GUIDELINES.md) - Rules and moderation
- [Content Calendar](social/CONTENT_CALENDAR.md) - Social media scheduling
- [Influencer Partnerships](social/INFLUENCER_PARTNERSHIPS.md) - Collaboration strategies
- [Brand Guidelines](social/BRAND_GUIDELINES.md) - Voice, tone, and visual identity
- [Crisis Management](social/CRISIS_MANAGEMENT.md) - Handling negative events

### 🎮 Game Design Documentation
Located in: `docs/games/`

Individual game design documents and processes:
- [Games Evaluation and Roadmap](games/GAMES_EVALUATION_AND_ROADMAP.md) - Game prioritization and implementation roadmap
- [Design Process](games/DESIGN_PROCESS.md) - Game design workflow
- [Game Design Template](games/GAME_DESIGN_TEMPLATE.md) - Standard GDD format
- Individual game documents (one per game)
  - [Quick Math Blitz](games/QUICK_MATH_BLITZ.md)
  - [Memory Matrix](games/MEMORY_MATRIX.md)
  - [Draw & Duel](games/DRAW_AND_DUEL.md)
  - ... (more games as developed)

### 🔬 Research Archive
Located in: `docs/research/`

Research documents, studies, and analysis:
- [Competitive Async Games Research](research/COMPETITIVE_ASYNC_MPG.md)
- [Brain Training Games Research](research/BRAIN_TRAINING_GAMES.md)
- [Cognitive Science Literature](research/COGNITIVE_SCIENCE.md)
- [User Research Studies](research/USER_RESEARCH.md)
- [A/B Test Results](research/AB_TEST_RESULTS.md)

---

## Documentation Standards

### Writing Guidelines

**Tone**: Professional, clear, and actionable
- Use active voice
- Write concisely
- Include examples
- Add visual aids when helpful

**Format**: Markdown with consistent structure
- Use headers (H1, H2, H3)
- Add table of contents for long documents
- Include metadata (author, date, version)
- Link to related documents

**Naming Convention**: `DESCRIPTIVE_NAME.md`
- All caps with underscores
- Descriptive and specific
- Keep under 30 characters when possible

### Document Template

```markdown
# Document Title

**Purpose**: Brief description of document purpose  
**Author**: Name(s)  
**Last Updated**: YYYY-MM-DD  
**Status**: Draft | Active | Archived  

---

## Table of Contents
1. [Section 1](#section-1)
2. [Section 2](#section-2)

---

## Section 1
Content here...

---

## References
- Link to related documents
- External resources
```

### Version Control

- **Major updates**: Change version number (v1.0 → v2.0)
- **Minor updates**: Increment minor version (v1.0 → v1.1)
- **Always update "Last Updated" date**
- **Add changelog section for significant documents**

---

## Contributing to Documentation

### Adding New Documents

1. **Choose the correct directory** based on content type
2. **Use the template** for consistency
3. **Name clearly** following naming convention
4. **Update this README** with link to new document
5. **Cross-reference** related documents

### Updating Existing Documents

1. **Check "Last Updated" date** to ensure you have latest version
2. **Make changes** following writing guidelines
3. **Update metadata** (version, date, author if adding significant content)
4. **Add changelog entry** for major changes
5. **Update cross-references** if structure changed

### Document Review Process

1. **Self-review** for clarity and completeness
2. **Peer review** for technical accuracy
3. **Leadership approval** for strategic documents
4. **Publish** and notify stakeholders

---

## Document Ownership

| Directory | Primary Owner | Review Frequency |
|-----------|---------------|------------------|
| `/business` | Product Manager | Monthly |
| `/project` | Engineering Lead | Weekly |
| `/social` | Community Manager | Weekly |
| `/games` | Game Designer | Per game release |
| `/research` | Research Lead | Quarterly |

---

## Frequently Asked Questions

### Where do I find...?

**Q: Business strategy and vision?**  
A: `docs/business/STRATEGY_OVERVIEW.md`

**Q: Technical architecture details?**  
A: `docs/project/TECHNICAL_ARCHITECTURE.md`

**Q: Game design specifications?**  
A: `docs/games/[GAME_NAME].md`

**Q: Social media guidelines?**  
A: `docs/social/SOCIAL_MEDIA_STRATEGY.md` and `docs/social/BRAND_GUIDELINES.md`

**Q: Research on cognitive benefits?**  
A: `docs/research/COGNITIVE_SCIENCE.md`

### How do I...?

**Q: Request a new document?**  
A: Create an issue or contact the directory owner

**Q: Suggest changes to existing document?**  
A: Submit a pull request or discuss with document owner

**Q: Archive outdated documents?**  
A: Move to `/archived` subdirectory within relevant folder and update status to "Archived"

---

## External Links

### Main Project Documents (Root Level)
These remain in the root directory for easy access:
- [README.md](../README.md) - Project overview
- [PRODUCT_BACKLOG.md](../PRODUCT_BACKLOG.md) - Prioritized feature backlog
- [ROADMAP.md](../ROADMAP.md) - Development timeline
- [ARCHITECTURE.md](../ARCHITECTURE.md) - High-level architecture
- [VOTING_SYSTEM.md](../VOTING_SYSTEM.md) - Game voting system documentation

### Migrated Documents
These documents have been moved into the docs directory structure:
- [GAMES_EVALUATION_AND_ROADMAP.md](games/GAMES_EVALUATION_AND_ROADMAP.md) - Game prioritization (moved to docs/games/)
- [USER_PERSONAS.md](business/USER_PERSONAS.md) - Target user personas (moved to docs/business/)
- [USER_STORIES.md](business/USER_STORIES.md) - User stories (moved to docs/business/)
- [BACKLOG_GUIDE.md](project/BACKLOG_GUIDE.md) - Guide to backlog documentation (moved to docs/project/)
- [Epic Implementation Documents](project/) - All EPIC_*.md files (moved to docs/project/)
- [PROJECT_STATUS.md](project/PROJECT_STATUS.md) - Project status (moved to docs/project/)
- [SPRINT_TEMPLATES.md](project/SPRINT_TEMPLATES.md) - Sprint templates (moved to docs/project/)
- [VALIDATION.md](project/VALIDATION.md) - Validation checklist (moved to docs/project/)

### Related Repositories
- [Mind Wars Backend](https://github.com/tescolopio/mind-wars-backend) - Server API
- [Mind Wars Design](https://github.com/tescolopio/mind-wars-design) - Design assets

---

## Document Update Log

| Date | Document | Change | Author |
|------|----------|--------|--------|
| 2025-11-09 | README.md | Initial documentation structure | Product Team |

---

**Questions or suggestions?**  
Contact: Product Manager or create an issue on GitHub

---

*Last Updated: 2025-11-09*  
*Document Version: 1.0*
