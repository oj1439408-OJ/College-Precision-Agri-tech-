import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:smart_agri_app/main.dart';
import 'package:smart_agri_app/screens/fertilizer_screen.dart';
import 'package:smart_agri_app/services/demo_data_service.dart';
import 'package:smart_agri_app/services/recommendation_service.dart';

void main() {
  testWidgets('App loads home screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PrecisionAgriApp());
    await tester.pumpAndSettle();
    expect(find.text('Precision Agri-Tech'), findsOneWidget);
  });

  test('demo data shares sensor readings and applies irrigation thresholds', () {
    final demoData = DemoDataService.instance;
    demoData.setThresholds(start: 30, stop: 45);
    demoData.setAutoMode(true);

    demoData.updateSensorData(moisture: 29);
    expect(demoData.sensorData.moisture, 29);
    expect(demoData.isPumpOn, isTrue);

    demoData.updateSensorData(moisture: 42);
    expect(demoData.isPumpOn, isTrue);

    demoData.updateSensorData(moisture: 45);
    expect(demoData.isPumpOn, isFalse);
    expect(demoData.history.first.moisture, 45);
    expect(demoData.history.first.pumpStatus, 'OFF');
  });

  test('crop and fertilizer recommendations respond to demo soil changes', () {
    final demoData = DemoDataService.instance;
    demoData.updateSensorData(
      moisture: 42,
      ph: 6.5,
      temperature: 28,
      nitrogen: 45,
      phosphorus: 32,
      potassium: 40,
    );
    final baselineCrop = RecommendationService.recommendCrop(demoData.sensorData);

    demoData.updateSensorData(
      moisture: 8,
      ph: 9.2,
      temperature: 41,
      nitrogen: 12,
      phosphorus: 70,
      potassium: 100,
    );

    final changedCrop = RecommendationService.recommendCrop(demoData.sensorData);
    final fertilizerResults = RecommendationService.analyzeNutrients(demoData.sensorData);

    expect(changedCrop.suitabilityPercentage, lessThan(baselineCrop.suitabilityPercentage));
    expect(fertilizerResults[0].status, 'Low');
    expect(fertilizerResults[1].status, 'High');
    expect(fertilizerResults[2].status, 'High');
    expect(fertilizerResults[0].recommendationText, isNot(contains('dose')));

    demoData.updateSensorData(
      moisture: 42,
      ph: 6.5,
      temperature: 28,
      nitrogen: 45,
      phosphorus: 32,
      potassium: 40,
    );
  });

  testWidgets('open crop recommendations refresh when demo data changes', (
    WidgetTester tester,
  ) async {
    final demoData = DemoDataService.instance;
    demoData.updateSensorData(
      moisture: 42,
      ph: 6.5,
      temperature: 28,
      nitrogen: 45,
      phosphorus: 32,
      potassium: 40,
    );
    await tester.pumpWidget(const PrecisionAgriApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('View'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Rule-based suggestions'), findsOneWidget);

    demoData.updateSensorData(
      moisture: 8,
      ph: 9.2,
      temperature: 41,
      nitrogen: 12,
      phosphorus: 70,
      potassium: 100,
    );
    await tester.pumpAndSettle();

    final changedRecommendation = RecommendationService.recommendCrop(demoData.sensorData);
    expect(
      find.text('${changedRecommendation.suitabilityPercentage}% Suitability Match'),
      findsOneWidget,
    );

    demoData.updateSensorData(
      moisture: 42,
      ph: 6.5,
      temperature: 28,
      nitrogen: 45,
      phosphorus: 32,
      potassium: 40,
    );
  });

  testWidgets('open fertilizer recommendations refresh with NPK changes', (
    WidgetTester tester,
  ) async {
    final demoData = DemoDataService.instance;
    demoData.updateSensorData(nitrogen: 45, phosphorus: 32, potassium: 40);
    await tester.pumpWidget(const MaterialApp(home: FertilizerScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Normal'), findsNWidgets(3));

    demoData.updateSensorData(nitrogen: 12, phosphorus: 70, potassium: 100);
    await tester.pumpAndSettle();

    expect(find.text('Low'), findsOneWidget);
    expect(find.text('High'), findsNWidgets(2));
    expect(find.textContaining('no dosage is provided'), findsOneWidget);

    demoData.updateSensorData(nitrogen: 45, phosphorus: 32, potassium: 40);
  });

  testWidgets('main navigation opens soil, irrigation, and history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PrecisionAgriApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Soil').last);
    await tester.pumpAndSettle();
    expect(find.text('Soil Monitoring'), findsOneWidget);

    await tester.tap(find.text('Irrigation').last);
    await tester.pumpAndSettle();
    expect(find.text('Smart Irrigation Control'), findsOneWidget);

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();
    expect(find.text('Soil Moisture Trend'), findsOneWidget);
  });
}
