/// Data validation utilities for input validation
class ValidationUtils {
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
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    if (value.length > 128) {
      return 'Password is too long';
    }
    
    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return 'Name is too long';
    }
    
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Validate age
  static String? validateAge(int? value) {
    if (value == null) {
      return 'Age is required';
    }
    
    if (value < 1) {
      return 'Please enter a valid age';
    }
    
    if (value > 150) {
      return 'Age seems invalid';
    }
    
    return null;
  }

  /// Validate height (in cm)
  static String? validateHeight(double? value) {
    if (value == null) {
      return 'Height is required';
    }
    
    if (value < 50 || value > 250) {
      return 'Please enter a valid height (50-250 cm)';
    }
    
    return null;
  }

  /// Validate weight (in kg)
  static String? validateWeight(double? value) {
    if (value == null) {
      return 'Weight is required';
    }
    
    if (value < 20 || value > 300) {
      return 'Please enter a valid weight (20-300 kg)';
    }
    
    return null;
  }

  /// Check if email is valid
  static bool isValidEmail(String email) {
    return validateEmail(email) == null;
  }

  /// Check if password is strong
  static bool isStrongPassword(String password) {
    return validatePassword(password) == null;
  }

  /// Check if phone is valid
  static bool isValidPhone(String phone) {
    return validatePhone(phone) == null;
  }
}

/// Sanitization utilities
class SanitizationUtils {
  /// Sanitize email
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Sanitize name
  static String sanitizeName(String name) {
    return name.trim();
  }

  /// Sanitize phone
  static String sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+\-\(\)\s]'), '');
  }

  /// Remove extra spaces
  static String removeExtraSpaces(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
