import '../features/pet/pet_state.dart';

class ChatMessage {
  const ChatMessage({required this.fromUser, required this.text, this.degraded = false});
  final bool fromUser;
  final String text;
  final bool degraded;
}

class EmotionResult {
  const EmotionResult({
    required this.label,
    required this.confidence,
    required this.scores,
    required this.appliedRule,
  });
  final String label;
  final double confidence;
  final Map<String, double> scores;
  final String appliedRule; // model | low_confidence_neutral | fallback
}

class TemaniResponse {
  const TemaniResponse({
    required this.requestId,
    required this.emotion,
    required this.petState,
    required this.reply,
    required this.safetyTriggered,
    required this.timingsMs,
    required this.degraded,
  });

  final String requestId;
  final EmotionResult? emotion;
  final PetState petState;
  final String reply;
  final bool safetyTriggered;
  final Map<String, int> timingsMs;
  final bool degraded;

  static const _rules = {'model', 'low_confidence_neutral', 'fallback'};

  /// Strict parser for the API contract. Throws [FormatException] on bad shape;
  /// callers then fall back to degraded mode.
  factory TemaniResponse.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) throw const FormatException('response is not an object');
    final reply = json['reply'];
    final requestId = json['request_id'];
    final petState = json['pet_state'];
    if (reply is! String || reply.isEmpty) throw const FormatException('reply missing');
    if (requestId is! String) throw const FormatException('request_id missing');
    if (petState is! String || !PetState.values.any((s) => s.name == petState)) {
      throw const FormatException('pet_state invalid');
    }
    EmotionResult? emotion;
    final e = json['emotion'];
    if (e != null) {
      if (e is! Map<String, dynamic>) throw const FormatException('emotion invalid');
      final label = e['label'];
      final conf = e['confidence'];
      final scores = e['scores'];
      final rule = e['applied_rule'];
      if (label is! String || conf is! num || scores is! Map || rule is! String || !_rules.contains(rule)) {
        throw const FormatException('emotion fields invalid');
      }
      if (conf < 0 || conf > 1) throw const FormatException('confidence out of range');
      emotion = EmotionResult(
        label: label,
        confidence: conf.toDouble(),
        scores: scores.map((k, v) => MapEntry(k as String, (v as num).toDouble())),
        appliedRule: rule,
      );
    }
    final safety = json['safety'];
    final timings = json['timings_ms'];
    return TemaniResponse(
      requestId: requestId,
      emotion: emotion,
      petState: PetState.fromName(petState),
      reply: reply,
      safetyTriggered: safety is Map && safety['triggered'] == true,
      timingsMs: timings is Map ? timings.map((k, v) => MapEntry(k as String, (v as num).toInt())) : const {},
      degraded: json['degraded'] == true,
    );
  }
}
