class SensorData {
  final double moisture; // Percentage %
  final double ph; // pH scale 0-14
  final double temperature; // °C
  final double humidity; // %
  final double nitrogen; // mg/kg
  final double phosphorus; // mg/kg
  final double potassium; // mg/kg
  final DateTime timestamp;

  SensorData({
    required this.moisture,
    required this.ph,
    required this.temperature,
    required this.humidity,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      moisture: (json['moisture'] as num?)?.toDouble() ?? 42.0,
      ph: (json['ph'] as num?)?.toDouble() ?? 6.5,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 28.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 65.0,
      nitrogen: (json['nitrogen'] as num?)?.toDouble() ?? 45.0,
      phosphorus: (json['phosphorus'] as num?)?.toDouble() ?? 32.0,
      potassium: (json['potassium'] as num?)?.toDouble() ?? 40.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moisture': moisture,
      'ph': ph,
      'temperature': temperature,
      'humidity': humidity,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Status Helpers (Low / Normal / High)
  String get moistureStatus {
    if (moisture < 30) return 'Low';
    if (moisture <= 60) return 'Normal';
    return 'High';
  }

  String get phStatus {
    if (ph < 6.0) return 'Low';
    if (ph <= 7.5) return 'Normal';
    return 'High';
  }

  String get tempStatus {
    if (temperature < 18) return 'Low';
    if (temperature <= 32) return 'Normal';
    return 'High';
  }

  String get humidityStatus {
    if (humidity < 40) return 'Low';
    if (humidity <= 75) return 'Normal';
    return 'High';
  }

  String get nitrogenStatus {
    if (nitrogen < 30) return 'Low';
    if (nitrogen <= 60) return 'Normal';
    return 'High';
  }

  String get phosphorusStatus {
    if (phosphorus < 20) return 'Low';
    if (phosphorus <= 50) return 'Normal';
    return 'High';
  }

  String get potassiumStatus {
    if (potassium < 30) return 'Low';
    if (potassium <= 80) return 'Normal';
    return 'High';
  }
}
