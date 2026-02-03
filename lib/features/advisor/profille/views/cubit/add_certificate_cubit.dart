import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/add_certificate_state.dart';
import 'package:tayseer/my_import.dart';

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

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.date ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // ⭐ تعيين الاتجاه للتقويم
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.kprimaryColor,
                onPrimary: Colors.white,
                onSurface: AppColors.secondary800,
              ),
              textTheme: TextTheme(
                bodyMedium: TextStyle(
                  fontFamily: 'ArabicFont',
                ), // ⭐ إضافة خط عربي
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && context.mounted) {
      emit(state.copyWith(date: picked));
    }
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
        // يمكنك إظهار رسالة خطأ هنا
        return;
      }

      emit(state.copyWith(certificateImageFile: file));
    }
  }

  void removeCertificateImage() {
    emit(state.copyWith(certificateImageFile: null));
  }

  Future<void> addCertificate(BuildContext context) async {
    // ⭐ التحقق من البيانات
    if (state.nameCertificate.isEmpty) {
      _showErrorSnackBar(context, 'يرجى إدخال اسم الشهادة');
      return;
    }

    if (state.fromWhere.isEmpty) {
      _showErrorSnackBar(context, 'يرجى إدخال الجهة المصدرة');
      return;
    }

    if (state.date == null) {
      _showErrorSnackBar(context, 'يرجى اختيار سنة الحصول');
      return;
    }

    if (state.certificateImageFile == null) {
      _showErrorSnackBar(context, 'يرجى تحميل صورة الشهادة');
      return;
    }

    emit(state.copyWith(isLoading: true));

    final result = await _repository.addCertificate(
      nameCertificate: state.nameCertificate,
      fromWhere: state.fromWhere,
      date: state.date!,
      image: state.certificateImageFile, // ⭐ إرسال الصورة
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        if (context.mounted) {
          _showErrorSnackBar(context, failure.message);
        }
      },
      (response) {
        emit(state.copyWith(isLoading: false));
        if (context.mounted) {
          // ⭐ مسح النموذج بعد الإضافة الناجحة
          _clearForm();
          // ⭐ إظهار رسالة النجاح
          showSafeSnackBar(
            context: context,
            text: 'تم إضافة الشهادة بنجاح',
            isSuccess: true,
          );

          // ⭐ العودة مع تحديث البيانات
          Navigator.pop(context, true);
        }
      },
    );
  }

  void _clearForm() {
    nameCertificateController.clear();
    fromWhereController.clear();
    emit(
      AddCertificateState(
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

  void _showErrorSnackBar(BuildContext context, String message) {
    showSafeSnackBar(context: context, text: message, isError: true);
  }
}
