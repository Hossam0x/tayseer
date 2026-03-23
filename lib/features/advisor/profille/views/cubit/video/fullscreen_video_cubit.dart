import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FullscreenVideoState extends Equatable {
  final bool isPlaying;
  final bool isMuted;
  final bool showControls;

  const FullscreenVideoState({
    this.isPlaying = true,
    this.isMuted = false,
    this.showControls = true,
  });

  FullscreenVideoState copyWith({
    bool? isPlaying,
    bool? isMuted,
    bool? showControls,
  }) {
    return FullscreenVideoState(
      isPlaying: isPlaying ?? this.isPlaying,
      isMuted: isMuted ?? this.isMuted,
      showControls: showControls ?? this.showControls,
    );
  }

  @override
  List<Object> get props => [isPlaying, isMuted, showControls];
}

class FullscreenVideoCubit extends Cubit<FullscreenVideoState> {
  FullscreenVideoCubit(bool initialMute)
    : super(FullscreenVideoState(isMuted: initialMute));

  void togglePlayPause() {
    emit(state.copyWith(isPlaying: !state.isPlaying));
  }

  void toggleMute() {
    emit(state.copyWith(isMuted: !state.isMuted));
  }

  void toggleControls() {
    emit(state.copyWith(showControls: !state.showControls));
  }
}
