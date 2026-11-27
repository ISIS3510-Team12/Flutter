
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DecisionWheelPainter extends CustomPainter {
  DecisionWheelPainter({
    required this.options,
    required this.rotation,
  });

  final List<String> options;
  final double rotation;

  static const List<Color> segmentColors = [
    Color(0xFF5455A9),
    Color(0xFFDF6835),
    Color(0xFF397376),
    Color(0xFF948F99),
    Color(0xFF7778C5),
    Color(0xFFB85F72),
    Color(0xFF6C91A0),
    Color(0xFFCC9A55),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty || size.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final sweepAngle = 2 * math.pi / options.length;
    final startAngle = rotation - math.pi / 2;

    final segmentPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final separatorPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    for (var i = 0; i < options.length; i++) {
      final segmentStart = startAngle + i * sweepAngle;

      segmentPaint.color = segmentColors[i % segmentColors.length];

      canvas.drawArc(
        rect,
        segmentStart,
        sweepAngle,
        true,
        segmentPaint,
      );

      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(segmentStart),
          center.dy + radius * math.sin(segmentStart),
        ),
        separatorPaint,
      );

      _drawSegmentLabel(
        canvas,
        options[i],
        center,
        radius,
        segmentStart + sweepAngle / 2,
        sweepAngle,
      );
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..isAntiAlias = true,
    );

    canvas.drawCircle(
      center,
      radius * 0.13,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  void _drawSegmentLabel(
    Canvas canvas,
    String label,
    Offset center,
    double radius,
    double angle,
    double sweepAngle,
  ) {
    if (sweepAngle < 0.20 || radius < 40) return;

    final fontSize = math.min(
      22.0,
      math.max(30.0, radius * 0.06),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      ellipsis: '...',
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      maxWidth: radius * 0.65,
    );

    final labelRadius = radius * 0.62;

    final position = Offset(
      center.dx + labelRadius * math.cos(angle),
      center.dy + labelRadius * math.sin(angle),
    );

    var textAngle = angle;

    final normalizedAngle = (angle % (2 * math.pi) + 2 * math.pi) %
        (2 * math.pi);

    if (normalizedAngle > math.pi / 2 &&
        normalizedAngle < 3 * math.pi / 2) {
      textAngle += math.pi;
    }

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(textAngle);

    textPainter.paint(
      canvas,
      Offset(
        -textPainter.width / 2,
        -textPainter.height / 2,
      ),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DecisionWheelPainter oldDelegate) {
    return !listEquals(oldDelegate.options, options) ||
        oldDelegate.rotation != rotation;
  }
}
