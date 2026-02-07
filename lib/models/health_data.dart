class HealthData {
  final int heartRate;
  final String bloodPressure;
  final int steps;
  final int calories;
  final double temperature;
  final int oxygenLevel;
  final DateTime timestamp;

  HealthData({
    required this.heartRate,
    required this.bloodPressure,
    required this.steps,
    required this.calories,
    required this.temperature,
    required this.oxygenLevel,
    required this.timestamp,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      heartRate: json['heartRate'] ?? 0,
      bloodPressure: json['bloodPressure'] ?? '0/0',
      steps: json['steps'] ?? 0,
      calories: json['calories'] ?? 0,
      temperature: json['temperature']?.toDouble() ?? 0.0,
      oxygenLevel: json['oxygenLevel'] ?? 0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heartRate': heartRate,
      'bloodPressure': bloodPressure,
      'steps': steps,
      'calories': calories,
      'temperature': temperature,
      'oxygenLevel': oxygenLevel,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class HealthScore {
  final int score;
  final String status;
  final List<String> insights;
  final int trend;

  HealthScore({
    required this.score,
    required this.status,
    required this.insights,
    required this.trend,
  });

  factory HealthScore.fromJson(Map<String, dynamic> json) {
    return HealthScore(
      score: json['score'] ?? 0,
      status: json['status'] ?? 'Unknown',
      insights: List<String>.from(json['insights'] ?? []),
      trend: json['trend'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'status': status,
      'insights': insights,
      'trend': trend,
    };
  }
}