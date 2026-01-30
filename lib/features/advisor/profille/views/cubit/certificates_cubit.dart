import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_state.dart';
import 'package:tayseer/my_import.dart';

class CertificatesCubit extends Cubit<CertificatesState> {
  final CertificatesRepository _certificatesRepository;
  final int _pageSize = 10;
  String? _currentAdvisorId;

  CertificatesCubit(this._certificatesRepository)
    : super(const CertificatesState());

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH CERTIFICATES AND VIDEOS
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchCertificatesAndVideos({
    String? advisorId,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;

      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _certificatesRepository.getCertificatesAndVideos(
        advisorId: advisorId,
        page: nextPage,
        limit: _pageSize,
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(isLoadingMore: false, errorMessage: failure.message),
          );
        },
        (response) {
          final updatedCertificates = [
            ...state.certificates,
            ...response.certificates,
          ];
          emit(
            state.copyWith(
              state: CubitStates.success,
              certificates: updatedCertificates,
              videoUrl: response.videos,
              isMe: response.isMe,
              currentPage: nextPage,
              hasMore: response.hasMore,
              isLoadingMore: false,
              errorMessage: null,
            ),
          );
        },
      );
    } else {
      _currentAdvisorId = advisorId;
      emit(
        state.copyWith(
          state: CubitStates.loading,
          certificates: [],
          currentPage: 1,
          hasMore: true,
          errorMessage: null,
        ),
      );

      final result = await _certificatesRepository.getCertificatesAndVideos(
        advisorId: advisorId,
        page: 1,
        limit: _pageSize,
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (response) {
          emit(
            state.copyWith(
              state: CubitStates.success,
              certificates: response.certificates,
              videoUrl: response.videos,
              isMe: response.isMe,
              currentPage: 1,
              hasMore: response.hasMore,
              errorMessage: null,
            ),
          );
        },
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 REFRESH
  // ═══════════════════════════════════════════════════════════
  Future<void> refresh({String? advisorId}) async {
    await fetchCertificatesAndVideos(advisorId: advisorId, loadMore: false);
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 LOAD MORE
  // ═══════════════════════════════════════════════════════════
  Future<void> loadMore() async {
    if (_currentAdvisorId != null) {
      await fetchCertificatesAndVideos(
        advisorId: _currentAdvisorId,
        loadMore: true,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 ADD CERTIFICATE
  // ═══════════════════════════════════════════════════════════
  void addCertificate(CertificateModel certificate) {
    final updatedCertificates = [...state.certificates, certificate];
    if (isClosed) return;
    emit(state.copyWith(certificates: updatedCertificates));
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 UPDATE CERTIFICATE
  // ═══════════════════════════════════════════════════════════
  void updateCertificate(CertificateModel updatedCertificate) {
    final updatedCertificates = state.certificates.map((cert) {
      return cert.id == updatedCertificate.id ? updatedCertificate : cert;
    }).toList();

    emit(state.copyWith(certificates: updatedCertificates));
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 DELETE CERTIFICATE
  // ═══════════════════════════════════════════════════════════
  void deleteCertificate(String certificateId) {
    final updatedCertificates = state.certificates
        .where((cert) => cert.id != certificateId)
        .toList();

    emit(state.copyWith(certificates: updatedCertificates));
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 CLEAR ERROR
  // ═══════════════════════════════════════════════════════════
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
