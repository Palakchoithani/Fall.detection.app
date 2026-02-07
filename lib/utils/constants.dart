/// Application-wide constants
class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://your-api-endpoint.com/api';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Health Data Thresholds
  static const int normalHeartRateMin = 60;
  static const int normalHeartRateMax = 100;
  static const int highHeartRateThreshold = 120;
  static const int criticalHeartRateThreshold = 140;

  static const String normalBloodPressure = '120/80';
  static const int highBPSystolic = 140;
  static const int highBPDiastolic = 90;

  static const double normalTemperature = 98.6;
  static const double feverThreshold = 100.4;
  static const double criticalTemperatureHigh = 104.0;
  static const double criticalTemperatureLow = 95.0;

  static const int normalOxygenLevel = 95;
  static const int lowOxygenThreshold = 90;
  static const int criticalOxygenThreshold = 80;

  static const int dailyStepGoal = 10000;

  // UI Constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 24.0;

  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 500);
  static const Duration animationDurationLong = Duration(milliseconds: 1000);

  // Notification Configuration
  static const String notificationChannelId = 'health_companion_channel';
  static const String notificationChannelName = 'Health Companion Notifications';
  static const String notificationChannelDescription =
      'Notifications for health alerts and updates';

  static const String reminderChannelId = 'health_reminders_channel';
  static const String reminderChannelName = 'Health Reminders';

  // App Strings
  static const String appName = 'Health Companion';
  static const String appDescription = 'AI-Powered Healthcare';

  // Validators
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Emergency
  static const Duration emergencyLongPressDuration = Duration(seconds: 2);
}

/// Feature flags for easy A/B testing and feature rollout
class FeatureFlags {
  static const bool enableAIInsights = true;
  static const bool enableFallDetection = true;
  static const bool enableEmergencyCall = true;
  static const bool enableHealthHistory = true;
  static const bool enableDoctorConnection = true;
  static const bool enableNotifications = true;
  static const bool enableDarkTheme = false; // Can be enabled in future
}
