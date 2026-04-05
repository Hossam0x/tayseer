import 'package:tayseer/features/shared/profile/data/models/certificate_model.dart';
import 'package:tayseer/features/shared/profile/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/edit_certificate_state.dart';
import 'package:tayseer/my_import.dart';

class EditCertificateCubit extends Cubit<EditCertificateState> {
  final CertificatesRepository _repository;

  EditCertificateCubit(this._repository, {CertificateModel? initialCertificate})
    : super(const EditCertificateState()) {
    if (initialCertificate != null) {
      _loadCertificateData(initialCertificate);
    }
  }

  void _loadCertificateData(CertificateModel certificate) {
    emit(
      state.copyWith(
        nameCertificate: certificate.nameCertificate,
        fromWhere: certificate.fromWhere,
        date: certificate.date,
        certificateImageUrl: certificate.image,
        selectedCertificateId: certificate.id,
        clearImageFile: true,
        isImageRemoved: false,
      ),
    );
  }

  void updateNameCertificate(String value) =>
      emit(state.copyWith(nameCertificate: value.trim()));

  void updateFromWhere(String value) =>
      emit(state.copyWith(fromWhere: value.trim()));

  void updateDate(DateTime date) => emit(state.copyWith(date: date));

  Future<void> pickCertificateImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      emit(
        state.copyWith(
          certificateImageFile: File(xFile.path),
          isImageRemoved: false,
        ),
      );
    }
  }

  void removeCertificateImage() {
    emit(
      state.copyWith(
        clearImageFile: true,
        clearImageUrl: true,
        isImageRemoved: true,
      ),
    );
  }

  void selectCertificate(CertificateModel cert) {
    emit(
      state.copyWith(
        nameCertificate: cert.nameCertificate,
        fromWhere: cert.fromWhere,
        date: cert.date,
        certificateImageUrl: cert.image,
        selectedCertificateId: cert.id,
        clearImageFile: true,
        isImageRemoved: false,
      ),
    );
  }

  Future<void> addCertificate() async {
    if (state.nameCertificate.isEmpty ||
        state.fromWhere.isEmpty ||
        state.date == null) {
      emit(
        state.copyWith(
          errorMessage: 'complete_all_data',
          state: CubitStates.failure,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
        state: CubitStates.loading,
      ),
    );

    final result = await _repository.addCertificate(
      nameCertificate: state.nameCertificate,
      fromWhere: state.fromWhere,
      date: state.date!,
      image: state.certificateImageFile,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          state: CubitStates.failure,
        ),
      ),
      (response) {
        CertificateModel? addedCertificate;
        if (response['data']?['certificate'] != null) {
          addedCertificate = CertificateModel.fromJson(
            Map<String, dynamic>.from(response['data']['certificate']),
          );
        }
        emit(
          state.copyWith(
            isLoading: false,
            successMessage: 'certificateAdded',
            state: CubitStates.success,
            isNavigationSuccess: true,
            updatedCertificate: addedCertificate,
          ),
        );
      },
    );
  }

  Future<void> updateCertificate() async {
    if (state.selectedCertificateId == null) {
      emit(
        state.copyWith(
          errorMessage: 'select_certificate_error',
          state: CubitStates.failure,
        ),
      );
      return;
    }

    if (state.nameCertificate.isEmpty ||
        state.fromWhere.isEmpty ||
        state.date == null) {
      emit(
        state.copyWith(
          errorMessage: 'complete_all_data',
          state: CubitStates.failure,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
        state: CubitStates.loading,
      ),
    );

    final result = await _repository.updateCertificate(
      certificateId: state.selectedCertificateId!,
      nameCertificate: state.nameCertificate,
      fromWhere: state.fromWhere,
      date: state.date!,
      image: state.certificateImageFile,
      removeImage: state.isImageRemoved,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          state: CubitStates.failure,
        ),
      ),
      (response) {
        String? newImageUrl = state.certificateImageUrl;
        CertificateModel? updatedCertificate;

        if (response['data']?['certificate'] != null) {
          updatedCertificate = CertificateModel.fromJson(
            Map<String, dynamic>.from(response['data']['certificate']),
          );
          newImageUrl = updatedCertificate.image;
        } else if (response['data']?['image'] != null) {
          newImageUrl = response['data']['image'] as String?;
        }

        emit(
          state.copyWith(
            isLoading: false,
            certificateImageUrl: newImageUrl,
            successMessage: 'update_success',
            state: CubitStates.success,
            isNavigationSuccess: true,
            updatedCertificate: updatedCertificate,
          ),
        );
      },
    );
  }

  void clearMessages() {
    emit(
      state.copyWith(
        errorMessage: null,
        successMessage: null,
        isNavigationSuccess: false,
      ),
    );
  }
}
