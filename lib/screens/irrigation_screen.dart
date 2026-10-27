import 'package:flutter/material.dart';
import '../services/demo_data_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// IrrigationScreen — Step 4
//
// Uses shared in-memory demo state only; no backend or hardware is connected.
// ─────────────────────────────────────────────────────────────────────────────

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen>
    with SingleTickerProviderStateMixin {
  double get _currentMoisture => DemoDataService.instance.sensorData.moisture;
  bool get _isPumpOn => DemoDataService.instance.isPumpOn;
  bool get _isAutoMode => DemoDataService.instance.isAutoMode;
  double get _startThreshold => DemoDataService.instance.startThreshold;
  double get _stopThreshold => DemoDataService.instance.stopThreshold;

  // ── Animation controller for moisture bar ────────────────────────────
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _currentMoisture / 100.0,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut));
    DemoDataService.instance.addListener(_handleDemoDataChanged);
    _progressController.forward();
  }

  void _handleDemoDataChanged() {
    if (!mounted) return;
    setState(() {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: _currentMoisture / 100.0,
      ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut));
    });
    _progressController.forward(from: 0);
  }

  @override
  void dispose() {
    DemoDataService.instance.removeListener(_handleDemoDataChanged);
    _progressController.dispose();
    super.dispose();
  }

  // ── Decision helpers ─────────────────────────────────────────────────
  _IrrigationDecision get _decision {
    if (_currentMoisture < _startThreshold) {
      return _IrrigationDecision.irrigate;
    } else if (_currentMoisture >= _stopThreshold) {
      return _IrrigationDecision.stop;
    } else {
      return _IrrigationDecision.monitor;
    }
  }

  String get _decisionTitle {
    switch (_decision) {
      case _IrrigationDecision.irrigate:
        return 'Irrigate Now';
      case _IrrigationDecision.stop:
        return 'Irrigation OFF';
      case _IrrigationDecision.monitor:
        return 'Monitor Soil';
    }
  }

  String get _decisionBody {
    switch (_decision) {
      case _IrrigationDecision.irrigate:
        return 'Soil moisture is critically low '
            '(${_currentMoisture.toInt()}% < ${_startThreshold.toInt()}%). '
            'Start irrigation immediately to prevent crop stress.';
      case _IrrigationDecision.stop:
        return 'Soil moisture is sufficient '
            '(${_currentMoisture.toInt()}% ≥ ${_stopThreshold.toInt()}%). '
            'Irrigation is not required — stop the pump to conserve water.';
      case _IrrigationDecision.monitor:
        return 'Soil moisture (${_currentMoisture.toInt()}%) is between the '
            'start threshold (${_startThreshold.toInt()}%) and stop threshold '
            '(${_stopThreshold.toInt()}%). Continue monitoring — no action needed.';
    }
  }

  Color get _decisionColor {
    switch (_decision) {
      case _IrrigationDecision.irrigate:
        return const Color(0xFFE65100);
      case _IrrigationDecision.stop:
        return const Color(0xFF1565C0);
      case _IrrigationDecision.monitor:
        return const Color(0xFF2E7D32);
    }
  }

  IconData get _decisionIcon {
    switch (_decision) {
      case _IrrigationDecision.irrigate:
        return Icons.warning_amber_rounded;
      case _IrrigationDecision.stop:
        return Icons.check_circle_outline;
      case _IrrigationDecision.monitor:
        return Icons.radar;
    }
  }

  void _togglePump(bool on) {
    DemoDataService.instance.setPump(on);
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              on ? Icons.water_drop : Icons.power_settings_new,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                on
                    ? 'Pump activated — simulated relay signal sent'
                    : 'Pump deactivated — simulated relay off',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: on ? const Color(0xFF2E7D32) : Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Irrigation Control'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Irrigation Dashboard',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C2D21),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Monitor and control your water pump',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7C6E),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDemoModeBadge(),
              ],
            ),
            const SizedBox(height: 16),

            // ── 1. Soil Moisture Card ──────────────────────────────────
            _buildMoistureCard(),
            const SizedBox(height: 12),

            // ── 2. Pump Status Card ────────────────────────────────────
            _buildPumpStatusCard(),
            const SizedBox(height: 12),

            // ── 3. Mode Control Card ───────────────────────────────────
            _buildModeControlCard(),
            const SizedBox(height: 12),

            // ── 4. Irrigation Decision Card ────────────────────────────
            _buildDecisionCard(),
            const SizedBox(height: 12),

            // ── 5. Threshold Sliders ───────────────────────────────────
            _buildThresholdCard(),
            const SizedBox(height: 12),

            // ── 6. Architecture note ───────────────────────────────────
            _buildArchitectureNote(),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Builder helpers
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildDemoModeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade400, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const SizedBox(
            width: 126,
            child: Text(
              DemoDataService.demoModeLabel,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7F4E00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoistureCard() {
    final Color color = _decisionColor;
    final double start = _startThreshold;
    final double stop = _stopThreshold;
    final double moisture = _currentMoisture;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.water_drop_outlined,
                      color: Color(0xFF1976D2), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Current Soil Moisture',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C2D21),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (_, child) => Text(
                    '${(_progressAnimation.value * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (_, child) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildZoneLabel(
                  label: 'Dry Zone\n< ${start.toInt()}%',
                  color: const Color(0xFFE65100),
                  isActive: moisture < start,
                  alignRight: false,
                ),
                _buildZoneLabel(
                  label: 'Monitor\n${start.toInt()}–${stop.toInt()}%',
                  color: const Color(0xFF2E7D32),
                  isActive: moisture >= start && moisture < stop,
                  alignRight: false,
                ),
                _buildZoneLabel(
                  label: 'Adequate\n≥ ${stop.toInt()}%',
                  color: const Color(0xFF1565C0),
                  isActive: moisture >= stop,
                  alignRight: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneLabel({
    required String label,
    required Color color,
    required bool isActive,
    required bool alignRight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: isActive
          ? BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            )
          : null,
      child: Text(
        label,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? color : Colors.grey.shade500,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildPumpStatusCard() {
    final bool locked = _isAutoMode;
    return Card(
      color: _isPumpOn ? const Color(0xFFE8F5E9) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _isPumpOn ? const Color(0xFF81C784) : const Color(0xFFE5EBE5),
          width: _isPumpOn ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isPumpOn ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPumpOn ? Icons.water_drop : Icons.power_settings_new,
                    color: _isPumpOn ? Colors.white : Colors.grey.shade600,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'PUMP STATUS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: locked
                                  ? const Color(0xFFE3F2FD)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              locked ? 'AUTO' : 'MANUAL',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: locked
                                    ? const Color(0xFF1976D2)
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isPumpOn ? 'PUMP IS ON' : 'PUMP IS OFF',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _isPumpOn
                              ? const Color(0xFF1B5E20)
                              : const Color(0xFF1C2D21),
                        ),
                      ),
                      Text(
                        _isPumpOn
                            ? 'Watering active (Simulated)'
                            : 'Standing by (Simulated)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isPumpOn,
                  activeTrackColor: const Color(0xFF2E7D32),
                  onChanged: locked ? null : _togglePump,
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: locked
                    ? null
                    : () => _togglePump(!_isPumpOn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: locked
                      ? Colors.grey.shade200
                      : (_isPumpOn
                          ? Colors.red.shade700
                          : const Color(0xFF2E7D32)),
                  foregroundColor: locked ? Colors.grey.shade500 : Colors.white,
                  disabledBackgroundColor: Colors.grey.shade200,
                  disabledForegroundColor: Colors.grey.shade500,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(
                  _isPumpOn
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                ),
                label: Text(
                  locked
                      ? 'Manual Controls Locked (Auto Mode ON)'
                      : (_isPumpOn
                          ? 'Manual Turn OFF Pump'
                          : 'Manual Turn ON Pump'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (locked)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Disable Automatic Mode below to control the pump manually.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeControlCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auto irrigation row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Color(0xFF1565C0), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Automatic Irrigation',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C2D21),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Logic controls pump based on moisture thresholds',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7C6E),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isAutoMode,
                  activeTrackColor: const Color(0xFF1565C0),
                  onChanged: DemoDataService.instance.setAutoMode,
                ),
              ],
            ),

            if (!_isAutoMode) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: Colors.orange, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manual Override Active',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C2D21),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'You are in full control of the pump',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7C6E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isPumpOn,
                    activeTrackColor: const Color(0xFF2E7D32),
                    onChanged: _togglePump,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDecisionCard() {
    final Color color = _decisionColor;
    return Card(
      color: color.withValues(alpha: 0.07),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_decisionIcon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Irrigation Decision',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _decisionTitle,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _decisionBody,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune,
                      color: Color(0xFF2E7D32), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Moisture Threshold Controls',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C2D21),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildThresholdBadge(
                    label: 'Start Irrigation',
                    value: '${_startThreshold.toInt()}%',
                    subtitle: 'Pump ON below this',
                    color: const Color(0xFFE65100),
                    icon: Icons.play_arrow_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildThresholdBadge(
                    label: 'Stop Irrigation',
                    value: '${_stopThreshold.toInt()}%',
                    subtitle: 'Pump OFF at/above this',
                    color: const Color(0xFF1565C0),
                    icon: Icons.stop_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Start Threshold',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_startThreshold.toInt()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
              ],
            ),
            Slider(
              value: _startThreshold,
              min: 10.0,
              max: 40.0,
              divisions: 30,
              activeColor: const Color(0xFFE65100),
              inactiveColor: const Color(0xFFE65100).withValues(alpha: 0.2),
              label: '${_startThreshold.toInt()}%',
              onChanged: (val) {
                if (val < _stopThreshold - 5) {
                  DemoDataService.instance.setThresholds(start: val);
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stop Threshold',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${_stopThreshold.toInt()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            Slider(
              value: _stopThreshold,
              min: 35.0,
              max: 80.0,
              divisions: 45,
              activeColor: const Color(0xFF1565C0),
              inactiveColor: const Color(0xFF1565C0).withValues(alpha: 0.2),
              label: '${_stopThreshold.toInt()}%',
              onChanged: (val) {
                if (val > _startThreshold + 5) {
                  DemoDataService.instance.setThresholds(stop: val);
                }
              },
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: Color(0xFF6B7C6E)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'At least 5% gap enforced between thresholds to prevent oscillation.',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdBadge({
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildArchitectureNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hub_outlined, color: Colors.grey, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Target Architecture: Flutter App → Flask REST API → ESP32 → Relay Module → Water Pump',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Irrigation decision enum
// ─────────────────────────────────────────────────────────────────────────────
enum _IrrigationDecision { irrigate, monitor, stop }
