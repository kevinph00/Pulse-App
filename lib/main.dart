import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:math' as math;
import 'dart:async';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CompassScreen(),
    );
  }
}

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});
  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with SingleTickerProviderStateMixin {
  final Location location = Location();
  LocationData? _locationData;
  bool _isRefreshing = false;
  bool _isContinuous = false;
  Timer? _continuousTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initLocation();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _continuousTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    if (!(await location.serviceEnabled())) {
      await location.requestService();
    }
    var perm = await location.hasPermission();
    if (perm == PermissionStatus.denied) {
      await location.requestPermission();
    }
    _locationData = await location.getLocation();
    setState(() {});
  }

  Future<void> _refreshOnce() async {
    setState(() => _isRefreshing = true);
    _pulseController
      ..reset()
      ..forward();
    final newLoc = await location.getLocation();
    setState(() {
      _locationData = newLoc;
      _isRefreshing = false;
    });
  }

  void _toggleContinuous() {
    if (_isContinuous) {
      // Stop continuous mode
      _continuousTimer?.cancel();
      setState(() => _isContinuous = false);
    } else {
      // Start continuous mode
      setState(() => _isContinuous = true);
      _continuousTimer =
          Timer.periodic(const Duration(seconds: 3), (_) => _refreshOnce());
      _refreshOnce();
    }
  }

  @override
  Widget build(BuildContext context) {
    final heading = _locationData?.heading ?? 0;
    final lat = _locationData?.latitude ?? 0;
    final lon = _locationData?.longitude ?? 0;
    final alt = _locationData?.altitude ?? 0;
    final timestamp = _locationData?.time != null
        ? DateTime.fromMillisecondsSinceEpoch(_locationData!.time!.toInt())
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _locationData == null
            ? const Center(
                child: Text('Getting location...',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // top bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Pulse",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text(
                          timestamp != null
                              ? "${timestamp.hour.toString().padLeft(2, '0')}:"
                                "${timestamp.minute.toString().padLeft(2, '0')}:"
                                "${timestamp.second.toString().padLeft(2, '0')}"
                              : "--:--:--",
                          style:
                              const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),

                  // compass + button
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // --- PULSE BEHIND ---
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 80 + _pulseAnimation.value * 350,
                                height: 80 + _pulseAnimation.value * 350,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blueAccent
                                      .withOpacity(0.35 * (1 - _pulseAnimation.value)),
                                ),
                              );
                            },
                          ),

                          // --- COMPASS ROTATING WITH LABELS ---
                          Transform.rotate(
                            angle: -(heading * math.pi / 180),
                            child: CustomPaint(
                              size: const Size(300, 300),
                              painter: CompassPainter(),
                            ),
                          ),

                          // --- Refresh button ---
                          GestureDetector(
                            onTap: () {
                              if (_isContinuous) {
                                _toggleContinuous(); // stop continuous if active
                              } else {
                                _refreshOnce(); // single refresh
                              }
                            },
                            onLongPress: _toggleContinuous, // toggle continuous mode
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isContinuous
                                    ? Colors.tealAccent.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.3),
                                border: _isContinuous
                                    ? Border.all(
                                        color: Colors.tealAccent, width: 3)
                                    : null,
                              ),
                              child: (_isRefreshing || _isContinuous)
                                  ? const Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(
                                          strokeWidth: 3, color: Colors.white),
                                    )
                                  : Icon(Icons.refresh,
                                      color: _isContinuous
                                          ? Colors.tealAccent
                                          : Colors.white,
                                      size: 32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // info text
                  Column(
                    children: [
                      Text("${heading.toStringAsFixed(0)}°",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("${lat.toStringAsFixed(5)}  ${lon.toStringAsFixed(5)}",
                          style:
                              const TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 4),
                      const Text("Location",
                          style: TextStyle(color: Colors.white54)),
                      Text("${alt.toStringAsFixed(2)} m",
                          style:
                              const TextStyle(color: Colors.white, fontSize: 16)),
                      const Text("Altitude",
                          style: TextStyle(color: Colors.white54)),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 60, top: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14)),
                      onPressed: () {},
                      child: const Text("TRACK",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ----------------- COMPASS PAINTER -----------------
class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final circlePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, circlePaint);

    final tickPaint = Paint()..color = Colors.white..strokeWidth = 1.5;

    for (int i = 0; i < 360; i += 10) {
      final angle = (i - 90) * math.pi / 180;
      final start = Offset(center.dx + math.cos(angle) * (radius - 8),
          center.dy + math.sin(angle) * (radius - 8));
      final end = Offset(center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius);

      if (i % 30 == 0) canvas.drawLine(start, end, tickPaint);

      if (i % 30 == 0) {
        final isNorth = i == 0;
        final tp = TextPainter(
            text: TextSpan(
                text: "$i°",
                style: TextStyle(
                    color: isNorth ? Colors.red : Colors.white,
                    fontSize: 14,
                    fontWeight:
                        isNorth ? FontWeight.bold : FontWeight.normal)),
            textDirection: TextDirection.ltr);
        tp.layout();
        final offset = Offset(
          center.dx + math.cos(angle) * (radius - 30) - tp.width / 2,
          center.dy + math.sin(angle) * (radius - 30) - tp.height / 2,
        );
        tp.paint(canvas, offset);
      }
    }

    // N/E/S/W labels attached to compass just outside
    _drawDir(canvas, center, radius + 20, 0, "N", Colors.red);
    _drawDir(canvas, center, radius + 20, 90, "E", Colors.white);
    _drawDir(canvas, center, radius + 20, 180, "S", Colors.white);
    _drawDir(canvas, center, radius + 20, 270, "W", Colors.white);
  }

  void _drawDir(Canvas c, Offset center, double dist,
      double angleDeg, String label, Color color) {
    final ang = (angleDeg - 90) * math.pi / 180;
    final tp = TextPainter(
        text: TextSpan(
            text: label,
            style: TextStyle(
                color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr);
    tp.layout();
    final offset = Offset(
      center.dx + math.cos(ang) * dist - tp.width / 2,
      center.dy + math.sin(ang) * dist - tp.height / 2,
    );
    tp.paint(c, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
