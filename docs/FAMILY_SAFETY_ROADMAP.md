---
name: Family Safety & COPPA Compliance Roadmap
description: Implementation plan for parent-linked child accounts, parental controls, and COPPA/child privacy compliance
type: project
---

# Mind Wars: Family Safety & COPPA Compliance Roadmap

## Executive Summary

Mind Wars is positioning itself as a **family-first cognitive games platform** with explicit parent involvement and full transparency. This roadmap ensures compliance with COPPA (US), GDPR Article 8 (EU), LGPD (Brazil), and similar child privacy laws globally.

**Core Principle:** *Kids play with their family, not with strangers. Parents have full visibility and control.*

---

## The Legal Landscape

### COPPA (Children's Online Privacy Protection Act) — USA
- **Applies to:** Any online service directed at children under 13, or knowingly collecting info from children under 13
- **Penalties:** $40,000+ per violation (FTC enforces)
- **Requirements:**
  - Parental notice and verifiable consent before collecting any personal info
  - Clear privacy policy (child-friendly language required)
  - No conditioning access on collection of unnecessary info
  - Parents can access, update, or request deletion of child's data
  - No targeted ads, behavioral tracking, or data sales to third parties
  - Reasonable security measures
  - Retention limits (delete data when no longer needed)

### GDPR Article 8 (EU & UK)
- **Applies to:** Processing personal data of children under 16 (varies by member state, some use 13)
- **Requirements:** Parental consent + clear notice
- **Right to deletion:** Child or parent can request all data deleted
- **Data minimization:** Collect only what you need

### LGPD (Brazil)
- **Applies to:** Children under 13
- **Requirements:** Explicit and separate parental consent
- **Sanctions:** Up to 2% of annual revenue

### Other Jurisdictions
- **South Korea:** Children under 14 need parental consent
- **China:** Children under 14 need parental consent + government reporting
- **Australia:** ACL (Australian Consumer Law) applies; regulatory guidance for kids' services

**Bottom line:** Regardless of where you launch, you need parental consent for under-13 accounts.

---

## Product Architecture: Parent-Linked Child Accounts

### Account Structure

```
Parent Account (Independent)
├── Email (verified)
├── Password (hashed)
├── Display Name
├── Avatar
├── Settings (notifications, etc.)
├── Privacy level (public/family-only/private)
└── Linked Child Accounts (1-10)
    ├── Child Account 1
    │   ├── Display Name
    │   ├── Birthday (encrypted)
    │   ├── Avatar
    │   ├── Status: "active" | "pending_approval" | "suspended"
    │   ├── Can only play in Mind Wars where parent is linked
    │   ├── All chat visible to parent
    │   └── Time limits set by parent
    └── Child Account 2
        └── (same structure)
```

### Account Types & Eligibility

| Account Type | Age Requirement | Can Play Solo | Can Play with Strangers | Can Chat Privately | Tracking/Ads |
|---|---|---|---|---|---|
| **Independent Adult** | 13+ | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes (optional) |
| **Parent Account** | 18+ (recommended) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes (optional) |
| **Linked Child Account** | Under 13 | ✅ Local only | ❌ No (family-only) | ❌ No (parent sees all) | ❌ No |
| **Independent Teen Account** | 13-17 | ✅ Yes | ⚠️ Limited (family opt-in) | ⚠️ Limited (parent setting) | ⚠️ Minimal |

---

## Phase 1: Child Account Foundation (Weeks 1-4)

**Goal:** Implement age verification, parental consent, and account linking infrastructure.

### 1.1 Database Schema Updates

