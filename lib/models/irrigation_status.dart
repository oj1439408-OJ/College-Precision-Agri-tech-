class IrrigationStatus {
  final bool isPumpOn;
  final bool isAutoMode;
  final double startThreshold; // e.g. 30.0%
  final double stopThreshold; // e.g. 45.0%
  final String statusMessage;
  final DateTime lastUpdated;

  IrrigationStatus({
    required this.isPumpOn,
    required this.isAutoMode,
    required this.startThreshold,
    required this.stopThreshold,
    required this.statusMessage,
    required this.lastUpdated,
  });

  IrrigationStatus copyWith({
    bool? isPumpOn,
    bool? isAutoMode,
    double? startThreshold,
    double? stopThreshold,
    String? statusMessage,
    DateTime? lastUpdated,
  }) {
    return IrrigationStatus(
      isPumpOn: isPumpOn ?? this.isPumpOn,
      isAutoMode: isAutoMode ?? this.isAutoMode,
      startThreshold: startThreshold ?? this.startThreshold,
      stopThreshold: stopThreshold ?? this.stopThreshold,
      statusMessage: statusMessage ?? this.statusMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
