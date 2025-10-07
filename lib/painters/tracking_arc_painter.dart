import 'package:flutter/material.dart';
import 'dart:math' as math;

class TrackingArcPainter extends CustomPainter {
  final double compassHeading;
  final double targetBearing;

  TrackingArcPainter({
    required this.compassHeading,
    required this.targetBearing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.green.withOpacity(0.7)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final angleToTarget = (targetBearing - compassHeading) % 360;
    final startAngle = (-angleToTarget - 10) * math.pi / 180;
    const sweepAngle = 20 * math.pi / 180;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 12),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
