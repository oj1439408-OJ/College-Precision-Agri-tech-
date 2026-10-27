class FertilizerRecommendation {
  final String nutrientName; // Nitrogen, Phosphorus, Potassium
  final String status; // Low, Optimal, Excess
  final String currentVal;
  final String targetVal;
  final String recommendationText;
  final String organicOption;

  FertilizerRecommendation({
    required this.nutrientName,
    required this.status,
    required this.currentVal,
    required this.targetVal,
    required this.recommendationText,
    required this.organicOption,
  });
}
