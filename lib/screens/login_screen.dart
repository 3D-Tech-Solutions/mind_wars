/**
 * Login Screen
 * Feature 1.2: User Login
 * - Email/password login form
 * - Auto-login option
 * - Loading state
 * - Error handling
 */

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import '../utils/build_config.dart';
import '../main.dart';
import '../utils/brand_assets.dart';
import '../utils/brand_animations.dart';
import '../widgets/debug_panel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _errorMessage;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  String _improveErrorMessage(String error) {
    // Improve error messages for better user experience
    if (error.toLowerCase().contains('invalid email or password')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (error.toLowerCase().contains('user not found')) {
      return 'This email is not registered. Please create an account.';
    }
    if (error.toLowerCase().contains('network')) {
      return 'Network error. Please check your connection and try again.';
    }
    if (error.toLowerCase().contains('type') && error.toLowerCase().contains('null')) {
      return 'Login encountered an error. Please try again.';
    }
    return error;
  }

  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      final result = await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        autoLogin: _rememberMe,
      );

      if (!mounted) return;

      if (result.success) {
        // Login successful - navigate to home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          _errorMessage = _improveErrorMessage(result.error ?? 'Login failed');
        });
      }
    } catch (e) {
      print('[LoginScreen] Exception: $e');
      setState(() {
        _errorMessage = _improveErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your email address and we\'ll send you instructions to reset your password.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'your.email@example.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateEmail,
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        emailController.dispose();
      }
    });

    if (result == true && mounted) {
      // Call auth service to request password reset
      final authService = Provider.of<AuthService>(context, listen: false);
      final resetResult = await authService.requestPasswordReset(emailController.text);
      
      if (resetResult.success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset instructions sent to your email'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resetResult.error ?? 'Failed to send reset email'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: BrandAssets.deepNavy,
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
                const SizedBox(height: 20),
                
                // Alpha mode indicator
                if (kAlphaMode)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: BrandAssets.cyan.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: BrandAssets.cyan.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: BrandAssets.cyan),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Alpha Mode: Using local authentication. Your data is stored on this device.',
                            style: const TextStyle(
                              color: BrandAssets.text,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                /// [2026-03-16 Integration] Replace the stock header icon with imported brand assets.
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [BrandAssets.deepNavy, BrandAssets.surface],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        BrandAssets.logomark,
                        width: 88,
                        height: 88,
                      ),
                      const SizedBox(height: 20),
                      SvgPicture.asset(
                        BrandAssets.wordmarkHorizontal,
                        width: 220,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome Back',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: BrandAssets.deepNavy,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to continue your Mind Wars journey',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
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
                
                // Password field
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                
                const SizedBox(height: 8),
                
                // Remember me checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                    ),
                    Text(
                      'Remember me',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _isLoading ? null : _showForgotPasswordDialog,
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Login button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandAssets.coral,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? BrandAnimations.loadingSpinner(size: 20)
                      : const Text('Login'),
                ),
                
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[400])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Register link
                OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.of(context).pushReplacementNamed('/register');
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: BrandAssets.deepNavy),
                  ),
                  child: const Text('Create New Account'),
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
                        '${BuildConfig.buildType} • ${BuildConfig.apiBaseUrl}',
                        style: TextStyle(
                          color: BuildConfig.isLocal ? Colors.blue[300] : Colors.grey[400],
                          fontSize: 10,
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
