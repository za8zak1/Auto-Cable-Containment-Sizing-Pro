import 'dart:math' as math;
import 'package:flutter/material.dart';

class RadialSegment {
  final String label;
  final int count;
  final double percent; // 0-100, of the whole database
  final Color color;

  const RadialSegment({
    required this.label,
    required this.count,
    required this.percent,
    required this.color,
  });
}

/// Concentric multi-ring chart: each [RadialSegment] gets its own ring,
/// sized to a fixed radius step, with an arc sweep proportional to its
/// share of the database. Tapping a ring calls [onSegmentTap]. The centre
/// shows whichever segment is currently selected.
class RadialFamilyChart extends StatefulWidget {
  final List<RadialSegment> segments;
  final int initialSelectedIndex;

  const RadialFamilyChart({
    super.key,
    required this.segments,
    this.initialSelectedIndex = 0,
  });

  @override
  State<RadialFamilyChart> createState() => _RadialFamilyChartState();
}

class _RadialFamilyChartState extends State<RadialFamilyChart> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = _safeSelectedIndex(widget.initialSelectedIndex);
  }

  @override
  void didUpdateWidget(covariant RadialFamilyChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.segments.length != oldWidget.segments.length ||
        widget.initialSelectedIndex != oldWidget.initialSelectedIndex) {
      _selected = _safeSelectedIndex(_selected);
    }
  }

  int _safeSelectedIndex(int requested) {
    if (widget.segments.isEmpty) return 0;
    return requested.clamp(0, widget.segments.length - 1).toInt();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.segments.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No data to chart yet')),
      );
    }
    final selected = widget.segments[_selected];

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest.shortestSide;
          return GestureDetector(
            onTapUp: (details) => _handleTap(details.localPosition, size),
            child: CustomPaint(
              painter: _RadialPainter(segments: widget.segments, selected: _selected),
              child: Center(
                child: SizedBox(
                  width: size * 0.46,
                  height: size * 0.46,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${selected.count}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          selected.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        Text(
                          '${selected.percent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: selected.color,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(Offset local, double size) {
    final center = Offset(size / 2, size / 2);
    final dx = local.dx - center.dx;
    final dy = local.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);

    final maxRadius = size / 2 - 4;
    final minRadius = size * 0.23;
    final ringBand = (maxRadius - minRadius) / widget.segments.length;
    if (dist < minRadius || dist > maxRadius) return;

    // Outermost ring = index 0 in the reference UI, so invert.
    final ringFromOutside = ((maxRadius - dist) / ringBand).floor();
    final index =
        (widget.segments.length - 1 - ringFromOutside).clamp(0, widget.segments.length - 1).toInt();
    setState(() => _selected = index);
  }
}

class _RadialPainter extends CustomPainter {
  final List<RadialSegment> segments;
  final int selected;

  _RadialPainter({required this.segments, required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 4;
    final minRadius = size.width * 0.23;
    final ringBand = (maxRadius - minRadius) / segments.length;
    final strokeWidth = ringBand * 0.62;

    for (int i = 0; i < segments.length; i++) {
      // outer ring first (i = 0) drawn at largest radius
      final radius = maxRadius - ringBand * i - ringBand / 2;
      final seg = segments[i];

      final trackPaint = Paint()
        ..color = seg.color.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, trackPaint);

      final sweep = math.pi * 2 * (seg.percent / 100).clamp(0.0, 1.0);
      final isSelected = i == selected;
      final progressPaint = Paint()
        ..color = seg.color.withValues(alpha: isSelected ? 1 : 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? strokeWidth * 1.08 : strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadialPainter oldDelegate) =>
      oldDelegate.segments != segments || oldDelegate.selected != selected;
}
