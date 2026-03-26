import 'package:equatable/equatable.dart';
import 'package:tayseer/features/shared/profile/data/models/certificate_model.dart';
import 'package:tayseer/my_import.dart';

class CertificatesState extends Equatable {
  final CubitStates state;
  final List<CertificateModel> certificates;
  final String? videoUrl;
  final bool isMe;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool hasLoadedOnce; // ⭐ Flag للتحقق من أول تحميل

  const CertificatesState({
    this.state = CubitStates.initial,
    this.certificates = const [],
    this.videoUrl,
    this.isMe = false,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.hasLoadedOnce = false, // ⭐ افتراضي false
  });

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasCertificates => certificates.isNotEmpty;

  CertificatesState copyWith({
    CubitStates? state,
    List<CertificateModel>? certificates,
    String? videoUrl,
    bool? isMe,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasLoadedOnce, // ⭐ إضافة parameter
  }) {
    return CertificatesState(
      state: state ?? this.state,
      certificates: certificates ?? this.certificates,
      videoUrl: videoUrl ?? this.videoUrl,
      isMe: isMe ?? this.isMe,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce, // ⭐
    );
  }

  @override
  List<Object?> get props => [
    state,
    certificates,
    videoUrl,
    isMe,
    errorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
    hasLoadedOnce, // ⭐
  ];
}
