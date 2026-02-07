import 'logger_service.dart';
import '../models/user_model.dart';

/// Session management service for user state tracking
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final LoggerService _logger = LoggerService();

  UserProfile? _currentUser;
  DateTime? _lastActivityTime;
  bool _isLoggedIn = false;

  // Session timeout duration
  final Duration _sessionTimeout = const Duration(hours: 2);

  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn && !_isSessionExpired;
  DateTime? get lastActivityTime => _lastActivityTime;

  bool get _isSessionExpired {
    if (_lastActivityTime == null) return false;
    return DateTime.now().difference(_lastActivityTime!) > _sessionTimeout;
  }

  /// Login user
  void login(UserProfile user) {
    _currentUser = user;
    _isLoggedIn = true;
    _lastActivityTime = DateTime.now();
    _logger.info(
      'User logged in: ${user.email}',
      tag: 'SessionManager',
    );
  }

  /// Logout user
  void logout() {
    if (_currentUser != null) {
      _logger.info(
        'User logged out: ${_currentUser!.email}',
        tag: 'SessionManager',
      );
    }
    _currentUser = null;
    _isLoggedIn = false;
    _lastActivityTime = null;
  }

  /// Update last activity time
  void recordActivity() {
    _lastActivityTime = DateTime.now();
  }

  /// Update user profile
  void updateUserProfile(UserProfile profile) {
    _currentUser = profile;
    _logger.info(
      'User profile updated',
      tag: 'SessionManager',
    );
  }

  /// Check if session is still valid
  bool isSessionValid() {
    if (!_isLoggedIn || _currentUser == null) {
      return false;
    }

    if (_isSessionExpired) {
      _logger.warning(
        'Session expired',
        tag: 'SessionManager',
      );
      logout();
      return false;
    }

    return true;
  }

  /// Get session info
  Map<String, dynamic> getSessionInfo() {
    return {
      'isLoggedIn': isLoggedIn,
      'user': _currentUser?.name ?? 'Unknown',
      'lastActivity': _lastActivityTime?.toIso8601String(),
      'sessionExpired': _isSessionExpired,
      'timeoutDuration': _sessionTimeout.inMinutes,
    };
  }
}
