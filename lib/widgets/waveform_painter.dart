
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;
  final bool isRecording;

  WaveformPainter({
    required this.waveformData,
    required this.color,
    required this.isRecording,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    final spacing = width / (waveformData.length - 1);

    for (var i = 0; i < waveformData.length - 1; i++) {
      final x1 = i * spacing;
      final y1 = height / 2 + (waveformData[i] * height / 2);
      final x2 = (i + 1) * spacing;
      final y2 = height / 2 + (waveformData[i + 1] * height / 2);

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) =>
      isRecording || waveformData != oldDelegate.waveformData;
}
