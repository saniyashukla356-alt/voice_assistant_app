import 'package:flutter/material.dart';
import 'dart:math' as math;

class ExactImageOrbPainter extends CustomPainter {
  final double rotation;
  final double voiceEnergy;
  final bool isListening;

  ExactImageOrbPainter({
    required this.rotation,
    required this.voiceEnergy,
    required this.isListening,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final coreRadius = size.width * 0.32;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    int ribbonLayers = 65;

    double organicAmplitude = isListening ? (4.5 + (voiceEnergy * 1.6)) : 4.0;

    for (int i = 0; i < ribbonLayers; i++) {
      final double progress = i / ribbonLayers;

      paint.color = Color.lerp(
        const Color(0xFFFF499E).withValues(alpha: 0.85),
        const Color(0xFF8A2BE2).withValues(alpha: 0.15),
        progress,
      )!;

      final Path layerPath = Path();

      for (int step = 0; step <= 120; step++) {
        final double radialAngle = (step / 120) * 2 * math.pi;

        double dynamicWaveform = math.sin(radialAngle * 5 + rotation) *
            math.cos(radialAngle * 3 - (progress * math.pi));

        if (voiceEnergy > 1.5) {
          dynamicWaveform +=
              0.20 * math.sin(radialAngle * 10 + (rotation * 1.5));
        }

        double finalRadius =
            (coreRadius * progress) + (dynamicWaveform * organicAmplitude);
        double x = center.dx + finalRadius * math.cos(radialAngle);
        double y = center.dy + finalRadius * math.sin(radialAngle);

        if (step == 0) {
          layerPath.moveTo(x, y);
        } else {
          layerPath.lineTo(x, y);
        }
      }
      canvas.drawPath(layerPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ExactImageOrbPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.voiceEnergy != voiceEnergy ||
        oldDelegate.isListening != isListening;
  }
}
