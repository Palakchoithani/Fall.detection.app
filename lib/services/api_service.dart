import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/health_data.dart';
import '../models/alert_model.dart';
import '../models/user_model.dart';

// Doctor model
class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String phone;
  final String email;
  final String? profileImage;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.phone,
    required this.email,
    this.profileImage,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      name: json['name'] as String,
      specialization: json['specialization'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      profileImage: json['profileImage'] as String?,
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://your-api-endpoint.com/api';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Health Data APIs
  Future<HealthData> getLatestHealthData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health-data/$userId/latest'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return HealthData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load health data');
      }
    } catch (e) {
      throw Exception('Error fetching health data: $e');
    }
  }

  Future<List<HealthData>> getHealthHistory(String userId, {int days = 7}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health-data/$userId/history?days=$days'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => HealthData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load health history');
      }
    } catch (e) {
      throw Exception('Error fetching health history: $e');
    }
  }

  Future<void> syncHealthData(HealthData healthData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/health-data/sync'),
        headers: _headers,
        body: json.encode(healthData.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to sync health data');
      }
    } catch (e) {
      throw Exception('Error syncing health data: $e');
    }
  }

  // Health Score APIs
  Future<HealthScore> getHealthScore(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health-score/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return HealthScore.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load health score');
      }
    } catch (e) {
      throw Exception('Error fetching health score: $e');
    }
  }

  // Alert APIs
  Future<List<AlertModel>> getAlerts(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/alerts/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AlertModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load alerts');
      }
    } catch (e) {
      throw Exception('Error fetching alerts: $e');
    }
  }

  Future<void> markAlertAsRead(String alertId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/alerts/$alertId/read'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark alert as read');
      }
    } catch (e) {
      throw Exception('Error marking alert as read: $e');
    }
  }

  // Doctor APIs
  Future<Doctor?> getConnectedDoctor(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctors/$userId/connected'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Doctor.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching doctor information: $e');
    }
  }


  // AI Prediction APIs
  Future<Map<String, dynamic>> getPredictiveAnalysis(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ai/predict/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load predictive analysis');
      }
    } catch (e) {
      throw Exception('Error fetching predictive analysis: $e');
    }
  }
}