import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../services/mock_firebase_service.dart';

class AlertCategoryDetailsScreen extends StatefulWidget {
  final String category; // 'all', 'critical', 'warning'
  final String categoryName; // Display name

  const AlertCategoryDetailsScreen({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  State<AlertCategoryDetailsScreen> createState() =>
      _AlertCategoryDetailsScreenState();
}

class _AlertCategoryDetailsScreenState
    extends State<AlertCategoryDetailsScreen> {
  final MockFirebaseService _firebaseService = MockFirebaseService();
  late final Stream<List<AlertModel>> _alertsStream;

  @override
  void initState() {
    super.initState();
    final user = _firebaseService.getCurrentUser();
    _alertsStream =
        _firebaseService.alertsStream(user?.uid ?? 'mock_user');
  }

  List<AlertModel> _applyFilter(List<AlertModel> alerts) {
    switch (widget.category) {
      case 'critical':
        return alerts
            .where((a) => a.priority == AlertPriority.emergency)
            .toList();
      case 'warning':
        return alerts
            .where((a) => a.type == AlertType.warning)
            .toList();
      default:
        return alerts;
    }
  }

  void _markAllAsRead() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All alerts marked as read')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.done_all,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: StreamBuilder<List<AlertModel>>(
        stream: _alertsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _errorState(snapshot.error.toString(), isDark);
          }

          final alerts = snapshot.data ?? [];
          final filteredAlerts = _applyFilter(alerts);

          if (filteredAlerts.isEmpty) {
            return _emptyState(isDark);
          }

          return Column(
            children: [
              _statsBar(filteredAlerts, isDark),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredAlerts.length,
                  itemBuilder: (_, i) =>
                      AlertItemWidget(alert: filteredAlerts[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statsBar(List<AlertModel> alerts, bool isDark) {
    final criticalCount = alerts
        .where((a) => a.priority == AlertPriority.emergency)
        .length;
    final unreadCount = alerts.where((a) => !(a.isRead ?? false)).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('Total', alerts.length.toString(), Colors.blue, isDark),
          _stat('Critical', criticalCount.toString(), Colors.red, isDark),
          _stat('Unread', unreadCount.toString(), Colors.orange, isDark),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600])),
      ],
    );
  }

  Widget _emptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off,
              size: 60,
              color: isDark ? Colors.grey[700] : Colors.grey[300]),
          const SizedBox(height: 12),
          Text('No ${widget.categoryName.toLowerCase()}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              )),
        ],
      ),
    );
  }

  Widget _errorState(String error, bool isDark) {
    return Center(
      child: Text(
        error,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

// Alert Item Widget
class AlertItemWidget extends StatelessWidget {
  final AlertModel alert;

  const AlertItemWidget({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _colorByPriority(alert.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(alert.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black,
              )),
          const SizedBox(height: 4),
          Text(alert.message,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              )),
          const SizedBox(height: 8),
          Text(_timeAgo(alert.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              )),
        ],
      ),
    );
  }

  Color _colorByPriority(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.emergency:
        return Colors.red;
      case AlertPriority.high:
        return Colors.orange;
      case AlertPriority.medium:
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
