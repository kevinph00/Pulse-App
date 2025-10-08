import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 for Clipboard
import 'package:flutter_compass/flutter_compass.dart';
import 'package:location/location.dart';

import '../painters/compass_painter.dart';
import '../painters/tracking_arc_painter.dart';
import '../widgets/pulse_button.dart';
import '../widgets/track_button.dart';
import '../widgets/top_toast.dart';
import '../widgets/compass_info.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with SingleTickerProviderStateMixin {
  final Location _location = Location();
  LocationData? _locationData;

  double _heading = 0;

  double? _targetLat;
  double? _targetLon;
  double _distance = 0;
  double _targetBearing = 0;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  bool _isRefreshing = false;
  bool _isContinuous = false;
  Timer? _continuousTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _initLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _continuousTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    if (!(await _location.serviceEnabled())) {
      await _location.requestService();
    }
    var perm = await _location.hasPermission();
    if (perm == PermissionStatus.denied) {
      await _location.requestPermission();
    }
    try {
      _locationData = await _location.getLocation();
      _updateDistanceAndBearing();
      setState(() {});
    } catch (_) {
      TopToast.show(context, "Could not get location");
    }
  }

  Future<void> _refreshOnce() async {
    setState(() => _isRefreshing = true);
    _pulseController
      ..reset()
      ..forward();
    try {
      final newLoc = await _location.getLocation();
      setState(() {
        _locationData = newLoc;
        _isRefreshing = false;
      });
      _updateDistanceAndBearing();
    } catch (_) {
      setState(() => _isRefreshing = false);
      TopToast.show(context, "Failed to refresh location");
    }
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

  /// ✅ Copy coordinates to clipboard
  void _copyCoordinates(double lat, double lon) {
    final coords = "${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}";
    Clipboard.setData(ClipboardData(text: coords)); // 👈 fixed
    TopToast.show(context, "Copied: $coords");
  }

  void _showTrackDialog() {
    final controller = TextEditingController(
      text: _targetLat != null && _targetLon != null
          ? "${_targetLat!.toStringAsFixed(5)}, ${_targetLon!.toStringAsFixed(5)}"
          : "",
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Track Coordinates",
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter or paste lat, lon",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.greenAccent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final input = controller.text.trim();
              if (input.isEmpty) {
                setState(() {
                  _targetLat = null;
                  _targetLon = null;
                  _distance = 0;
                  _targetBearing = 0;
                });
                TopToast.show(context, "Tracking reset");
                Navigator.pop(context);
                return;
              }

              final parts = input.split(',');
              if (parts.length == 2) {
                final lat = double.tryParse(parts[0].trim());
                final lon = double.tryParse(parts[1].trim());
                if (lat != null && lon != null) {
                  setState(() {
                    _targetLat = lat;
                    _targetLon = lon;
                  });
                  _updateDistanceAndBearing();
                  TopToast.show(context,
                      "Tracking: ${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}");
                } else {
                  TopToast.show(context, "Invalid coordinates");
                }
              } else {
                TopToast.show(context, "Invalid coordinates");
              }
              Navigator.pop(context);
            },
            child:
                const Text("Save", style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  double _degToRad(double deg) => deg * math.pi / 180.0;
  double _radToDeg(double rad) => rad * 180.0 / math.pi;

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = _degToRad(lon2 - lon1);
    final y = math.sin(dLon) * math.cos(_degToRad(lat2));
    final x = math.cos(_degToRad(lat1)) * math.sin(_degToRad(lat2)) -
        math.sin(_degToRad(lat1)) * math.cos(_degToRad(lat2)) * math.cos(dLon);
    return (_radToDeg(math.atan2(y, x)) + 360) % 360;
  }

  void _updateDistanceAndBearing() {
    if (_locationData == null) return;
    if (_targetLat != null && _targetLon != null) {
      final lat1 = _locationData!.latitude ?? 0;
      final lon1 = _locationData!.longitude ?? 0;
      final lat2 = _targetLat!;
      final lon2 = _targetLon!;
      final dist = _calculateDistance(lat1, lon1, lat2, lon2);
      final bearing = _calculateBearing(lat1, lon1, lat2, lon2);
      setState(() {
        _distance = dist;
        _targetBearing = bearing;
      });
    }
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
                child: Text('Getting location...',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
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

                  // Compass + arc + pulse button
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          StreamBuilder<double>(
                            stream: FlutterCompass.events
                                ?.map((e) => e.heading ?? 0),
                            builder: (context, snapshot) {
                              final heading = snapshot.data ?? 0;

                              // Update _heading for info panel
                              _heading = (heading + 360) % 360;

                              final rotation = -heading * (math.pi / 180);

                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: rotation,
                                    child: CustomPaint(
                                      size: const Size(300, 300),
                                      painter: CompassPainter(),
                                    ),
                                  ),
                                  if (_targetLat != null && _targetLon != null)
                                    CustomPaint(
                                      size: const Size(300, 300),
                                      painter: TrackingArcPainter(
                                        compassHeading: heading,
                                        targetBearing: _targetBearing,
                                      ),
                                    ),
                                  if (_targetLat != null && _targetLon != null)
                                    Positioned(
                                      top: 60,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.45),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          "${_distance.toStringAsFixed(1)} m",
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),

                          // 👇 Only ONE pulse button at center
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

                  // Info panel + one TrackButton
                  Column(
                    children: [
                      CompassInfoPanel(
                        heading: _heading,
                        latitude: lat,
                        longitude: lon,
                        altitude: alt,
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 60, top: 8),
                        child: TrackButton(
                          onPressed: _showTrackDialog,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
