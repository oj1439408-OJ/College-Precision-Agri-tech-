import 'package:flutter/material.dart';
import '../services/demo_data_service.dart';
import '../services/recommendation_service.dart';

class CropRecommendationScreen extends StatelessWidget {
  const CropRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: DemoDataService.instance,
      builder: (context, _) {
        final crop = RecommendationService.recommendCrop(
          DemoDataService.instance.sensorData,
        );
        return Scaffold(
          appBar: AppBar(
            title: const Text('Crop Recommendations'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
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
                        style: TextStyle(
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rule-based suggestions from demo soil readings; not an ML prediction.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF49634D)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
            // Top Banner Card
            Card(
              color: const Color(0xFFE8F5E9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFA5D6A7), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.grass, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'TOP RECOMMENDED CROP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF388E3C),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      crop.cropName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${crop.season} • ${crop.soilType}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF49634D)),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      backgroundColor: const Color(0xFF2E7D32),
                      label: Text(
                        '${crop.suitabilityPercentage}% Suitability Match',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Why This Crop?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  crop.reason,
                  style: const TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF1C2D21)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Required Soil & Environment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: crop.requiredConditions.entries.map((entry) {
                  return ListTile(
                    dense: true,
                    title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text(
                      entry.value,
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Alternative Crop Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...crop.alternativeCrops.map((alt) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.spa, color: Color(0xFF4CAF50)),
                  title: Text(alt, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            }),
              ],
            ),
          ),
        );
      },
    );
  }
}
