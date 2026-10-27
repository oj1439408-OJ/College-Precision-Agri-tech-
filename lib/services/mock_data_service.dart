import '../models/sensor_data.dart';
import '../models/soil_health.dart';
import '../models/crop_recommendation.dart';
import '../models/fertilizer_recommendation.dart';
import '../models/irrigation_status.dart';
import '../models/history_log.dart';
import '../models/chat_message.dart';
import 'demo_data_service.dart';
import 'recommendation_service.dart';

class MockDataService {
  static SensorData getMockSensorData() {
    return DemoDataService.instance.sensorData;
  }

  static SoilHealthScore getMockSoilHealth() {
    return DemoDataService.instance.soilHealth;
  }

  static CropRecommendation getMockCropRecommendation() {
    return RecommendationService.recommendCrop(DemoDataService.instance.sensorData);
  }

  static List<FertilizerRecommendation> getMockFertilizers() {
    return RecommendationService.analyzeNutrients(DemoDataService.instance.sensorData);
  }

  static IrrigationStatus getMockIrrigationStatus() {
    return DemoDataService.instance.irrigationStatus;
  }

  static List<HistoryLog> getMockHistory() {
    return DemoDataService.instance.history;
  }

  static List<ChatMessage> getInitialChatMessages() {
    return [
      ChatMessage(
        id: 'init-1',
        text: 'Hello Farmer! 🌾 I am your AI Agri Assistant. Ask me anything about your soil condition, crop selection, fertilizer recommendations, or irrigation schedule.',
        sender: SenderType.assistant,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  static String getAssistantResponse(String userQuery) {
    final query = userQuery.toLowerCase();
    if (query.contains('crop') || query.contains('plant') || query.contains('grow')) {
      return 'Based on your current soil pH (6.5) and moisture (42%), **Wheat** and **Soybean** are highly recommended. Wheat matches 94% of your soil parameters!';
    } else if (query.contains('water') || query.contains('irrigation') || query.contains('pump') || query.contains('moisture')) {
      return 'Your current soil moisture level is **42.0%**, which is well above your minimum threshold of 30%. Irrigation is currently not needed.';
    } else if (query.contains('fertilizer') || query.contains('npk') || query.contains('nitrogen') || query.contains('phosphorus')) {
      return 'Your NPK levels are **45-32-40 mg/kg**, all in the optimal range! No chemical fertilizers are needed right now.';
    } else if (query.contains('ph') || query.contains('acid') || query.contains('soil health')) {
      return 'Your soil pH is **6.5 (Good)** and overall health score is **82/100 (Good)**.';
    } else {
      return 'Thank you for your question! For optimal crop yield, keep soil moisture between 30% and 60% and maintain your balanced NPK levels.';
    }
  }
}
