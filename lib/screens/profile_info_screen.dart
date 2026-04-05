/**
 * Profile Info Screen
 * Feature: Manage Personal/Demographic Information
 * - First name, last name
 * - Date of birth
 * - Gender/sex
 * - Bio/about
 * - Location
 *
 * Separate from gaming identity (username, displayName, avatar)
 * which are edited in the Edit Profile screen.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _dateOfBirthController;

  String? _selectedGender;
  bool _isLoading = false;
  String? _errorMessage;
  bool _didInitializeProfile = false;

  final List<String> _genderOptions = ['M', 'F', 'Other', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _bioController = TextEditingController();
    _locationController = TextEditingController();
    _dateOfBirthController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInitializeProfile) {
      return;
    }

    _loadProfileInfo();
    _didInitializeProfile = true;
  }

  Future<void> _loadProfileInfo() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final profile = await authService.getPersonalProfile();

      setState(() {
        _firstNameController.text = profile['firstName'] ?? '';
        _lastNameController.text = profile['lastName'] ?? '';
        _bioController.text = profile['bio'] ?? '';
        _locationController.text = profile['location'] ?? '';
        _selectedGender = profile['gender'];

        if (profile['dateOfBirth'] != null) {
          _dateOfBirthController.text = profile['dateOfBirth'];
        }
      });
    } catch (e) {
      print('[ProfileInfo] Error loading profile: $e');
      // Silently fail - user can still edit empty form
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = picked.toString().split(' ')[0]; // YYYY-MM-DD format
      });
    }
  }

  Future<void> _handleSave() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      await authService.updatePersonalProfile(
        firstName: _firstNameController.text.trim().isNotEmpty ? _firstNameController.text.trim() : null,
        lastName: _lastNameController.text.trim().isNotEmpty ? _lastNameController.text.trim() : null,
        dateOfBirth: _dateOfBirthController.text.trim().isNotEmpty ? _dateOfBirthController.text.trim() : null,
        gender: _selectedGender,
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        location: _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile information updated successfully')),
      );

      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile. Please try again.';
      });
      print('[ProfileInfo] Save error: $e');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
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

                // Name section
                Text(
                  'Name',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    hintText: 'Your first name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Your last name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 24),

                // Date of birth section
                Text(
                  'Date of Birth',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _dateOfBirthController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'YYYY-MM-DD',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                    suffixIcon: _isLoading
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.date_range),
                            onPressed: _selectDate,
                          ),
                  ),
                  readOnly: true,
                  onTap: _isLoading ? null : _selectDate,
                ),

                const SizedBox(height: 24),

                // Gender section
                Text(
                  'Gender',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.wc),
                    border: OutlineInputBorder(),
                  ),
                  items: _genderOptions
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                ),

                const SizedBox(height: 24),

                // Bio section
                Text(
                  'About',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio / About',
                    hintText: 'Tell others about yourself (optional)',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  maxLength: 1000,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 24),

                // Location section
                Text(
                  'Location',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'City, Region, or Country (optional)',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 32),

                // Save button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleSave,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

                const SizedBox(height: 16),

                // Cancel button
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
