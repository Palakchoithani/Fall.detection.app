import 'package:flutter/material.dart';
import '../models/health_data.dart';

class HealthScoreCard extends StatelessWidget {
  final HealthScore healthScore;

  const HealthScoreCard({
    Key? key,
    required this.healthScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradientColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _getGradientColors()[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Score',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${healthScore.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    healthScore.status,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                healthScore.trend > 0
                    ? Icons.trending_up
                    : healthScore.trend < 0
                        ? Icons.trending_down
                        : Icons.trending_flat,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                healthScore.trend > 0
                    ? '+${healthScore.trend} points this week'
                    : healthScore.trend < 0
                        ? '${healthScore.trend} points this week'
                        : 'No change this week',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors() {
    if (healthScore.score >= 80) {
      return [const Color(0xFF10B981), const Color(0xFF059669)];
    } else if (healthScore.score >= 60) {
      return [const Color(0xFF3B82F6), const Color(0xFF2563EB)];
    } else if (healthScore.score >= 40) {
      return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
    } else {
      return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
    }
  }
}