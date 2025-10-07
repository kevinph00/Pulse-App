
import 'package:flutter/material.dart';

class PulseButton extends StatelessWidget {
  final bool isRefreshing;
  final bool isContinuous;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Animation<double> pulseAnimation;

  const PulseButton({
    super.key,
    required this.isRefreshing,
    required this.isContinuous,
    required this.onTap,
    required this.onLongPress,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse animation behind the button
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Container(
              width: 80 + pulseAnimation.value * 350,
              height: 80 + pulseAnimation.value * 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(
                    0.35 * (1 - pulseAnimation.value)),
              ),
            );
          },
        ),
        GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isContinuous
                  ? Colors.tealAccent.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
              border: isContinuous
                  ? Border.all(color: Colors.tealAccent, width: 3)
                  : null,
            ),
            child: (isRefreshing || isContinuous)
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 32,
                  ),
          ),
        ),
      ],
    );
  }
}
