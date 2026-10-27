import 'package:flutter/material.dart';
import '../models/history_log.dart';
import '../services/demo_data_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryLog> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    DemoDataService.instance.addListener(_handleDemoDataChanged);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final logs = DemoDataService.instance.history;
    if (!mounted) return;
    setState(() {
      _historyList = logs;
      _isLoading = false;
    });
  }

  void _handleDemoDataChanged() {
    if (!mounted) return;
    setState(() => _historyList = DemoDataService.instance.history);
  }

  @override
  void dispose() {
    DemoDataService.instance.removeListener(_handleDemoDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
        ),
      );
    }

    final chartData = _historyList.isEmpty ? <double>[] : _historyList.map((log) => log.moisture).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHistory,
          color: const Color(0xFF2E7D32),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFB7E4BF)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF2E7D32), size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        DemoDataService.demoModeLabel,
                        style: TextStyle(
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Soil Moisture Trend',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C2D21),
                            ),
                          ),
                          Text(
                            'Last 7 records',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7C6E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: CustomPaint(
                          painter: MoistureTrendPainter(chartData),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12, bottom: 12),
                              child: Row(
                                children: const [
                                  Icon(Icons.water_drop_rounded, size: 12, color: Color(0xFF2E7D32)),
                                  SizedBox(width: 4),
                                  Text(
                                    '% moisture',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7C6E)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildMetricCard(
                    label: 'Moisture',
                    value: '${_historyList.first.moisture.toInt()}%',
                    icon: Icons.water_drop_rounded,
                    accent: const Color(0xFF2E7D32),
                  ),
                  _buildMetricCard(
                    label: 'pH',
                    value: _historyList.first.ph.toStringAsFixed(1),
                    icon: Icons.science_rounded,
                    accent: const Color(0xFF4CAF50),
                  ),
                  _buildMetricCard(
                    label: 'Temperature',
                    value: '${_historyList.first.temperature.toStringAsFixed(1)}°C',
                    icon: Icons.thermostat_rounded,
                    accent: const Color(0xFF66BB6A),
                  ),
                  _buildMetricCard(
                    label: 'Soil Health',
                    value: '${_historyList.first.soilHealthScore}/100',
                    icon: Icons.eco_rounded,
                    accent: const Color(0xFF1B5E20),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Reading Log',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C2D21),
                    ),
                  ),
                  Text(
                    'Humidity',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7C6E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ..._historyList.map((log) => _buildHistoryItem(log)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EBE5)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7C6E),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C2D21),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(HistoryLog log) {
    final isPumpOn = log.pumpStatus.toUpperCase().contains('ON');
    final pumpColor = isPumpOn ? const Color(0xFF0288D1) : const Color(0xFF2E7D32);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EBE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _formatFullDate(log.timestamp),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1C2D21),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isPumpOn ? const Color(0xFFE3F2FD) : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  log.pumpStatus,
                  style: TextStyle(
                    color: pumpColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildStatChip('Moisture', '${log.moisture.toStringAsFixed(1)}%'),
              _buildStatChip('pH', log.ph.toStringAsFixed(1)),
              _buildStatChip('Temp', '${log.temperature.toStringAsFixed(1)}°C'),
              _buildStatChip('Hum', '${log.humidity.toStringAsFixed(0)}%'),
              _buildStatChip('Soil', '${log.soilHealthScore}/100'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7C6E)),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFF1C2D21),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(DateTime dt) {
    final date = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date • $time';
  }
}

class MoistureTrendPainter extends CustomPainter {
  final List<double> moistureValues;

  MoistureTrendPainter(this.moistureValues);

  @override
  void paint(Canvas canvas, Size size) {
    if (moistureValues.isEmpty) {
      return;
    }

    final padding = const EdgeInsets.only(left: 18, right: 10, top: 14, bottom: 18);
    final chartRect = Rect.fromLTWH(
      padding.left,
      padding.top,
      size.width - padding.left - padding.right,
      size.height - padding.top - padding.bottom,
    );

    final minValue = 20.0;
    final maxValue = 60.0;
    final gridPaint = Paint()
      ..color = const Color(0xFFE5EBE5)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = chartRect.top + (chartRect.height / 3) * i;
      canvas.drawLine(Offset(chartRect.left, y), Offset(chartRect.right, y), gridPaint);
    }

    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < moistureValues.length; i++) {
      final x = chartRect.left + (chartRect.width / (moistureValues.length > 1 ? moistureValues.length - 1 : 1)) * i;
      final ratio = (moistureValues[i] - minValue) / (maxValue - minValue);
      final y = chartRect.bottom - ratio * chartRect.height;
      final point = Offset(x, y);

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
        fillPath.moveTo(point.dx, chartRect.bottom);
        fillPath.lineTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
        fillPath.lineTo(point.dx, point.dy);
      }
    }

    fillPath.lineTo(
      chartRect.right,
      chartRect.bottom,
    );
    fillPath.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB7E4BF), Color(0xFFEBF7ED)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(chartRect);

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    for (int i = 0; i < moistureValues.length; i++) {
      final x = chartRect.left + (chartRect.width / (moistureValues.length > 1 ? moistureValues.length - 1 : 1)) * i;
      final ratio = (moistureValues[i] - minValue) / (maxValue - minValue);
      final y = chartRect.bottom - ratio * chartRect.height;
      final circlePaint = Paint()..color = const Color(0xFF1B5E20);
      canvas.drawCircle(Offset(x, y), 4, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
