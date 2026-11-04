import '../../core/game_config.dart';
import '../streak/streak_logic.dart';

enum StarSource { dailyStory, smallMoment }

class Star {
  const Star({required this.id, required this.earnedAt, required this.source, this.note});
  final int id;
  final DateTime earnedAt;
  final StarSource source;
  final String? note;
}

class JarState {
  const JarState({this.stars = const [], this.jarsCompleted = 0, this.nextId = 1, this.log = const []});

  /// Stars in the current jar.
  final List<Star> stars;

  /// Every star ever earned (used for the per-day cap and star details).
  final List<Star> log;
  final int jarsCompleted;
  final int nextId;
}

class JarUpdate {
  const JarUpdate(this.state, {this.awarded, this.jarCompleted = false});
  final JarState state;
  final Star? awarded;
  final bool jarCompleted;
}

class JarLogic {
  /// Stars are earned for telling a story, never for feeling happy.
  /// [emotionLabel] is deliberately ignored: anger == happy.
  static JarUpdate onStorySaved(JarState s, DateTime now, {String? emotionLabel}) =>
      _award(s, now, StarSource.dailyStory, null);

  static JarUpdate onSmallMoment(JarState s, DateTime now, {String? note}) =>
      _award(s, now, StarSource.smallMoment, note);

  static JarUpdate _award(JarState s, DateTime now, StarSource source, String? note) {
    final today = dateOnly(now);
    final todays = s.log.where((x) => dateOnly(x.earnedAt) == today);
    if (todays.length >= GameConfig.maxStarsPerDay || todays.any((x) => x.source == source)) {
      return JarUpdate(s);
    }
    final star = Star(id: s.nextId, earnedAt: now, source: source, note: note);
    final stars = [...s.stars, star];
    final full = stars.length >= GameConfig.jarCapacity;
    return JarUpdate(
      JarState(
        stars: full ? const [] : stars,
        jarsCompleted: s.jarsCompleted + (full ? 1 : 0),
        nextId: s.nextId + 1,
        log: [...s.log, star],
      ),
      awarded: star,
      jarCompleted: full,
    );
  }
}
