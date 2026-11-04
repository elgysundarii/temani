import 'package:flutter_test/flutter_test.dart';
import 'package:temani/features/pet/pet_state.dart';
import 'package:temani/features/pet/pet_state_machine.dart';

void main() {
  test('typing -> listening, stop restores', () {
    final m = PetStateMachine();
    expect(m.send(const UserTyping()), PetState.listening);
    expect(m.send(const UserStoppedTyping()), PetState.normal);
  });

  test('send -> thinking -> emotion state', () {
    final m = PetStateMachine();
    expect(m.send(const MessageSent()), PetState.thinking);
    expect(m.send(const ReplyArrived(PetState.gentle)), PetState.gentle);
  });

  test('celebrating does not override negative emotion; deferred', () {
    final m = PetStateMachine(PetState.calm);
    expect(m.send(const CelebrationRequested()), PetState.calm);
    expect(m.celebrationPending, isTrue);
    expect(m.send(const ConversationEnded()), PetState.celebrating);
    expect(m.send(const CelebrationFinished()), PetState.normal);
  });

  test('celebrating allowed on positive state', () {
    final m = PetStateMachine(PetState.cheerful);
    expect(m.send(const CelebrationRequested()), PetState.celebrating);
  });

  test('typing during thinking keeps thinking', () {
    final m = PetStateMachine()..send(const MessageSent());
    expect(m.send(const UserTyping()), PetState.thinking);
  });
}
