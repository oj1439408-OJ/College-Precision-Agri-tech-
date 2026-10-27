import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../models/soil_health.dart';
import '../models/crop_recommendation.dart';
import '../services/demo_data_service.dart';
import '../services/recommendation_service.dart';
import '../widgets/sensor_card.dart';
import '../widgets/health_score_card.dart';
import '../widgets/pump_status_card.dart';
import 'soil_health_screen.dart';
import 'crop_recommendation_screen.dart';
import 'fertilizer_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({
    super.key,
    required this.onNavigateTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SensorData _sensorData;
  late SoilHealthScore _soilHealth;
  late CropRecommendation _cropRec;
  bool _isPumpOn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    DemoDataService.instance.addListener(_handleDemoDataChanged);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final demoData = DemoDataService.instance;
    if (mounted) {
      setState(() {
        _sensorData = demoData.sensorData;
        _soilHealth = demoData.soilHealth;
        _cropRec = RecommendationService.recommendCrop(demoData.sensorData);
        _isPumpOn = demoData.isPumpOn;
        _isLoading = false;
      });
    }
  }

  void _handleDemoDataChanged() {
    if (!mounted || _isLoading) return;
    final demoData = DemoDataService.instance;
    setState(() {
      _sensorData = demoData.sensorData;
      _soilHealth = demoData.soilHealth;
      _cropRec = RecommendationService.recommendCrop(demoData.sensorData);
      _isPumpOn = demoData.isPumpOn;
    });
  }

  void _handlePumpToggle(bool val) {
    DemoDataService.instance.setPump(val);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(val ? 'Pump turned ON (Simulated)' : 'Pump turned OFF'),
          duration: const Duration(seconds: 2),
          backgroundColor: val ? const Color(0xFF2E7D32) : Colors.grey.shade800,
        ),
      );
    }
  }

  @override
  void dispose() {
    DemoDataService.instance.removeListener(_handleDemoDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Precision Agri-Tech',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  DemoDataService.demoModeLabel,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: const Color(0xFF2E7D32),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Good Morning, Farmer 👋',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C2D21),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Here is your live field & soil status',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Overall Soil Health Score Card
              HealthScoreCard(
                score: _soilHealth.score,
                rating: _soilHealth.overallRating,
                summary: _soilHealth.summary,
                onTapDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SoilHealthScreen(healthScore: _soilHealth),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Water Pump Status Card
              PumpStatusCard(
                isPumpOn: _isPumpOn,
                isAutoMode: DemoDataService.instance.isAutoMode,
                onTogglePump: _handlePumpToggle,
              ),

              const SizedBox(height: 20),

              // Live Sensors Grid Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Live Sensor Readings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C2D21),
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigateTab(1), // Soil tab
                    child: const Text(
                      'View All',
                      style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Sensor Grid Cards
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.25,
                children: [
                  SensorCard(
                    title: 'Soil Moisture',
                    value: '${_sensorData.moisture}',
                    unit: '%',
                    icon: Icons.water_drop_outlined,
                    iconColor: const Color(0xFF1976D2),
                    status: _sensorData.moistureStatus,
                    statusColor: _sensorData.moisture < 30 ? Colors.orange : Colors.green,
                  ),
                  SensorCard(
                    title: 'Soil pH Level',
                    value: '${_sensorData.ph}',
                    unit: 'pH',
                    icon: Icons.science_outlined,
                    iconColor: const Color(0xFF7B1FA2),
                    status: _sensorData.phStatus,
                    statusColor: Colors.green,
                  ),
                  SensorCard(
                    title: 'Soil Temp',
                    value: '${_sensorData.temperature}',
                    unit: '°C',
                    icon: Icons.thermostat_outlined,
                    iconColor: const Color(0xFFE65100),
                    status: _sensorData.tempStatus,
                    statusColor: Colors.green,
                  ),
                  SensorCard(
                    title: 'Air Humidity',
                    value: '${_sensorData.humidity}',
                    unit: '%',
                    icon: Icons.cloud_outlined,
                    iconColor: const Color(0xFF00838F),
                    status: _sensorData.humidityStatus,
                    statusColor: Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Recommended Crop Quick Highlight
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFC8E6C9), width: 1),
                ),
                color: const Color(0xFFF9FDF9),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.grass,
                          color: Color(0xFF2E7D32),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Recommended Crop',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _cropRec.cropName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C2D21),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Suitability: ${_cropRec.suitabilityPercentage}% match',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CropRecommendationScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        child: const Text('View', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Quick Actions Header
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C2D21),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionItem(
                      icon: Icons.health_and_safety_outlined,
                      label: 'Soil Health',
                      color: const Color(0xFF2E7D32),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SoilHealthScreen(healthScore: _soilHealth),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionItem(
                      icon: Icons.spa_outlined,
                      label: 'Fertilizer',
                      color: const Color(0xFFE65100),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FertilizerScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionItem(
                      icon: Icons.smart_toy_outlined,
                      label: 'Ask AI',
                      color: const Color(0xFF1565C0),
                      onTap: () => widget.onNavigateTab(3), // AI Assistant tab
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C2D21),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
