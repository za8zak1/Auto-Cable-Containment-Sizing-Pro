import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Small circular progress gauge used inside the hero result card
/// (Ampacity %, VD %).
class CircularGauge extends StatelessWidget {
  final double percent; // 0-100+
  final String label;
  final String valueText;
  final Color trackColor;
  final Color progressColor;
  final double size;

  const CircularGauge({
    super.key,
    required this.percent,
    required this.label,
    required this.valueText,
    this.trackColor = Colors.white24,
    this.progressColor = Colors.white,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(
          percent: percent.clamp(0, 100).toDouble(),
          trackColor: trackColor,
          progressColor: progressColor,
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percent;
  final Color trackColor;
  final Color progressColor;

  _GaugePainter({
    required this.percent,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final strokeWidth = size.width * 0.14;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweep = math.pi * 2 * (percent / 100).clamp(0, 1).toDouble();
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.percent != percent ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}

/// Full gauge "card" combining the ring, icon, label and value text - matches
/// the Ampacity / VD tiles inside the hero card.
class GaugeStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valueText;
  final double percent;
  final VoidCallback? onInfoTap;

  const GaugeStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.valueText,
    required this.percent,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularGauge(
                percent: percent,
                label: label,
                valueText: valueText,
                progressColor: percent > 100
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF34D399),
              ),
              Icon(icon, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text(
                  valueText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onInfoTap,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded,
                  size: 15, color: Color(0xFF1730B8)),
            ),
          ),
        ],
      ),
    );
  }
}
