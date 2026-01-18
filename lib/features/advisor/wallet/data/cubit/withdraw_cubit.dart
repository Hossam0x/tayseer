import 'package:file_picker/file_picker.dart';
import 'package:tayseer/features/advisor/wallet/data/cubit/withdraw_state.dart';
import 'package:tayseer/features/advisor/wallet/data/models/withdraw_model.dart';
import 'package:tayseer/my_import.dart';

class WithdrawCubit extends Cubit<WithdrawState> {
  // final ImagePicker _picker = ImagePicker();

  WithdrawCubit() : super(const WithdrawState());

  // ثوابت النظام
  static const double minWithdrawAmount = 50.0;
  static const double withdrawFeePercentage = 0.10; // 10%

  // تحديث المبلغ المطلوب سحبه
  void updateAmount(double amount) {
    if (amount < 0) amount = 0;

    final fees = _calculateFees(amount);
    final netAmount = amount - fees;

    emit(
      state.copyWith(
        amount: amount,
        fees: fees,
        netAmount: netAmount,
        isValid: amount >= minWithdrawAmount,
      ),
    );
  }

  Future<void> addImages(List<XFile> files) async {
    final List<File> newFiles = [];
    for (var file in files) {
      newFiles.add(File(file.path));
    }

    emit(
      state.copyWith(
        images: [...state.images, ...newFiles],
        errorMessage: null,
      ),
    );
  }

  // رفع الصور من المعرض
  Future<void> pickImagesFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowCompression: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.paths.map((path) => XFile(path!)).toList();
        await addImages(files);
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'حدث خطأ أثناء رفع الصور'));
    }
  }

  // إزالة صورة
  void removeImage(int index) {
    final newImages = List<File>.from(state.images);
    newImages.removeAt(index);

    emit(state.copyWith(images: newImages));
  }

  // مسح جميع الصور
  void clearImages() {
    emit(state.copyWith(images: []));
  }

  // حساب الرسوم
  double _calculateFees(double amount) {
    return amount * withdrawFeePercentage;
  }

  // تغيير طريقة السحب
  void changeMethod(WithdrawMethod method) {
    emit(
      state.copyWith(
        method: method,
        accountNumber: method == WithdrawMethod.bankAccount
            ? 'SAXXXXXXXXXXXXXXXXXXXXX'
            : '+9665XXXXXXXXX',
      ),
    );
  }

  // تحديث رقم الحساب
  void updateAccountNumber(String accountNumber) {
    emit(state.copyWith(accountNumber: accountNumber));
  }


  // إعادة تعيين النموذج
  void reset() {
    emit(
      state.copyWith(
        amount: 0,
        fees: 0,
        netAmount: 0,
        accountNumber: '',
        errorMessage: null,
        successMessage: null,
        isValid: false,
      ),
    );
  }
}
