/// Production-ready logging service
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  final List<LogEntry> _logs = [];
  static const int maxLogs = 1000;

  void info(String message, {String? tag}) {
    _log('INFO', message, tag);
  }

  void warning(String message, {String? tag}) {
    _log('WARNING', message, tag);
  }

  void error(String message, {String? tag, StackTrace? stackTrace}) {
    final sb = StringBuffer(message);
    if (stackTrace != null) {
      sb.write('\n$stackTrace');
    }
    _log('ERROR', sb.toString(), tag);
  }

  void debug(String message, {String? tag}) {
    _log('DEBUG', message, tag);
  }

  void _log(String level, String message, String? tag) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
    );

    _logs.add(entry);

    // Keep logs within limit
    if (_logs.length > maxLogs) {
      _logs.removeRange(0, _logs.length - maxLogs);
    }

    // Print to console in debug mode
    _printLog(entry);
  }

  void _printLog(LogEntry entry) {
    final time = entry.timestamp.toIso8601String();
    final tagStr = entry.tag != null ? '[${entry.tag}]' : '';
    print('$time [${entry.level}] $tagStr ${entry.message}');
  }

  List<LogEntry> getLogs({String? level, int? limit}) {
    var filtered = _logs;

    if (level != null) {
      filtered = filtered.where((l) => l.level == level).toList();
    }

    if (limit != null && limit > 0) {
      return filtered.sublist(
        (filtered.length - limit) > 0 ? filtered.length - limit : 0,
      );
    }

    return filtered;
  }

  void clear() {
    _logs.clear();
  }
}

class LogEntry {
  final DateTime timestamp;
  final String level;
  final String message;
  final String? tag;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
  });

  @override
  String toString() => '$timestamp [$level] ${tag ?? ''} $message';
}
