import 'dart:ui';
import '../../core/theme/app_colors.dart';
import 'pet_state.dart';

/// Parametric face/body description. Every field is interpolated on state change.
class PetParams {
  const PetParams({
    required this.eyeOpen,
    required this.sparkle,
    required this.browTilt,
    required this.mouthCurve,
    required this.earDroop,
    required this.tailLift,
    required this.tailSway,
    required this.headTilt,
    required this.cheek,
    required this.lean,
    required this.aura,
    required this.auraIntensity,
  });

  /// 0 = closed line, 1 = wide open.
  final double eyeOpen;

  /// 0..1 shine in the eyes.
  final double sparkle;

  /// -1 worried (inner up) .. 1 relaxed/outer up.
  final double browTilt;

  /// -1 frown .. 1 smile.
  final double mouthCurve;

  /// -1 perked up .. 1 drooped.
  final double earDroop;

  /// 0 low/curled .. 1 raised.
  final double tailLift;

  /// Idle sway amplitude in radians.
  final double tailSway;

  /// Radians.
  final double headTilt;

  /// 0..1 blush.
  final double cheek;

  /// Horizontal lean, -1..1 of body width fraction.
  final double lean;
  final Color aura;
  final double auraIntensity;

  static PetParams lerp(PetParams a, PetParams b, double t) => PetParams(
        eyeOpen: lerpDouble(a.eyeOpen, b.eyeOpen, t)!,
        sparkle: lerpDouble(a.sparkle, b.sparkle, t)!,
        browTilt: lerpDouble(a.browTilt, b.browTilt, t)!,
        mouthCurve: lerpDouble(a.mouthCurve, b.mouthCurve, t)!,
        earDroop: lerpDouble(a.earDroop, b.earDroop, t)!,
        tailLift: lerpDouble(a.tailLift, b.tailLift, t)!,
        tailSway: lerpDouble(a.tailSway, b.tailSway, t)!,
        headTilt: lerpDouble(a.headTilt, b.headTilt, t)!,
        cheek: lerpDouble(a.cheek, b.cheek, t)!,
        lean: lerpDouble(a.lean, b.lean, t)!,
        aura: Color.lerp(a.aura, b.aura, t)!,
        auraIntensity: lerpDouble(a.auraIntensity, b.auraIntensity, t)!,
      );

  /// Draft mapping (pending review). Gentle, slow, never mimics negative emotion.
  static PetParams forState(PetState s) {
    switch (s) {
      case PetState.normal:
        return const PetParams(eyeOpen: 0.85, sparkle: 0.3, browTilt: 0.2, mouthCurve: 0.3, earDroop: 0, tailLift: 0.5, tailSway: 0.12, headTilt: 0, cheek: 0.1, lean: 0, aura: AppColors.auraNeutral, auraIntensity: 0.5);
      case PetState.listening:
        return const PetParams(eyeOpen: 1, sparkle: 0.5, browTilt: 0.3, mouthCurve: 0.15, earDroop: -0.8, tailLift: 0.5, tailSway: 0.08, headTilt: 0.05, cheek: 0.1, lean: 0.05, aura: AppColors.auraNeutral, auraIntensity: 0.6);
      case PetState.thinking:
        return const PetParams(eyeOpen: 0.7, sparkle: 0.2, browTilt: 0.4, mouthCurve: 0.0, earDroop: -0.2, tailLift: 0.4, tailSway: 0.1, headTilt: 0.2, cheek: 0.05, lean: 0, aura: AppColors.auraNeutral, auraIntensity: 0.4);
      case PetState.cheerful:
        return const PetParams(eyeOpen: 1, sparkle: 1, browTilt: 0.8, mouthCurve: 0.9, earDroop: -0.5, tailLift: 1, tailSway: 0.3, headTilt: -0.05, cheek: 0.5, lean: 0, aura: AppColors.auraHappy, auraIntensity: 0.8);
      case PetState.gentle:
        return const PetParams(eyeOpen: 0.7, sparkle: 0.4, browTilt: -0.4, mouthCurve: 0.25, earDroop: 0.7, tailLift: 0.3, tailSway: 0.06, headTilt: 0.12, cheek: 0.2, lean: 0.12, aura: AppColors.auraSadness, auraIntensity: 0.7);
      case PetState.calm:
        return const PetParams(eyeOpen: 0.5, sparkle: 0.1, browTilt: 0.5, mouthCurve: 0.15, earDroop: 0.1, tailLift: 0.3, tailSway: 0.04, headTilt: 0, cheek: 0.05, lean: -0.05, aura: AppColors.auraAnger, auraIntensity: 0.55);
      case PetState.comforting:
        return const PetParams(eyeOpen: 0.75, sparkle: 0.3, browTilt: -0.2, mouthCurve: 0.3, earDroop: 0.2, tailLift: 0.2, tailSway: 0.05, headTilt: 0.06, cheek: 0.15, lean: 0.08, aura: AppColors.auraFear, auraIntensity: 0.7);
      case PetState.warm:
        return const PetParams(eyeOpen: 0.3, sparkle: 0.2, browTilt: 0.9, mouthCurve: 0.7, earDroop: 0, tailLift: 0.6, tailSway: 0.12, headTilt: 0.1, cheek: 0.8, lean: 0.1, aura: AppColors.auraLove, auraIntensity: 0.8);
      case PetState.celebrating:
        return const PetParams(eyeOpen: 1, sparkle: 1, browTilt: 0.9, mouthCurve: 1, earDroop: -0.6, tailLift: 1, tailSway: 0.35, headTilt: -0.08, cheek: 0.6, lean: 0, aura: AppColors.auraHappy, auraIntensity: 1);
    }
  }
}
