import 'package:flutter/material.dart';

class InitializingScreen extends StatelessWidget {
  const InitializingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minimalist Gradient Ring
                SizedBox(
                  width: 42,
                  height: 42,
                  child: ShaderMask(
                    shaderCallback: (rect) => const SweepGradient(
                      startAngle: 0,
                      endAngle: 3.14 * 2,
                      colors: [Color(0xFFF2F2F7), Color(0xFF1B6EF3)],
                    ).createShader(rect),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // Professional Spacing Typography
                const Text(
                  "ESTABLISHING SECURE SESSION",
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4.0, // Luxury tech feel
                  ),
                ),
              ],
            ),
          ),
          // Build/Version info at bottom
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "SYSTEM v1.0.4",
                style: TextStyle(
                  color: Colors.black.withOpacity(0.1),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