```sql
-- Add age verification to users table
ALTER TABLE users ADD COLUMN birthday DATE ENCRYPTED;
ALTER TABLE users ADD COLUMN account_type ENUM('independent', 'parent', 'child') DEFAULT 'independent';
ALTER TABLE users ADD COLUMN parent_id UUID REFERENCES users(id) ON DELETE CASCADE;
ALTER TABLE users ADD COLUMN requires_parental_consent BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN parental_consent_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN parental_consent_timestamp TIMESTAMP;
ALTER TABLE users ADD COLUMN parental_consent_ip INET;

-- Parental consent audit log
CREATE TABLE parental_consents (
  id UUID PRIMARY KEY,
  parent_id UUID REFERENCES users(id),
  child_id UUID REFERENCES users(id),
  consent_type ENUM('initial_signup', 'data_access', 'feature_unlock'),
  consent_method ENUM('email_verification', 'oauth', 'pin'),
  consent_verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMP,
  verified_via VARCHAR(255),
  ip_address INET,
  user_agent TEXT,
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Child account restrictions
CREATE TABLE child_account_settings (
  id UUID PRIMARY KEY,
  child_id UUID REFERENCES users(id) UNIQUE,
  parent_id UUID REFERENCES users(id),
  daily_playtime_limit_minutes INT DEFAULT 60,
  daily_playtime_used_minutes INT DEFAULT 0,
  playtime_reset_hour INT DEFAULT 0, -- Midnight
  max_concurrent_mind_wars INT DEFAULT 3,
  approved_players JSONB DEFAULT '[]', -- List of approved player IDs
  profanity_filter_level ENUM('strict', 'moderate', 'light') DEFAULT 'strict',
  allow_chat_with_non_family BOOLEAN DEFAULT FALSE,
  parent_can_see_all_messages BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Family group (optional: for multi-parent households, shared custody, etc.)
CREATE TABLE family_groups (
  id UUID PRIMARY KEY,
  name VARCHAR(255),
  invitation_code VARCHAR(32) UNIQUE,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE family_group_members (
  id UUID PRIMARY KEY,
  family_group_id UUID REFERENCES family_groups(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  role ENUM('parent', 'child', 'guardian') DEFAULT 'parent',
  joined_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(family_group_id, user_id)
);
```

### 1.2 Registration Flow: Child Account

**Scenario: Child under 13 signing up**

```
1. Child enters email, password (normal signup)
2. System asks: "What's your birthday?"
3. Child enters birthday
4. System calculates age:
   - If < 13: "We need your parent's approval to continue"
   - If >= 13: Continue to account creation (normal flow)

5. If < 13, show parental consent screen:
   "Mind Wars requires your parent or guardian's approval.
    We'll send them an email asking permission."

6. Ask for parent email

7. System sends email to parent:
   Subject: "[Child's Name] wants to play Mind Wars"
   Body:
   ---
   Hi [Parent Name],

   [Child Name] wants to join Mind Wars, a cognitive games platform
   designed for families to play together.

   To approve their account, please:
   1. Click the link below
   2. Verify your email
   3. Review our privacy policy
   4. Approve your child's account

   [APPROVE ACCOUNT BUTTON with unique token]

   Privacy: We don't track, ad, or share your child's data.
   You'll have full visibility into their games and messages.

   Questions? See our Privacy Policy: [link]
   ---

8. Parent clicks link, sees:
   - Child's details (name, birthday)
   - Privacy policy summary (child-friendly)
   - Consent checkbox: "I approve [Child Name] playing Mind Wars"
   - Parent name, email verification

9. Parent verifies email (confirmation code)

10. Parent approves

11. Backend creates child account:
    - account_type = 'child'
    - parent_id = parent_user_id
    - parental_consent_verified = TRUE
    - parental_consent_timestamp = NOW()
    - Creates child_account_settings row with defaults

12. Parent gets dashboard access
    Child gets login access

13. Both get onboarding:
    - Parent sees: "Monitor [Child Name]'s progress here"
    - Child sees: "Play with your parent/family!"
```

### 1.3 Registration Flow: Parent Account

**No changes to existing registration.** Just clarify in ToS that parents agree to supervise any linked children.

### 1.4 Backend API Endpoints

```
POST /auth/register/child
Body: {
  email, password, display_name, birthday,
  parent_email (will receive verification)
}
Return: { status: "pending_parental_consent", ... }

POST /auth/parent/consent/send
Body: { child_id, parent_email }
Return: { sent: true, message: "Verification email sent" }

POST /auth/parent/consent/verify
Body: { token, parent_name, parent_email }
Query: token sent in email
Return: { verified: true, child_account_created: true }

GET /auth/parent/children
Headers: { Authorization: Bearer parent_token }
Return: [
  { id, name, age, status, created_at, last_played },
  ...
]

GET /auth/parent/child/:child_id/activity
Headers: { Authorization: Bearer parent_token }
Return: {
  games_played_today: 3,
  playtime_today: 45,
  playtime_limit: 60,
  recent_games: [ { game, score, timestamp }, ... ],
  recent_chat: [ { player, message, timestamp }, ... ]
}
```

