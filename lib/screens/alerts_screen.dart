import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../services/mock_firebase_service.dart';
import 'alert_category_details_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final MockFirebaseService _firebaseService = MockFirebaseService();
  late final Stream<List<AlertModel>> _alertsStream;

  @override
  void initState() {
    super.initState();
    final user = _firebaseService.getCurrentUser();
    _alertsStream =
        _firebaseService.alertsStream(user?.uid ?? 'mock_user');
  }

  void _navigateToCategory(String category, String categoryName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AlertCategoryDetailsScreen(
          category: category,
          categoryName: categoryName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Alerts & Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
          final criticalCount = alerts
              .where((a) => a.priority == AlertPriority.emergency)
              .length;
          final warningCount =
              alerts.where((a) => a.type == AlertType.warning).length;
          final unreadCount = alerts.where((a) => !(a.isRead ?? false)).length;

          return _buildCategoryView(
            context,
            isDark,
            alerts.length,
            criticalCount,
            warningCount,
            unreadCount,
          );
        },
      ),
    );
  }

  Widget _buildCategoryView(
    BuildContext context,
    bool isDark,
    int totalAlerts,
    int criticalCount,
    int warningCount,
    int unreadCount,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Overview Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.grey[800]!
                      : Colors.grey[200]!,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total', totalAlerts, Colors.blue, isDark),
                  _buildStatItem('Critical', criticalCount, Colors.red, isDark),
                  _buildStatItem('Unread', unreadCount, Colors.orange, isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category Title
            Text(
              'Alert Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // All Alerts Category
            _buildCategoryCard(
              context,
              isDark,
              icon: Icons.notifications_active_outlined,
              title: 'All Alerts',
              subtitle: '$totalAlerts alerts',
              count: totalAlerts,
              color: Colors.blue,
              onTap: () => _navigateToCategory('all', 'All Alerts'),
            ),
            const SizedBox(height: 12),

            // Critical Alerts Category
            _buildCategoryCard(
              context,
              isDark,
              icon: Icons.warning_amber_outlined,
              title: 'Critical Alerts',
              subtitle: '$criticalCount critical issues',
              count: criticalCount,
              color: Colors.red,
              onTap: () => _navigateToCategory('critical', 'Critical Alerts'),
            ),
            const SizedBox(height: 12),

            // Warning Alerts Category
            _buildCategoryCard(
              context,
              isDark,
              icon: Icons.info_outline,
              title: 'Warning Alerts',
              subtitle: '$warningCount warnings',
              count: warningCount,
              color: Colors.orange,
              onTap: () => _navigateToCategory('warning', 'Warning Alerts'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    int value,
    Color color,
    bool isDark,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.grey[800]!
                : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isDark ? 0.1 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.2 : 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Count Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
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
