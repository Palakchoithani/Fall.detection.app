import '../models/health_data.dart';
import '../utils/constants.dart';

/// Health data calculation and analysis utilities
class HealthAnalytics {
  /// Calculate BMI (Body Mass Index)
  static double calculateBMI(double heightCm, double weightKg) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  /// Check if heart rate is normal
  static bool isHeartRateNormal(int heartRate) {
    return heartRate >= AppConstants.normalHeartRateMin &&
        heartRate <= AppConstants.normalHeartRateMax;
  }

  /// Check if heart rate is high
  static bool isHeartRateHigh(int heartRate) {
    return heartRate > AppConstants.highHeartRateThreshold;
  }

  /// Check if heart rate is critical
  static bool isHeartRateCritical(int heartRate) {
    return heartRate >= AppConstants.criticalHeartRateThreshold;
  }

  /// Get heart rate status
  static String getHeartRateStatus(int heartRate) {
    if (isHeartRateCritical(heartRate)) return 'Critical';
    if (isHeartRateHigh(heartRate)) return 'High';
    if (isHeartRateNormal(heartRate)) return 'Normal';
    return 'Low';
  }

  /// Parse blood pressure string
  static Map<String, int>? parseBloodPressure(String bpString) {
    try {
      final parts = bpString.split('/');
      if (parts.length == 2) {
        return {
          'systolic': int.parse(parts[0].trim()),
          'diastolic': int.parse(parts[1].trim()),
        };
      }
    } catch (e) {
      // Invalid format
    }
    return null;
  }

  /// Check if blood pressure is normal
  static bool isBloodPressureNormal(String bpString) {
    final bp = parseBloodPressure(bpString);
    if (bp == null) return false;
    
    return bp['systolic']! <= 120 && bp['diastolic']! <= 80;
  }

  /// Get blood pressure status
  static String getBloodPressureStatus(String bpString) {
    final bp = parseBloodPressure(bpString);
    if (bp == null) return 'Unknown';
    
    final systolic = bp['systolic']!;
    final diastolic = bp['diastolic']!;
    
    if (systolic < 90 && diastolic < 60) return 'Low';
    if (systolic <= 120 && diastolic <= 80) return 'Normal';
    if (systolic <= 130 && diastolic <= 80) return 'Elevated';
    if (systolic <= 139 || diastolic <= 89) return 'Stage 1 Hypertension';
    if (systolic >= 140 || diastolic >= 90) return 'Stage 2 Hypertension';
    if (systolic > 180 || diastolic > 120) return 'Hypertensive Crisis';
    
    return 'Unknown';
  }

  /// Check if temperature is normal
  static bool isTemperatureNormal(double temp) {
    return temp >= 97.0 && temp <= 99.0;
  }

  /// Check if temperature indicates fever
  static bool hasFever(double temp) {
    return temp > AppConstants.feverThreshold;
  }

  /// Check if temperature is critical
  static bool isTemperatureCritical(double temp) {
    return temp >= AppConstants.criticalTemperatureHigh ||
        temp <= AppConstants.criticalTemperatureLow;
  }

  /// Get temperature status
  static String getTemperatureStatus(double temp) {
    if (isTemperatureCritical(temp)) return 'Critical';
    if (hasFever(temp)) return 'Fever';
    if (isTemperatureNormal(temp)) return 'Normal';
    return 'Low';
  }

  /// Check if oxygen level is normal
  static bool isOxygenLevelNormal(int oxygenLevel) {
    return oxygenLevel >= AppConstants.normalOxygenLevel;
  }

  /// Check if oxygen level is low
  static bool isOxygenLevelLow(int oxygenLevel) {
    return oxygenLevel < AppConstants.lowOxygenThreshold;
  }

  /// Check if oxygen level is critical
  static bool isOxygenLevelCritical(int oxygenLevel) {
    return oxygenLevel <= AppConstants.criticalOxygenThreshold;
  }

  /// Get oxygen level status
  static String getOxygenLevelStatus(int oxygenLevel) {
    if (isOxygenLevelCritical(oxygenLevel)) return 'Critical';
    if (isOxygenLevelLow(oxygenLevel)) return 'Low';
    if (isOxygenLevelNormal(oxygenLevel)) return 'Normal';
    return 'Very Low';
  }

  /// Check daily step goal progress
  static double getStepProgressPercentage(int steps) {
    return (steps / AppConstants.dailyStepGoal * 100).clamp(0, 100);
  }

  /// Get step status
  static String getStepStatus(int steps) {
    if (steps < AppConstants.dailyStepGoal * 0.25) return 'Low Activity';
    if (steps < AppConstants.dailyStepGoal * 0.5) return 'Moderate Activity';
    if (steps < AppConstants.dailyStepGoal * 0.75) return 'Good Activity';
    if (steps < AppConstants.dailyStepGoal) return 'Very Good Activity';
    return 'Goal Reached!';
  }

  /// Generate health recommendations based on data
  static List<String> generateRecommendations(HealthData data) {
    final recommendations = <String>[];

    // Heart rate recommendations
    if (isHeartRateCritical(data.heartRate)) {
      recommendations.add(
        'Your heart rate is critically high. Please seek medical attention immediately.',
      );
    } else if (isHeartRateHigh(data.heartRate)) {
      recommendations.add(
        'Your heart rate is elevated. Take some rest and try to relax.',
      );
    }

    // Blood pressure recommendations
    final bpStatus = getBloodPressureStatus(data.bloodPressure);
    if (bpStatus.contains('Hypertensive Crisis')) {
      recommendations.add(
        'Your blood pressure is critically high. Please seek emergency medical care.',
      );
    } else if (bpStatus.contains('Hypertension')) {
      recommendations.add(
        'Your blood pressure is elevated. Consult your doctor.',
      );
    }

    // Temperature recommendations
    if (isTemperatureCritical(data.temperature)) {
      recommendations.add(
        'Your temperature is critical. Seek immediate medical attention.',
      );
    } else if (hasFever(data.temperature)) {
      recommendations.add(
        'You have a fever. Stay hydrated and rest.',
      );
    }

    // Oxygen recommendations
    if (isOxygenLevelCritical(data.oxygenLevel)) {
      recommendations.add(
        'Your oxygen level is critically low. Seek medical attention immediately.',
      );
    } else if (isOxygenLevelLow(data.oxygenLevel)) {
      recommendations.add(
        'Your oxygen level is low. Try deep breathing exercises.',
      );
    }

    // Activity recommendations
    if (getStepProgressPercentage(data.steps) < 25) {
      recommendations.add(
        'Increase physical activity. Try to take more steps today.',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('Your health metrics look good. Keep it up!');
    }

    return recommendations;
  }
}
