class CropRecommendation {
  final String cropName;
  final int suitabilityPercentage;
  final String season;
  final String soilType;
  final String reason;
  final Map<String, String> requiredConditions;
  final List<String> alternativeCrops;

  CropRecommendation({
    required this.cropName,
    required this.suitabilityPercentage,
    required this.season,
    required this.soilType,
    required this.reason,
    required this.requiredConditions,
    required this.alternativeCrops,
  });
}
