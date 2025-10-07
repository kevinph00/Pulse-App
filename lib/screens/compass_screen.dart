import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:async';
import 'dart:math' as math;

import '../painters/compass_painter.dart';
import '../services/location_service.dart';
import '../widgets/pulse_button.dart';
import '../widgets/track_button.dart';
import '../widgets/compass_info.dart';
import '../widgets/top_toast.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with SingleTickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  LocationData? _locationData;
  bool _isRefreshing = false;
  bool _isContinuous = false;
  Timer? _continuousTimer;
  double _heading = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String? _trackingCoordinates;

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

    // Listen to compass heading continuously
    FlutterCompass.events?.listen((event) {
      setState(() {
        _heading = event.heading ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _continuousTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    _locationData = await _locationService.initAndGetLocation();
    setState(() {});
  }

  Future<void> _refreshOnce() async {
    setState(() => _isRefreshing = true);
    _pulseController
      ..reset()
      ..forward();
    final newLoc = await _locationService.getLocation();
    setState(() {
      _locationData = newLoc;
      _isRefreshing = false;
    });
  }

  void _toggleContinuous() {
    if (_isContinuous) {
      _continuousTimer?.cancel();
      setState(() => _isContinuous = false);
    } else {
      setState(() => _isContinuous = true);
      _continuousTimer =
          Timer.periodic(const Duration(seconds: 3), (_) => _refreshOnce());
      _refreshOnce();
    }
  }

  void _copyCoordinates(double lat, double lon) {
    final coords = "${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}";
    TopToast.show(context, "📋 Copied: $coords");
  }

  Future<void> _showTrackDialog() async {
    final controller =
        TextEditingController(text: _trackingCoordinates ?? "");

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Track Coordinates"),
          content: TextField(
            controller: controller,
            decoration:
                const InputDecoration(hintText: "Enter latitude, longitude"),
            keyboardType: TextInputType.text,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  final input = controller.text.trim();
                  if (input.isEmpty) {
                    _trackingCoordinates = null;
                    TopToast.show(context, "Tracking reset");
                  } else {
                    _trackingCoordinates = input;
                    TopToast.show(context, "Tracking: $input");
                  }
                  Navigator.of(context).pop();
                },
                child: const Text("OK")),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: Text(
                  'Getting location...',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top bar
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
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),

                  // Compass + pulse button
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: -(_heading * math.pi / 180),
                            child: CustomPaint(
                              size: const Size(300, 300),
                              painter: CompassPainter(),
                            ),
                          ),
                          PulseButton(
                            isRefreshing: _isRefreshing,
                            isContinuous: _isContinuous,
                            pulseAnimation: _pulseAnimation,
                            onTap: () {
                              if (_isContinuous) {
                                _toggleContinuous();
                              } else {
                                _refreshOnce();
                              }
                            },
                            onLongPress: _toggleContinuous,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Compass info
                  CompassInfo(
                    heading: _heading,
                    latitude: lat,
                    longitude: lon,
                    altitude: alt,
                    onCopyCoordinates: _copyCoordinates,
                  ),

                  // Track button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60, top: 8),
                    child: TrackButton(onPressed: _showTrackDialog),
                  ),
                ],
              ),
      ),
    );
  }
}
