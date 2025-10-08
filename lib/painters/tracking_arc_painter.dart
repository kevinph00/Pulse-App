import 'package:flutter/material.dart';
import 'dart:math' as math;

class TrackingArcPainter extends CustomPainter {
  final double compassHeading; // current heading of the phone
  final double targetBearing;  // absolute bearing to target

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

    // Compute relative angle of target from the center of screen
    // 0° = top of the screen
    double relativeAngle = (targetBearing - compassHeading) % 360;

    // Convert to radians, rotate clockwise from top (-90 deg adjustment)
    final startAngle = (relativeAngle - 10) * math.pi / 180;
    const sweepAngle = 20 * math.pi / 180;

    // Arc radius slightly outside the compass
    final arcRadius = radius + 12;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant TrackingArcPainter oldDelegate) {
    return oldDelegate.compassHeading != compassHeading ||
        oldDelegate.targetBearing != targetBearing;
  }
}
