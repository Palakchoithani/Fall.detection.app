import '../models/user_model.dart';
import '../models/health_data.dart';
import '../models/alert_model.dart';

/// Mock User object for testing
class UserMock {
  final String uid;
  final String email;

  UserMock({required this.email}) : uid = 'mock_user_${email.hashCode}';
}

/// Mock Firebase Service for development without real Firebase credentials
class MockFirebaseService {
  static final MockFirebaseService _instance = MockFirebaseService._internal();
  factory MockFirebaseService() => _instance;
  MockFirebaseService._internal() {
    // Start with NO user - users must login or sign up
    _currentUser = null;
  }

  UserMock? _currentUser;
  UserProfile? _userProfile;
  
  final List<AlertModel> _alerts = [
    AlertModel(
      id: '1',
      title: 'High Heart Rate Detected',
      message: 'Your heart rate is 120 BPM. Please take a rest.',
      type: AlertType.warning,
      priority: AlertPriority.high,
      timestamp: DateTime.now(),
      metadata: {'heartRate': 120},
    ),
  ];

  // Mock Authentication
  Future<dynamic> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = UserMock(email: email);
    return _currentUser;
  }

  Future<dynamic> signUpWithEmail(
    String email,
    String password,
    UserProfile profile,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = UserMock(email: email);
    // Store the user profile data from sign-up
    _userProfile = profile;
    return _currentUser;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _userProfile = null;
  }

  dynamic getCurrentUser() => _currentUser;

  Stream<dynamic> authStateChanges() {
    return Stream.value(_currentUser);
  }

  // Mock Firestore - User Profile
  Future<UserProfile?> getUserProfile(String userId) async {
    // Return the stored user profile from sign-up, not hardcoded data
    if (_userProfile != null) {
      return _userProfile!;
    }
    // If no profile was set during sign-up, return null or empty profile
    return null;
  }

  /// Check if a user profile exists in the system
  Future<bool> profileExists(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _userProfile != null;
  }

  Future<void> updateUserProfile(String userId, UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Update the stored user profile
    _userProfile = profile;
  }

  // Mock Doctor
  Future<Doctor> getConnectedDoctor(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Doctor(
      id: 'doctor_123',
      name: 'Dr. Sarah Johnson',
      specialization: 'Cardiologist',
      phone: '+1-555-0123',
      email: 'dr.johnson@hospital.com',
      profileImage: null,
    );
  }

  // Mock Health Data
  Stream<HealthData> healthDataStream(String userId) {
    return Stream.value(
      HealthData(
        heartRate: 72,
        bloodPressure: '120/80',
        steps: 8542,
        calories: 450,
        temperature: 98.6,
        oxygenLevel: 98,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> saveHealthData(String userId, HealthData data) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<HealthData>> getHealthHistory(String userId, int days) async {
    return [
      HealthData(
        heartRate: 70,
        bloodPressure: '118/78',
        steps: 7500,
        calories: 400,
        temperature: 98.5,
        oxygenLevel: 99,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      HealthData(
        heartRate: 72,
        bloodPressure: '120/80',
        steps: 8542,
        calories: 450,
        temperature: 98.6,
        oxygenLevel: 98,
        timestamp: DateTime.now(),
      ),
    ];
  }

  // Mock Health Score API
  Future<dynamic> getHealthScore(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'score': 82,
      'status': 'Good',
      'insights': [
        'Your heart rate is in healthy range',
        'Keep up your daily step goal',
        'Stay hydrated',
      ],
      'trend': 5,
    };
  }

  // Mock Alerts
  Stream<List<AlertModel>> alertsStream(String userId) {
    return Stream.value(_alerts).asBroadcastStream();
  }

  Future<void> addAlert(String userId, AlertModel alert) async {
    _alerts.add(alert);
  }

  Future<void> markAlertAsRead(String userId, String alertId) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index >= 0) {
      _alerts[index] = AlertModel(
        id: _alerts[index].id,
        title: _alerts[index].title,
        message: _alerts[index].message,
        type: _alerts[index].type,
        priority: _alerts[index].priority,
        timestamp: _alerts[index].timestamp,
        metadata: _alerts[index].metadata,
        isRead: true,
      );
    }
  }

  // Mock FCM
  Future<String?> getFCMToken() async {
    return 'mock_fcm_token_12345';
  }

  Future<void> saveFCMToken(String userId, String token) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void setupFCMListeners(Function(Map<String, dynamic>) onMessage) {
    // Mock listener - do nothing
  }

  // Mock Emergency
  Future<void> triggerEmergency(
    String userId,
    Map<String, dynamic> location,
  ) async {
    await addAlert(
      userId,
      AlertModel(
        id: DateTime.now().toString(),
        title: 'Emergency SOS Triggered',
        message: 'Emergency services have been notified',
        type: AlertType.critical,
        priority: AlertPriority.emergency,
        timestamp: DateTime.now(),
        metadata: location,
      ),
    );
  }
}
