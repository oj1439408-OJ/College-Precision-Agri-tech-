class HistoryLog {
  final String id;
  final DateTime timestamp;
  final double moisture;
  final double ph;
  final double temperature;
  final double humidity;
  final int soilHealthScore;
  final String pumpStatus;

  HistoryLog({
    required this.id,
    required this.timestamp,
    required this.moisture,
    required this.ph,
    required this.temperature,
    required this.humidity,
    this.soilHealthScore = 0,
    required this.pumpStatus,
  });
}
