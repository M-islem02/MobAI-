import 'dart:math';
import 'package:flutter/material.dart';
import '../models/warehouse_data.dart';

// ═══════════════════════════════════════════════════════════════
//  HEATMAP FLOOR PAINTER — Full-floor heatmap visualization
//  Renders occupancy / pick-frequency heatmap over the floor plan
// ═══════════════════════════════════════════════════════════════

class HeatmapFloorPainter extends CustomPainter {
  final WarehouseFloor floor;
  final String? selectedZoneId;
  final double animValue;

  HeatmapFloorPainter({
    required this.floor,
    this.selectedZoneId,
    this.animValue = 0,
  });

  double _scale(Size size) {
    final sx = size.width / floor.totalWidthM;
    final sy = size.height / floor.totalHeightM;
    return sx < sy ? sx : sy;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = _scale(size);

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, floor.totalWidthM * s, floor.totalHeightM * s),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF1A2332),
    );

    // Grid overlay (dark theme)
    final gridP = Paint()
      ..color = const Color(0xFF2A3A4A).withValues(alpha: 0.5)
      ..strokeWidth = 0.5;
    for (double x = 0; x <= floor.totalWidthM; x += 1) {
      canvas.drawLine(
          Offset(x * s, 0), Offset(x * s, floor.totalHeightM * s), gridP);
    }
    for (double y = 0; y <= floor.totalHeightM; y += 1) {
      canvas.drawLine(
          Offset(0, y * s), Offset(floor.totalWidthM * s, y * s), gridP);
    }

    // Heatmap cells — 1m² resolution
    final rng = Random(floor.id.hashCode);
    final gridW = floor.totalWidthM.toInt();
    final gridH = floor.totalHeightM.toInt();

    // Pre-compute zone heat map
    final heatGrid = List.generate(gridH, (_) => List.filled(gridW, 0.0));

    for (var zone in floor.zones) {
      final x1 = zone.x.floor().clamp(0, gridW - 1);
      final y1 = zone.y.floor().clamp(0, gridH - 1);
      final x2 = (zone.x + zone.widthM).ceil().clamp(0, gridW);
      final y2 = (zone.y + zone.heightM).ceil().clamp(0, gridH);

      // Heat = occupancy * some random activity factor
      final baseHeat = zone.occupancyRate;
      final activityFactor = 0.3 + rng.nextDouble() * 0.7;

      for (int y = y1; y < y2; y++) {
        for (int x = x1; x < x2; x++) {
          if (x >= 0 && x < gridW && y >= 0 && y < gridH) {
            heatGrid[y][x] = (baseHeat * activityFactor).clamp(0.0, 1.0);
          }
        }
      }
    }

    // Draw heatmap cells
    for (int y = 0; y < gridH; y++) {
      for (int x = 0; x < gridW; x++) {
        final heat = heatGrid[y][x];
        if (heat > 0.01) {
          final color = _heatColor(heat);
          canvas.drawRect(
            Rect.fromLTWH(x * s, y * s, s, s),
            Paint()..color = color.withValues(alpha: 0.6),
          );
        }
      }
    }

    // Zone outlines
    for (var zone in floor.zones) {
      final rect = Rect.fromLTWH(
          zone.x * s, zone.y * s, zone.widthM * s, zone.heightM * s);
      final isSelected = zone.id == selectedZoneId;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()
          ..color = isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2.5 : 0.8,
      );

      // Label
      if (zone.widthM * s > 16 && zone.heightM * s > 10) {
        final fontSize = (s * 0.8).clamp(6.0, 12.0);
        _paintText(
          canvas,
          zone.label,
          Offset(
            zone.x * s + (zone.widthM * s) / 2 -
                zone.label.length * fontSize * 0.25,
            zone.y * s + (zone.heightM * s) / 2 - fontSize / 2,
          ),
          fontSize,
          Colors.white.withValues(alpha: 0.9),
          bold: true,
        );
      }
    }

    // Selection pulse
    if (selectedZoneId != null) {
      for (var zone in floor.zones) {
        if (zone.id == selectedZoneId) {
          final rect = Rect.fromLTWH(
              zone.x * s, zone.y * s, zone.widthM * s, zone.heightM * s);
          final pulse = 3 + 5 * sin(animValue * 2 * pi).abs();
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                rect.inflate(pulse), const Radius.circular(6)),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
    }

    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, floor.totalWidthM * s, floor.totalHeightM * s),
        const Radius.circular(6),
      ),
      Paint()
        ..color = const Color(0xFF455A64)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Axis labels
    for (double x = 0; x <= floor.totalWidthM; x += 5) {
      _paintText(canvas, '${x.toInt()}m',
          Offset(x * s - 8, floor.totalHeightM * s + 2), 8,
          const Color(0xFF78909C));
    }
    for (double y = 0; y <= floor.totalHeightM; y += 5) {
      _paintText(canvas, '${y.toInt()}m',
          Offset(floor.totalWidthM * s + 2, y * s - 5), 8,
          const Color(0xFF78909C));
    }

    // Legend
    _drawLegend(canvas, size, s);
  }

  void _drawLegend(Canvas canvas, Size size, double s) {
    final lx = 10.0;
    final ly = floor.totalHeightM * s - 50;
    final lw = 120.0;
    final lh = 40.0;

    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(lx, ly, lw, lh), const Radius.circular(6)),
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );

    // Gradient bar
    final gradRect = Rect.fromLTWH(lx + 10, ly + 8, lw - 20, 10);
    for (int i = 0; i < (lw - 20).toInt(); i++) {
      final t = i / (lw - 20);
      canvas.drawLine(
        Offset(gradRect.left + i, gradRect.top),
        Offset(gradRect.left + i, gradRect.bottom),
        Paint()..color = _heatColor(t),
      );
    }

    // Labels
    _paintText(canvas, 'Low', Offset(lx + 10, ly + 22), 8, Colors.white54);
    _paintText(canvas, 'High', Offset(lx + lw - 36, ly + 22), 8, Colors.white54);
  }

  Color _heatColor(double t) {
    // Green → Yellow → Orange → Red
    if (t < 0.25) {
      return Color.lerp(const Color(0xFF4CAF50), const Color(0xFFCDDC39), t / 0.25)!;
    } else if (t < 0.5) {
      return Color.lerp(const Color(0xFFCDDC39), const Color(0xFFFFC107), (t - 0.25) / 0.25)!;
    } else if (t < 0.75) {
      return Color.lerp(const Color(0xFFFFC107), const Color(0xFFFF5722), (t - 0.5) / 0.25)!;
    } else {
      return Color.lerp(const Color(0xFFFF5722), const Color(0xFFD32F2F), (t - 0.75) / 0.25)!;
    }
  }

  void _paintText(Canvas canvas, String text, Offset offset, double size,
      Color color, {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant HeatmapFloorPainter old) => true;
}
