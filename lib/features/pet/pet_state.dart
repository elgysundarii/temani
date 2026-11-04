enum PetState {
  normal,
  listening,
  thinking,
  cheerful,
  gentle,
  calm,
  comforting,
  warm,
  celebrating;

  static PetState fromName(String name) =>
      PetState.values.firstWhere((s) => s.name == name, orElse: () => PetState.normal);

  /// States that answer a negative emotion; celebrating must not override them.
  bool get isNegativeEmotion =>
      this == calm || this == gentle || this == comforting;
}

/// Events that can move the pet between states.
sealed class PetEvent {
  const PetEvent();
}

class UserTyping extends PetEvent {
  const UserTyping();
}

class UserStoppedTyping extends PetEvent {
  const UserStoppedTyping();
}

class MessageSent extends PetEvent {
  const MessageSent();
}

class ReplyArrived extends PetEvent {
  const ReplyArrived(this.emotionState);
  final PetState emotionState;
}

class CelebrationRequested extends PetEvent {
  const CelebrationRequested();
}

class CelebrationFinished extends PetEvent {
  const CelebrationFinished();
}

class ConversationEnded extends PetEvent {
  const ConversationEnded();
}
