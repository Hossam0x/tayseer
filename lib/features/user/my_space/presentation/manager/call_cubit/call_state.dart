part of 'call_cubit.dart';

class CallState {
  final Map<String, String> avatarsCache;
  final SessionCancelledModel? sessionCancelledModel;
  final bool isSessionEnd;
  final String sessionId;
  final String sessionEndMessage;

  const CallState({
    this.avatarsCache = const {},
    this.sessionCancelledModel,
    this.isSessionEnd = false,
    this.sessionId = '',
    this.sessionEndMessage = '',
  });

  CallState copyWith({
    Map<String, String>? avatarsCache,
    SessionCancelledModel? sessionCancelledModel,
    bool? isSessionEnd,
    String? sessionId,
    String? sessionEndMessage,
  }) {
    return CallState(
      avatarsCache: avatarsCache ?? this.avatarsCache,
      sessionCancelledModel:
          sessionCancelledModel ?? this.sessionCancelledModel,
      isSessionEnd: isSessionEnd ?? this.isSessionEnd,
      sessionId: sessionId ?? this.sessionId,
      sessionEndMessage: sessionEndMessage ?? this.sessionEndMessage,
    );
  }

  // ✅ Reset to initial state
  CallState reset() {
    return const CallState();
  }
}
