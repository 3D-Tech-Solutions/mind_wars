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
import '../utils/brand_assets.dart';
import '../utils/brand_animations.dart';
import '../widgets/branded_avatar.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  
  String? _selectedAvatar;
  bool _isLoading = false;
  String? _errorMessage;
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

    /// [2026-03-26 Feature] Seed profile setup from the authenticated account.
    ///
    /// This preserves the original username casing from registration, prefills
    /// the display name, and keeps any previously selected avatar visible.
    final currentUser = Provider.of<AuthService>(context, listen: false).currentUser;
    if (currentUser != null) {
      _displayNameController.text =
          (currentUser.displayName?.trim().isNotEmpty ?? false)
              ? currentUser.displayName!.trim()
              : currentUser.username;

      if (currentUser.avatar != null && currentUser.avatar!.isNotEmpty) {
        _selectedAvatar = currentUser.avatar;
      }
    }

    _didInitializeProfile = true;
  }
  
  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
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
      
      /// [2026-03-26 Feature] Persist profile data through the auth layer.
      ///
      /// This keeps alpha mode local-first while preserving the backend update
      /// path for non-alpha builds.
      await authService.updateProfile(
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
                  'Choose your display name and avatar',
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
                
                // Username info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: BrandAssets.coral),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Username',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            currentUser?.username ?? '',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Display name field
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'Enter your display name',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                    helperText: 'This is how other players will see you',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Display name is required';
                    }
                    if (value.length < 2) {
                      return 'Display name must be at least 2 characters';
                    }
                    if (value.length > 30) {
                      return 'Display name must be less than 30 characters';
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
