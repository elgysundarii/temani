import 'temani_models.dart';

/// App <-> backend boundary. The mock implements it now; a Dio client
/// calling the n8n webhook replaces it later.
abstract class TemaniApi {
  Future<TemaniResponse> send({
    required String sessionId,
    required String message,
    required List<ChatMessage> history,
  });
}
