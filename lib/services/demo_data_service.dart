import 'package:flutter/material.dart';

import '../models/history_log.dart';
import '../models/irrigation_status.dart';
import '../models/sensor_data.dart';
import '../models/soil_health.dart';

class DemoDataService extends ChangeNotifier {
  DemoDataService._() {
    final now = DateTime.now();
    _sensorData = SensorData(
      moisture: 42.0,
      ph: 6.5,
      temperature: 28.0,
      humidity: 65.0,
      nitrogen: 45.0,
      phosphorus: 32.0,
      potassium: 40.0,
      timestamp: now,
    );
    _history = [
      _reading('1', now.subtract(const Duration(minutes: 5)), 42, 6.5, 28, 65, 82, 'OFF'),
      _reading('2', now.subtract(const Duration(hours: 2)), 43.5, 6.5, 27.8, 66, 84, 'OFF'),
      _reading('3', now.subtract(const Duration(hours: 6)), 45, 6.6, 26.5, 70, 86, 'OFF'),
      _reading('4', now.subtract(const Duration(hours: 12)), 48, 6.6, 25, 72, 88, 'ON (Irrigated)'),
      _reading('5', now.subtract(const Duration(days: 1)), 29, 6.4, 29, 60, 72, 'OFF'),
    ];
  }

  static final DemoDataService instance = DemoDataService._();
  static const String demoModeLabel = 'Demo Mode — Simulated Data';
  static const double defaultStartThreshold = 30.0;
  static const double defaultStopThreshold = 45.0;

  late SensorData _sensorData;
  late List<HistoryLog> _history;
  bool _isPumpOn = false;
  bool _isAutoMode = true;
  double _startThreshold = defaultStartThreshold;
  double _stopThreshold = defaultStopThreshold;

  SensorData get sensorData => _sensorData;
  bool get isPumpOn => _isPumpOn;
  bool get isAutoMode => _isAutoMode;
  double get startThreshold => _startThreshold;
  double get stopThreshold => _stopThreshold;
  List<HistoryLog> get history => List.unmodifiable(_history);

  int get soilHealthScore {
    final change =
        (_sensorData.moisture - 42).abs() * 0.3 +
        (_sensorData.ph - 6.5).abs() * 4 +
        (_sensorData.temperature - 28).abs() * 0.25 +
        (_sensorData.humidity - 65).abs() * 0.1 +
        (_sensorData.nitrogen - 45).abs() * 0.08 +
        (_sensorData.phosphorus - 32).abs() * 0.08 +
        (_sensorData.potassium - 40).abs() * 0.08;
    return (82 - change.round()).clamp(0, 100).toInt();
  }

  SoilHealthScore get soilHealth {
    final score = soilHealthScore;
    final rating = score >= 80 ? 'Good' : score >= 60 ? 'Fair' : 'Needs Attention';
    return SoilHealthScore(
      score: score,
      overallRating: rating,
      summary:
          'Soil moisture is ${_sensorData.moisture.toStringAsFixed(1)}%, pH is ${_sensorData.ph.toStringAsFixed(1)}, and nutrient readings are based on the current demo sensor values.',
      disclaimer: 'Demo analysis using simulated sensor data. No hardware or backend is connected.',
      items: [
        _healthItem(
          title: 'Soil Moisture',
          value: '${_sensorData.moisture.toStringAsFixed(1)}%',
          status: _sensorData.moistureStatus,
          progress: _sensorData.moisture / 100,
          icon: Icons.water_drop_outlined,
          explanation: 'Current moisture reading from the shared demo sensor.',
        ),
        _healthItem(
          title: 'Soil pH',
          value: _sensorData.ph.toStringAsFixed(1),
          status: _sensorData.phStatus,
          progress: _sensorData.ph / 14,
          icon: Icons.science_outlined,
          explanation: 'A pH near 6.5 is favorable for many common crops.',
        ),
        _healthItem(
          title: 'Nitrogen (N)',
          value: '${_sensorData.nitrogen.toStringAsFixed(0)} mg/kg',
          status: _sensorData.nitrogenStatus,
          progress: _sensorData.nitrogen / 100,
          icon: Icons.eco_outlined,
          explanation: 'Nitrogen supports leafy and vegetative plant growth.',
        ),
        _healthItem(
          title: 'Phosphorus (P)',
          value: '${_sensorData.phosphorus.toStringAsFixed(0)} mg/kg',
          status: _sensorData.phosphorusStatus,
          progress: _sensorData.phosphorus / 100,
          icon: Icons.bubble_chart_outlined,
          explanation: 'Phosphorus contributes to root and flower development.',
        ),
        _healthItem(
          title: 'Potassium (K)',
          value: '${_sensorData.potassium.toStringAsFixed(0)} mg/kg',
          status: _sensorData.potassiumStatus,
          progress: _sensorData.potassium / 100,
          icon: Icons.grain_outlined,
          explanation: 'Potassium helps support plant water balance and resilience.',
        ),
        _healthItem(
          title: 'Temperature',
          value: '${_sensorData.temperature.toStringAsFixed(1)}°C',
          status: _sensorData.tempStatus,
          progress: _sensorData.temperature / 50,
          icon: Icons.thermostat_outlined,
          explanation: 'Current soil temperature from the shared demo sensor.',
        ),
        _healthItem(
          title: 'Humidity',
          value: '${_sensorData.humidity.toStringAsFixed(0)}%',
          status: _sensorData.humidityStatus,
          progress: _sensorData.humidity / 100,
          icon: Icons.cloud_outlined,
          explanation: 'Current air humidity from the shared demo sensor.',
        ),
      ],
    );
  }

