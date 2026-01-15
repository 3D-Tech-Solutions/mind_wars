# Alpha Testing - Pre-Distribution Checklist

Use this checklist before distributing builds to alpha testers.

## Build Verification

### Android Build
- [ ] `./build-alpha.sh android` completes successfully
- [ ] APK file is generated at `build/app/outputs/flutter-apk/`
- [ ] APK size is reasonable (< 50MB)
- [ ] Package ID is `com.mindwars.app.alpha`
- [ ] App name shows as "Mind Wars Alpha"

### iOS Build (if applicable)
- [ ] `./build-alpha.sh ios` completes successfully
- [ ] Opens in Xcode without errors
- [ ] Code signing configured correctly
- [ ] Bundle ID is `com.mindwars.app.alpha`
- [ ] App name shows as "Mind Wars Alpha"

## Installation Testing

### Fresh Install
- [ ] App installs without errors
- [ ] App icon displays correctly
- [ ] First launch shows splash screen
- [ ] Splash screen shows "ALPHA VERSION" badge
- [ ] Redirects to login screen

## Authentication Flow

### Registration
- [ ] Can navigate to registration screen
- [ ] All form fields are visible and functional
- [ ] Alpha mode info banner is displayed
- [ ] Email validation works (rejects invalid emails)
- [ ] Password validation works (min 8 chars, mixed case, number)
- [ ] Duplicate email is rejected
- [ ] Duplicate username is rejected
- [ ] Successful registration redirects to home/onboarding
- [ ] Account is saved locally

### Login
- [ ] Can login with registered credentials
- [ ] Wrong password shows appropriate error
- [ ] Non-existent account shows appropriate error
- [ ] "Remember me" checkbox is functional
- [ ] Successful login redirects to home screen
- [ ] Alpha mode info banner is displayed

### Auto-Login
- [ ] Checking "Remember me" saves credentials
- [ ] Closing and reopening app auto-logs in
- [ ] Can disable auto-login by logging out

## Home Screen

### Navigation
- [ ] Home screen displays correctly
- [ ] App title shows "Mind Wars Alpha"
- [ ] Can access profile from home
- [ ] "Multiplayer" button shows lobby list
- [ ] "Play Offline" button shows game selection
- [ ] "Leaderboard" button shows rankings

### UI Elements
- [ ] All buttons are tappable (48dp minimum)
- [ ] Icons display correctly
- [ ] Text is readable on small screens
- [ ] Feature chips display at bottom

## Offline Games

### Game Selection Screen
- [ ] Displays all game categories
- [ ] Shows 15+ games in catalog
- [ ] Category filter chips work
- [ ] Game cards display with icon, name, category
- [ ] Tapping game card shows details modal
- [ ] Details modal shows rules and description
- [ ] "Play" button starts the game

### Memory Match Game
- [ ] Game screen loads correctly
- [ ] 16 cards displayed in 4x4 grid
- [ ] Cards flip on tap
- [ ] Matching pairs stay revealed
- [ ] Non-matching pairs flip back after delay
- [ ] Score increases on match (+10 points)
- [ ] Timer counts up correctly
- [ ] Hint button works (shows hint dialog, -5 points)
- [ ] Game completes when all pairs found
- [ ] Completion screen shows final stats

### Word Builder Game
- [ ] Shows 9 random letters (5 consonants, 4 vowels)
- [ ] Can type words in text field
- [ ] Submit button submits word
- [ ] Valid words are accepted and added to list
- [ ] Score increases by word length × 2
- [ ] Words can't be submitted twice
- [ ] Invalid letter combinations are rejected
- [ ] Hint button works
- [ ] Can play continuously (no completion)

### Sequence Recall Game
- [ ] Shows 4 colored buttons (red, blue, green, yellow)
- [ ] "Show Sequence" button displays sequence
- [ ] Level indicator shows current level
- [ ] Can tap buttons to repeat sequence
- [ ] Correct sequence advances level
- [ ] Wrong input resets and shows error
- [ ] Score increases with level (+10 × level)
- [ ] Hint button works
- [ ] Sequence gets progressively longer

### Anagram Attack Game
- [ ] Shows scrambled word in large letters
- [ ] Can type answer in text field
- [ ] Correct answer advances to next word (+15 points)
- [ ] Wrong answer shows feedback
- [ ] Hint button works
- [ ] Game completes after all words
- [ ] Shows remaining word count

### Code Breaker Game
- [ ] Shows instructions clearly
- [ ] Number pad displays (1-6)
- [ ] Can tap numbers to build guess
- [ ] Submits automatically after 4 digits
- [ ] Shows feedback (correct position, wrong position)
- [ ] Previous guesses are displayed
- [ ] Correct code completes game (+50 points)
- [ ] Hint button works

### Game Completion
- [ ] Completion screen shows for all games
- [ ] Displays trophy icon
- [ ] Shows final score
- [ ] Shows time taken
- [ ] Shows hints used
- [ ] "Play Again" button restarts game
- [ ] "Back to Games" returns to selection

## Profile Screen

### Display
- [ ] Shows user avatar (first letter of username)
- [ ] Displays username
- [ ] Displays email
- [ ] Shows alpha tester badge
- [ ] Statistics cards display:
  - Games Played: 0
  - Wins: 0
  - Total Score: 0
  - Streak: 0 days

