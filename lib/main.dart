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
import 'services/connectivity_service.dart';
import 'services/app_logger.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/offline_game_play_screen.dart';
import 'games/game_catalog.dart';
import 'models/models.dart';
import 'widgets/branded_avatar.dart';
import 'widgets/debug_panel.dart';
import 'utils/build_config.dart';
import 'utils/theme/brand_theme.dart';

/// [2025-11-16 Feature] Alpha mode flag for authentication method
/// When true: Uses local authentication (offline testing only)
/// When false: Authenticates through backend API at war.e-mothership.com:3000
/// [2026-03-26 Bugfix] Tie alpha authentication mode to the build flavor.
///
/// This ensures Android alpha builds use local authentication automatically,
/// which keeps registration and login testable even when the hosted backend is
/// unavailable. Production builds continue using backend authentication.
const bool kAlphaMode = String.fromEnvironment(
      'FLAVOR',
      defaultValue: 'production',
    ) ==
    'alpha';

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

  runApp(const MindWarsApp());
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
              '/home': (context) => const HomeScreen(),
              '/lobby-list': (context) => const LobbyListScreen(),
              '/leaderboard': (context) => const LeaderboardScreen(),
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
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
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
                icon: const Icon(Icons.offline_bolt),
                label: const Text('Play Offline'),
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
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Placeholder screens (to be implemented)
class LobbyListScreen extends StatefulWidget {
  const LobbyListScreen({super.key});

  @override
  State<LobbyListScreen> createState() => _LobbyListScreenState();
}

class _LobbyListScreenState extends State<LobbyListScreen> {
  bool _showDebugPanel = false;

  @override
  void initState() {
    super.initState();
    // Show debug panel on enter in alpha mode
    if (kAlphaMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDebugPanelModal();
      });
    }
  }

  void _showDebugPanelModal() {
    showDebugPanel(
      context,
      onContinue: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiplayer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Info Banner with debug button in alpha
            if (kAlphaMode)
              Card(
                color: Colors.orange[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Alpha Testing: Backend connectivity required',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use the debug panel below to test server connectivity. '
                        'If servers are unreachable, try "Play Offline" instead.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _showDebugPanelModal,
                          icon: const Icon(Icons.bug_report),
                          label: const Text('Show Debug Panel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Illustration
            Icon(
              Icons.people,
              size: 100,
              color: Colors.grey[300],
            ),

            const SizedBox(height: 24),

            Text(
              'Multiplayer Coming Soon',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 12),

            Text(
              'Create lobbies, invite friends, and compete in real-time when the servers are ready!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/offline');
              },
              icon: const Icon(Icons.offline_bolt),
              label: const Text('Play Offline Instead'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Weekly', icon: Icon(Icons.calendar_today)),
            Tab(text: 'All Time', icon: Icon(Icons.emoji_events)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardTab(context, isWeekly: true),
          _buildLeaderboardTab(context, isWeekly: false),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(BuildContext context, {required bool isWeekly}) {
    // Mock data for alpha testing
    final mockEntries = [
      {'rank': 1, 'name': 'AlphaGamer1', 'score': 1250, 'badge': '🥇'},
      {'rank': 2, 'name': 'BrainChamp', 'score': 1180, 'badge': '🥈'},
      {'rank': 3, 'name': 'MindMaster', 'score': 1050, 'badge': '🥉'},
      {'rank': 4, 'name': 'PuzzlePro', 'score': 980, 'badge': ''},
      {'rank': 5, 'name': 'LogicLord', 'score': 920, 'badge': ''},
      {'rank': 6, 'name': 'WordWizard', 'score': 850, 'badge': ''},
      {'rank': 7, 'name': 'MemoryKing', 'score': 780, 'badge': ''},
      {'rank': 8, 'name': 'QuickThinker', 'score': 720, 'badge': ''},
    ];

    return Column(
      children: [
        // Info Banner
        if (kAlphaMode)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange[100],
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Alpha Mode: Showing sample data. Real leaderboards will be available in production.',
                    style: TextStyle(
                      color: Colors.orange[900],
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Podium for top 3
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPodiumItem(context, mockEntries[1], height: 100),
              const SizedBox(width: 16),
              _buildPodiumItem(context, mockEntries[0], height: 140),
              const SizedBox(width: 16),
              _buildPodiumItem(context, mockEntries[2], height: 80),
            ],
          ),
        ),
        
        const Divider(height: 1),
        
        // Rest of leaderboard
        Expanded(
          child: ListView.builder(
            itemCount: mockEntries.length - 3,
            itemBuilder: (context, index) {
              final entry = mockEntries[index + 3];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Text(
                    '#${entry['rank']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                title: Text(
                  entry['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Text(
                  '${entry['score']} pts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    Map<String, dynamic> entry, {
    required double height,
  }) {
    final rank = entry['rank'] as int;
    Color color;
    
    switch (rank) {
      case 1:
        color = Colors.amber;
        break;
      case 2:
        color = Colors.grey[400]!;
        break;
      case 3:
        color = Colors.brown[300]!;
        break;
      default:
        color = Colors.grey;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          entry['badge'] as String,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 4),
        Text(
          entry['name'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${entry['score']} pts',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
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
