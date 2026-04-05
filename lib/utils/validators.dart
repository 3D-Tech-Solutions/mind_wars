/**
 * Validation utilities for forms
 * Provides email validation, password strength checking, etc.
 */

class Validators {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validate password strength
  /// Requirements: 8+ chars, mixed case, numbers
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain uppercase letter';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Must contain lowercase letter';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Must contain a number';
    }
    
    return null;
  }
  
  /// Validate confirm password matches password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, _ and -';
    }

    return null;
  }
  
  /// Calculate password strength (0-4)
  /// 0 = very weak, 4 = very strong
  static int calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    
    int strength = 0;
    
    // Length check
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    
    // Character variety
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    
    // Cap at 4
    return strength > 4 ? 4 : strength;
  }
  
  /// Get password strength label
  static String getPasswordStrengthLabel(int strength) {
    switch (strength) {
      case 0:
        return 'Very Weak';
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Very Weak';
    }
  }
  
  /// Get password strength color
  static int getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 0xFFE53935; // Red
      case 2:
        return 0xFFFB8C00; // Orange
      case 3:
        return 0xFFFDD835; // Yellow
      case 4:
        return 0xFF43A047; // Green
      default:
        return 0xFFE53935; // Red
    }
  }
}
