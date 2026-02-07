import 'package:flutter/material.dart';
import '../widgets/health_score_card.dart';
import '../widgets/compact_health_metric_card.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/emergency_button.dart';
import '../models/health_data.dart' as models;
import '../services/mock_firebase_service.dart';
import '../services/api_service.dart';
import '../services/logger_service.dart';
import '../services/error_handler.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onAlertsPressed;

  const DashboardScreen({Key? key, this.onAlertsPressed}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MockFirebaseService _firebaseService = MockFirebaseService();
  final ApiService _apiService = ApiService();
  final LoggerService _logger = LoggerService();
  final ErrorHandler _errorHandler = ErrorHandler();
  
  models.HealthData? _currentHealthData;
  models.HealthScore? _healthScore;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupRealTimeUpdates();
  }

  Future<void> _loadData() async {
    try {
      _logger.info('Loading dashboard data', tag: 'Dashboard');
      final user = _firebaseService.getCurrentUser();
      if (user != null) {
        final healthScoreData = await _firebaseService.getHealthScore(user.uid);
        final healthScore = models.HealthScore(
          score: healthScoreData['score'] ?? 0,
          status: healthScoreData['status'] ?? 'Unknown',
          insights: List<String>.from(healthScoreData['insights'] ?? []),
          trend: healthScoreData['trend'] ?? 0,
        );
        if (mounted) {
          setState(() {
            _healthScore = healthScore;
            _isLoading = false;
            _errorMessage = null;
          });
        }
        _logger.info('Dashboard data loaded successfully', tag: 'Dashboard');
      }
    } catch (e) {
      _logger.error('Error loading dashboard data: $e', tag: 'Dashboard');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _errorHandler.getErrorMessage(e);
        });
      }
    }
  }

  void _setupRealTimeUpdates() {
    try {
      final user = _firebaseService.getCurrentUser();
      if (user != null) {
        _firebaseService.healthDataStream(user.uid).listen((data) {
          if (mounted) {
            setState(() {
              _currentHealthData = data;
            });
          }
        }, onError: (error) {
          _logger.error('Error in health data stream: $error', tag: 'Dashboard');
        });
      }
    } catch (e) {
      _logger.error('Error setting up real-time updates: $e', tag: 'Dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Companion',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'AI-Powered Healthcare',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  if (widget.onAlertsPressed != null) {
                    widget.onAlertsPressed!();
                  }
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _loadData();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Health Score Card
                    if (_healthScore != null)
                      HealthScoreCard(healthScore: _healthScore!),
                    
                    const SizedBox(height: 20),
                    
                    // Quick Stats Grid
                    if (_currentHealthData != null)
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.15,
                        children: [
                          CompactHealthMetricCard(
                            icon: Icons.favorite,
                            label: 'Heart Rate',
                            value: '${_currentHealthData!.heartRate}',
                            unit: 'bpm',
                            color: Colors.red,
                            status: _currentHealthData!.heartRate > 100 ? 'High' : 'Normal',
                          ),
                          CompactHealthMetricCard(
                            icon: Icons.show_chart,
                            label: 'Blood Pressure',
                            value: _currentHealthData!.bloodPressure,
                            unit: 'mmHg',
                            color: Colors.purple,
                          ),
                          CompactHealthMetricCard(
                            icon: Icons.directions_walk,
                            label: 'Steps',
                            value: '${_currentHealthData!.steps}',
                            unit: 'K',
                            color: Colors.green,
                            status: _currentHealthData!.steps >= 10000 ? 'Goal' : 'Active',
                          ),
                          CompactHealthMetricCard(
                            icon: Icons.local_fire_department,
                            label: 'Calories',
                            value: '${_currentHealthData!.calories}',
                            unit: 'kcal',
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // AI Insights
                    if (_healthScore != null)
                      AIInsightCard(insights: _healthScore!.insights),
                    
                    const SizedBox(height: 20),
                    
                    // Emergency Button
                    const EmergencyButton(),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}