import 'package:flutter/material.dart';

class AIInsightCard extends StatelessWidget {
  final List<String> insights;

  const AIInsightCard({
    Key? key,
    required this.insights,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI Health Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (insights.isEmpty)
            Text(
              'No insights available at this time',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          else
            ...insights.asMap().entries.map((entry) {
              final index = entry.key;
              final insight = entry.value;
              return _buildInsightItem(insight, index);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String insight, int index) {
    Color bgColor;
    Color dotColor;
    IconData icon;

    // Simple categorization based on keywords
    if (insight.toLowerCase().contains('great') ||
        insight.toLowerCase().contains('excellent') ||
        insight.toLowerCase().contains('good')) {
      bgColor = const Color(0xFFECFDF5);
      dotColor = const Color(0xFF10B981);
      icon = Icons.check_circle;
    } else if (insight.toLowerCase().contains('warning') ||
        insight.toLowerCase().contains('increase') ||
        insight.toLowerCase().contains('decrease')) {
      bgColor = const Color(0xFFFEF3C7);
      dotColor = const Color(0xFFF59E0B);
      icon = Icons.warning;
    } else {
      bgColor = const Color(0xFFDBEAFE);
      dotColor = const Color(0xFF3B82F6);
      icon = Icons.info;
    }

    return Container(
      margin: EdgeInsets.only(bottom: index < insights.length - 1 ? 12 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}