  IrrigationStatus get irrigationStatus {
    final String message;
    if (_sensorData.moisture < _startThreshold) {
      message = 'Moisture is below ${_startThreshold.toStringAsFixed(0)}%; irrigation should start.';
    } else if (_sensorData.moisture >= _stopThreshold) {
      message = 'Moisture reached ${_stopThreshold.toStringAsFixed(0)}%; irrigation should stop.';
    } else {
      message = 'Moisture is between thresholds; continue monitoring.';
    }
    return IrrigationStatus(
      isPumpOn: _isPumpOn,
      isAutoMode: _isAutoMode,
      startThreshold: _startThreshold,
      stopThreshold: _stopThreshold,
      statusMessage: message,
      lastUpdated: _sensorData.timestamp,
    );
  }

  void updateSensorData({
    double? moisture,
    double? ph,
    double? temperature,
    double? humidity,
    double? nitrogen,
    double? phosphorus,
    double? potassium,
  }) {
    _sensorData = SensorData(
      moisture: moisture ?? _sensorData.moisture,
      ph: ph ?? _sensorData.ph,
      temperature: temperature ?? _sensorData.temperature,
      humidity: humidity ?? _sensorData.humidity,
      nitrogen: nitrogen ?? _sensorData.nitrogen,
      phosphorus: phosphorus ?? _sensorData.phosphorus,
      potassium: potassium ?? _sensorData.potassium,
      timestamp: DateTime.now(),
    );
    _applyAutomaticDecision();
    _addCurrentReading();
    notifyListeners();
  }

  void setPump(bool isOn) {
    if (_isPumpOn == isOn) return;
    _isPumpOn = isOn;
    _addCurrentReading();
    notifyListeners();
  }

  void setAutoMode(bool isAuto) {
    if (_isAutoMode == isAuto) return;
    _isAutoMode = isAuto;
    if (_isAutoMode) _applyAutomaticDecision();
    _addCurrentReading();
    notifyListeners();
  }

  void setThresholds({double? start, double? stop}) {
    _startThreshold = start ?? _startThreshold;
    _stopThreshold = stop ?? _stopThreshold;
    _applyAutomaticDecision();
    notifyListeners();
  }

  void _applyAutomaticDecision() {
    if (!_isAutoMode) return;
    if (_sensorData.moisture < _startThreshold) {
      _isPumpOn = true;
    } else if (_sensorData.moisture >= _stopThreshold) {
      _isPumpOn = false;
    }
  }

  void _addCurrentReading() {
    _history.insert(
      0,
      _reading(
        DateTime.now().microsecondsSinceEpoch.toString(),
        DateTime.now(),
        _sensorData.moisture,
        _sensorData.ph,
        _sensorData.temperature,
        _sensorData.humidity,
        soilHealthScore,
        _isPumpOn ? 'ON' : 'OFF',
      ),
    );
    if (_history.length > 50) _history.removeLast();
  }

  static HistoryLog _reading(
    String id,
    DateTime timestamp,
    double moisture,
    double ph,
    double temperature,
    double humidity,
    int score,
    String pumpStatus,
  ) {
    return HistoryLog(
      id: id,
      timestamp: timestamp,
      moisture: moisture,
      ph: ph,
      temperature: temperature,
      humidity: humidity,
      soilHealthScore: score,
      pumpStatus: pumpStatus,
    );
  }

  static SoilHealthItem _healthItem({
    required String title,
    required String value,
    required String status,
    required double progress,
    required IconData icon,
    required String explanation,
  }) {
    return SoilHealthItem(
      title: title,
      currentValue: value,
      status: status,
      explanation: explanation,
      statusColorHex: status == 'Low' ? '#F57C00' : '#2E7D32',
      progressValue: progress.clamp(0.0, 1.0).toDouble(),
      icon: icon,
    );
  }
}