### Actions
- [ ] Settings icon in app bar works
- [ ] "Edit Profile" button shows dialog (coming soon)
- [ ] "Logout" button shows confirmation
- [ ] Logout confirmation works
- [ ] After logout, returns to login screen

## Settings Screen

### Display
- [ ] All settings options are listed
- [ ] Theme shows "System default"
- [ ] Notifications toggle displays
- [ ] Sound effects toggle displays
- [ ] Alpha mode info tile displays

### Actions
- [ ] Notification toggle can be switched
- [ ] Sound toggle can be switched
- [ ] Alpha mode tile shows info dialog
- [ ] About tile shows about dialog
- [ ] About dialog shows correct version (1.0.0-alpha)
- [ ] About dialog shows app icon

## Leaderboard Screen

### Display
- [ ] Shows two tabs: Weekly and All Time
- [ ] Alpha mode warning banner displays
- [ ] Top 3 podium displays with medals
- [ ] Podium shows correct heights (1st tallest)
- [ ] Ranking list displays below podium
- [ ] Each entry shows rank, name, score

### Navigation
- [ ] Can switch between tabs
- [ ] Tabs animate smoothly
- [ ] Back button returns to home

## Lobby List Screen

### Display
- [ ] Shows "Multiplayer Coming Soon" message
- [ ] Alpha mode info banner explains limitation
- [ ] People icon displays
- [ ] Message explains server requirement

### Actions
- [ ] "Play Offline Instead" navigates to game selection
- [ ] "Back to Home" returns to home screen

## General UI/UX

### Navigation
- [ ] Back button works on all screens
- [ ] Android back button works correctly
- [ ] iOS swipe back gesture works (if iOS)
- [ ] No navigation dead ends
- [ ] Can reach all screens from home

### Responsiveness
- [ ] App works on 5" phone screen
- [ ] App works on 7" tablet (if available)
- [ ] Portrait orientation works
- [ ] Landscape orientation works
- [ ] Text doesn't overflow on small screens
- [ ] Buttons don't overlap

### Performance
- [ ] App launches in < 3 seconds
- [ ] No noticeable lag when navigating
- [ ] Games run smoothly (60fps target)
- [ ] No memory leaks during extended use
- [ ] Battery drain is reasonable

### Error Handling
- [ ] Invalid inputs show appropriate errors
- [ ] Network toggle doesn't crash app
- [ ] Rapid button clicking doesn't cause issues
- [ ] Interruptions (calls, notifications) handled gracefully

## Alpha Mode Indicators

### Visual Indicators
- [ ] Splash screen shows "ALPHA VERSION" badge
- [ ] App title shows "Mind Wars Alpha"
- [ ] Login screen shows alpha info banner
- [ ] Registration screen shows alpha info banner
- [ ] Settings shows alpha mode info option
- [ ] Leaderboard shows alpha data notice

## Documentation

### Files Present
- [ ] ALPHA_TESTING_QUICKSTART.md exists and is complete
- [ ] ALPHA_IMPLEMENTATION_SUMMARY.md exists and is complete
- [ ] ALPHA_USER_STORIES.md exists (for detailed testing)
- [ ] README.md includes alpha build instructions

### Content Accuracy
- [ ] Quick start guide matches current UI
- [ ] Game descriptions are accurate
- [ ] Testing scenarios are comprehensive
- [ ] Known limitations are documented

## Pre-Distribution Final Checks

### Code Quality
- [ ] No console errors in debug mode
- [ ] No warnings in build output
- [ ] Code is properly formatted
- [ ] Comments explain complex logic

### Security
- [ ] Passwords are hashed (not plain text)
- [ ] No sensitive data in logs
- [ ] No hardcoded credentials
- [ ] Local storage is secure

### Legal/Compliance
- [ ] App name includes "Alpha" indicator
- [ ] Version number includes "-alpha" suffix
- [ ] Package ID uses `.alpha` suffix
- [ ] Privacy policy is accessible

## Distribution Readiness

### Android
- [ ] APK is signed
- [ ] APK is tested on physical device
- [ ] Installation instructions are documented
- [ ] "Unknown sources" warning documented

### iOS
- [ ] Build is signed with correct certificate
- [ ] Tested on physical iOS device
- [ ] TestFlight setup (if using)
- [ ] Installation instructions are documented

### Communication
- [ ] Alpha tester list is ready
- [ ] Welcome email/message prepared
- [ ] Feedback collection method defined
- [ ] Support channel established (GitHub issues, etc.)

## Sign-Off

- [ ] All critical items above are checked
- [ ] Build has been tested end-to-end
- [ ] Documentation is complete and accurate
- [ ] Ready to distribute to alpha testers

**Verified By**: _________________  
**Date**: _________________  
**Build Version**: 1.0.0-alpha  
**Platform**: Android / iOS  

---

## Issues Found During Verification

_Document any issues found and their resolution_

| Issue | Severity | Status | Resolution |
|-------|----------|--------|------------|
|       |          |        |            |
|       |          |        |            |

## Notes

_Additional notes or observations during verification_

---

**Status**: Ready / Not Ready (circle one)