### 1.5 Frontend Changes

**Registration Screen:**
```dart
// lib/screens/registration_screen.dart - NEW SECTION

Column(
  children: [
    TextField(label: "Birthday"),
    if (age < 13) ...[
      Text("You need your parent's approval to play."),
      TextField(label: "Parent's email"),
      Text("We'll send them an email to approve your account."),
    ],
  ],
)
```

**Parent Consent Email Verification Screen:**
```dart
// lib/screens/parental_consent_screen.dart - NEW

// Shows when parent clicks link in email
Form(
  children: [
    Text("Approve [Child Name]'s Mind Wars Account"),
    Text("Privacy: No ads, no tracking, full parental visibility"),
    CheckboxListTile(
      title: "I approve this account",
      value: approved,
      onChanged: (val) => setState(() => approved = val),
    ),
    ElevatedButton(
      onPressed: () => approveConsent(),
      child: Text("Approve Account"),
    ),
  ],
)
```

---

## Phase 2: Parental Dashboard & Controls (Weeks 5-8)

**Goal:** Give parents full visibility and control over child accounts.

### 2.1 Parental Dashboard

**Screen: Parent Home → "Children" tab**

```
Children (2)
├─ Emma (8 years old)
│  ├─ [Avatar]
│  ├─ Status: Active now
│  ├─ Played today: 3 games, 45 min
│  ├─ Time remaining: 15 min
│  ├─ Quick Actions:
│  │  ├─ View Activity
│  │  ├─ Set Time Limit
│  │  ├─ Manage Connections
│  │  └─ Review Messages
│  └─ Recent games: [game cards]
│
└─ David (11 years old)
   ├─ [Avatar]
   ├─ Status: Offline (last played 2h ago)
   ├─ Played today: 2 games, 30 min
   ├─ Time remaining: 30 min
   ├─ Quick Actions: [same as Emma]
   └─ Recent games: [game cards]
```

### 2.2 Parental Control Features

**Time Management:**
```dart
// Parent taps "Set Time Limit" on Emma's account

TimePickerDialog(
  title: "Daily playtime limit for Emma",
  current: 60, // minutes
  options: [30, 45, 60, 90, 120],
)

// When child reaches limit:
// Toast: "You've played 60 minutes today. Come back tomorrow!"
// Child kicked from current game (with save state)
// Parent gets notification: "Emma hit her daily limit"
```

**Connection Approval:**
```dart
// Parent taps "Manage Connections" on Emma's account

ApprovedPlayers(
  approved: [
    { name: "Mom", status: "Parent", can_block: false },
    { name: "David (brother)", status: "Sibling", can_block: true },
  ],
  pending: [
    { name: "Aunt Sarah", requested_by: "Emma", actions: ["Approve", "Decline"] },
  ],
  blocked: [
    { name: "Grandpa Joe", can_unblock: true },
  ],
)
```

**Message Review:**
```dart
// Parent taps "Review Messages" on Emma's account

ChatHistory(
  mindWar: "Emma vs. David - Logic Games",
  messages: [
    { player: "Emma", text: "Your turn!" },
    { player: "David", text: "Ready, let's go!" },
    // System events also visible
    { system: "🎮 Emma finished Sudoku Duel - 3:42 • 1st place" },
  ],
  // Parent can:
  // - See full history
  // - Flag inappropriate messages
  // - Disable child's chat for a Mind War
  // - Export/download conversation
)
```

### 2.3 Enhanced Profanity Filter (Child Accounts)

Child accounts use **strict** profanity filter:
- Standard swear words (same as adults)
- Plus: Mild insults, condescending language, sarcasm that implies mockery
- Detect leetspeak variants (h3llo, l00ser, etc.)
- Detect Unicode variants (ḧëḷḷö)
- Detect partial censoring attempts (f**k, s***, etc.)

