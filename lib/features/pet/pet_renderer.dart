import 'package:flutter/widgets.dart';
import 'pet_params.dart';

/// Swap point: a Rive/Lottie renderer can implement this later.
abstract class PetRenderer {
  const PetRenderer();

  /// [idle] is 0..1 looping; [blink] is 0 (open) .. 1 (closed);
  /// [extraSquint] and [purr] come from touch reactions.
  Widget build(
    BuildContext context, {
    required PetParams params,
    required double idle,
    required double blink,
    required double extraSquint,
    required double purr,
    required bool reduceMotion,
  });
}
