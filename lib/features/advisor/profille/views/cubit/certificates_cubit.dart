import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_state.dart';
import 'package:tayseer/my_import.dart';

class CertificatesCubit extends Cubit<CertificatesState> {
  final CertificatesRepository _certificatesRepository;

  CertificatesCubit(this._certificatesRepository)
    : super(const CertificatesState()) {
    fetchCertificatesAndVideos();
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH CERTIFICATES AND VIDEOS
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchCertificatesAndVideos() async {
    emit(state.copyWith(state: CubitStates.loading));

    final result = await _certificatesRepository.getCertificatesAndVideos();

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
            errorMessage: null,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 REFRESH
  // ═══════════════════════════════════════════════════════════
  Future<void> refresh() async {
    await fetchCertificatesAndVideos();
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
