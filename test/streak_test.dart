import 'package:flutter_test/flutter_test.dart';
import 'package:temani/features/streak/streak_logic.dart';

StreakState run(List<DateTime> times) {
  var s = StreakState.empty;
  for (final t in times) {
    s = StreakLogic.recordStory(s, t).state;
  }
  return s;
}

void main() {
  final d1 = DateTime(2026, 11, 1, 10);

  test('first story = 1; same day does not add', () {
    expect(run([d1]).current, 1);
    expect(run([d1, DateTime(2026, 11, 1, 22)]).current, 1);
  });

  test('consecutive days add', () {
    expect(run([d1, DateTime(2026, 11, 2, 9), DateTime(2026, 11, 3, 9)]).current, 3);
  });

  test('midnight boundary 23:59 -> 00:01 counts as next day', () {
    expect(run([DateTime(2026, 11, 1, 23, 59), DateTime(2026, 11, 2, 0, 1)]).current, 2);
  });

  test('one missed day is a rest day, streak continues', () {
    final u = StreakLogic.recordStory(run([d1]), DateTime(2026, 11, 3, 9));
    expect(u.restedDay, isTrue);
    expect(u.state.current, 2);
  });

  test('second rest inside 7 days breaks the streak', () {
    // rest on Nov 2 (story Nov 1, 3), missing Nov 4 again -> within window
    final s = run([d1, DateTime(2026, 11, 3, 9)]);
    final u = StreakLogic.recordStory(s, DateTime(2026, 11, 5, 9));
    expect(u.restarted, isTrue);
    expect(u.state.current, 1);
    expect(u.state.longest, 2); // record kept
  });

  test('rest allowed exactly 7 days after previous rest', () {
    // rest day Nov 2; missed Nov 9 is 7 days later -> allowed
    var s = run([d1, DateTime(2026, 11, 3), DateTime(2026, 11, 4), DateTime(2026, 11, 5), DateTime(2026, 11, 6), DateTime(2026, 11, 7), DateTime(2026, 11, 8)]);
    expect(s.restDays.length, 1);
    final u = StreakLogic.recordStory(s, DateTime(2026, 11, 10));
    expect(u.restedDay, isTrue);
    // and 6 days later is blocked
    s = run([d1, DateTime(2026, 11, 3), DateTime(2026, 11, 4), DateTime(2026, 11, 5), DateTime(2026, 11, 6), DateTime(2026, 11, 7)]);
    final blocked = StreakLogic.recordStory(s, DateTime(2026, 11, 9));
    expect(blocked.restarted, isTrue);
  });

  test('gap of 3+ days restarts at 1, no rest', () {
    final u = StreakLogic.recordStory(run([d1]), DateTime(2026, 11, 5));
    expect(u.restarted, isTrue);
    expect(u.state.current, 1);
  });

  test('device clock moving backwards never adds', () {
    final s = run([d1, DateTime(2026, 11, 2)]);
    final u = StreakLogic.recordStory(s, DateTime(2026, 10, 30));
    expect(u.state.current, 2);
    expect(u.state.lastStoryDay, s.lastStoryDay);
  });

  test('fresh install after data loss starts from 1', () {
    expect(run([DateTime(2026, 12, 1)]).current, 1);
  });

  test('milestone reported at 3', () {
    var s = run([d1, DateTime(2026, 11, 2)]);
    expect(StreakLogic.recordStory(s, DateTime(2026, 11, 3)).milestone, 3);
  });
}
