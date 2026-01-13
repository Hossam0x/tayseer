import 'package:tayseer/features/advisor/profille/data/models/certificate_model_profile.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/edit_certificate_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/year_picker_dialog.dart';
import 'package:tayseer/my_import.dart';

class EditCertificateCubit extends Cubit<EditCertificateState> {
  EditCertificateCubit() : super(const EditCertificateState());

  void initWithCertificate(CertificateModelProfile cert) {
    emit(
      state.copyWith(
        degree: cert.degree,
        university: cert.university,
        graduationYear: cert.graduationYear,
        certificateImageUrl: cert.imageUrl,
      ),
    );
  }

  void updateDegree(String value) => emit(state.copyWith(degree: value.trim()));
  void updateUniversity(String value) =>
      emit(state.copyWith(university: value.trim()));

  Future<void> pickGraduationYear(BuildContext context) async {
    final year = await showDialog<int?>(
      context: context,
      builder: (context) => YearPickerDialog(
        initialYear: state.graduationYear ?? DateTime.now().year - 10,
      ),
    );

    if (year != null && context.mounted) {
      emit(state.copyWith(graduationYear: year));
    }
  }

  Future<void> pickCertificateImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);

    if (xFile != null) {
      emit(state.copyWith(certificateImageFile: File(xFile.path)));
    }
  }

  Future<void> saveChanges(BuildContext context) async {
    if (state.degree.isEmpty ||
        state.university.isEmpty ||
        state.graduationYear == null) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات بنجاح')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }
}
