import 'dart:math';

import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/domain/models/pomodoro/pomodoro.dart';
import 'package:team12_flutter_juggle/ui/core/themes/app_typography.dart';

Color pomodoroTint(ColorScheme colors) =>
    Color.alphaBlend(colors.primary.withValues(alpha: 0.25), colors.surface);

class TimerDial extends StatelessWidget {
  const TimerDial({
    super.key,
    required this.remainingSeconds,
    required this.progress,
    required this.cycle,
    required this.completed,
    required this.caption,
    required this.size,
  });

  final int remainingSeconds;
  final double progress;
  final int cycle;
  final bool completed;
  final String caption;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final tint = pomodoroTint(colors);

    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          color: colors.primary,
          track: tint,
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.14),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatCountdown(remainingSeconds),
                  style: AppHeadingTypography.h1.copyWith(
                    color: colors.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Semantics(
                  label: completed
                      ? 'All $pomodoroCycles cycles completed'
                      : 'Cycle $cycle of $pomodoroCycles',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 1; i <= pomodoroCycles; i++)
                        if (completed)
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: colors.primary,
                          )
                        else
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i <= cycle ? colors.primary : tint,
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  caption,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  static const _stroke = 12.0;

  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = (Offset.zero & size).deflate(_stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    canvas.drawArc(bounds, 0, 2 * pi, false, paint..color = track);
    canvas.drawArc(
      bounds,
      -pi / 2,
      2 * pi * progress,
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
