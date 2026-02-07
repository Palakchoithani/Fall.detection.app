import 'package:flutter/material.dart';
import '../models/user_model.dart' as models;
import '../services/mock_firebase_service.dart';
import '../services/api_service.dart' as api;
import '../services/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MockFirebaseService _firebaseService = MockFirebaseService();
  final api.ApiService _apiService = api.ApiService();

  models.UserProfile? _userProfile;
  models.Doctor? _connectedDoctor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _firebaseService.getCurrentUser();
      if (user != null) {
        final profile = await _firebaseService.getUserProfile(user.uid);
        final doctor = await _firebaseService.getConnectedDoctor(user.uid);

        setState(() {
          _userProfile = profile;
          _connectedDoctor = doctor;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _firebaseService.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Theme',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            _buildThemeOption(
              icon: Icons.light_mode_outlined,
              label: 'Light Mode',
              isSelected: !isDark,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              icon: Icons.dark_mode_outlined,
              label: 'Dark Mode',
              isSelected: isDark,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              icon: Icons.brightness_auto_outlined,
              label: 'System Default',
              isSelected: themeProvider.themeMode == ThemeMode.system,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3B82F6).withOpacity(0.1)
                : (isDark ? Colors.grey[900] : Colors.grey[50]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF3B82F6),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
          ),
        ),
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Handle case where user profile is not available
    if (_userProfile == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('Profile'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                'No profile data available',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please sign up to create your profile',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/signup',
                    (route) => false,
                  );
                },
                child: const Text('Create Profile'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              _showThemeOptions();
            },
            tooltip: 'Change Theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header Card
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Health Info Section
            _buildSectionTitle('Health Information'),
            const SizedBox(height: 12),
            _buildHealthInfoCard(),
            const SizedBox(height: 24),

            // Connected Doctor Section
            _buildSectionTitle('Connected Doctor'),
            const SizedBox(height: 12),
            _buildDoctorCard(),
            const SizedBox(height: 24),

            // Emergency Contacts Section
            _buildSectionTitle('Emergency Contacts'),
            const SizedBox(height: 12),
            _buildEmergencyContacts(),
            const SizedBox(height: 24),

            // Medical History Section
            _buildSectionTitle('Medical History'),
            const SizedBox(height: 12),
            _buildMedicalHistory(),
            const SizedBox(height: 24),

            // Contact Us Section
            _buildSectionTitle('Support & Feedback'),
            const SizedBox(height: 12),
            _buildContactUsSection(),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    if (_userProfile == null) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 50,
              color: const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userProfile!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _userProfile!.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoBadge('Age', _userProfile!.age.toString()),
              const SizedBox(width: 16),
              _buildInfoBadge('Height', '${_userProfile!.height.toStringAsFixed(1)} cm'),
              const SizedBox(width: 16),
              _buildInfoBadge('Weight', '${_userProfile!.weight.toStringAsFixed(1)} kg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthInfoCard() {
    if (_userProfile == null) {
      return const SizedBox.shrink();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow('Gender', _userProfile!.gender),
          const Divider(),
          _buildInfoRow('Height', '${_userProfile!.height.toStringAsFixed(1)} cm'),
          const Divider(),
          _buildInfoRow('Weight', '${_userProfile!.weight.toStringAsFixed(1)} kg'),
          const Divider(),
          _buildInfoRow('Age', '${_userProfile!.age} years'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_connectedDoctor == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.green[200]!),
        ),
        child: Text(
          'No connected doctor',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.green[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(isDark ? 0.05 : 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green[100],
                child: Icon(
                  Icons.medical_services,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _connectedDoctor!.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      _connectedDoctor!.specialization,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildContactButton(
                  Icons.call,
                  'Call',
                  Colors.green,
                  () async {
                    final uri = Uri(scheme: 'tel', path: _connectedDoctor!.phone);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactButton(
                  Icons.message,
                  'Message',
                  Colors.blue,
                  () async {
                    final uri = Uri(scheme: 'mailto', path: _connectedDoctor!.email);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    if (_userProfile == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Only use emergencyContacts list (single source of truth)
    final contacts = _userProfile!.emergencyContacts;
    
    if (contacts.isEmpty) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                'No emergency contacts added',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Emergency Contact'),
              onPressed: _showAddEmergencyContactDialog,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: const Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      );
    }

    // Display all emergency contacts
    final contactWidgets = contacts
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key + 1;
          final contact = entry.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.red[100],
                      child: Text(
                        contact.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            contact.relationship,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _removeEmergencyContact(index - 1),
                      tooltip: 'Remove contact',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Phone', contact.phone),
              ],
            ),
          );
        })
        .toList();

    return Column(
      children: [
        ...contactWidgets,
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Another Emergency Contact'),
            onPressed: _showAddEmergencyContactDialog,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: const Color(0xFF3B82F6),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddEmergencyContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Contact Name',
                  hintText: 'e.g., John Doe',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g., +1234567890',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty || phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }
              _addEmergencyContact(
                nameController.text.trim(),
                phoneController.text.trim(),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addEmergencyContact(String name, String phone) {
    if (_userProfile == null) return;

    // Create new emergency contact
    final newContact = models.EmergencyContact(
      name: name,
      phone: phone,
      relationship: 'Emergency Contact',
    );

    // Add to the list
    final updatedContacts = [..._userProfile!.emergencyContacts, newContact];

    // Create updated profile with new contacts list
    final updatedProfile = models.UserProfile(
      id: _userProfile!.id,
      name: _userProfile!.name,
      email: _userProfile!.email,
      phoneNumber: _userProfile!.phoneNumber,
      countryCode: _userProfile!.countryCode,
      dateOfBirth: _userProfile!.dateOfBirth,
      age: _userProfile!.age,
      gender: _userProfile!.gender,
      height: _userProfile!.height,
      weight: _userProfile!.weight,
      profileImage: _userProfile!.profileImage,
      emergencyContactNumber: _userProfile!.emergencyContactNumber,
      emergencyContactName: _userProfile!.emergencyContactName,
      healthPreferenceOptIn: _userProfile!.healthPreferenceOptIn,
      acceptedTermsAndConditions: _userProfile!.acceptedTermsAndConditions,
      acceptedPrivacyPolicy: _userProfile!.acceptedPrivacyPolicy,
      medicalHistory: _userProfile!.medicalHistory,
      connectedDoctorId: _userProfile!.connectedDoctorId,
      emergencyContacts: updatedContacts,
    );

    // Update in service
    _firebaseService.updateUserProfile(_userProfile!.id, updatedProfile);

    // Update local state
    setState(() {
      _userProfile = updatedProfile;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency contact added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeEmergencyContact(int index) {
    if (_userProfile == null || index < 0 || index >= _userProfile!.emergencyContacts.length) {
      return;
    }

    // Remove contact from list
    final updatedContacts = List<models.EmergencyContact>.from(_userProfile!.emergencyContacts);
    updatedContacts.removeAt(index);

    // Create updated profile
    final updatedProfile = models.UserProfile(
      id: _userProfile!.id,
      name: _userProfile!.name,
      email: _userProfile!.email,
      phoneNumber: _userProfile!.phoneNumber,
      countryCode: _userProfile!.countryCode,
      dateOfBirth: _userProfile!.dateOfBirth,
      age: _userProfile!.age,
      gender: _userProfile!.gender,
      height: _userProfile!.height,
      weight: _userProfile!.weight,
      profileImage: _userProfile!.profileImage,
      emergencyContactNumber: _userProfile!.emergencyContactNumber,
      emergencyContactName: _userProfile!.emergencyContactName,
      healthPreferenceOptIn: _userProfile!.healthPreferenceOptIn,
      acceptedTermsAndConditions: _userProfile!.acceptedTermsAndConditions,
      acceptedPrivacyPolicy: _userProfile!.acceptedPrivacyPolicy,
      medicalHistory: _userProfile!.medicalHistory,
      connectedDoctorId: _userProfile!.connectedDoctorId,
      emergencyContacts: updatedContacts,
    );

    // Update in service
    _firebaseService.updateUserProfile(_userProfile!.id, updatedProfile);

    // Update local state
    setState(() {
      _userProfile = updatedProfile;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency contact removed'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildMedicalHistory() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_userProfile == null || _userProfile!.medicalHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
        ),
        child: Center(
          child: Text(
            'No medical history recorded',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        children: _userProfile!.medicalHistory.asMap().entries.map((entry) {
          final index = entry.key;
          final condition = entry.value;
          final isLast = index == _userProfile!.medicalHistory.length - 1;

          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      condition,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactUsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Support Email
        _buildContactCard(
          icon: Icons.email_outlined,
          label: 'Support Email',
          value: 'support@healthcompanion.com',
          onTap: () async {
            final email = 'support@healthcompanion.com';
            final subject = 'Health Companion Support Request';
            final uri =
                Uri(scheme: 'mailto', path: email, queryParameters: {
              'subject': subject,
            });
            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not launch $email'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error launching email: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
        const SizedBox(height: 12),
        // Help Center
        _buildContactCard(
          icon: Icons.help_outline,
          label: 'Help Center',
          value: 'Frequently Asked Questions & Guides',
          onTap: () {
            _showHelpCenterDialog();
          },
        ),
        const SizedBox(height: 12),
        // Phone Support
        _buildContactCard(
          icon: Icons.phone_outlined,
          label: 'Phone Support',
          value: '+1 (555) 123-4567',
          onTap: () async {
            final phone = '+15551234567';
            final uri = Uri(scheme: 'tel', path: phone);
            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Could not launch phone call'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error launching phone: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
        const SizedBox(height: 12),
        // Feedback Form
        _buildContactCard(
          icon: Icons.feedback_outlined,
          label: 'Send Feedback',
          value: 'Share your suggestions & improvements',
          onTap: () {
            _showFeedbackDialog();
          },
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpCenterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help Center'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem('How do I track my health data?',
                  'You can manually enter data in the dashboard or sync with your fitness devices.'),
              const SizedBox(height: 12),
              _buildHelpItem('What data is private?',
                  'All your health data is encrypted and only accessible by you and your connected doctor.'),
              const SizedBox(height: 12),
              _buildHelpItem('How do I update my profile?',
                  'Tap the Edit Profile button on your profile screen to update your information.'),
              const SizedBox(height: 12),
              _buildHelpItem('Can I contact my doctor?',
                  'Yes, you can send messages to your connected doctor through the app.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'We\'d love to hear from you! Please share your feedback to help us improve.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (feedbackController.text.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your feedback!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _loadProfile,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh Profile'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            if (_userProfile != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    userProfile: _userProfile!,
                  ),
                ),
              ).then((updatedProfile) {
                if (updatedProfile != null && updatedProfile is models.UserProfile) {
                  setState(() {
                    _userProfile = updatedProfile;
                  });
                }
              });
            }
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profile'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: Color(0xFF3B82F6)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}
