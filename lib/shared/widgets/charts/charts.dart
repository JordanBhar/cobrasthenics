import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

class AppProgressBar extends StatelessWidget {
  final double pct;
  final Color color;
  final double height;
  final double borderRadius;

  const AppProgressBar({
    super.key,
    required this.pct,
    this.color = AppColors.brand,
    this.height = 4,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Container(
            height: height,
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          FractionallySizedBox(
            widthFactor: pct.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        ],
      );
}

class RingProgress extends StatelessWidget {
  final double pct;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color bgColor;
  final Widget? child;

  const RingProgress({
    super.key,
    required this.pct,
    this.size = 52,
    this.strokeWidth = 4,
    this.color = AppColors.brand,
    this.bgColor = AppColors.elevated,
    this.child,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(
                pct: pct,
                color: color,
                bgColor: bgColor,
                strokeWidth: strokeWidth,
              ),
            ),
            if (child != null) child!,
          ],
        ),
      );
}

class _RingPainter extends CustomPainter {
  final double pct;
  final Color color;
  final Color bgColor;
  final double strokeWidth;

  _RingPainter({
    required this.pct,
    required this.color,
    required this.bgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final bgPaint = Paint()
      ..color = bgColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * pct,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.pct != pct || old.color != color;
}

class MiniBarChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height;

  const MiniBarChart({
    super.key,
    required this.values,
    this.color = AppColors.brand,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final max = values.fold<double>(1, (prev, v) => v > prev ? v : prev);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.asMap().entries.map((e) {
          final isLast = e.key == values.length - 1;
          final frac = (e.value / max).clamp(0.0, 1.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: FractionallySizedBox(
                heightFactor: frac,
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: isLast ? color : color.withValues(alpha: 0.36),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TierDotsRow extends StatelessWidget {
  final int current;
  final int total;
  final Color accent;
  final double height;

  const TierDotsRow({
    super.key,
    required this.current,
    required this.total,
    required this.accent,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(
          total,
          (i) => Expanded(
            child: Container(
              height: height,
              margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: i < current
                    ? accent
                    : i == current
                        ? accent.withValues(alpha: 0.4)
                        : AppColors.elevated,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ),
      );
}

class HeatmapGrid extends StatelessWidget {
  final List<List<int>> grid;
  final Color color;

  const HeatmapGrid({
    super.key,
    required this.grid,
    this.color = AppColors.brand,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: grid
            .map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: row
                      .map(
                        (v) => Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: v == 0
                                  ? AppColors.elevated
                                  : color.withValues(
                                      alpha: v == 1
                                          ? 0.35
                                          : v == 2
                                              ? 0.6
                                              : 1.0,
                                    ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            )
            .toList(),
      );
}
