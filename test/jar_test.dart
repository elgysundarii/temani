import 'package:flutter_test/flutter_test.dart';
import 'package:temani/features/jar/jar_logic.dart';

void main() {
  final day = DateTime(2026, 11, 1, 10);

  test('anger story earns the same as happy story', () {
    final a = JarLogic.onStorySaved(const JarState(), day, emotionLabel: 'anger');
    final h = JarLogic.onStorySaved(const JarState(), day, emotionLabel: 'happy');
    expect(a.state.stars.length, h.state.stars.length);
    expect(a.awarded!.source, h.awarded!.source);
  });

  test('only first story each day earns a star', () {
    var u = JarLogic.onStorySaved(const JarState(), day);
    u = JarLogic.onStorySaved(u.state, day.add(const Duration(hours: 3)));
    expect(u.awarded, isNull);
    expect(u.state.stars.length, 1);
  });

  test('max 2 stars per day (story + small moment)', () {
    var u = JarLogic.onStorySaved(const JarState(), day);
    u = JarLogic.onSmallMoment(u.state, day, note: 'teh hangat');
    expect(u.state.stars.length, 2);
    u = JarLogic.onSmallMoment(u.state, day);
    expect(u.awarded, isNull);
    expect(u.state.stars.length, 2);
  });

  test('jar completes at capacity and a new one starts', () {
    var s = const JarState();
    JarUpdate u = JarUpdate(s);
    for (var i = 0; i < 10; i++) {
      u = JarLogic.onStorySaved(s, DateTime(2026, 11, 1 + i, 9));
      s = u.state;
    }
    expect(u.jarCompleted, isTrue);
    expect(s.jarsCompleted, 1);
    expect(s.stars, isEmpty);
    expect(s.log.length, 10);
  });
}
