import 'package:flutter/material.dart';
import 'dart:math' as math;

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    final circlePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, circlePaint);

    // Tick marks
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;

    for (int i = 0; i < 360; i += 10) {
      final angle = (i - 90) * math.pi / 180;
      final start = Offset(
        center.dx + math.cos(angle) * (radius - 8),
        center.dy + math.sin(angle) * (radius - 8),
      );
      final end = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      // Draw a tick line every 10 degrees
      if (i % 30 == 0) {
        canvas.drawLine(start, end, tickPaint);
      }

      // Draw degree labels every 30 degrees
      if (i % 30 == 0) {
        final isNorth = i == 0;
        final tp = TextPainter(
          text: TextSpan(
            text: "$i°",
            style: TextStyle(
              color: isNorth ? Colors.red : Colors.white,
              fontSize: 14,
              fontWeight: isNorth ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        final offset = Offset(
          center.dx + math.cos(angle) * (radius - 30) - tp.width / 2,
          center.dy + math.sin(angle) * (radius - 30) - tp.height / 2,
        );
        tp.paint(canvas, offset);
      }
    }

    // Direction labels outside the compass
    _drawDir(canvas, center, radius + 20, 0, "N", Colors.red);
    _drawDir(canvas, center, radius + 20, 90, "E", Colors.white);
    _drawDir(canvas, center, radius + 20, 180, "S", Colors.white);
    _drawDir(canvas, center, radius + 20, 270, "W", Colors.white);
  }

  void _drawDir(Canvas canvas, Offset center, double distance,
      double angleDeg, String label, Color color) {
    final angle = (angleDeg - 90) * math.pi / 180;
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    final offset = Offset(
      center.dx + math.cos(angle) * distance - tp.width / 2,
      center.dy + math.sin(angle) * distance - tp.height / 2,
    );
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
