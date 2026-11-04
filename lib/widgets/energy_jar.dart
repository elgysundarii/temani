import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/game_config.dart';
import '../features/jar/jar_logic.dart';
import 'components.dart';

class EnergyJar extends StatefulWidget {
  const EnergyJar({super.key, required this.stars, this.dropStarId, this.reduceMotion = false, this.onStarTap, this.height = 300});
  final List<Star> stars;
  final int? dropStarId;
  final bool reduceMotion;
  final void Function(Star)? onStarTap;
  final double height;

  @override
  State<EnergyJar> createState() => _EnergyJarState();
}

class _EnergyJarState extends State<EnergyJar> with TickerProviderStateMixin {
  late final AnimationController _drop = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  late final AnimationController _wobble = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  late final AnimationController _twinkle = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void initState() {
    super.initState();
    _drop.value = 1;
    _maybeDrop();
  }

  void _maybeDrop() {
    if (widget.dropStarId != null && !widget.reduceMotion) _drop.forward(from: 0);
  }

  @override
  void didUpdateWidget(EnergyJar old) {
    super.didUpdateWidget(old);
    if (old.dropStarId != widget.dropStarId) _maybeDrop();
  }

  @override
  void dispose() {
    _drop.dispose();
    _wobble.dispose();
    _twinkle.dispose();
    super.dispose();
  }

  void _touchJar() {
    HapticFeedback.lightImpact();
    if (widget.reduceMotion) return;
    _wobble.forward(from: 0);
    _twinkle.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TemaniColors>()!;
    final fill = Color.lerp(colors.jarPale, colors.jarWarm, widget.stars.length / GameConfig.jarCapacity)!;
    return Semantics(
      label: 'Toples Energi Bahagia, ${widget.stars.length} dari ${GameConfig.jarCapacity} bintang',
      child: LayoutBuilder(builder: (context, c) {
        final w = min(c.maxWidth, widget.height * 0.8);
        final h = widget.height;
        return Center(
          child: RepaintBoundary(
            child: SizedBox(
              width: w,
              height: h,
              child: AnimatedBuilder(
                animation: Listenable.merge([_drop, _wobble, _twinkle]),
                builder: (context, _) {
                  return Transform.rotate(
                    angle: jarWobble(_wobble.value),
                    child: Stack(children: [
                      Positioned.fill(
                        child: GestureDetector(onTap: _touchJar, child: CustomPaint(painter: _JarPainter(fill, widget.stars.length))),
                      ),
                      for (var i = 0; i < widget.stars.length; i++) _star(i, w, h),
                    ]),
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _star(int i, double w, double h) {
    final star = widget.stars[i];
    final slot = starSlot(i);
    final isDropping = star.id == widget.dropStarId && _drop.isAnimating;
    final t = isDropping ? Curves.bounceOut.transform(_drop.value) : 1.0;
    final y = isDropping ? lerpDouble2(-0.1, slot.dy, t) : slot.dy;
    final twinkle = 0.75 + 0.25 * sin((_twinkle.value * 2 * pi) + i);
    return Positioned(
      left: slot.dx * w - 16,
      top: y * h - 16,
      child: GestureDetector(
        onTap: () => widget.onStarTap?.call(star),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Opacity(opacity: _twinkle.isAnimating ? twinkle : 1, child: const StarWidget(size: 30, color: AppColors.yellow600)),
        ),
      ),
    );
  }
}

double lerpDouble2(double a, double b, double t) => a + (b - a) * t;

class _JarPainter extends CustomPainter {
  _JarPainter(this.fill, this.count);
  final Color fill;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final body = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.1, h * 0.14, w * 0.8, h * 0.84), Radius.circular(w * 0.18));
    // Content tint rises with star count.
    final level = 0.12 + 0.55 * (count / GameConfig.jarCapacity);
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(Rect.fromLTWH(0, h * (1 - level), w, h * level), Paint()..color = fill.withValues(alpha: 0.45));
    canvas.restore();
    canvas.drawRRect(body, Paint()..color = Colors.white.withValues(alpha: 0.35));
    canvas.drawRRect(body, Paint()..color = AppColors.yellow600..style = PaintingStyle.stroke..strokeWidth = 3);
    final lid = RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.04, w * 0.6, h * 0.11), Radius.circular(12));
    canvas.drawRRect(lid, Paint()..color = AppColors.yellow700);
    // Glass highlight.
    canvas.drawLine(Offset(w * 0.2, h * 0.3), Offset(w * 0.2, h * 0.6), Paint()..color = Colors.white..strokeWidth = 4..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_JarPainter old) => old.fill != fill || old.count != count;
}
