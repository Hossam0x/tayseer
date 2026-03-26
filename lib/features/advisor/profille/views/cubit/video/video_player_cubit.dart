import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoPlayerState extends Equatable {
  final bool isInitialized;
  final bool hasError;
  final bool isBuffering;
  final bool showControls;
  final bool isMuted;
  final bool isEnded;
  final bool isPlaying;

  const VideoPlayerState({
    this.isInitialized = false,
    this.hasError = false,
    this.isBuffering = false,
    this.showControls = false,
    this.isMuted = false,
    this.isEnded = false,
    this.isPlaying = false,
  });

  VideoPlayerState copyWith({
    bool? isInitialized,
    bool? hasError,
    bool? isBuffering,
    bool? showControls,
    bool? isMuted,
    bool? isEnded,
    bool? isPlaying,
  }) {
    return VideoPlayerState(
      isInitialized: isInitialized ?? this.isInitialized,
      hasError: hasError ?? this.hasError,
      isBuffering: isBuffering ?? this.isBuffering,
      showControls: showControls ?? this.showControls,
      isMuted: isMuted ?? this.isMuted,
      isEnded: isEnded ?? this.isEnded,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object> get props => [
    isInitialized,
    hasError,
    isBuffering,
    showControls,
    isMuted,
    isEnded,
    isPlaying,
  ];
}

class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  VideoPlayerCubit() : super(const VideoPlayerState());

  void setInitialized(bool value) {
    emit(state.copyWith(isInitialized: value));
  }

  void setError(bool value) {
    emit(state.copyWith(hasError: value));
  }

  void setBuffering(bool value) {
    emit(state.copyWith(isBuffering: value));
  }

  void setControls(bool value) {
    emit(state.copyWith(showControls: value));
  }

  void toggleControls() {
    emit(state.copyWith(showControls: !state.showControls));
  }

  void setMuted(bool value) {
    emit(state.copyWith(isMuted: value));
  }

  void setEnded(bool value) {
    emit(state.copyWith(isEnded: value));
  }

  void setPlaying(bool value) {
    emit(state.copyWith(isPlaying: value));
  }

  void reset() {
    emit(const VideoPlayerState());
  }
}
