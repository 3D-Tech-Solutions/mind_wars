/**
 * Edit Profile Screen
 * Feature: Edit Profile After Setup
 * - Edit username with availability check
 * - Change avatar
 * - View read-only stats (level, score, streaks, games)
 * - Save changes back to server
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/brand_assets.dart';
import '../utils/brand_animations.dart';
import '../utils/validators.dart';
import '../widgets/branded_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _displayNameController;

  String? _selectedAvatar;
  String? _originalUsername;
  String? _originalDisplayName;
  String? _originalAvatar;
  bool _isLoading = false;
  String? _errorMessage;
  String? _usernameStatus;  // null, 'checking', 'available', 'taken'
  List<String> _suggestedUsernames = [];
  bool _didInitializeProfile = false;

  final List<String> _avatarOptions = List<String>.generate(
    60,
    (index) => BrandAssets.defaultAvatar(index + 1),
  );

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _displayNameController = TextEditingController();
    _selectedAvatar = _avatarOptions[0];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInitializeProfile) {
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    if (currentUser != null) {
      _originalUsername = currentUser.username;
      _originalDisplayName = currentUser.displayName ?? '';
      _originalAvatar = currentUser.avatar;
      _usernameController.text = currentUser.username;
      _displayNameController.text = currentUser.displayName ?? '';

      if (currentUser.avatar != null && currentUser.avatar!.isNotEmpty) {
        _selectedAvatar = currentUser.avatar;
      }
    }

    _didInitializeProfile = true;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  /// Check if username is available (excluding current user)
  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty) {
      setState(() {
        _usernameStatus = null;
        _suggestedUsernames = [];
      });
      return;
    }

    // Don't check if username hasn't changed
    if (username == _originalUsername) {
      setState(() {
        _usernameStatus = 'available';
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
      print('[EditProfile] Username check error: $e');
      setState(() {
        _usernameStatus = null;
      });
    }
  }

  /// Check if avatar is a remote URL (uploaded) vs asset
  bool _isRemoteAvatar(String? avatar) {
    if (avatar == null) return false;
    return avatar.startsWith('http') || avatar.startsWith('/uploads/');
  }

  /// Upload avatar image from camera
  Future<void> _uploadFromCamera() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        await _processUploadedImage(image.path);
      }
    } catch (e) {
      print('[EditProfile] Camera error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }

  /// Upload avatar image from gallery
  Future<void> _uploadFromGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        await _processUploadedImage(image.path);
      }
    } catch (e) {
      print('[EditProfile] Gallery error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select image: $e')),
      );
    }
  }

  /// Process uploaded image - send to backend
  Future<void> _processUploadedImage(String imagePath) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.uploadAvatarImage(imagePath);

      if (!mounted) return;

      setState(() {
        // Update the selected avatar to the new URL so it displays
        _selectedAvatar = user.avatarUrl ?? _selectedAvatar;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar uploaded successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload avatar: $e')),
      );
      print('[EditProfile] Upload error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Check if any changes have been made
  bool _hasChanges() {
    final username = _usernameController.text.trim();
    final displayName = _displayNameController.text.trim();
    return username != _originalUsername ||
           displayName != (_originalDisplayName ?? '') ||
           _selectedAvatar != _originalAvatar;
  }

  /// Save profile changes
  Future<void> _handleSave() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = _usernameController.text.trim();

    // Check username availability if it changed
    if (username != _originalUsername && _usernameStatus != 'available') {
      setState(() {
        _errorMessage = 'Please choose an available username';
      });
      return;
    }

    if (!_hasChanges()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes to save')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final displayName = _displayNameController.text.trim();

      await authService.updateProfile(
        username: username != _originalUsername ? username : null,
        displayName: displayName != (_originalDisplayName ?? '') ? displayName : null,
        avatar: _selectedAvatar != _originalAvatar ? _selectedAvatar : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile. Please try again.';
      });
      print('[EditProfile] Save error: $e');
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

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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

                // Avatar section
                Text(
                  'Avatar',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                // Current avatar display with tap to change
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => _buildAvatarPickerSheet(),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        BrandedAvatar(
                          avatar: _isRemoteAvatar(_selectedAvatar) ? null : _selectedAvatar,
                          avatarUrl: _isRemoteAvatar(_selectedAvatar) ? _selectedAvatar : null,
                          userId: Provider.of<AuthService>(context, listen: false).currentUser?.id,
                          fallbackLabel: 'A',
                          radius: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tap to change',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Username section
                Text(
                  'Username',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

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

                const SizedBox(height: 32),

                // Display Name section
                Text(
                  'Display Name (Optional)',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'How you\'ll appear in Mind Wars (leave blank to use username)',
                    prefixIcon: const Icon(Icons.visibility),
                    border: const OutlineInputBorder(),
                    helperText: 'Can be anything - shown in games, leaderboards, chat',
                  ),
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 32),

                // Stats section
                Text(
                  'Your Stats',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        label: 'Level',
                        value: '${currentUser.level ?? 1}',
                        icon: Icons.star,
                      ),
                      _buildStatItem(
                        label: 'Score',
                        value: '${currentUser.totalScore ?? 0}',
                        icon: Icons.show_chart,
                      ),
                      _buildStatItem(
                        label: 'Streak',
                        value: '${currentUser.currentStreak ?? 0}',
                        icon: Icons.local_fire_department,
                      ),
                      _buildStatItem(
                        label: 'Wins',
                        value: '${currentUser.gamesWon ?? 0}',
                        icon: Icons.emoji_events,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action buttons
                ElevatedButton(
                  onPressed: !_hasChanges() || _isLoading
                      ? null
                      : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandAssets.coral,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: _isLoading
                      ? BrandAnimations.loadingSpinner(size: 20)
                      : const Text('Save Changes'),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),

                // Navigation to personal profile info
                Text(
                  'Personal Information',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pushNamed('/profile-info'),
                  icon: const Icon(Icons.person_outline),
                  label: const Text('Edit Personal Details'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your name, date of birth, location, and bio',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPickerSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose Your Avatar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Upload buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _uploadFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _uploadFromGallery,
                  icon: const Icon(Icons.image),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Text(
            'Or choose an emoji:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 12),

          Expanded(
            child: GridView.builder(
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
                  onTap: () {
                    setState(() {
                      _selectedAvatar = avatar;
                    });
                    Navigator.of(context).pop();
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: BrandAssets.coral, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
