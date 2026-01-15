# Quick Start Guide - Alpha Testing Authentication

## 🎯 Overview

This guide helps you get started with Mind Wars alpha testing. The app now supports **local authentication** so you can create accounts and login without requiring a backend server.

**📖 For Comprehensive Testing**: See **[ALPHA_USER_STORIES.md](ALPHA_USER_STORIES.md)** for detailed user stories, Epics, Features, Tasks, and structured testing workflows for Alpha testing.

## 🚀 Getting Started

### 1. Build and Run the App

```bash
# Install dependencies
flutter pub get

# Run on your device
flutter run
```

### 2. Create Your Account

When you launch the app:

1. **See the splash screen** with "ALPHA VERSION" badge
2. **On the login screen**, tap "Create New Account"
3. **Fill in your details**:
   - Username (minimum 3 characters)
   - Email (valid format)
   - Password (8+ chars, uppercase, lowercase, number)
   - Confirm password
4. **Tap "Create Account"**
5. You're in! 🎉

### 3. Using the App

After creating your account:
- ✅ Your credentials are saved locally on your device
- ✅ You can logout and login again anytime
- ✅ Check "Remember me" to auto-login on app restart
- ✅ All your game progress is saved locally

## 📱 What You'll See

### Alpha Mode Indicators

You'll notice these visual cues that you're in alpha mode:

1. **Splash Screen**: Shows "ALPHA VERSION" badge
2. **Login Screen**: Blue info banner explaining local authentication
3. **Registration Screen**: Blue info banner about local storage
4. **App Title**: "Mind Wars Alpha" instead of "Mind Wars"

## 🔐 Your Data

### Where is it stored?

- **Locally on your device** in an SQLite database
- **Password is hashed** (not stored in plain text)
- **No data sent to servers** (there's no backend yet!)

### Multiple Accounts

You can create multiple accounts on the same device:
- Each needs a unique email
- Each needs a unique username
- Switch accounts by logging out and logging back in

## 🧪 Testing Scenarios

Try these scenarios to help us test:

### Registration & Authentication
- ✅ Create account with valid credentials
- ✅ Try weak passwords (should fail)
- ✅ Try invalid emails (should fail)
- ✅ Try duplicate email (should fail)
- ✅ Try duplicate username (should fail)

### Login
- ✅ Login with correct credentials
- ✅ Try wrong password (should fail)
- ✅ Try non-existent email (should fail)
- ✅ Use "Remember me" and restart app

### Multiple Sessions
- ✅ Create multiple accounts
- ✅ Logout and login to different accounts
- ✅ Verify each account has its own data

### Offline Games Testing
- ✅ Play each of the 5 games
- ✅ Test hint system (score should decrease)
- ✅ Complete a game and check final score
- ✅ Try all difficulty levels
- ✅ Navigate between different games
- ✅ Check if progress is saved

### UI/UX Testing
- ✅ Navigate through all screens
- ✅ Test on different screen sizes
- ✅ Check landscape and portrait modes
- ✅ Verify all buttons work
- ✅ Test back button behavior

## ❓ Troubleshooting

### Can't Login After Creating Account

- Double-check your email and password
- Make sure password meets requirements (8+ chars, mixed case, numbers)
- Try logging out and logging back in

### Forgot Your Password

In alpha mode, there's no password recovery. You can:
- Create a new account with a different email
- Clear app data and start fresh
- Reinstall the app

### App Crashes or Errors

Please report any issues with:
- Device model and OS version
- Steps to reproduce the problem
- Screenshots if possible
- Error messages if any

## 📊 What We're Testing

Help us validate these features:

### Authentication
- [ ] Account creation process
- [ ] Login flow
- [ ] Auto-login (remember me)
- [ ] Password validation
- [ ] Email validation
- [ ] Duplicate prevention
- [ ] Multiple accounts
- [ ] Logout functionality

### Offline Gameplay
- [ ] Game selection interface
- [ ] Memory Match gameplay
- [ ] Word Builder gameplay  
- [ ] Sequence Recall gameplay
- [ ] Anagram Attack gameplay
- [ ] Code Breaker gameplay
- [ ] Scoring system
- [ ] Hint system
- [ ] Game completion flow

### User Interface
- [ ] Profile screen
- [ ] Settings screen
- [ ] Leaderboard display
- [ ] Navigation flow
- [ ] Responsive design
- [ ] App performance
- [ ] UI/UX clarity

## 🐛 Reporting Issues

Found a bug? Please report it with:

1. **Clear title** describing the issue
2. **Steps to reproduce** the problem
3. **Expected behavior** vs actual behavior
4. **Screenshots** if applicable
5. **Device info** (model, OS version)
6. **Label**: `alpha-testing`

## 💡 Tips

- **Use a test email** - Use a throwaway email for testing
- **Try edge cases** - Test with unusual inputs to find bugs
- **Document everything** - Take notes on your experience
- **Be creative** - Try to break things!

## 🎮 Next Steps

Once you're logged in:
1. **Play Offline Games** - Try the 5 fully playable games!
2. **Explore the home screen** - Check out the main menu
3. **View your profile** - See your stats and settings
4. **Check the leaderboard** - Browse rankings (sample data)

### 🎯 Playing Games

Mind Wars includes **5 fully functional games** you can play offline:

#### 1. Memory Match 🃏
- **Category**: Memory
- **How to Play**: Flip cards to find matching pairs
- **Tip**: Try to remember card positions

#### 2. Word Builder 📝  
- **Category**: Language
- **How to Play**: Create words from letter tiles
- **Tip**: Look for common patterns like -ING, -ED, -ER

#### 3. Sequence Recall 🔢
- **Category**: Memory  
- **How to Play**: Watch sequences and repeat them
- **Tip**: Break sequences into chunks

#### 4. Anagram Attack 🔤
- **Category**: Language
- **How to Play**: Unscramble words as fast as you can
- **Tip**: Look for common letter combinations

#### 5. Code Breaker 🔐
- **Category**: Logic
- **How to Play**: Guess the secret code using feedback
- **Tip**: Use previous guesses to narrow down options

### How to Access Games

1. From the **Home Screen**, tap **"Play Offline"**
2. Browse games by **category** or view **all games**
3. Tap a game card to see **details and rules**
4. Tap **"Play"** to start the game

### Game Features

- ⏱️ **Time Tracking**: See how long each game takes
- ⭐ **Scoring**: Earn points for correct moves
- 💡 **Hints**: Get help (with small score penalty)
- 📊 **Stats**: View your performance after completing

## 🔮 Coming Soon

When the backend is ready:
- ☁️ Cloud sync of your local account
- 🔄 Multi-device sync
- 📧 Email verification
- 🔑 Password reset
- 🌐 Online multiplayer
- 📊 Global leaderboards

## 📚 Technical Details

Want to know how it works? Check out:
- `ALPHA_AUTH_SETUP.md` - Detailed technical documentation
- `lib/services/local_auth_service.dart` - Authentication implementation
- `test/alpha_auth_integration_test.dart` - Test scenarios

## 🤝 Thank You!

Your alpha testing helps us build a better game. Every bug you find, every piece of feedback you provide, makes Mind Wars better for everyone.

**Happy testing!** 🧠⚔️

---

*Questions? Issues? Reach out via GitHub issues or team channels.*
