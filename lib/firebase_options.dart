import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB8mK_zL9nPq2rStUvWxYzAbCdEfGhIjKl',
    appId: '1:123456789012:web:abcdef1234567890',
    messagingSenderId: '123456789012',
    projectId: 'health-companion-app-2026',
    authDomain: 'health-companion-app-2026.firebaseapp.com',
    databaseURL: 'https://health-companion-app-2026.firebaseio.com',
    storageBucket: 'health-companion-app-2026.appspot.com',
    measurementId: 'G-1234567890AB',
  );
}
