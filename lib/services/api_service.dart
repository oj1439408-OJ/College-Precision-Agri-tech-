import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/sensor_data.dart';
import '../models/soil_health.dart';
import '../models/crop_recommendation.dart';
import '../models/fertilizer_recommendation.dart';
import '../models/irrigation_status.dart';
import '../models/history_log.dart';
import 'mock_data_service.dart';

class ApiService {
  // Configurable Flask Server Base URL
  static String baseUrl = 'http://192.168.1.100:5000/api';
  static bool isOfflineDemoMode = true;

  static final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 3);

  // GET /api/sensors
  static Future<SensorData> fetchSensorData() async {
    if (isOfflineDemoMode) {
      return MockDataService.getMockSensorData();
    }
    try {
      final request = await _client.getUrl(Uri.parse('$baseUrl/sensors'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final jsonMap = jsonDecode(stringData);
        return SensorData.fromJson(jsonMap);
      }
    } catch (_) {
      // Fallback to mock data if network request fails
    }
    return MockDataService.getMockSensorData();
  }

  // GET /api/soil-health
  static Future<SoilHealthScore> fetchSoilHealth() async {
    if (isOfflineDemoMode) {
      return MockDataService.getMockSoilHealth();
    }
    try {
      final request = await _client.getUrl(Uri.parse('$baseUrl/soil-health'));
      final response = await request.close();
      if (response.statusCode == 200) {
        // Parse from network if API connected
      }
    } catch (_) {}
    return MockDataService.getMockSoilHealth();
  }

  // GET /api/crop-recommendation
  static Future<CropRecommendation> fetchCropRecommendation() async {
    if (isOfflineDemoMode) {
      return MockDataService.getMockCropRecommendation();
    }
    try {
      final request = await _client.getUrl(Uri.parse('$baseUrl/crop-recommendation'));
      final response = await request.close();
      if (response.statusCode == 200) {
        // Parse from network
      }
    } catch (_) {}
    return MockDataService.getMockCropRecommendation();
  }

  // GET /api/fertilizer-recommendation
  static Future<List<FertilizerRecommendation>> fetchFertilizers() async {
    if (isOfflineDemoMode) {
      return MockDataService.getMockFertilizers();
    }
    try {
      final request = await _client.getUrl(Uri.parse('$baseUrl/fertilizer-recommendation'));
      final response = await request.close();
      if (response.statusCode == 200) {
        // Parse from network
      }
    } catch (_) {}
    return MockDataService.getMockFertilizers();
  }

  // GET /api/pump/status
  static Future<IrrigationStatus> fetchPumpStatus() async {
    if (isOfflineDemoMode) {
      return MockDataService.getMockIrrigationStatus();
    }
    try {
      final request = await _client.getUrl(Uri.parse('$baseUrl/pump/status'));
      final response = await request.close();
      if (response.statusCode == 200) {
        // Parse from network
      }
    } catch (_) {}
    return MockDataService.getMockIrrigationStatus();
  }

  // POST /api/pump/control
  static Future<bool> togglePump(bool turnOn) async {
    if (isOfflineDemoMode) {
      return true; // Simulated success
    }
    try {
      final request = await _client.postUrl(Uri.parse('$baseUrl/pump/control'));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(jsonEncode({'action': turnOn ? 'ON' : 'OFF'})));
      final response = await request.close();
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // GET /api/history
  static Future<List<HistoryLog>> fetchHistory() async {
    if (isOfflineDemoMode) {
      return MockDataService.getMockHistory();
    }
    try {
      final request = await _client.getUrl(Uri.parse('$baseUrl/history'));
      final response = await request.close();
      if (response.statusCode == 200) {
        // Parse from network
      }
    } catch (_) {}
    return MockDataService.getMockHistory();
  }

  // POST /api/assistant
  static Future<String> askAssistant(String question) async {
    if (isOfflineDemoMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      return MockDataService.getAssistantResponse(question);
    }
    try {
      final request = await _client.postUrl(Uri.parse('$baseUrl/assistant'));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(jsonEncode({'prompt': question})));
      final response = await request.close();
      if (response.statusCode == 200) {
        final stringData = await response.transform(utf8.decoder).join();
        final jsonMap = jsonDecode(stringData);
        return jsonMap['response'] ?? MockDataService.getAssistantResponse(question);
      }
    } catch (_) {}
    return MockDataService.getAssistantResponse(question);
  }
}
