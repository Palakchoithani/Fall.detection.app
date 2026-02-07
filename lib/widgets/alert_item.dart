import 'package:flutter/material.dart';
import '../models/alert_model.dart';

class AlertItem extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback onTap;

  const AlertItem({
    Key? key,
    required this.alert,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: alert.isRead ? Colors.white : _getBackgroundColor().withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: alert.isRead ? Colors.grey[200]! : _getBackgroundColor().withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            if (!alert.isRead)
              BoxShadow(
                color: _getBackgroundColor().withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getBackgroundColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(),
                color: _getBackgroundColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: alert.isRead ? FontWeight.w500 : FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      if (!alert.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getBackgroundColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    alert.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(alert.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getPriorityLabel(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getPriorityColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (alert.type) {
      case AlertType.critical:
      case AlertType.fall:
        return const Color(0xFFEF4444);
      case AlertType.warning:
        return const Color(0xFFF59E0B);
      case AlertType.success:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getIcon() {
    switch (alert.type) {
      case AlertType.critical:
        return Icons.error;
      case AlertType.warning:
        return Icons.warning;
      case AlertType.success:
        return Icons.check_circle;
      case AlertType.fall:
        return Icons.person_off;
      default:
        return Icons.info;
    }
  }

  Color _getPriorityColor() {
    switch (alert.priority) {
      case AlertPriority.emergency:
        return const Color(0xFFDC2626);
      case AlertPriority.high:
        return const Color(0xFFEF4444);
      case AlertPriority.medium:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getPriorityLabel() {
    switch (alert.priority) {
      case AlertPriority.emergency:
        return 'EMERGENCY';
      case AlertPriority.high:
        return 'HIGH';
      case AlertPriority.medium:
        return 'MEDIUM';
      default:
        return 'LOW';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}