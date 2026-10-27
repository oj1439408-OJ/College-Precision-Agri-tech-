import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/demo_data_service.dart';
import '../widgets/soil_parameter_card.dart';
import 'soil_health_screen.dart';

class SoilScreen extends StatefulWidget {
  const SoilScreen({super.key});

  @override
  State<SoilScreen> createState() => _SoilScreenState();
}

class _SoilScreenState extends State<SoilScreen> {
  late SensorData _sensorData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    DemoDataService.instance.addListener(_handleDemoDataChanged);
    _loadData();
  }

  Future<void> _loadData() async {
    final data = DemoDataService.instance.sensorData;
    if (mounted) {
      setState(() {
        _sensorData = data;
        _isLoading = false;
      });
    }
  }

  void _handleDemoDataChanged() {
    if (!mounted) return;
    setState(() => _sensorData = DemoDataService.instance.sensorData);
  }

  @override
  void dispose() {
    DemoDataService.instance.removeListener(_handleDemoDataChanged);
    super.dispose();
  }

  String _formatLastUpdated(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
        title: const Text('Soil Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF2E7D32),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section: Title, Last Updated & Demo Mode Badge
              Row(
                children: [
                  Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Soil Monitoring',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C2D21),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Last updated: ${_formatLastUpdated(_sensorData.timestamp)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade400),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          DemoDataService.demoModeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7F4E00),
                          ),
                        ),
                      ],
                    ),
                  ),

              const SizedBox(height: 16),

              // Parameter 1: Soil Moisture
              SoilParameterCard(
                name: 'Soil Moisture',
                value: '${_sensorData.moisture.toInt()}',
                unit: '%',
                icon: Icons.water_drop_outlined,
                themeColor: const Color(0xFF1976D2),
                status: _sensorData.moistureStatus,
                progressValue: _sensorData.moisture / 100.0,
              ),
              const SizedBox(height: 10),

              // Parameter 2: Soil pH
              SoilParameterCard(
                name: 'Soil pH Level',
                value: '${_sensorData.ph}',
                unit: 'pH',
                icon: Icons.science_outlined,
                themeColor: const Color(0xFF7B1FA2),
                status: _sensorData.phStatus,
                progressValue: _sensorData.ph / 14.0,
              ),
              const SizedBox(height: 10),

              // Parameter 3: Temperature
              SoilParameterCard(
                name: 'Soil Temperature',
                value: '${_sensorData.temperature.toInt()}',
                unit: '°C',
                icon: Icons.thermostat_outlined,
                themeColor: const Color(0xFFE65100),
                status: _sensorData.tempStatus,
                progressValue: _sensorData.temperature / 50.0,
              ),
              const SizedBox(height: 10),

              // Parameter 4: Humidity
              SoilParameterCard(
                name: 'Air Humidity',
                value: '${_sensorData.humidity.toInt()}',
                unit: '%',
                icon: Icons.cloud_outlined,
                themeColor: const Color(0xFF00838F),
                status: _sensorData.humidityStatus,
                progressValue: _sensorData.humidity / 100.0,
              ),
              const SizedBox(height: 10),

              // Parameter 5: Nitrogen (N)
              SoilParameterCard(
                name: 'Nitrogen (N)',
                value: '${_sensorData.nitrogen.toInt()}',
                unit: 'mg/kg',
                icon: Icons.eco_outlined,
                themeColor: const Color(0xFF2E7D32),
                status: _sensorData.nitrogenStatus,
                progressValue: _sensorData.nitrogen / 100.0,
              ),
              const SizedBox(height: 10),

              // Parameter 6: Phosphorus (P)
              SoilParameterCard(
                name: 'Phosphorus (P)',
                value: '${_sensorData.phosphorus.toInt()}',
                unit: 'mg/kg',
                icon: Icons.bubble_chart_outlined,
                themeColor: const Color(0xFFD84315),
                status: _sensorData.phosphorusStatus,
                progressValue: _sensorData.phosphorus / 100.0,
              ),
              const SizedBox(height: 10),

              // Parameter 7: Potassium (K)
              SoilParameterCard(
                name: 'Potassium (K)',
                value: '${_sensorData.potassium.toInt()}',
                unit: 'mg/kg',
                icon: Icons.grain_outlined,
                themeColor: const Color(0xFF1565C0),
                status: _sensorData.potassiumStatus,
                progressValue: _sensorData.potassium / 100.0,
              ),

              const SizedBox(height: 20),

              // Soil Condition Summary Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFC8E6C9), width: 1.5),
                ),
                color: const Color(0xFFF1F8F1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.verified_outlined, color: Color(0xFF2E7D32), size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Soil Condition Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Overall soil condition is ${DemoDataService.instance.soilHealth.overallRating} (${DemoDataService.instance.soilHealth.score}/100). The summary reflects the current simulated sensor and NPK values.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final health = DemoDataService.instance.soilHealth;
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SoilHealthScreen(healthScore: health),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.analytics_outlined, size: 18),
                          label: const Text('View Full Health Breakdown'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
