import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_model.dart';
import '../models/health_data.dart';
import '../models/alert_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Authentication
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<User?> signUpWithEmail(String email, String password, UserProfile profile) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(profile.toJson());
      }
      
      return result.user;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Firestore - User Profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  Future<void> updateUserProfile(String userId, UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update(profile.toJson());
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  // Firestore - Health Data
  Stream<HealthData> healthDataStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('healthData')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return HealthData.fromJson(snapshot.docs.first.data());
      }
      return HealthData(
        heartRate: 0,
        bloodPressure: '0/0',
        steps: 0,
        calories: 0,
        temperature: 0.0,
        oxygenLevel: 0,
        timestamp: DateTime.now(),
      );
    });
  }

  Future<void> saveHealthData(String userId, HealthData data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('healthData')
          .add(data.toJson());
    } catch (e) {
      throw Exception('Error saving health data: $e');
    }
  }

  Future<List<HealthData>> getHealthHistory(String userId, int days) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('healthData')
          .where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => HealthData.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error fetching health history: $e');
    }
  }

  // Firestore - Alerts
  Stream<List<AlertModel>> alertsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AlertModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  Future<void> addAlert(String userId, AlertModel alert) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('alerts')
          .add(alert.toJson());
    } catch (e) {
      throw Exception('Error adding alert: $e');
    }
  }

  Future<void> markAlertAsRead(String userId, String alertId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('alerts')
          .doc(alertId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Error marking alert as read: $e');
    }
  }

  // Firebase Cloud Messaging
  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      throw Exception('Error getting FCM token: $e');
    }
  }

  Future<void> saveFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    } catch (e) {
      throw Exception('Error saving FCM token: $e');
    }
  }

  void setupFCMListeners(Function(Map<String, dynamic>) onMessage) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onMessage(message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onMessage(message.data);
    });
  }

  // Emergency
  Future<void> triggerEmergency(String userId, Map<String, dynamic> location) async {
    try {
      await _firestore.collection('emergencies').add({
        'userId': userId,
        'location': location,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      // Also add as critical alert
      await addAlert(
        userId,
        AlertModel(
          id: '',
          title: 'Emergency SOS Triggered',
          message: 'Emergency services have been notified',
          type: AlertType.critical,
          priority: AlertPriority.emergency,
          timestamp: DateTime.now(),
          metadata: location,
        ),
      );
    } catch (e) {
      throw Exception('Error triggering emergency: $e');
    }
  }
}