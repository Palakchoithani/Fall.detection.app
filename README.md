# Health Companion - AI-Driven Predictive Health & Fall Detection App

A comprehensive Flutter mobile application for real-time health monitoring, fall detection, and AI-powered predictive healthcare.

## ⚡ Quick Start

```bash
# Clone or navigate to project
cd /Users/palakchoithani/Desktop/vsc/Fall

# Install dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Or run on available device
flutter run
```

## 📱 Features

- **Real-time Health Monitoring**: Track heart rate, blood pressure, steps, and calories
- **AI Health Score**: Get personalized health insights powered by machine learning
- **Fall Detection**: Automatic detection with emergency alerts
- **Emergency SOS**: Quick access to emergency services with GPS tracking
- **Doctor Connectivity**: Direct communication with healthcare providers
- **Health Insights**: AI-generated recommendations and warnings
- **Secure Authentication**: Firebase-based user authentication
- **Real-time Alerts**: Push notifications for health events

## 🏗️ Project Structure

```
health_companion/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── health_data.dart
│   │   ├── user_model.dart
│   │   └── alert_model.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── alerts_screen.dart
│   │   └── profile_screen.dart
│   ├── widgets/
│   │   ├── health_score_card.dart
│   │   ├── vital_card.dart
│   │   ├── ai_insight_card.dart
│   │   ├── emergency_button.dart
│   │   └── alert_item.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── firebase_service.dart
│   │   └── notification_service.dart
│   └── utils/
│       └── app_theme.dart
├── android/
├── ios/
└── pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode
- Firebase Account

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/health-companion.git
cd health-companion
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**

   a. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   
   b. Add Android/iOS app to your Firebase project
   
   c. Download `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
   
   d. Place the files in:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
   
   e. Enable Firebase Authentication, Firestore, and Cloud Messaging

4. **Update API Endpoint**

   Edit `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'YOUR_API_ENDPOINT';
   ```

5. **Run the app**

On Web (Chrome):
```bash
flutter run -d chrome
```

On Android:
```bash
flutter run -d android
```

On iOS:
```bash
flutter run -d ios
```

Or simply:
```bash
flutter run
```

## 🔧 Configuration

### Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location for emergency services</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location for fall detection</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to connect to health devices</string>
```

## 📦 Dependencies

Key packages used in this project:

- **firebase_core**: Firebase initialization
- **firebase_auth**: User authentication
- **cloud_firestore**: Real-time database
- **firebase_messaging**: Push notifications
- **flutter_local_notifications**: Local notifications
- **geolocator**: Location services
- **http**: API communication
- **permission_handler**: Runtime permissions

## 🎨 Design System

The app follows a modern, clean design system:

- **Primary Color**: Blue (#3B82F6)
- **Secondary Color**: Purple (#8B5CF6)
- **Accent Color**: Green (#10B981)
- **Error Color**: Red (#EF4444)
- **Typography**: System default with custom weights

## 🔐 Security

- All API calls use HTTPS
- User authentication via Firebase Auth
- Data encrypted in transit
- Role-based access control
- Secure token management

## 📊 Features Implementation

### Dashboard
- Real-time health metrics display
- AI-powered health score
- Quick stats grid
- Emergency SOS button

### Alerts System
- Real-time notifications
- Priority-based categorization
- Fall detection status
- GPS tracking indicator

### Profile Management
- User information display
- Connected doctor details
- Medical history tracking
- Emergency contacts

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📱 Build for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Backend API Endpoints

The app expects the following API endpoints:

- `GET /health-data/:userId/latest` - Get latest health data
- `GET /health-data/:userId/history` - Get health history
- `POST /health-data/sync` - Sync health data
- `GET /health-score/:userId` - Get health score
- `GET /alerts/:userId` - Get user alerts
- `POST /emergency/sos` - Trigger emergency
- `GET /users/:userId` - Get user profile
- `GET /users/:userId/doctor` - Get connected doctor

## 🔮 Future Enhancements

- [ ] Wearable device integration (ESP32 + MPU6050)
- [ ] Machine learning model integration
- [ ] Telemedicine video calls
- [ ] Medication reminders
- [ ] Health report generation
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Offline mode with sync

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- Your Name - Initial work

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- The open-source community

## 📞 Support

For support, email support@healthcompanion.com or open an issue in the repository.

---

Made with ❤️ for better healthcare# Fall.detection.app
