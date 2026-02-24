// upload_post_state.dart

enum UploadPostStatus { idle, uploading, success, failure }

class UploadPostProgressState {
  final UploadPostStatus status;
  final String? errorMessage;

  const UploadPostProgressState({
    this.status = UploadPostStatus.idle,
    this.errorMessage,
  });

  UploadPostProgressState copyWith({
    UploadPostStatus? status,
    String? errorMessage,
  }) {
    return UploadPostProgressState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
