import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:temani/data/temani_models.dart';
import 'package:temani/features/pet/pet_state.dart';

const sample = '''
{
  "request_id": "uuid-v4",
  "emotion": {"label": "sadness", "confidence": 0.82,
    "scores": {"anger": 0.03, "fear": 0.05, "happy": 0.02, "love": 0.08, "sadness": 0.82},
    "applied_rule": "model"},
  "pet_state": "gentle",
  "reply": "Kedengarannya hari ini berat banget ya...",
  "safety": {"triggered": false},
  "timings_ms": {"emotion": 210, "llm": 1450, "total_server": 1720},
  "degraded": false
}''';

void main() {
  test('parses the contract example', () {
    final r = TemaniResponse.fromJson(jsonDecode(sample));
    expect(r.petState, PetState.gentle);
    expect(r.emotion!.label, 'sadness');
    expect(r.timingsMs['llm'], 1450);
    expect(r.degraded, isFalse);
  });

  test('rejects malformed responses', () {
    expect(() => TemaniResponse.fromJson({'reply': 'x'}), throwsFormatException);
    expect(() => TemaniResponse.fromJson('nope'), throwsFormatException);
    final bad = jsonDecode(sample) as Map<String, dynamic>..['pet_state'] = 'angry';
    expect(() => TemaniResponse.fromJson(bad), throwsFormatException);
  });
}
