import 'pet_state.dart';

/// All pet transitions live in [next]. Keep it the single place to explain.
///
/// Table:
///   any non-thinking      + UserTyping        -> listening
///   listening             + UserStoppedTyping -> previous resting state
///   any                   + MessageSent       -> thinking
///   thinking              + ReplyArrived(s)   -> s (emotion state)
///   resting, not negative + CelebrationRequested -> celebrating
///   negative emotion      + CelebrationRequested -> unchanged (deferred)
///   celebrating           + CelebrationFinished -> normal
///   any                   + ConversationEnded -> normal (pending celebration may run)
class PetStateMachine {
  PetStateMachine([this.state = PetState.normal]);

  PetState state;
  PetState _resting = PetState.normal;
  bool _celebrationPending = false;

  bool get celebrationPending => _celebrationPending;

  PetState send(PetEvent event) {
    state = next(event);
    return state;
  }

  PetState next(PetEvent event) {
    switch (event) {
      case UserTyping():
        if (state == PetState.thinking || state == PetState.celebrating) return state;
        if (state != PetState.listening) _resting = state;
        return PetState.listening;
      case UserStoppedTyping():
        return state == PetState.listening ? _resting : state;
      case MessageSent():
        return PetState.thinking;
      case ReplyArrived(:final emotionState):
        _resting = emotionState;
        return emotionState;
      case CelebrationRequested():
        if (state.isNegativeEmotion || state == PetState.thinking || state == PetState.listening) {
          _celebrationPending = true;
          return state;
        }
        return PetState.celebrating;
      case CelebrationFinished():
        _resting = PetState.normal;
        return state == PetState.celebrating ? PetState.normal : state;
      case ConversationEnded():
        _resting = PetState.normal;
        if (_celebrationPending) {
          _celebrationPending = false;
          return PetState.celebrating;
        }
        return PetState.normal;
    }
  }
}
