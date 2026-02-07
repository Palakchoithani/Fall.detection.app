import 'package:flutter/material.dart';
import '../services/mock_firebase_service.dart';
import '../models/user_model.dart';
import '../models/user_model.dart' as models;
import '../widgets/custom_text_field.dart';
import '../widgets/form_section_header.dart';
import '../widgets/checkbox_with_label.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late dynamic _firebaseService;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Personal Info
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  String? _selectedGender;
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  // Step 2: Contact & Security
  final _countryCodeController = TextEditingController(text: '+1');
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Checkboxes
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  bool _healthPreference = false;

  // State
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firebaseService = MockFirebaseService();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    _countryCodeController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _emergencyNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  bool _validateStep1() {
    if (_fullNameController.text.isEmpty) {
      _showError('Please enter your full name');
      return false;
    }
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showError('Please enter a valid email address');
      return false;
    }
    if (_dateOfBirthController.text.isEmpty) {
      _showError('Please select your date of birth');
      return false;
    }
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      _showError('Please select your gender');
      return false;
    }
    if (_heightController.text.isEmpty) {
      _showError('Please enter your height');
      return false;
    }
    final height = double.tryParse(_heightController.text);
    if (height == null || height <= 0) {
      _showError('Please enter a valid height (in cm)');
      return false;
    }
    if (_weightController.text.isEmpty) {
      _showError('Please enter your weight');
      return false;
    }
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      _showError('Please enter a valid weight (in kg)');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_phoneController.text.isEmpty) {
      _showError('Please enter your phone number');
      return false;
    }
    if (_emergencyContactController.text.isEmpty) {
      _showError('Please enter emergency contact number');
      return false;
    }
    if (_emergencyNameController.text.isEmpty) {
      _showError('Please enter emergency contact name');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Please enter a password');
      return false;
    }
    if (_passwordController.text.length < 8) {
      _showError('Password must be at least 8 characters');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }
    if (!_acceptTerms || !_acceptPrivacy) {
      _showError('You must accept Terms & Conditions and Privacy Policy');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_validateStep2()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProfile = UserProfile(
        id: '',
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        countryCode: _countryCodeController.text.trim(),
        dateOfBirth: _dateOfBirthController.text.trim(),
        age: _calculateAge(_dateOfBirthController.text),
        gender: _selectedGender ?? '',
        height: double.tryParse(_heightController.text) ?? 0.0,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        emergencyContactNumber: _emergencyContactController.text.trim(),
        emergencyContactName: _emergencyNameController.text.trim(),
        healthPreferenceOptIn: _healthPreference,
        acceptedTermsAndConditions: _acceptTerms,
        acceptedPrivacyPolicy: _acceptPrivacy,
        medicalHistory: [],
        emergencyContacts: [
          if (_emergencyNameController.text.isNotEmpty && _emergencyContactController.text.isNotEmpty)
            models.EmergencyContact(
              name: _emergencyNameController.text.trim(),
              phone: _emergencyContactController.text.trim(),
              relationship: 'Emergency Contact',
            ),
        ],
      );

      await _firebaseService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        userProfile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        _showError('Sign up failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int _calculateAge(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length != 3) return 0;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final birthDate = DateTime(year, month, day);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
              )
            : null,
        title: const Text('Create Account'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Indicator
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_currentStep + 1) / 2,
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Step ${_currentStep + 1} of 2',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Step 1: Personal Information
                if (_currentStep == 0) ...[
                  FormSectionHeader(
                    stepNumber: 1,
                    title: 'Personal Information',
                    subtitle: 'Let\'s start with your basic details',
                  ),
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _fullNameController,
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Full name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Email Address',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Date of Birth',
                    controller: _dateOfBirthController,
                    prefixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Date of birth is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Gender',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'Male',
                        label: Text('Male'),
                        icon: Icon(Icons.male),
                      ),
                      ButtonSegment(
                        value: 'Female',
                        label: Text('Female'),
                        icon: Icon(Icons.female),
                      ),
                      ButtonSegment(
                        value: 'Other',
                        label: Text('Other'),
                        icon: Icon(Icons.more_horiz),
                      ),
                    ],
                    selected: <String>{if (_selectedGender != null) _selectedGender!},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedGender =
                            newSelection.isEmpty ? null : newSelection.first;
                      });
                    },
                    multiSelectionEnabled: false,
                    emptySelectionAllowed: true,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Health Metrics',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Height (cm)',
                          hint: 'e.g., 170',
                          controller: _heightController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: Icons.height,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Height is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Weight (kg)',
                          hint: 'e.g., 70',
                          controller: _weightController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: Icons.monitor_weight,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Weight is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],

                // Step 2: Contact & Security
                if (_currentStep == 1) ...[
                  FormSectionHeader(
                    stepNumber: 2,
                    title: 'Contact & Security',
                    subtitle: 'Secure your account and provide emergency contact',
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: CustomTextField(
                          label: 'Country Code',
                          controller: _countryCodeController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Code required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Phone Number',
                          hint: 'Your phone number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Emergency Contact Name',
                    hint: 'Contact person name',
                    controller: _emergencyNameController,
                    prefixIcon: Icons.person_add_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Emergency contact name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Emergency Contact Number',
                    hint: 'Emergency contact phone',
                    controller: _emergencyContactController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_missed_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Emergency contact is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Password',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Create a strong password',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  CheckboxWithLabel(
                    value: _healthPreference,
                    onChanged: (value) {
                      setState(() {
                        _healthPreference = value ?? false;
                      });
                    },
                    label: 'Enable Health Insights',
                    subtitle:
                        'Receive personalized health recommendations and tips',
                  ),
                  const SizedBox(height: 12),
                  CheckboxWithLabel(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                    label: 'I accept Terms & Conditions',
                    isError: !_acceptTerms && _isLoading,
                  ),
                  const SizedBox(height: 12),
                  CheckboxWithLabel(
                    value: _acceptPrivacy,
                    onChanged: (value) {
                      setState(() {
                        _acceptPrivacy = value ?? false;
                      });
                    },
                    label: 'I accept Privacy Policy',
                    isError: !_acceptPrivacy && _isLoading,
                  ),
                ],

                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _currentStep--;
                                  });
                                },
                          child: const Text('Back'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_currentStep == 0) {
                                  if (_validateStep1()) {
                                    setState(() {
                                      _currentStep++;
                                    });
                                  }
                                } else {
                                  _handleSignUp();
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _currentStep == 0 ? 'Continue' : 'Create Account',
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Sign In Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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
