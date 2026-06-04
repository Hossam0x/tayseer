part of 'call_cubit.dart';

class CallState {
  final Map<String, String> avatarsCache;
  final SessionCancelledModel? sessionCancelledModel;
  final bool isSessionEnd;
  final String sessionId;
  final String sessionEndMessage;
  final int callDurationSeconds;

  // ✅ Zego credentials fetch state
  final CubitStates zegoCredentialsState;
  final int? zegoAppId;
  final String? zegoAppSign;
  final String? zegoErrorMessage;

  const CallState({
    this.avatarsCache = const {},
    this.sessionCancelledModel,
    this.isSessionEnd = false,
    this.sessionId = '',
    this.sessionEndMessage = '',
    this.callDurationSeconds = 0,
    this.zegoCredentialsState = CubitStates.initial,
    this.zegoAppId,
    this.zegoAppSign,
    this.zegoErrorMessage,
  });

  CallState copyWith({
    Map<String, String>? avatarsCache,
    SessionCancelledModel? sessionCancelledModel,
    bool? isSessionEnd,
    String? sessionId,
    String? sessionEndMessage,
    int? callDurationSeconds,
    CubitStates? zegoCredentialsState,
    int? zegoAppId,
    String? zegoAppSign,
    String? zegoErrorMessage,
  }) {
    return CallState(
      avatarsCache: avatarsCache ?? this.avatarsCache,
      sessionCancelledModel:
          sessionCancelledModel ?? this.sessionCancelledModel,
      isSessionEnd: isSessionEnd ?? this.isSessionEnd,
      sessionId: sessionId ?? this.sessionId,
      sessionEndMessage: sessionEndMessage ?? this.sessionEndMessage,
      callDurationSeconds: callDurationSeconds ?? this.callDurationSeconds,
      zegoCredentialsState: zegoCredentialsState ?? this.zegoCredentialsState,
      zegoAppId: zegoAppId ?? this.zegoAppId,
      zegoAppSign: zegoAppSign ?? this.zegoAppSign,
      zegoErrorMessage: zegoErrorMessage ?? this.zegoErrorMessage,
    );
  }

  // ✅ Reset to initial state
  CallState reset() {
    return const CallState();
  }
}
