import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/mock_temani_api.dart';
import 'data/temani_api.dart';
import 'data/temani_models.dart';
import 'features/jar/jar_logic.dart';
import 'features/pet/pet_state.dart';
import 'features/pet/pet_state_machine.dart';
import 'features/streak/streak_logic.dart';

final apiProvider = Provider<TemaniApi>((ref) => MockTemaniApi());
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class Settings {
  const Settings({this.reduceMotion = false, this.saveHistory = true, this.onboarded = false});
  final bool reduceMotion;
  final bool saveHistory;
  final bool onboarded;
  Settings copyWith({bool? reduceMotion, bool? saveHistory, bool? onboarded}) => Settings(
        reduceMotion: reduceMotion ?? this.reduceMotion,
        saveHistory: saveHistory ?? this.saveHistory,
        onboarded: onboarded ?? this.onboarded,
      );
}

class SettingsNotifier extends Notifier<Settings> {
  @override
  Settings build() => const Settings();
  void update(Settings Function(Settings) f) => state = f(state);
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

class StoryEntry {
  const StoryEntry(this.at, this.text);
  final DateTime at;
  final String text;
}

class Progress {
  const Progress({this.streak = StreakState.empty, this.jar = const JarState(), this.history = const []});
  final StreakState streak;
  final JarState jar;
  final List<StoryEntry> history;
  Progress copyWith({StreakState? streak, JarState? jar, List<StoryEntry>? history}) =>
      Progress(streak: streak ?? this.streak, jar: jar ?? this.jar, history: history ?? this.history);
}

/// Local-only data. In-memory for now (see docs/ASSUMPTIONS.md).
class ProgressNotifier extends Notifier<Progress> {
  @override
  Progress build() => const Progress();

  void clearAll() => state = const Progress();
  void removeHistory(StoryEntry e) => state = state.copyWith(history: [...state.history]..remove(e));
  void setJar(JarState j) => state = state.copyWith(jar: j);
  void setStreak(StreakState s) => state = state.copyWith(streak: s);
  void addHistory(StoryEntry e) => state = state.copyWith(history: [e, ...state.history]);
}

final progressProvider = NotifierProvider<ProgressNotifier, Progress>(ProgressNotifier.new);

class ChatState {
  const ChatState({
    this.messages = const [],
    this.pet = PetState.normal,
    this.busy = false,
    this.lastStarId,
    this.notice,
    this.canOfferSmallMoment = false,
  });
  final List<ChatMessage> messages;
  final PetState pet;
  final bool busy;
  final int? lastStarId;
  final String? notice;
  final bool canOfferSmallMoment;

  ChatState copyWith({
    List<ChatMessage>? messages,
    PetState? pet,
    bool? busy,
    int? lastStarId,
    String? notice,
    bool clearNotice = false,
    bool? canOfferSmallMoment,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        pet: pet ?? this.pet,
        busy: busy ?? this.busy,
        lastStarId: lastStarId ?? this.lastStarId,
        notice: clearNotice ? null : (notice ?? this.notice),
        canOfferSmallMoment: canOfferSmallMoment ?? this.canOfferSmallMoment,
      );
}

class ChatNotifier extends Notifier<ChatState> {
  final _machine = PetStateMachine();
  final sessionId = DateTime.now().microsecondsSinceEpoch.toString();
  static const maxMessageLength = 1000; // TODO-VERIFY with supervisor

  @override
  ChatState build() => const ChatState();

  void _pet(PetEvent e) => state = state.copyWith(pet: _machine.send(e));

  void typing(bool isTyping) {
    if (state.busy) return;
    _pet(isTyping ? const UserTyping() : const UserStoppedTyping());
  }

  /// Returns an error code or null on success.
  String? validate(String text) {
    final t = text.trim();
    if (t.isEmpty) return 'message_empty';
    if (t.length > maxMessageLength) return 'message_too_long';
    return null;
  }

  Future<void> send(String text) async {
    if (state.busy || validate(text) != null) return;
    final message = text.trim();
    final history = state.messages.length > 6 ? state.messages.sublist(state.messages.length - 6) : state.messages;
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(fromUser: true, text: message)],
      busy: true,
      clearNotice: true,
    );
    _pet(const MessageSent());

    TemaniResponse? res;
    try {
      res = await ref.read(apiProvider).send(sessionId: sessionId, message: message, history: history);
    } catch (_) {
      res = null;
    }
    final reply = res?.reply ?? 'Maaf, aku lagi susah nyambung. Tapi aku tetap di sini dan dengerin kamu.';
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(fromUser: false, text: reply, degraded: res == null || res.degraded)],
      busy: false,
      canOfferSmallMoment: true,
    );
    _pet(ReplyArrived(res?.petState ?? PetState.listening));
    _recordStory(message, emotionLabel: res?.emotion?.label);
  }

  void _recordStory(String text, {String? emotionLabel}) {
    final now = ref.read(clockProvider)();
    final p = ref.read(progressProvider.notifier);
    final progress = ref.read(progressProvider);
    final su = StreakLogic.recordStory(progress.streak, now);
    final ju = JarLogic.onStorySaved(progress.jar, now, emotionLabel: emotionLabel);
    p.setStreak(su.state);
    p.setJar(ju.state);
    if (ref.read(settingsProvider).saveHistory) p.addHistory(StoryEntry(now, text));
    state = state.copyWith(lastStarId: ju.awarded?.id);
    if (ju.jarCompleted || su.milestone != null) {
      state = state.copyWith(notice: su.milestone != null ? 'Sudah ${su.milestone} hari bercerita berturut-turut.' : 'Satu toples penuh.');
      _pet(const CelebrationRequested());
      if (state.pet == PetState.celebrating) _finishCelebrationLater();
    }
  }

  void _finishCelebrationLater() {
    Timer(const Duration(seconds: 3), () {
      if (!ref.mounted) return;
      _pet(const CelebrationFinished());
    });
  }

  void saveSmallMoment(String? note) {
    final now = ref.read(clockProvider)();
    final progress = ref.read(progressProvider);
    final ju = JarLogic.onSmallMoment(progress.jar, now, note: note);
    ref.read(progressProvider.notifier).setJar(ju.state);
    state = state.copyWith(canOfferSmallMoment: false, lastStarId: ju.awarded?.id);
    if (ju.jarCompleted) {
      state = state.copyWith(notice: 'Satu toples penuh.');
      _pet(const CelebrationRequested());
    }
  }

  void dismissSmallMoment() => state = state.copyWith(canOfferSmallMoment: false);

  /// Called when leaving the chat. A deferred celebration may now run.
  void endConversation() {
    final before = _machine.celebrationPending;
    _pet(const ConversationEnded());
    state = state.copyWith(messages: const [], canOfferSmallMoment: false, clearNotice: true);
    if (before) _finishCelebrationLater();
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
