part of 'call_cubit.dart';

class CallState {
  final Map<String, String> avatarsCache;
  final SessionCancelledModel? sessionCancelledModel;
  final bool isSessionEnd;
  final String sessionId;
  final String sessionEndMessage;
  final int callDurationSeconds;

  const CallState({
    this.avatarsCache = const {},
    this.sessionCancelledModel,
    this.isSessionEnd = false,
    this.sessionId = '',
    this.sessionEndMessage = '',
    this.callDurationSeconds = 0,
  });

  CallState copyWith({
    Map<String, String>? avatarsCache,
    SessionCancelledModel? sessionCancelledModel,
    bool? isSessionEnd,
    String? sessionId,
    String? sessionEndMessage,
    int? callDurationSeconds,
  }) {
    return CallState(
      avatarsCache: avatarsCache ?? this.avatarsCache,
      sessionCancelledModel:
          sessionCancelledModel ?? this.sessionCancelledModel,
      isSessionEnd: isSessionEnd ?? this.isSessionEnd,
      sessionId: sessionId ?? this.sessionId,
      sessionEndMessage: sessionEndMessage ?? this.sessionEndMessage,
      callDurationSeconds: callDurationSeconds ?? this.callDurationSeconds,
    );
  }

  // ✅ Reset to initial state
  CallState reset() {
    return const CallState();
  }
}
