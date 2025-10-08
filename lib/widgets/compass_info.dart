import 'package:flutter/material.dart';
import '../widgets/top_toast.dart';
import 'package:flutter/services.dart'; // for Clipboard

class CompassInfoPanel extends StatelessWidget {
  final double heading;
  final double latitude;
  final double longitude;
  final double altitude;

  const CompassInfoPanel({
    super.key,
    required this.heading,
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });

  void _copyCoordinates(BuildContext context) {
    final coords = "${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}";
    Clipboard.setData(ClipboardData(text: coords));
    TopToast.show(context, "Copied: $coords");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("${heading.toStringAsFixed(0)}°",
            style: const TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _copyCoordinates(context),
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
