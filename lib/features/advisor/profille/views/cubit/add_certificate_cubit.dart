import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/add_certificate_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/enum/cubit_states.dart';

class AddCertificateCubit extends Cubit<AddCertificateState> {
  final CertificatesRepository _repository;

  late TextEditingController nameCertificateController;
  late TextEditingController fromWhereController;

  AddCertificateCubit(this._repository) : super(const AddCertificateState()) {
    nameCertificateController = TextEditingController();
    fromWhereController = TextEditingController();
    emit(
      state.copyWith(
        nameCertificateController: nameCertificateController,
        fromWhereController: fromWhereController,
      ),
    );
  }

  void updateNameCertificate(String value) {
    emit(state.copyWith(nameCertificate: value));
  }

  void updateFromWhere(String value) {
    emit(state.copyWith(fromWhere: value));
  }

  void updateDate(DateTime date) {
    emit(state.copyWith(date: date));
  }

  Future<void> pickCertificateImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // ⭐ تقليل الجودة لتقليل الحجم
      maxWidth: 1200, // ⭐ تحديد أقصى عرض
    );

    if (xFile != null) {
      final file = File(xFile.path);
      final fileSize = await file.length();

      // ⭐ التحقق من حجم الملف (مثال: 5 ميجابايت كحد أقصى)
      if (fileSize > 5 * 1024 * 1024) {
        emit(state.copyWith(errorMessage: 'حجم الملف كبير جداً'));
        return;
      }

      emit(state.copyWith(certificateImageFile: file));
    }
  }

  void removeCertificateImage() {
    emit(state.copyWith(certificateImageFile: null));
  }

  Future<void> addCertificate() async {
    // ⭐ التحقق من البيانات
    if (state.nameCertificate.isEmpty) {
      emit(state.copyWith(errorMessage: 'يرجى إدخال اسم الشهادة'));
      return;
    }

    if (state.fromWhere.isEmpty) {
      emit(state.copyWith(errorMessage: 'يرجى إدخال الجهة المصدرة'));
      return;
    }

    if (state.date == null) {
      emit(state.copyWith(errorMessage: 'يرجى اختيار سنة الحصول'));
      return;
    }

    if (state.certificateImageFile == null) {
      emit(state.copyWith(errorMessage: 'يرجى تحميل صورة الشهادة'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _repository.addCertificate(
      nameCertificate: state.nameCertificate,
      fromWhere: state.fromWhere,
      date: state.date!,
      image: state.certificateImageFile, // ⭐ إرسال الصورة
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            state: CubitStates.failure,
          ),
        );
      },
      (response) {
        // ⭐ مسح النموذج بعد الإضافة الناجحة
        _clearForm();

        // Extract certificate from response
        CertificateModel? addedCertificate;
        if (response['data'] != null &&
            response['data']['certificate'] != null) {
          addedCertificate = CertificateModel.fromJson(
            Map<String, dynamic>.from(response['data']['certificate']),
          );
        }

        emit(
          state.copyWith(
            isLoading: false,
            successMessage: 'تم إضافة الشهادة بنجاح',
            state: CubitStates.success,
            addedCertificate: addedCertificate,
          ),
        );
      },
    );
  }

  void _clearForm() {
    nameCertificateController.clear();
    fromWhereController.clear();
    emit(
      state.copyWith(
        nameCertificate: '',
        fromWhere: '',
        date: null,
        certificateImageFile: null,
        nameCertificateController: nameCertificateController,
        fromWhereController: fromWhereController,
      ),
    );
  }

  @override
  Future<void> close() {
    nameCertificateController.dispose();
    fromWhereController.dispose();
    return super.close();
  }

  void clearMessage() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }
}