```javascript
// backend/services/profanityFilter.js

const PROFANITY_LEVELS = {
  strict: ['badword1', 'badword2', ...variants],
  moderate: ['badword1', ...], // subset
  light: ['explicit_only']
};

const shouldFilterMessage = (message, level) => {
  // Detect profanity, variants, leetspeak, unicode tricks
  // Return flagged words
}

// In chatHandlers.js:
socket.on('chat:message', (data) => {
  const filtered = shouldFilterMessage(data.content, childAccount.profanity_filter_level);
  
  if (filtered.length > 0) {
    // For child accounts: block message entirely
    // For parent viewing: show message with flagged words highlighted
    // Alert moderation team if severity > threshold
  }
});
```

### 2.4 Chat Visibility for Parents

When a child sends a message in a Mind War:
- ✅ Message delivered to other players normally
- ✅ Message also sent to parent's dashboard (read-only)
- ✅ Parent sees message immediately in "Review Messages"
- ✅ Parent can export full chat history
- ✅ Parent sees flagged messages (profanity, moderation alerts)

```json
{
  "type": "player_message",
  "mind_war_id": "abc123",
  "player_id": "child_789",
  "display_name": "Emma",
  "content": "Your turn!",
  "timestamp": "2026-04-06T14:32:45Z",
  
  // ADDED FOR CHILD ACCOUNTS:
  "from_child_account": true,
  "parent_can_see": true,
  "flagged_words": [],
  "moderation_alert": null
}
```

### 2.5 API Endpoints for Parental Dashboard

```
GET /parent/children
  Returns: [{ child_id, name, age, status, today_playtime, ... }, ...]

GET /parent/child/:child_id/activity
  Returns: { games_today, playtime_today, connections, recent_messages }

PUT /parent/child/:child_id/settings
Body: { daily_playtime_limit, profanity_filter_level, ... }
  Returns: { updated: true }

PUT /parent/child/:child_id/connection/:player_id/approve
  Returns: { approved: true }

DELETE /parent/child/:child_id/connection/:player_id/block
  Returns: { blocked: true }

GET /parent/child/:child_id/chat-history/:mind_war_id
  Returns: [ { player, message, timestamp, flagged }, ... ]

POST /parent/child/:child_id/export-data
  Returns: { export_url: "...", expires_in: 604800 } // 7 days
```

---

## Phase 3: Production Compliance & Moderation (Weeks 9-12)

**Goal:** Hardened production system with audit trails, moderation, and third-party compliance.

### 3.1 Compliance Audit Trail

```sql
-- Log all sensitive operations on child accounts
CREATE TABLE child_account_audit_log (
  id UUID PRIMARY KEY,
  child_id UUID,
  parent_id UUID,
  action VARCHAR(255), -- 'consent_verified', 'time_limit_set', 'connection_approved', etc.
  details JSONB,
  ip_address INET,
  user_agent TEXT,
  timestamp TIMESTAMP DEFAULT NOW()
);

-- Automatically insert on:
-- - Parental consent verification
-- - Time limit changes
-- - Connection approvals/blocks
-- - Child account deletion
-- - Data export requests
```

### 3.2 Moderation Team Training

**On-call moderation team handles:**
- Flagged messages from profanity filter
- Parent reports of inappropriate behavior
- Suspicious patterns (e.g., adult contacting child repeatedly)
- Data breach or security incident response

**Escalation playbook:**
1. Severity 1 (Adult attempting grooming) → Immediate account suspension + law enforcement notification
2. Severity 2 (Profanity, bullying) → Warn user, time-out, parent notification
3. Severity 3 (Minor violations) → Warning, log in audit trail

### 3.3 Third-Party COPPA Certification (Optional but Recommended)

Services that verify COPPA compliance:
- **TRUSTe** — $3-5K/year, certifies compliance with COPPA + GDPR
- **Privo** — Provides consent management service + certification
- **Apptopia** — Independent compliance audit

