/**
 * Mind Wars - Main Application Entry Point
 * Mobile-First: Designed for 5" touch screens, scales up
 * Flutter app for iOS 14+ and Android 8+
 * Alpha Mode: Local authentication without backend server
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/local_auth_service.dart';
import 'services/multiplayer_service.dart';
import 'services/offline_service.dart';
import 'services/progression_service.dart';
import 'services/app_logger.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/profile_info_screen.dart';
import 'screens/offline_game_play_screen.dart';
import 'screens/lobby_browser_screen.dart';
import 'screens/lobby_creation_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/multiplayer_hub_screen.dart';
import 'screens/join_mind_war_screen.dart';
import 'games/game_catalog.dart';
import 'models/models.dart';
import 'widgets/branded_avatar.dart';
import 'widgets/debug_panel.dart';
import 'utils/build_config.dart';
import 'utils/screen_version_registry.dart';
import 'utils/theme/brand_theme.dart';

/// [2025-11-16 Feature] Alpha mode flag for authentication method
/// When true: Uses local authentication (offline testing only)
/// When false: Authenticates through backend API at war.e-mothership.com:3000
/// [2026-03-26 Bugfix] Tie alpha authentication mode to the build flavor.
///
/// This ensures Android alpha builds use local authentication automatically,
/// which keeps registration and login testable even when the hosted backend is
/// unavailable. Production builds continue using backend authentication.
/// [2026-04-06 Fix] Also enable alpha mode for 'local' flavor (local dev testing).
const bool kAlphaMode =
  String.fromEnvironment('FLAVOR', defaultValue: 'production') == 'alpha' ||
  String.fromEnvironment('FLAVOR', defaultValue: 'production') == 'local';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger for alpha builds
  AppLogger.init(alphaMode: kAlphaMode);

  if (kAlphaMode) {
    AppLogger.info('Mind Wars Alpha Started', source: 'main');
    AppLogger.info('Build Config: ${BuildConfig.buildType}', source: 'main');
    AppLogger.info('API URL: ${BuildConfig.apiBaseUrl}', source: 'main');
    AppLogger.info('WS URL: ${BuildConfig.wsBaseUrl}', source: 'main');
  }

  // Register all screen versions in the registry
  _registerScreenVersions();

  runApp(const MindWarsApp());
}

void _registerScreenVersions() {
  final registry = ScreenVersionRegistry();

  registry.register('/', const ScreenVersion(
    name: 'Splash Screen',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'App initialization and splash display',
  ));

  registry.register('/login', const ScreenVersion(
    name: 'Login Screen',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'User authentication login',
  ));

  registry.register('/register', const ScreenVersion(
    name: 'Registration Screen',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'New user registration',
  ));

  registry.register('/onboarding', const ScreenVersion(
    name: 'Onboarding Screen',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'User onboarding tutorial',
  ));

  registry.register('/profile-setup', const ScreenVersion(
    name: 'Profile Setup',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'Initial profile configuration',
  ));

  registry.register('/edit-profile', const ScreenVersion(
    name: 'Edit Profile',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'User profile editing',
  ));

  registry.register('/profile-info', const ScreenVersion(
    name: 'Profile Info',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'User profile information display',
  ));

  registry.register('/home', const ScreenVersion(
    name: 'Home Screen',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'Main application home screen',
  ));

  registry.register('/lobby-list', const ScreenVersion(
    name: 'Multiplayer Hub',
    version: '1.1.0',
    lastUpdated: '2026-04-05',
    description: 'Multi-War hub with real-time cards and live updates',
  ));

  registry.register('/create-lobby', const ScreenVersion(
    name: 'Lobby Creation',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'Create a new mind war lobby',
  ));

  registry.register('/join-mind-war', const ScreenVersion(
    name: 'Join Mind War',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'Join existing mind war by code',
  ));

  registry.register('/browse-lobbies', const ScreenVersion(
    name: 'Lobby Browser',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'Browse available lobbies',
  ));

  registry.register('/lobby', const ScreenVersion(
    name: 'Lobby Screen',
    version: '1.2.0',
    lastUpdated: '2026-04-05',
    description: 'Active lobby view with admin chat UI for hosts',
  ));

  registry.register('/game', const ScreenVersion(
    name: 'Multiplayer Game',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'Active multiplayer game session',
  ));

  registry.register('/game-results', const ScreenVersion(
    name: 'Game Results',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'Game results and scoring',
  ));

  registry.register('/leaderboard', const ScreenVersion(
    name: 'Leaderboard',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'Player leaderboard and rankings',
  ));

  registry.register('/profile', const ScreenVersion(
    name: 'Profile',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'User profile view',
  ));

  registry.register('/offline', const ScreenVersion(
    name: 'Offline Game',
    version: '1.0.0',
    lastUpdated: '2026-04-05',
    description: 'Offline game play',
  ));
}

class MindWarsApp extends StatefulWidget {
  const MindWarsApp({super.key});

  @override
  State<MindWarsApp> createState() => _MindWarsAppState();
}

class _MindWarsAppState extends State<MindWarsApp> {
  late Future<void> _initFuture;
  late ApiService _apiService;
  late AuthService _authService;
  late OfflineService _offlineService;
  late MultiplayerService _multiplayerService;
  late ProgressionService _progressionService;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeServices();
  }

  Future<void> _initializeServices() async {
    /// [2026-03-26 Bugfix] Use build-based API configuration instead of a hardcoded endpoint.
    ///
    /// This keeps alpha and production environment wiring aligned with the
    /// declared build configuration and avoids forcing alpha installs onto a
    /// backend that may not be reachable during device testing.
    _apiService = ApiService(
      baseUrl: '${BuildConfig.apiBaseUrl}/api',
    );
    
    _offlineService = OfflineService();
    _multiplayerService = MultiplayerService();
    _progressionService = ProgressionService(apiService: _apiService);
    
    // Initialize database for local auth in alpha mode
    if (kAlphaMode) {
      final database = await _offlineService.database;
      final localAuthService = LocalAuthService(database: database);
      _authService = AuthService(
        apiService: _apiService,
        localAuthService: localAuthService,
        isAlphaMode: true,
      );
    } else {
      _authService = AuthService(
        apiService: _apiService,
        isAlphaMode: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Show loading screen while initializing
          return MaterialApp(
            home: Scaffold(
              body: Container(
                decoration: MindWarsBrandTheme.loadingBackgroundDecoration,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          );
        }

        return MultiProvider(
          providers: [
            Provider<ApiService>.value(value: _apiService),
            Provider<AuthService>.value(value: _authService),
            Provider<MultiplayerService>.value(value: _multiplayerService),
            Provider<OfflineService>.value(value: _offlineService),
            Provider<ProgressionService>.value(value: _progressionService),
          ],
          child: MaterialApp(
            title: kAlphaMode ? 'Mind Wars Alpha' : 'Mind Wars',
            debugShowCheckedModeBanner: false,
            theme: MindWarsBrandTheme.lightTheme(),
            darkTheme: MindWarsBrandTheme.darkTheme(),
            
            themeMode: ThemeMode.system,
            
            // Initial route - splash screen handles navigation
            initialRoute: '/',
            
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegistrationScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/profile-setup': (context) => const ProfileSetupScreen(),
              '/edit-profile': (context) => const EditProfileScreen(),
              '/profile-info': (context) => const ProfileInfoScreen(),
              '/home': (context) => const HomeScreen(),
              '/lobby-list': (context) => const MultiplayerHubScreen(),
              '/create-lobby': (context) => LobbyCreationScreen(
                    multiplayerService: context.read<MultiplayerService>(),
                  ),
              '/browse-lobbies': (context) => LobbyBrowserScreen(
                    multiplayerService: context.read<MultiplayerService>(),
                  ),
              '/join-mind-war': (context) => JoinMindWarScreen(
                    multiplayerService: context.read<MultiplayerService>(),
                  ),
              '/lobby': (context) => LobbyScreen(
                    multiplayerService: context.read<MultiplayerService>(),
                    currentUserId: context.read<AuthService>().currentUser?.id ?? '',
                  ),
              '/profile': (context) => const ProfileScreen(),
              '/offline': (context) => const OfflineScreen(),
            },
          ),
        );
      },
    );
  }
}

/// Home Screen - Main entry point
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Wars'),
        actions: [
          // Debug panel button - only in alpha builds
          if (kAlphaMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              tooltip: 'Debug Panel',
              onPressed: () {
                showDebugPanel(context);
              },
            ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo/Header
              const SizedBox(height: 40),
              const Icon(
                Icons.psychology,
                size: 80,
                color: Color(0xFF6200EE),
              ),
              const SizedBox(height: 16),
              Text(
                'Mind Wars',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Challenge Your Mind',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 60),
              
              // Main Action Buttons
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/lobby-list');
                },
                icon: const Icon(Icons.people),
                label: const Text('Multiplayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6200EE),
                  foregroundColor: Colors.white,
                ),
              ),
              
              const SizedBox(height: 16),
              
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/offline');
                },
                icon: const Icon(Icons.person),
                label: const Text('Single Player'),
              ),
              
              const SizedBox(height: 16),
              
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/leaderboard');
                },
                icon: const Icon(Icons.leaderboard),
                label: const Text('Leaderboard'),
              ),
              
              const Spacer(),
              
              // Feature Highlights
              _buildFeatureChip(context, 'Compete 1v1 or in Mind Wars'),
              const SizedBox(height: 8),
              _buildFeatureChip(context, '12+ Games, 5 Categories'),
              const SizedBox(height: 8),
              _buildFeatureChip(context, 'Individual Gameplay, Competitive Scores'),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 20, color: Colors.green[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Not logged in'))
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Profile Header
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              BrandedAvatar(
                                avatar: user.avatar,
                                fallbackLabel: user.username[0].toUpperCase(),
                                radius: 50,
                                backgroundColor: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                user.username,
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(height: 16),
                              if (kAlphaMode)
                                Chip(
                                  avatar: const Icon(Icons.science, size: 16),
                                  label: const Text('ALPHA TESTER'),
                                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Stats Section
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              Icons.games,
                              'Games Played',
                              '0',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              Icons.emoji_events,
                              'Wins',
                              '0',
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              Icons.stars,
                              'Total Score',
                              '0',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              Icons.local_fire_department,
                              'Streak',
                              '0 days',
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Achievements
                      Text(
                        'Achievements',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.emoji_events_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No achievements yet',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Play games to unlock achievements!',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Actions
                      FilledButton.icon(
                        onPressed: () => _editProfile(context),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      OutlinedButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text(
          'Profile editing will be available in the next update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('System default'),
            onTap: () {
              // Theme settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Enabled'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle notification toggle
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('Sound Effects'),
            subtitle: const Text('Enabled'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle sound toggle
              },
            ),
          ),
          const Divider(),
          if (kAlphaMode)
            ListTile(
              leading: const Icon(Icons.science, color: Colors.orange),
              title: const Text('Alpha Mode'),
              subtitle: const Text('Local authentication enabled'),
              trailing: const Icon(Icons.info_outline),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    icon: const Icon(Icons.science, color: Colors.orange, size: 48),
                    title: const Text('Alpha Mode'),
                    content: const Text(
                      'You are using Mind Wars in Alpha mode.\n\n'
                      'Features:\n'
                      '• Local authentication without backend\n'
                      '• Offline gameplay\n'
                      '• Practice mode for all games\n\n'
                      'Note: Progress will not sync to servers until production mode is enabled.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Mind Wars',
                applicationVersion: '1.0.0-alpha',
                applicationIcon: const Icon(Icons.psychology, size: 48),
                children: [
                  const Text(
                    'Async Multiplayer Cognitive Games Platform\n\n'
                    'Challenge your mind across multiple cognitive categories.',
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              // Open help
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              // Open privacy policy
            },
          ),
        ],
      ),
    );
  }
}

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  CognitiveCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Offline'),
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.offline_bolt,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Practice Mode',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Play games offline to practice and improve your skills',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Category Filter
                Text(
                  'Select Category',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildCategoryChip(context, null, 'All Games'),
                    ...CognitiveCategory.values.map(
                      (category) => _buildCategoryChip(
                        context,
                        category,
                        _getCategoryName(category),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Games Grid
                Text(
                  _selectedCategory == null 
                      ? 'All Games' 
                      : '${_getCategoryName(_selectedCategory!)} Games',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildGamesGrid(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    CognitiveCategory? category,
    String label,
  ) {
    final isSelected = _selectedCategory == category;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _buildGamesGrid(BuildContext context) {
    final games = _selectedCategory == null
        ? GameCatalog.getAllGames()
        : GameCatalog.getGamesByCategory(_selectedCategory!);

    if (games.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No games in this category'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return _buildGameCard(context, game);
      },
    );
  }

  Widget _buildGameCard(BuildContext context, GameTemplate game) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _showGameDetails(context, game);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                game.icon,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 12),
              Text(
                game.name,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                _getCategoryName(game.category),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  _startGame(context, game);
                },
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('Play'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGameDetails(BuildContext context, GameTemplate game) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      game.icon,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    game.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(_getCategoryName(game.category)),
                    avatar: const Icon(Icons.category, size: 16),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    game.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'How to Play',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    game.rules,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _startGame(context, game);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Playing'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _startGame(BuildContext context, GameTemplate game) {
    // Navigate to game play screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfflineGamePlayScreen(gameTemplate: game),
      ),
    );
  }

  String _getCategoryName(CognitiveCategory category) {
    switch (category) {
      case CognitiveCategory.memory:
        return 'Memory';
      case CognitiveCategory.logic:
        return 'Logic';
      case CognitiveCategory.attention:
        return 'Attention';
      case CognitiveCategory.spatial:
        return 'Spatial';
      case CognitiveCategory.language:
        return 'Language';
    }
  }
}
