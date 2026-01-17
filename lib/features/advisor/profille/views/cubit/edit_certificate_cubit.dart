import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/edit_certificate_state.dart';
import 'package:tayseer/my_import.dart';

class EditCertificateCubit extends Cubit<EditCertificateState> {
  final CertificatesRepository _repository;
  late TextEditingController nameCertificateController;
  late TextEditingController fromWhereController;

  EditCertificateCubit(
    this._repository, {
    CertificateModel? initialCertificate, // ⭐ بارامتر جديد
  }) : super(const EditCertificateState()) {
    nameCertificateController = TextEditingController();
    fromWhereController = TextEditingController();

    // ⭐ إذا كانت هناك شهادة أولية، قم بتحميل بياناتها
    if (initialCertificate != null) {
      _loadCertificateData(initialCertificate);
    }

    emit(
      state.copyWith(
        nameCertificateController: nameCertificateController,
        fromWhereController: fromWhereController,
      ),
    );
  }

  void clearForm() {
    nameCertificateController.clear();
    fromWhereController.clear();

    emit(
      EditCertificateState(
        nameCertificateController: nameCertificateController,
        fromWhereController: fromWhereController,
      ),
    );
  }

  void _loadCertificateData(CertificateModel certificate) {
    nameCertificateController.text = certificate.nameCertificate;
    fromWhereController.text = certificate.fromWhere;

    emit(
      state.copyWith(
        nameCertificate: certificate.nameCertificate,
        fromWhere: certificate.fromWhere,
        date: certificate.date,
        certificateImageUrl: certificate.image,
        selectedCertificateId: certificate.id,
        certificateImageFile: null,
      ),
    );
  }

  void updateNameCertificate(String value) =>
      emit(state.copyWith(nameCertificate: value.trim()));

  void updateFromWhere(String value) =>
      emit(state.copyWith(fromWhere: value.trim()));

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.date ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.kprimaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.secondary800,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && context.mounted) {
      emit(state.copyWith(date: picked));
    }
  }

  Future<void> pickCertificateImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      emit(state.copyWith(certificateImageFile: File(xFile.path)));
    }
  }

  void removeCertificateImage() {
    emit(state.copyWith(certificateImageFile: null, certificateImageUrl: null));
  }

  Future<void> addCertificate(BuildContext context) async {
    if (state.nameCertificate.isEmpty ||
        state.fromWhere.isEmpty ||
        state.date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: 'يرجى ملء جميع الحقول المطلوبة',
          isError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true));

    final result = await _repository.addCertificate(
      nameCertificate: state.nameCertificate,
      fromWhere: state.fromWhere,
      date: state.date!,
      image: state.certificateImageFile,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: failure.message, isError: true),
          );
        }
      },
      (response) {
        emit(state.copyWith(isLoading: false));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: 'تم إضافة الشهادة بنجاح',
              isSuccess: true,
            ),
          );
          Navigator.pop(context, true);
        }
      },
    );
  }

  // في EditCertificateCubit
  // تعديل دالة selectCertificate لتحميل البيانات بشكل صحيح
  void selectCertificate(CertificateModel cert) {
    nameCertificateController.text = cert.nameCertificate;
    fromWhereController.text = cert.fromWhere;

    emit(
      state.copyWith(
        nameCertificate: cert.nameCertificate,
        fromWhere: cert.fromWhere,
        date: cert.date,
        certificateImageUrl: cert.image,
        selectedCertificateId: cert.id,
        certificateImageFile: null,
      ),
    );
  }

  // // إضافة دالة لحذف الشهادة (اختياري)
  // Future<void> deleteCertificate(
  //   BuildContext context,
  //   String certificateId,
  // ) async {
  //   if (certificateId.isEmpty) return;

  //   emit(state.copyWith(isLoading: true));

  //   final result = await _repository.deleteCertificate(certificateId);

  //   if (isClosed) return;

  //   result.fold(
  //     (failure) {
  //       emit(state.copyWith(isLoading: false));
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           CustomSnackBar(context, text: failure.message, isError: true),
  //         );
  //       }
  //     },
  //     (response) {
  //       emit(state.copyWith(isLoading: false));
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           CustomSnackBar(
  //             context,
  //             text: 'تم حذف الشهادة بنجاح',
  //             isSuccess: true,
  //           ),
  //         );
  //         Navigator.pop(context, true);
  //       }
  //     },
  //   );
  // }

  Future<void> updateCertificate(BuildContext context) async {
    if (state.selectedCertificateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: 'لم يتم تحديد شهادة للتحديث',
          isError: true,
        ),
      );
      return;
    }

    if (state.nameCertificate.isEmpty ||
        state.fromWhere.isEmpty ||
        state.date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: 'يرجى ملء جميع الحقول المطلوبة',
          isError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true));

    final result = await _repository.updateCertificate(
      certificateId: state.selectedCertificateId!,
      nameCertificate: state.nameCertificate,
      fromWhere: state.fromWhere,
      date: state.date!,
      image: state.certificateImageFile,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: failure.message, isError: true),
          );
        }
      },
      (response) {
        emit(state.copyWith(isLoading: false));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: 'تم تحديث الشهادة بنجاح',
              isSuccess: true,
            ),
          );
          Navigator.pop(context, true);
        }
      },
    );
  }

  @override
  Future<void> close() {
    nameCertificateController.dispose();
    fromWhereController.dispose();
    return super.close();
  }
}
