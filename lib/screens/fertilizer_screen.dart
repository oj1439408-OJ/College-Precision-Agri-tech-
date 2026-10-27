import 'package:flutter/material.dart';
import '../models/fertilizer_recommendation.dart';
import '../services/demo_data_service.dart';
import '../services/recommendation_service.dart';

class FertilizerScreen extends StatefulWidget {
  const FertilizerScreen({super.key});

  @override
  State<FertilizerScreen> createState() => _FertilizerScreenState();
}

class _FertilizerScreenState extends State<FertilizerScreen> {
  List<FertilizerRecommendation> _list = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    DemoDataService.instance.addListener(_handleDemoDataChanged);
    _loadData();
  }

  Future<void> _loadData() async {
    final data = RecommendationService.analyzeNutrients(
      DemoDataService.instance.sensorData,
    );
    if (mounted) {
      setState(() {
        _list = data;
        _isLoading = false;
      });
    }
  }

  void _handleDemoDataChanged() {
    if (!mounted) return;
    setState(() {
      _list = RecommendationService.analyzeNutrients(
        DemoDataService.instance.sensorData,
      );
    });
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
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fertilizer Recommendations'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DemoDataService.demoModeLabel,
                    style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rule-based NPK guidance only. Confirm nutrient needs with a local soil test; no dosage is provided.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF49634D)),
                  ),
                ],
              ),
            ),
            const Text(
              'NPK Deficiency Analysis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Nutrient status is classified from the current demo readings.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            ..._list.map((item) {
              final isLow = item.status.toLowerCase().contains('low');
                final isHigh = item.status.toLowerCase().contains('high');
                final statusColor = isLow
                  ? Colors.orange.shade900
                  : isHigh
                    ? Colors.red.shade800
                    : Colors.green.shade900;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.nutrientName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          Text('Current: ${item.currentVal}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          Text('Reference: ${item.targetVal}',
                              style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.science, color: Color(0xFF2E7D32), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Suggestion:',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.recommendationText,
                                  style: const TextStyle(fontSize: 13, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.eco, color: Color(0xFF4CAF50), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Organic Alternative:',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.organicOption,
                                  style: const TextStyle(fontSize: 13, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
