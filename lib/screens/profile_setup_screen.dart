/**
 * Profile Setup Screen
 * Feature 1.4: Profile Setup
 * - Display name input
 * - Avatar selection (preset options)
 * - Profile validation
 * - Profile sync across devices
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/brand_assets.dart';
import '../utils/brand_animations.dart';
import '../utils/validators.dart';
import '../widgets/branded_avatar.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();

  String? _selectedAvatar;
  bool _isLoading = false;
  String? _errorMessage;
  String? _usernameStatus;  // null, 'checking', 'available', 'taken'
  List<String> _suggestedUsernames = [];
  bool _didInitializeProfile = false;
  
  /// [2026-03-26 Feature] Expose the full imported avatar set during profile setup.
  ///
  /// The branding drop includes 60 default avatars, and alpha testers should be
  /// able to choose from the complete set instead of an arbitrary subset.
  final List<String> _avatarOptions = List<String>.generate(
    60,
    (index) => BrandAssets.defaultAvatar(index + 1),
  );
  
  @override
  void initState() {
    super.initState();
    _selectedAvatar = _avatarOptions[0];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInitializeProfile) {
      return;
    }

    /// [2026-04-04 Feature] Seed profile setup from authenticated account.
    ///
    /// Username is now entered during profile setup.
    /// Use email prefix as initial suggestion.
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      // Suggest username based on email prefix
      if (currentUser.email != null && currentUser.email!.isNotEmpty) {
        final emailPrefix = currentUser.email!.split('@')[0];
        _usernameController.text = emailPrefix;
      }

      // Set display name from current user or default to username
      _displayNameController.text = currentUser.displayName ??
        (currentUser.email?.split('@')[0] ?? '');

      if (currentUser.avatar != null && currentUser.avatar!.isNotEmpty) {
        _selectedAvatar = currentUser.avatar;
      }
    }

    _didInitializeProfile = true;

    // Check availability of the pre-filled username
    if (_usernameController.text.isNotEmpty) {
      _checkUsernameAvailability(_usernameController.text);
    }
  }
  
  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  /// Generate username suggestions when the entered username is taken
  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty) {
      setState(() {
        _usernameStatus = null;
        _suggestedUsernames = [];
      });
      return;
    }

    setState(() {
      _usernameStatus = 'checking';
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.id;

      final result = await apiService.checkUsernameAvailability(username, userId: userId);

      if (!mounted) return;

      if (result['available'] == true) {
        setState(() {
          _usernameStatus = 'available';
          _suggestedUsernames = [];
        });
      } else {
        // Generate suggestions based on the taken username
        final suggestions = <String>[
          '${username}1',
          '${username}_pro',
          '${username}_alt',
        ];
        setState(() {
          _usernameStatus = 'taken';
          _suggestedUsernames = suggestions;
        });
      }
    } catch (e) {
      print('[ProfileSetup] Username check error: $e');
      setState(() {
        _usernameStatus = null;
      });
    }
  }
  
  Future<void> _handleComplete() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check username availability before completing
    if (_usernameStatus != 'available') {
      setState(() {
        _errorMessage = 'Please choose an available username';
      });
      return;
    }

    if (_selectedAvatar == null) {
      setState(() {
        _errorMessage = 'Please select an avatar';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      /// [2026-04-04 Feature] Persist profile data with username through auth layer.
      ///
      /// Username is now collected during profile setup and stored with display name.
      /// This keeps alpha mode local-first while preserving the backend update path.
      /// [2026-04-06 Feature] Added displayName field to allow users to show a
      /// different name than their username if it's already taken.
      await authService.updateProfile(
        username: _usernameController.text.trim(),
        displayName: _displayNameController.text.trim(),
        avatar: _selectedAvatar!,
      );

      if (!mounted) return;

      // Profile setup complete - navigate to home
      Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Your Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Personalize Your Profile',
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your username and avatar',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Username field with availability check
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                    helperText: 'Your unique username for playing',
                    suffixIcon: _usernameStatus == 'checking'
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _usernameStatus == 'available'
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : _usernameStatus == 'taken'
                                ? const Icon(Icons.cancel, color: Colors.red)
                                : null,
                  ),
                  validator: Validators.validateUsername,
                  onChanged: (value) {
                    _checkUsernameAvailability(value);
                  },
                  enabled: !_isLoading,
                ),

                // Show username suggestions if taken
                if (_usernameStatus == 'taken' && _suggestedUsernames.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'That username is taken. Try:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _suggestedUsernames
                              .map((suggestion) => ActionChip(
                                    label: Text(suggestion),
                                    onPressed: () {
                                      _usernameController.text = suggestion;
                                      _checkUsernameAvailability(suggestion);
                                    },
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Display name field
                /// [2026-04-06 Feature] Allow users to display a different name than
                /// their unique username (for cases where preferred username is taken).
                TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: 'Display Name (Optional)',
                    hintText: 'What name to show other players',
                    prefixIcon: const Icon(Icons.badge),
                    border: const OutlineInputBorder(),
                    helperText: 'This is what other players will see (can be different from username)',
                  ),
                  validator: (value) {
                    if (value != null && value.length > 50) {
                      return 'Display name must be 50 characters or less';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 32),
                
                // Avatar selection
                Text(
                  'Choose Your Avatar',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                // Avatar grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _avatarOptions.length,
                  itemBuilder: (context, index) {
                    final avatar = _avatarOptions[index];
                    final isSelected = avatar == _selectedAvatar;
                    
                    return GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _selectedAvatar = avatar;
                              });
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? BrandAssets.cyan.withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? BrandAssets.cyan
                                : Colors.grey[300]!,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: Center(
                          child: BrandedAvatar(
                            avatar: avatar,
                            fallbackLabel: '${index + 1}',
                            radius: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Complete button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandAssets.coral,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? BrandAnimations.loadingSpinner(size: 20)
                      : const Text('Complete Setup'),
                ),
                
                const SizedBox(height: 16),
                
                // Skip button
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).pushReplacementNamed('/home');
                        },
                  child: const Text('Skip for now'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
