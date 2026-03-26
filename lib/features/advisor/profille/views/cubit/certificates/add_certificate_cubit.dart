import 'package:tayseer/features/shared/profile/data/models/certificate_model.dart';
import 'package:tayseer/features/shared/profile/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/add_certificate_state.dart';
import 'package:tayseer/my_import.dart';

class AddCertificateCubit extends Cubit<AddCertificateState> {
  final CertificatesRepository _repository;

  AddCertificateCubit(this._repository) : super(const AddCertificateState());

  void updateNameCertificate(String value) =>
      emit(state.copyWith(nameCertificate: value));

  void updateFromWhere(String value) => emit(state.copyWith(fromWhere: value));

  void updateDate(DateTime date) => emit(state.copyWith(date: date));

  Future<void> pickCertificateImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (xFile != null) {
      final file = File(xFile.path);
      final fileSize = await file.length();

      if (fileSize > 5 * 1024 * 1024) {
        emit(state.copyWith(errorMessage: 'file_too_large'));
        return;
      }

      emit(state.copyWith(certificateImageFile: file));
    }
  }

  void removeCertificateImage() =>
      emit(state.copyWith(certificateImageFile: null));

  Future<void> addCertificate() async {
    if (state.nameCertificate.isEmpty) {
      emit(state.copyWith(errorMessage: 'enter_certificate_name'));
      return;
    }
    if (state.fromWhere.isEmpty) {
      emit(state.copyWith(errorMessage: 'enter_issuing_entity'));
      return;
    }
    if (state.date == null) {
      emit(state.copyWith(errorMessage: 'choose_year'));
      return;
    }
    if (state.certificateImageFile == null) {
      emit(state.copyWith(errorMessage: 'upload_certificate_image'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

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
            successMessage: 'certificate_added_success',
            state: CubitStates.success,
            addedCertificate: addedCertificate,
          ),
        );
      },
    );
  }

  void clearMessage() =>
      emit(state.copyWith(errorMessage: null, successMessage: null));
}
