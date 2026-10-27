import 'package:flutter/material.dart';

class PumpStatusCard extends StatelessWidget {
  final bool isPumpOn;
  final bool isAutoMode;
  final ValueChanged<bool> onTogglePump;

  const PumpStatusCard({
    super.key,
    required this.isPumpOn,
    required this.isAutoMode,
    required this.onTogglePump,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPumpOn ? const Color(0xFF81C784) : const Color(0xFFE0E0E0),
          width: 1.5,
        ),
      ),
      color: isPumpOn ? const Color(0xFFE8F5E9) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPumpOn ? const Color(0xFF2E7D32) : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.water_drop_rounded,
                color: isPumpOn ? Colors.white : Colors.grey.shade600,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Water Pump',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPumpOn ? const Color(0xFF1B5E20) : const Color(0xFF1C2D21),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAutoMode ? const Color(0xFFE3F2FD) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isAutoMode ? 'AUTO MODE' : 'MANUAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isAutoMode ? const Color(0xFF1976D2) : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPumpOn ? 'Pump is actively running' : 'Pump is currently turned OFF',
                    style: TextStyle(
                      fontSize: 13,
                      color: isPumpOn ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: isPumpOn,
              activeTrackColor: const Color(0xFF2E7D32),
              onChanged: onTogglePump,
            ),
          ],
        ),
      ),
    );
  }
}
