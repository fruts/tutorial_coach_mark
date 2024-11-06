import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/clipper/rect_clipper.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';

class LightPaintRect extends CustomPainter {
  final double progress;
  final TargetPosition target;
  final Color colorShadow;
  final double opacityShadow;
  final double offset;
  final double radius;
  final BorderSide? borderSide;
  final List<Color>? gradientColorsShadow;

  LightPaintRect({
    required this.progress,
    required this.target,
    this.colorShadow = Colors.transparent,
    this.opacityShadow = 0.8,
    this.offset = 10,
    this.radius = 10,
    this.borderSide,
    this.gradientColorsShadow,
  }) : assert(opacityShadow >= 0 && opacityShadow <= 1);

  static Path _drawJustHole(
    Size canvasSize,
    double x,
    double y,
    double w,
    double h,
  ) {
    return Path()
      ..moveTo(x + w, y)
      ..lineTo(x + w, y + h)
      ..lineTo(x, y + h)
      ..lineTo(x, y)
      ..close();
  }

  static Path _drawJustRHole(
    Size canvasSize,
    double x,
    double y,
    double w,
    double h,
    double radius,
  ) {
    double diameter = radius * 2;

    return Path()
      ..moveTo(x, y + radius)
      ..arcTo(
        Rect.fromLTWH(x, y, diameter, diameter),
        pi,
        pi / 2,
        false,
      )
      ..arcTo(
        Rect.fromLTWH(x + w - diameter, y, diameter, diameter),
        3 * pi / 2,
        pi / 2,
        false,
      )
      ..arcTo(
        Rect.fromLTWH(x + w - diameter, y + h - diameter, diameter, diameter),
        0,
        pi / 2,
        false,
      )
      ..arcTo(
        Rect.fromLTWH(x, y + h - diameter, diameter, diameter),
        pi / 2,
        pi / 2,
        false,
      )
      ..lineTo(x, y + radius)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (target.offset == Offset.zero) return;

    var maxSize = max(size.width, size.height) +
        max(target.size.width, target.size.height) +
        target.getBiggerSpaceBorder(size);

    double x = -maxSize / 2 * (1 - progress) + target.offset.dx - offset / 2;

    double y = -maxSize / 2 * (1 - progress) + target.offset.dy - offset / 2;

    double w = maxSize * (1 - progress) + target.size.width + offset;

    double h = maxSize * (1 - progress) + target.size.height + offset;
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 4;

    if (gradientColorsShadow?.isNotEmpty ?? false) {
      paint.shader = SweepGradient(colors: gradientColorsShadow!).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    }

    paint.color = colorShadow.withOpacity(opacityShadow);

    canvas.drawPath(
      radius > 0
          ? RectClipper.rRectHolePath(size, x, y, w, h, radius)
          : RectClipper.rectHolePath(size, x, y, w, h),
      paint,
    );
    if (borderSide != null && borderSide?.style != BorderStyle.none) {
      canvas.drawPath(
        radius > 0
            ? _drawJustRHole(size, x, y, w, h, radius)
            : _drawJustHole(size, x, y, w, h),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = borderSide!.color
          ..strokeWidth = borderSide!.width,
      );
    }
  }

  @override
  bool shouldRepaint(LightPaintRect oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
