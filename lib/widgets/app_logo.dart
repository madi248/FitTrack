import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 80,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tealColor = color ?? const Color(0xFF14B8A6);
    
    return CustomPaint(
      size: Size(size, size),
      painter: _LogoPainter(color: tealColor),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw the open circle (C-shape)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.25, // Start at about 45 degrees
      math.pi * 1.5, // Draw 270 degrees (3/4 of circle)
      false,
      paint,
    );

    // Draw the heartbeat/ECG line on the left side
    final heartbeatPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    final heartbeatStartX = size.width * 0.25;
    final heartbeatStartY = size.height * 0.4;
    final heartbeatPath = Path();

    // Create ECG/heartbeat waveform
    heartbeatPath.moveTo(heartbeatStartX, heartbeatStartY);
    heartbeatPath.lineTo(heartbeatStartX + size.width * 0.08, heartbeatStartY);
    heartbeatPath.lineTo(heartbeatStartX + size.width * 0.1, heartbeatStartY - size.height * 0.15);
    heartbeatPath.lineTo(heartbeatStartX + size.width * 0.15, heartbeatStartY + size.height * 0.12);
    heartbeatPath.lineTo(heartbeatStartX + size.width * 0.2, heartbeatStartY - size.height * 0.08);
    heartbeatPath.lineTo(heartbeatStartX + size.width * 0.25, heartbeatStartY);

    canvas.drawPath(heartbeatPath, heartbeatPaint);

    // Draw the fork and knife inside a smaller circle on the right
    final innerCircleRadius = size.width * 0.18;
    final innerCircleCenter = Offset(size.width * 0.65, size.height * 0.5);

    final innerCirclePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025;

    canvas.drawCircle(innerCircleCenter, innerCircleRadius, innerCirclePaint);

    // Draw fork (left side of inner circle)
    final forkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final forkStartX = innerCircleCenter.dx - size.width * 0.06;
    final forkStartY = innerCircleCenter.dy - size.height * 0.12;
    final forkEndY = innerCircleCenter.dy + size.height * 0.12;

    // Fork handle
    canvas.drawRect(
      Rect.fromLTWH(
        forkStartX - size.width * 0.008,
        forkStartY,
        size.width * 0.016,
        (forkEndY - forkStartY),
      ),
      forkPaint,
    );

    // Fork prongs (3 prongs)
    final prongWidth = size.width * 0.015;
    final prongSpacing = size.width * 0.02;
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          forkStartX - size.width * 0.04 + (i * prongSpacing),
          forkStartY,
          prongWidth,
          size.height * 0.08,
        ),
        forkPaint,
      );
    }

    // Draw knife (right side of inner circle)
    final knifeStartX = innerCircleCenter.dx + size.width * 0.03;
    final knifeStartY = innerCircleCenter.dy - size.height * 0.12;
    final knifeEndY = innerCircleCenter.dy + size.height * 0.12;

    // Knife handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          knifeStartX - size.width * 0.008,
          knifeStartY,
          size.width * 0.016,
          (knifeEndY - knifeStartY) * 0.6,
        ),
        const Radius.circular(2),
      ),
      forkPaint,
    );

    // Knife blade (diagonal)
    final bladePath = Path();
    bladePath.moveTo(knifeStartX, knifeStartY + (knifeEndY - knifeStartY) * 0.4);
    bladePath.lineTo(knifeStartX + size.width * 0.03, knifeStartY + size.height * 0.03);
    bladePath.lineTo(knifeStartX + size.width * 0.03, knifeEndY);
    bladePath.lineTo(knifeStartX - size.width * 0.01, knifeEndY);
    bladePath.close();
    canvas.drawPath(bladePath, forkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
