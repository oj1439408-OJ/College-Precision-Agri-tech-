import '../models/crop_recommendation.dart';
import '../models/fertilizer_recommendation.dart';
import '../models/sensor_data.dart';

class RecommendationService {
  static const List<_CropProfile> _cropProfiles = [
    _CropProfile(
      name: 'Wheat',
      season: 'Rabi (Winter)',
      soilType: 'Loamy soil',
      ph: (6.0, 7.5),
      moisture: (30.0, 50.0),
      temperature: (15.0, 28.0),
      nitrogen: (30.0, 60.0),
      phosphorus: (20.0, 50.0),
      potassium: (30.0, 80.0),
    ),
    _CropProfile(
      name: 'Soybean',
      season: 'Kharif (Monsoon)',
      soilType: 'Well-drained loamy soil',
      ph: (6.0, 7.5),
      moisture: (40.0, 60.0),
      temperature: (20.0, 30.0),
      nitrogen: (20.0, 50.0),
      phosphorus: (20.0, 50.0),
      potassium: (30.0, 80.0),
    ),
    _CropProfile(
      name: 'Maize',
      season: 'Kharif or Rabi',
      soilType: 'Fertile, well-drained soil',
      ph: (5.8, 7.0),
      moisture: (40.0, 60.0),
      temperature: (18.0, 32.0),
      nitrogen: (30.0, 60.0),
      phosphorus: (20.0, 50.0),
      potassium: (30.0, 80.0),
    ),
    _CropProfile(
      name: 'Chickpea',
      season: 'Rabi (Winter)',
      soilType: 'Well-drained loamy or black soil',
      ph: (6.0, 8.0),
      moisture: (25.0, 45.0),
      temperature: (15.0, 30.0),
      nitrogen: (20.0, 50.0),
      phosphorus: (20.0, 50.0),
      potassium: (30.0, 80.0),
    ),
  ];

  static CropRecommendation recommendCrop(SensorData data) {
    final ranked = _cropProfiles.map((profile) {
      final scores = [
        _rangeScore(data.ph, profile.ph),
        _rangeScore(data.moisture, profile.moisture),
        _rangeScore(data.temperature, profile.temperature),
        _rangeScore(data.nitrogen, profile.nitrogen),
        _rangeScore(data.phosphorus, profile.phosphorus),
        _rangeScore(data.potassium, profile.potassium),
      ];
      final score = (scores.reduce((sum, value) => sum + value) / scores.length).round();
      return (profile: profile, score: score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final best = ranked.first;
    final profile = best.profile;
    final factors = [
      _explain('pH', data.ph, profile.ph),
      _explain('Moisture', data.moisture, profile.moisture, suffix: '%'),
      _explain('Temperature', data.temperature, profile.temperature, suffix: '°C'),
      _explain('Nitrogen', data.nitrogen, profile.nitrogen, suffix: ' mg/kg'),
      _explain('Phosphorus', data.phosphorus, profile.phosphorus, suffix: ' mg/kg'),
      _explain('Potassium', data.potassium, profile.potassium, suffix: ' mg/kg'),
    ];

    return CropRecommendation(
      cropName: profile.name,
      suitabilityPercentage: best.score,
      season: profile.season,
      soilType: profile.soilType,
      reason: '${factors.join('. ')}.',
      requiredConditions: {
        'Soil pH': '${profile.ph.$1} - ${profile.ph.$2}',
        'Moisture': '${profile.moisture.$1.toInt()}% - ${profile.moisture.$2.toInt()}%',
        'Temperature': '${profile.temperature.$1.toInt()}°C - ${profile.temperature.$2.toInt()}°C',
        'NPK reference': 'Compared against current demo readings',
      },
      alternativeCrops: ranked
          .skip(1)
          .take(3)
          .map((entry) => '${entry.profile.name} (${entry.score}% match)')
          .toList(),
    );
  }

  static List<FertilizerRecommendation> analyzeNutrients(SensorData data) => [
        _nutrientRecommendation(
          name: 'Nitrogen (N)',
          value: data.nitrogen,
          range: (30, 60),
        ),
        _nutrientRecommendation(
          name: 'Phosphorus (P)',
          value: data.phosphorus,
          range: (20, 50),
        ),
        _nutrientRecommendation(
          name: 'Potassium (K)',
          value: data.potassium,
          range: (30, 80),
        ),
      ];

  static int _rangeScore(double value, (double, double) range) {
    if (value >= range.$1 && value <= range.$2) return 100;
    final distance = value < range.$1 ? range.$1 - value : value - range.$2;
    final tolerance = (range.$2 - range.$1) * 0.75;
    return (100 * (1 - distance / tolerance).clamp(0.0, 1.0)).round();
  }

  static String _explain(
    String label,
    double value,
    (double, double) range, {
    String suffix = '',
  }) {
    final current = '${value.toStringAsFixed(1)}$suffix';
    final target = '${range.$1.toStringAsFixed(1)} - ${range.$2.toStringAsFixed(1)}$suffix';
    return value >= range.$1 && value <= range.$2
        ? '$label ($current) is within the crop reference range ($target)'
        : '$label ($current) is outside the crop reference range ($target)';
  }

  static FertilizerRecommendation _nutrientRecommendation({
    required String name,
    required double value,
    required (int, int) range,
  }) {
    final String status;
    final String guidance;
    if (value < range.$1) {
      status = 'Low';
      guidance = 'This demo reading is below its reference band. Confirm with a soil test and consider improving soil organic matter or crop rotation.';
    } else if (value > range.$2) {
      status = 'High';
      guidance = 'This demo reading is above its reference band. Avoid adding more of this nutrient until a soil test confirms it is needed.';
    } else {
      status = 'Normal';
      guidance = 'This demo reading is within its reference band. Maintain balanced soil practices and monitor over time.';
    }

    return FertilizerRecommendation(
      nutrientName: name,
      status: status,
      currentVal: '${value.toStringAsFixed(1)} mg/kg',
      targetVal: '${range.$1} - ${range.$2} mg/kg reference band',
      recommendationText: guidance,
      organicOption: 'Use locally appropriate compost and confirm any amendment need with soil testing.',
    );
  }
}

class _CropProfile {
  final String name;
  final String season;
  final String soilType;
  final (double, double) ph;
  final (double, double) moisture;
  final (double, double) temperature;
  final (double, double) nitrogen;
  final (double, double) phosphorus;
  final (double, double) potassium;

  const _CropProfile({
    required this.name,
    required this.season,
    required this.soilType,
    required this.ph,
    required this.moisture,
    required this.temperature,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
  });
}