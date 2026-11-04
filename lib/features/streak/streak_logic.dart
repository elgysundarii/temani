import '../../core/game_config.dart';

DateTime dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

class StreakState {
  const StreakState({
    this.current = 0,
    this.longest = 0,
    this.lastStoryDay,
    this.storyDays = const {},
    this.restDays = const {},
  });

  final int current;
  final int longest;
  final DateTime? lastStoryDay;
  final Set<DateTime> storyDays;
  final Set<DateTime> restDays;

  /// True when the streak was reset on the last recorded story.
  /// The UI only shows a neutral welcome-back greeting; never a negative message.
  static const empty = StreakState();
}

class StreakUpdate {
  const StreakUpdate(this.state, {this.restedDay = false, this.restarted = false, this.milestone});
  final StreakState state;
  final bool restedDay;
  final bool restarted;
  final int? milestone;
}

class StreakLogic {
  /// Records a story saved at [now] (device local time). Calendar days only.
  /// A device clock that moves backwards never adds to the streak.
  static StreakUpdate recordStory(StreakState s, DateTime now) {
    final today = dateOnly(now);
    final last = s.lastStoryDay;

    if (last == null) return _commit(s, today, 1, false, restarted: false);
    final gap = today.difference(last).inDays;
    if (gap <= 0) return StreakUpdate(s); // same day or clock moved back

    if (gap == 1) return _commit(s, today, s.current + 1, false);
    if (gap == 2) {
      final missed = last.add(const Duration(days: 1));
      final canRest = s.restDays.where((r) => missed.difference(r).inDays < GameConfig.restWindowDays && missed.difference(r).inDays >= 0).length <
          GameConfig.restDaysAllowed;
      if (canRest) return _commit(s, today, s.current + 1, true, missed: missed);
    }
    return _commit(s, today, 1, false, restarted: true);
  }

  static StreakUpdate _commit(StreakState s, DateTime today, int next, bool rested,
      {DateTime? missed, bool restarted = false}) {
    final longest = next > s.longest ? next : s.longest;
    final ns = StreakState(
      current: next,
      longest: longest,
      lastStoryDay: today,
      storyDays: {...s.storyDays, today},
      restDays: missed == null ? s.restDays : {...s.restDays, missed},
    );
    return StreakUpdate(
      ns,
      restedDay: rested,
      restarted: restarted,
      milestone: GameConfig.streakMilestones.contains(next) && next != s.current ? next : null,
    );
  }

  /// Last 7 calendar days ending at [today]: story / rest / none.
  static List<DayMark> weekMarks(StreakState s, DateTime now) {
    final today = dateOnly(now);
    return [
      for (var i = 6; i >= 0; i--)
        () {
          final d = today.subtract(Duration(days: i));
          return DayMark(d, s.storyDays.contains(d) ? DayStatus.story : s.restDays.contains(d) ? DayStatus.rest : DayStatus.none);
        }(),
    ];
  }
}

enum DayStatus { story, rest, none }

class DayMark {
  const DayMark(this.day, this.status);
  final DateTime day;
  final DayStatus status;
}
