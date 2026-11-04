import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'pet_params.dart';
import 'pet_renderer.dart';

class CatRenderer extends PetRenderer {
  const CatRenderer();

  @override
  Widget build(
    BuildContext context, {
    required PetParams params,
    required double idle,
    required double blink,
    required double extraSquint,
    required double purr,
    required bool reduceMotion,
  }) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: CatPainter(
          params: params,
          idle: idle,
          blink: blink,
          extraSquint: extraSquint,
          purr: purr,
          reduceMotion: reduceMotion,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class CatPainter extends CustomPainter {
  CatPainter({
    required this.params,
    required this.idle,
    required this.blink,
    required this.extraSquint,
    required this.purr,
    required this.reduceMotion,
  });

  final PetParams params;
  final double idle;
  final double blink;
  final double extraSquint;
  final double purr;
  final bool reduceMotion;

  static const _fur = Color(0xFFFFB84D);
  static const _furDark = Color(0xFFE59A2B);
  static const _belly = Color(0xFFFFE9BF);

  @override
  void paint(Canvas canvas, Size size) {
    final s = min(size.width, size.height);
    final motion = reduceMotion ? 0.0 : 1.0;
    final breath = sin(idle * 2 * pi) * 0.012 * s * motion;
    final shake = sin(idle * 2 * pi * 14) * purr * 0.004 * s * motion;
    canvas.save();
    canvas.translate(size.width / 2 + params.lean * s * 0.15 + shake, size.height * 0.52 + breath);

    // Aura glow.
    final aura = Paint()
      ..shader = RadialGradient(colors: [
        params.aura.withValues(alpha: 0.55 * params.auraIntensity),
        params.aura.withValues(alpha: 0),
      ]).createShader(Rect.fromCircle(center: Offset.zero, radius: s * 0.62));
    canvas.drawCircle(Offset.zero, s * 0.62, aura);

    _tail(canvas, s);
    // Body.
    final body = Paint()..color = _fur;
    canvas.drawOval(Rect.fromCenter(center: Offset(0, s * 0.27), width: s * 0.52, height: s * 0.42), body);
    canvas.drawOval(Rect.fromCenter(center: Offset(0, s * 0.31), width: s * 0.3, height: s * 0.28), Paint()..color = _belly);
    // Paws.
    for (final dx in [-0.1, 0.1]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(dx * s, s * 0.46), width: s * 0.13, height: s * 0.07), Paint()..color = _belly);
    }

    // Head.
    canvas.save();
    canvas.translate(0, -s * 0.06);
    canvas.rotate(params.headTilt);
    _ears(canvas, s);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s * 0.5, height: s * 0.42), body);
    _face(canvas, s);
    canvas.restore();
    canvas.restore();
  }

  void _tail(Canvas canvas, double s) {
    final sway = sin(idle * 2 * pi) * params.tailSway * (reduceMotion ? 0 : 1);
    final lift = params.tailLift;
    final base = Offset(s * 0.22, s * 0.36);
    final tip = Offset(s * (0.36 + 0.04 * lift) + sin(sway) * s * 0.1, s * (0.38 - 0.34 * lift) );
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..cubicTo(s * 0.38, s * 0.42, s * 0.42, s * (0.3 - 0.2 * lift), tip.dx, tip.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = _furDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.055
        ..strokeCap = StrokeCap.round,
    );
  }

  void _ears(Canvas canvas, double s) {
    final droop = params.earDroop;
    for (final side in [-1.0, 1.0]) {
      final baseX = side * s * 0.15;
      final tipX = side * s * (0.21 + 0.04 * droop);
      final tipY = -s * (0.34 - 0.12 * droop.clamp(-1, 1));
      final path = Path()
        ..moveTo(baseX - side * s * 0.1, -s * 0.12)
        ..lineTo(tipX, tipY)
        ..lineTo(baseX + side * s * 0.06, -s * 0.18)
        ..close();
      canvas.drawPath(path, Paint()..color = _fur);
      final inner = Path()
        ..moveTo(baseX - side * s * 0.05, -s * 0.15)
        ..lineTo(tipX - side * s * 0.01, tipY + s * 0.06)
        ..lineTo(baseX + side * s * 0.03, -s * 0.18)
        ..close();
      canvas.drawPath(inner, Paint()..color = AppColors.auraLove.withValues(alpha: 0.7));
    }
  }

  void _face(Canvas canvas, double s) {
    final ink = Paint()..color = AppColors.ink;
    final open = (params.eyeOpen * (1 - blink) * (1 - 0.7 * extraSquint)).clamp(0.0, 1.0);

    // Cheeks.
    final cheek = Paint()..color = AppColors.auraLove.withValues(alpha: 0.55 * params.cheek.clamp(0, 1));
    for (final side in [-1.0, 1.0]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(side * s * 0.17, s * 0.06), width: s * 0.09, height: s * 0.05), cheek);
    }

    // Eyes.
    for (final side in [-1.0, 1.0]) {
      final c = Offset(side * s * 0.1, -s * 0.01);
      if (open < 0.12) {
        final p = Path()
          ..moveTo(c.dx - s * 0.04, c.dy)
          ..quadraticBezierTo(c.dx, c.dy + s * 0.02 * (params.mouthCurve > 0.5 ? -1 : 1), c.dx + s * 0.04, c.dy);
        canvas.drawPath(p, Paint()..color = AppColors.ink..style = PaintingStyle.stroke..strokeWidth = s * 0.012..strokeCap = StrokeCap.round);
      } else {
        final h = s * 0.075 * open;
        canvas.drawOval(Rect.fromCenter(center: c, width: s * 0.06, height: h), ink);
        if (open > 0.4) {
          canvas.drawCircle(c + Offset(-s * 0.012, -h * 0.2), s * (0.008 + 0.008 * params.sparkle), Paint()..color = Colors.white);
        }
      }
      // Brow.
      final by = c.dy - s * 0.065;
      final tilt = params.browTilt * s * 0.012;
      canvas.drawLine(
        Offset(c.dx - side * s * 0.035, by + tilt * side.abs() * 1),
        Offset(c.dx + side * s * 0.035, by - tilt),
        Paint()..color = _furDark..strokeWidth = s * 0.01..strokeCap = StrokeCap.round,
      );
    }

    // Nose and mouth.
    final nose = Path()
      ..moveTo(-s * 0.016, s * 0.035)
      ..lineTo(s * 0.016, s * 0.035)
      ..lineTo(0, s * 0.05)
      ..close();
    canvas.drawPath(nose, Paint()..color = AppColors.auraLove);
    final m = params.mouthCurve * s * 0.022;
    final mouth = Path()
      ..moveTo(-s * 0.05, s * 0.07)
      ..quadraticBezierTo(-s * 0.025, s * 0.07 + m, 0, s * 0.055)
      ..quadraticBezierTo(s * 0.025, s * 0.07 + m, s * 0.05, s * 0.07);
    canvas.drawPath(mouth, Paint()..color = AppColors.ink..style = PaintingStyle.stroke..strokeWidth = s * 0.009..strokeCap = StrokeCap.round);

    // Whiskers.
    final w = Paint()..color = AppColors.inkSoft..strokeWidth = s * 0.005;
    for (final side in [-1.0, 1.0]) {
      canvas.drawLine(Offset(side * s * 0.13, s * 0.05), Offset(side * s * 0.24, s * 0.03), w);
      canvas.drawLine(Offset(side * s * 0.13, s * 0.07), Offset(side * s * 0.24, s * 0.08), w);
    }
  }

  @override
  bool shouldRepaint(CatPainter old) =>
      old.params != params || old.idle != idle || old.blink != blink || old.extraSquint != extraSquint || old.purr != purr || old.reduceMotion != reduceMotion;
}
