/**
 * Registration Screen
 * Feature 1.1: User Registration
 * - Email input with validation
 * - Password input with strength indicator
 * - Confirm password field
 * - Register button with loading state
 * - Client-side validation
 * - Error handling
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../utils/build_config.dart';
import '../main.dart';
import '../utils/brand_animations.dart';
import '../widgets/debug_panel.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _passwordStrength = 0;
  String? _errorMessage;

@override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  void _onPasswordChanged(String value) {
    setState(() {
      _passwordStrength = Validators.calculatePasswordStrength(value);
    });
  }

  String _improveErrorMessage(String error) {
    // Improve error messages for better user experience
    if (error.toLowerCase().contains('email already registered') ||
        error.toLowerCase().contains('email already exists')) {
      return 'This email is already registered. Please log in instead or use a different email.';
    }
    if (error.toLowerCase().contains('validation failed')) {
      return 'Please check your input and try again.';
    }
    if (error.toLowerCase().contains('network')) {
      return 'Network error. Please check your connection and try again.';
    }
    return error;
  }
  
  Future<void> _handleRegistration() async {
    print('\n========== REGISTRATION SCREEN HANDLER START ==========');
    print('[RegistrationScreen] Timestamp: ${DateTime.now().toIso8601String()}');
    
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });
    print('[RegistrationScreen] Previous error cleared');
    
    // Validate form
    print('[RegistrationScreen] Validating form...');
    if (!_formKey.currentState!.validate()) {
      print('[RegistrationScreen] Form validation FAILED');
      print('========== REGISTRATION SCREEN HANDLER END ==========\n');
      return;
    }
    print('[RegistrationScreen] Form validation PASSED ✓');

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    print('[RegistrationScreen] Email: $email');
    print('[RegistrationScreen] Password length: ${password.length}');
    
    setState(() {
      _isLoading = true;
    });
    print('[RegistrationScreen] Loading state set to true');
    
    try {
      print('[RegistrationScreen] Getting AuthService from Provider...');
      final authService = Provider.of<AuthService>(context, listen: false);
      print('[RegistrationScreen] AuthService obtained: ${authService.runtimeType}');
      print('[RegistrationScreen] Is alpha mode: ${authService.isAlphaMode}');
      
      print('[RegistrationScreen] Calling authService.register()...');
      final result = await authService.register(
        email: email,
        password: password,
      );
      
      print('[RegistrationScreen] Register call completed');
      print('[RegistrationScreen] Result success: ${result.success}');
      print('[RegistrationScreen] Result error: ${result.error}');
      print('[RegistrationScreen] Result user: ${result.user?.username}');
      
      if (!mounted) {
        print('[RegistrationScreen] Widget not mounted, aborting');
        return;
      }
      
      if (result.success) {
        print('[RegistrationScreen] ✓ REGISTRATION SUCCESSFUL');
        print('[RegistrationScreen] Navigating to /onboarding...');
        Navigator.of(context).pushReplacementNamed('/onboarding');
        print('[RegistrationScreen] Navigation called');
        print('========== REGISTRATION SCREEN HANDLER SUCCESS ==========\n');
      } else {
        print('[RegistrationScreen] ✗ REGISTRATION FAILED');
        print('[RegistrationScreen] Error message: ${result.error}');

        // Improve error messages for better UX
        final errorMessage = result.error ?? 'Registration failed - Unknown error';
        final displayMessage = _improveErrorMessage(errorMessage);

        setState(() {
          _errorMessage = displayMessage;
        });
        print('[RegistrationScreen] Error state updated: $_errorMessage');
        print('========== REGISTRATION SCREEN HANDLER FAILED ==========\n');
      }
    } catch (e, stackTrace) {
      print('\n========== REGISTRATION SCREEN EXCEPTION ==========');
      print('[RegistrationScreen] Exception type: ${e.runtimeType}');
      print('[RegistrationScreen] Exception message: $e');
      print('[RegistrationScreen] Stack trace:');
      print(stackTrace);
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Registration error: $e';
        });
        print('[RegistrationScreen] Error state set: $_errorMessage');
      }
      print('========== REGISTRATION SCREEN EXCEPTION END ==========\n');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('[RegistrationScreen] Loading state set to false');
      }
      print('========== REGISTRATION SCREEN HANDLER END ==========\n');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        actions: [
          if (kAlphaMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              tooltip: 'Debug Panel',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: SizedBox(
                      height: 600,
                      child: DebugPanel(),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Alpha mode indicator
                if (kAlphaMode)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Alpha Mode: Your account is stored locally on this device and will be synced when the cloud backend is available.',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                // Header
                const Icon(
                  Icons.person_add,
                  size: 64,
                  color: Color(0xFF6200EE),
                ),
                const SizedBox(height: 16),
                Text(
                  'Join Mind Wars',
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account to start playing',
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

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.validateEmail,
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 16),
                
                // Password field with strength indicator
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: Validators.validatePassword,
                  onChanged: _onPasswordChanged,
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 8),
                
                // Password strength indicator
                if (_passwordController.text.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: _passwordStrength / 4,
                              backgroundColor: Colors.grey[300],
                              color: Color(
                                Validators.getPasswordStrengthColor(_passwordStrength),
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            Validators.getPasswordStrengthLabel(_passwordStrength),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(
                                Validators.getPasswordStrengthColor(_passwordStrength),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '8+ chars, uppercase, lowercase, numbers',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 16),
                
                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Register button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6200EE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? BrandAnimations.loadingSpinner(size: 20)
                      : const Text('Create Account'),
                ),
                
                const SizedBox(height: 16),
                
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.of(context).pushReplacementNamed('/login');
                            },
                      child: const Text('Login'),
                    ),
                  ],
                ),

                // Build info display
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: BuildConfig.isLocal ? Colors.blue[900] : Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: BuildConfig.isLocal ? Colors.blue[400]! : Colors.grey[700]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        BuildConfig.appName,
                        style: TextStyle(
                          color: BuildConfig.isLocal ? Colors.blue[200] : Colors.grey[300],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'v${BuildConfig.appVersion}+${BuildConfig.buildNumber} (${BuildConfig.buildType})',
                        style: TextStyle(
                          color: BuildConfig.isLocal ? Colors.blue[300] : Colors.grey[400],
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        BuildConfig.apiBaseUrl,
                        style: TextStyle(
                          color: BuildConfig.isLocal ? Colors.blue[300] : Colors.grey[400],
                          fontSize: 9,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
