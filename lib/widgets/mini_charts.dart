import 'dart:math';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
//  SPARK AREA CHART — small area chart for trends
// ═══════════════════════════════════════════════════════════════

class SparkAreaChart extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double height;
  final List<String>? labels;

  const SparkAreaChart({
    super.key,
    required this.data,
    this.color = const Color(0xFF0E93AF),
    this.height = 160,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _SparkAreaPainter(data, color, labels),
      ),
    );
  }
}

class _SparkAreaPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final List<String>? labels;
  _SparkAreaPainter(this.data, this.color, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.reduce(max) * 1.15;
    final minVal = data.reduce(min) * 0.85;
    final range = maxVal - minVal;
    final stepX = size.width / (data.length - 1);
    final padding = 24.0;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE8ECF0)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 4; i++) {
      final y = padding + (size.height - padding * 2) * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Build path
    final path = Path();
    final fillPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = padding + (size.height - padding * 2) * (1 - (data[i] - minVal) / range);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height - padding);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = padding + (size.height - padding * 2) * (1 - (data[i - 1] - minVal) / range);
        final cx1 = prevX + stepX * 0.4;
        final cx2 = x - stepX * 0.4;
        path.cubicTo(cx1, prevY, cx2, y, x, y);
        fillPath.cubicTo(cx1, prevY, cx2, y, x, y);
      }
    }
    fillPath.lineTo(size.width - stepX * 0 + (data.length - 1) * stepX - (data.length - 1) * stepX + (data.length - 1) * stepX, size.height - padding);
    fillPath.lineTo((data.length - 1) * stepX, size.height - padding);
    fillPath.close();

    // Fill gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.02)],
    );
    canvas.drawPath(
      fillPath,
      Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Stroke
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Dots
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = padding + (size.height - padding * 2) * (1 - (data[i] - minVal) / range);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);
      canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = Colors.white);
    }

    // Labels
    if (labels != null) {
      for (int i = 0; i < labels!.length && i < data.length; i++) {
        final x = i * stepX;
        final tp = TextPainter(
          text: TextSpan(
            text: labels![i],
            style: const TextStyle(fontSize: 9, color: Color(0xFF8A9BAC)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, size.height - 12));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════
//  DONUT CHART — pie/donut chart
// ═══════════════════════════════════════════════════════════════

class DonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final double size;
  final String? centerLabel;
  final String? centerValue;

  const DonutChart({
    super.key,
    required this.segments,
    this.size = 160,
    this.centerLabel,
    this.centerValue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(segments),
          ),
          if (centerValue != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(centerValue!,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2B3C))),
                if (centerLabel != null)
                  Text(centerLabel!,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF8A9BAC))),
              ],
            ),
        ],
      ),
    );
  }
}

class DonutSegment {
  final String label;
  final double value;
  final Color color;
  const DonutSegment(this.label, this.value, this.color);
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  _DonutPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (s, e) => s + e.value);
    if (total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final strokeWidth = radius * 0.32;
    double startAngle = -pi / 2;

    for (var seg in segments) {
      final sweep = (seg.value / total) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep - 0.03,
        false,
        Paint()
          ..color = seg.color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ═══════════════════════════════════════════════════════════════
//  HORIZONTAL BAR — simple horizontal bar list
// ═══════════════════════════════════════════════════════════════

class HorizontalBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;

  const HorizontalBar({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    this.color = const Color(0xFF0E93AF),
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF5A6B7C)),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8ECF0),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              value.toStringAsFixed(0),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PROGRESS GAUGE — circular progress indicator
// ═══════════════════════════════════════════════════════════════

class ProgressGauge extends StatelessWidget {
  final double value; // 0..1
  final Color color;
  final double size;
  final String label;

  const ProgressGauge({
    super.key,
    required this.value,
    this.color = const Color(0xFF64CC91),
    this.size = 100,
    this.label = '',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(value.clamp(0, 1), color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(value * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                      fontSize: size * 0.18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A2B3C))),
              if (label.isNotEmpty)
                Text(label,
                    style: TextStyle(
                        fontSize: size * 0.1,
                        color: const Color(0xFF8A9BAC))),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  _GaugePainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeW = 10.0;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi,
      false,
      Paint()
        ..color = const Color(0xFFE8ECF0)
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Value arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * value,
      false,
      Paint()
        ..color = color
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
