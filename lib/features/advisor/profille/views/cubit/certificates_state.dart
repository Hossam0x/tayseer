// features/advisor/profile/views/cubit/certificates_state.dart
import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/my_import.dart';

class CertificatesState extends Equatable {
  final CubitStates state;
  final List<CertificateModel> certificates;
  final String? videoUrl;
  final bool isMe;
  final String? errorMessage;

  const CertificatesState({
    this.state = CubitStates.initial,
    this.certificates = const [],
    this.videoUrl,
    this.isMe = false,
    this.errorMessage,
  });

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasCertificates => certificates.isNotEmpty;

  CertificatesState copyWith({
    CubitStates? state,
    List<CertificateModel>? certificates,
    String? videoUrl,
    bool? isMe,
    String? errorMessage,
  }) {
    return CertificatesState(
      state: state ?? this.state,
      certificates: certificates ?? this.certificates,
      videoUrl: videoUrl ?? this.videoUrl,
      isMe: isMe ?? this.isMe,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    state,
    certificates,
    videoUrl,
    isMe,
    errorMessage,
  ];
}
