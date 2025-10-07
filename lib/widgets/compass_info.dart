import 'package:flutter/material.dart';

class CompassInfo extends StatelessWidget {
  final double heading;
  final double latitude;
  final double longitude;
  final double altitude;
  final void Function(double, double) onCopyCoordinates;

  const CompassInfo({
    super.key,
    required this.heading,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.onCopyCoordinates,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("${heading.toStringAsFixed(0)}°",
            style: const TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => onCopyCoordinates(latitude, longitude),
          child: Text(
            "${latitude.toStringAsFixed(5)}  ${longitude.toStringAsFixed(5)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text("Location", style: TextStyle(color: Colors.white54)),
        Text("${altitude.toStringAsFixed(2)} m",
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        const Text("Altitude", style: TextStyle(color: Colors.white54)),
      ],
    );
  }
}
