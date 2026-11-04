import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../features/pet/pet_state.dart';
import 'temani_api.dart';
import 'temani_models.dart';

/// Offline stand-in for n8n + emotion service + LLM. Keyword stub only;
/// results are NOT model output.
class MockTemaniApi implements TemaniApi {
  MockTemaniApi({this.latency = const Duration(milliseconds: 1100), this.threshold = 0.5});

  final Duration latency;
  final double threshold; // TODO-VERIFY: placeholder until the supervisor decides.
  final _rng = Random();
  Map<String, List<String>>? _replies;
  final Map<PetState, String> _last = {};

  // Draft keywords, to be reviewed. Kept small on purpose.
  static const _keywords = {
    'anger': ['marah', 'kesal', 'benci', 'emosi', 'sebal', 'dongkol'],
    'sadness': ['sedih', 'nangis', 'kecewa', 'sepi', 'capek', 'lelah', 'kangen'],
    'fear': ['takut', 'cemas', 'khawatir', 'gelisah', 'panik', 'deg-degan'],
    'happy': ['senang', 'bahagia', 'seneng', 'lega', 'asik', 'gembira', 'berhasil'],
    'love': ['sayang', 'cinta', 'rindu', 'hangat', 'terima kasih', 'bersyukur'],
  };
  static const labelToState = {
    'anger': PetState.calm,
    'sadness': PetState.gentle,
    'fear': PetState.comforting,
    'happy': PetState.cheerful,
    'love': PetState.warm,
    'neutral': PetState.normal,
  };
  // Draft crisis keywords. TODO-VERIFY: must be reviewed by a psychology expert.
  static const _crisis = ['bunuh diri', 'mengakhiri hidup', 'menyakiti diri', 'ingin mati', 'pengen mati'];

  static const safetyReply =
      'Terima kasih sudah jujur soal perasaanmu. Kedengarannya ini berat sekali. '
      'Kamu tidak harus menghadapinya sendirian: coba hubungi orang yang kamu percaya, '
      'atau tenaga profesional di dekatmu. Aku di sini menemani, tapi aku bukan pengganti bantuan profesional.';

  @override
  Future<TemaniResponse> send({
    required String sessionId,
    required String message,
    required List<ChatMessage> history,
  }) async {
    final sw = Stopwatch()..start();
    await Future<void>.delayed(latency);
    final text = message.toLowerCase();
    final crisis = _crisis.any(text.contains);

    final scores = {for (final k in _keywords.keys) k: 0.04};
    _keywords.forEach((label, words) {
      final hits = words.where(text.contains).length;
      if (hits > 0) scores[label] = (0.55 + 0.15 * hits).clamp(0.0, 0.95);
    });
    final top = scores.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final belowThreshold = top.value < threshold;
    final label = belowThreshold ? 'neutral' : top.key;
    final state = labelToState[label]!;

    final String reply;
    if (crisis) {
      reply = safetyReply;
    } else {
      reply = await _pick(state);
    }
    return TemaniResponse(
      requestId: '${DateTime.now().microsecondsSinceEpoch}',
      emotion: EmotionResult(
        label: label,
        confidence: top.value,
        scores: scores,
        appliedRule: belowThreshold ? 'low_confidence_neutral' : 'model',
      ),
      petState: crisis ? PetState.comforting : state,
      reply: reply,
      safetyTriggered: crisis,
      timingsMs: {'emotion': 5, 'llm': latency.inMilliseconds, 'total_server': sw.elapsedMilliseconds},
      degraded: false,
    );
  }

  Future<String> _pick(PetState state) async {
    _replies ??= (jsonDecode(await rootBundle.loadString('assets/config/fallback_replies.json'))
            as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, List<String>.from(v as List)));
    final list = _replies![state.name] ?? _replies!['normal']!;
    String choice;
    do {
      choice = list[_rng.nextInt(list.length)];
    } while (list.length > 1 && choice == _last[state]);
    _last[state] = choice;
    return choice;
  }
}