**Benefits:**
- ✅ Legal liability insurance
- ✅ App Store preference (shows "certified family-friendly")
- ✅ Trust signal to parents ("This app takes child privacy seriously")
- ✅ Quarterly compliance audits (ensures you don't drift)

### 3.4 Data Deletion & Portability

**Parent can request:**
1. **Full data export** — All child data in machine-readable format (JSON, CSV)
2. **Account deletion** — All data permanently deleted within 30 days
3. **Data portability** — Export to another app/service

```
POST /parent/child/:child_id/request-data-export
Body: { format: 'json' | 'csv' }
Return: {
  status: 'pending',
  export_url_will_be_sent_to: 'parent@email.com',
  expires_in: 604800 // 7 days
}

# Parent receives email with download link
# Link expires after 7 days (for security)
# Parent can also request permanent deletion
```

### 3.5 Legal Documents (Lawyer Review Required)

**Privacy Policy — Child-specific section:**
```
# Privacy Policy for Children Under 13

## What Information We Collect
- Name, birthday (encrypted), avatar
- Game scores and playtime
- Messages in family-only Mind Wars
- Device info (for crash reporting only, on parent's device)

## What We DON'T Do
- ❌ No ads
- ❌ No behavioral tracking (no Google Analytics, Facebook Pixel, etc.)
- ❌ No selling or sharing data with third parties
- ❌ No cookies or device identifiers

## Parental Rights
- View all of your child's data
- Download all data at any time
- Delete your child's account and all data
- Contact us at privacy@mindwars.app

## Contact
Privacy Officer: privacy@mindwars.app
Mailing address: [Legal address]
```

**Terms of Service — Family Account section:**
```
# Family Accounts & Child Eligibility

## Parent Responsibilities
By approving a child account, you agree to:
- Monitor your child's playtime (we provide time limits as tools, not substitutes)
- Review messages and activity regularly
- Report inappropriate behavior to our moderation team
- Ensure compliance with your local laws and school policies

## Child Account Restrictions
- Children under 13 can only play with their parent or approved family members
- All messages are visible to parents
- Playtime limits are enforced automatically
- Accounts will be suspended for policy violations

## COPPA Acknowledgment (US)
We comply with the Children's Online Privacy Protection Act (COPPA).
- We obtain verifiable parental consent before collecting child data
- We do not condition account access on unnecessary data collection
- Parents have the right to access, update, or delete child data
- We maintain reasonable security measures to protect child data
```

---

## Account Graduation: Age 13+ Transition

When a child reaches 13, parents get notification:
```
Emma turned 13!

Options:
1. Upgrade to independent account (age 13-17 with parental controls)
2. Keep current account structure (parent still sees all activity)
3. Delete account and create new independent account
```

**If upgraded to age 13-17:**
- Account type changes to "teen"
- Can play with approved non-family members
- Can create private conversations (parent can enable privacy at 16+)
- Parent still sees game history and time usage (can be disabled by teen)
- Parent can re-enable full controls if needed

---

## Implementation Priority

| Epic | Phase | Timeline | Effort |
|---|---|---|---|
| Age verification + parental consent | 1 | Weeks 1-2 | 8 pts |
| Account linking + restrictions | 1 | Weeks 2-3 | 8 pts |
| Database schema + migrations | 1 | Weeks 1-4 | 5 pts |
| **Phase 1 Subtotal** | | **4 weeks** | **21 pts** |
| Parental dashboard | 2 | Weeks 5-6 | 13 pts |
| Child-mode restrictions enforcement | 2 | Weeks 6-7 | 8 pts |
| Enhanced profanity filter | 2 | Weeks 7-8 | 8 pts |
| Chat visibility for parents | 2 | Weeks 8 | 5 pts |
| **Phase 2 Subtotal** | | **4 weeks** | **34 pts** |
| Compliance audit trail | 3 | Weeks 9-10 | 5 pts |
| Moderation team setup + playbook | 3 | Weeks 10 | 8 pts |
| Third-party COPPA audit | 3 | Weeks 10-11 | 3 pts |
| Legal document review | 3 | Weeks 11-12 | 5 pts |
| Data export/deletion API | 3 | Weeks 11-12 | 8 pts |
| **Phase 3 Subtotal** | | **4 weeks** | **29 pts** |
| **TOTAL** | | **12 weeks** | **84 pts** |

---

## Success Criteria

### Phase 1 (MVP)
- ✅ Age verification in signup flow
- ✅ Parental consent email sent and verified
- ✅ Child accounts linked to parent accounts
- ✅ Child can only play in family Mind Wars
- ✅ 0 false positives (age verification works for legit users)
- ✅ Consent email response rate > 50% (within 24h)

### Phase 2 (Beta)
- ✅ Parental dashboard shows all child activity
- ✅ Time limits enforced (child kicked when exceeded)
- ✅ Connection approval required before new players added
- ✅ Parents can see all child messages
- ✅ Profanity filter catches 95%+ of inappropriate content
- ✅ Parent satisfaction (NPS > 50)

### Phase 3 (Production)
- ✅ Third-party COPPA certification obtained
- ✅ Zero regulatory violations (COPPA, GDPR, LGPD)
- ✅ 100% audit trail coverage (all child account actions logged)
- ✅ Moderation team responds to reports within 24h
- ✅ Data export/deletion working (parent gets data within 24h)
- ✅ Legal review completed (no exposed data collection)

---

## Risk Mitigation

### Risk: Parents don't respond to consent email

**Mitigation:**
- Send reminder email after 24h
- Send SMS reminder after 48h (if phone collected)
- Link to consent page in parent's account (if they create one)
- Allow re-send of consent email
- Auto-delete pending account after 30 days

### Risk: Child creates fake birthdate to bypass age gate

**Mitigation:**
- Require parental email anyway (catches some)
- Flag accounts with suspicious birthdates (e.g., 1999-12-31)
- Monitor for patterns (multiple accounts same email, same household)
- Manual review for accounts under 5 years old

### Risk: Moderation team mishandles child safety incident

**Mitigation:**
- Clear escalation procedures + training
- Law enforcement contact info for severity-1 incidents
- Insurance/legal counsel on retainer
- Regular audits of moderation decisions
- External compliance review (TRUSTe, etc.)

### Risk: Data breach exposes child PII

**Mitigation:**
- Encrypt all personally identifiable information (birthday, parent email)
- Regular security audits
- Incident response plan
- Parent notification within 24h if data breach occurs
- Cyber liability insurance

---

## Messaging to Parents

**On signup:**
> "Mind Wars is designed for families. Create an account for yourself, then invite your child, parents, or siblings. You'll see everything they play and can set time limits. No ads, no tracking, no surprises."

**In parent dashboard:**
> "You're in control. Set daily playtime limits, approve who your child plays with, and see all their games and messages. Mind Wars keeps family time healthy."

**In child account:**
> "Playing with your family! Your parent/guardian can see your games and messages. This keeps everyone safe. Talk to them about time limits or players you'd like to add."

**In app store listing:**
> "⭐ Family-First Design: Kids require parental approval. Parents have full visibility. ⭐ No Ads: Zero tracking, no targeted ads, no data sales. ⭐ Parental Controls: Time limits, connection approval, message review. This is how family games should work."

---

## References

- COPPA FTC Enforcement: https://www.ftc.gov/enforcement/coppa
- COPPA FAQs: https://www.ftc.gov/business-guidance/faqs-childrens-online-privacy-protection-rule-coppa
- GDPR Article 8: https://gdpr-info.eu/art-8-gdpr/
- LGPD Child Data: https://www.lgpdbrasil.com.br/
- Common Sense Media Guidelines: https://www.commonsensemedia.org/articles/top-10-tips-for-kid-friendly-app-design

---

## Questions for Legal Counsel

1. Should parental consent be via email link, or do we need additional verification (phone call, credit card)?
2. What's our liability if a parent claims they didn't give consent? (Consider: email domain control, IP logging)
3. How long should we retain child data after account deletion? (Legal hold for disputes, etc.)
4. Should we collect parent's name, address, date of birth? (COPPA says only what's necessary)
5. Do we need a DPA (Data Processing Agreement) with any third-party services?
6. What's our process if law enforcement requests child data?

---

**Document Version:** 1.0  
**Last Updated:** April 6, 2026  
**Owner:** Product / Legal  
**Status:** Ready for development planning

