import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pet_params.dart';
import 'pet_renderer.dart';
import 'pet_state.dart';
import 'cat_painter.dart';

/// Shows the pet, animates idle motion and state transitions, handles touch.
/// Touch reactions never change [state] and never grant stars.
class PetStage extends StatefulWidget {
  const PetStage({
    super.key,
    required this.state,
    this.reduceMotion = false,
    this.renderer = const CatRenderer(),
    this.height = 280,
  });

  final PetState state;
  final bool reduceMotion;
  final PetRenderer renderer;
  final double height;

  @override
  State<PetStage> createState() => _PetStageState();
}

class _PetStageState extends State<PetStage> with TickerProviderStateMixin {
  late final AnimationController _idle =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  late final AnimationController _transition =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
  late final AnimationController _blink =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
  late final AnimationController _touch =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

  late PetParams _from = PetParams.forState(widget.state);
  late PetParams _to = _from;
  final _rng = Random();
  bool _purring = false;
  bool _stroking = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _scheduleBlink();
  }

  void _scheduleBlink() async {
    await Future<void>.delayed(Duration(milliseconds: 2500 + _rng.nextInt(3500)));
    if (_disposed) return;
    if (!widget.reduceMotion) {
      await _blink.forward();
      if (_disposed) return;
      await _blink.reverse();
    }
    if (!_disposed) _scheduleBlink();
  }

  @override
  void didUpdateWidget(PetStage old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      final current = PetParams.lerp(_from, _to, Curves.easeInOutCubic.transform(_transition.value));
      _from = current;
      _to = PetParams.forState(widget.state);
      if (widget.reduceMotion) {
        _transition.value = 1;
      } else {
        _transition.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _idle.dispose();
    _transition.dispose();
    _blink.dispose();
    _touch.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (widget.reduceMotion) return;
    await _blink.forward();
    if (!_disposed) await _blink.reverse();
  }

  void _onLongPressStart() {
    HapticFeedback.lightImpact();
    setState(() => _purring = true);
  }

  void _setStroking(bool v) {
    if (_stroking == v) return;
    setState(() => _stroking = v);
  }

  @override
  Widget build(BuildContext context) {
    final reduce = widget.reduceMotion || MediaQuery.of(context).disableAnimations;
    return Semantics(
      label: 'Kucing Temani, sedang ${_label(widget.state)}',
      image: true,
      child: GestureDetector(
        onTap: _onTap,
        onLongPressStart: (_) => _onLongPressStart(),
        onLongPressEnd: (_) => setState(() => _purring = false),
        onPanStart: (_) => _setStroking(true),
        onPanEnd: (_) => _setStroking(false),
        onPanCancel: () => _setStroking(false),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: Listenable.merge([_idle, _transition, _blink]),
            builder: (context, _) {
              final t = Curves.easeInOutCubic.transform(_transition.value);
              return widget.renderer.build(
                context,
                params: PetParams.lerp(_from, _to, t),
                idle: reduce ? 0 : _idle.value,
                blink: _blink.value,
                extraSquint: _stroking || _purring ? 0.6 : 0,
                purr: _purring ? 1 : 0,
                reduceMotion: reduce,
              );
            },
          ),
        ),
      ),
    );
  }

  String _label(PetState s) => switch (s) {
        PetState.normal => 'santai',
        PetState.listening => 'mendengarkan',
        PetState.thinking => 'berpikir',
        PetState.cheerful => 'ikut senang',
        PetState.gentle => 'menemani dengan lembut',
        PetState.calm => 'tenang di dekatmu',
        PetState.comforting => 'menemani dengan tenang',
        PetState.warm => 'hangat',
        PetState.celebrating => 'merayakan',
      };
}
