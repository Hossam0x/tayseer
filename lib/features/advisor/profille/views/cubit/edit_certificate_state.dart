import 'package:tayseer/my_import.dart';

class EditCertificateState {
  final String nameCertificate;
  final String fromWhere;
  final DateTime? date;
  final File? certificateImageFile;
  final String? certificateImageUrl;
  final bool isLoading;
  final String? selectedCertificateId;
  final TextEditingController? nameCertificateController; // ⭐ أضف
  final TextEditingController? fromWhereController; // ⭐ أضف

  const EditCertificateState({
    this.nameCertificate = '',
    this.fromWhere = '',
    this.date,
    this.certificateImageFile,
    this.certificateImageUrl,
    this.isLoading = false,
    this.selectedCertificateId,
    this.nameCertificateController,
    this.fromWhereController,
  });

  EditCertificateState copyWith({
    String? nameCertificate,
    String? fromWhere,
    DateTime? date,
    File? certificateImageFile,
    String? certificateImageUrl,
    bool? isLoading,
    String? selectedCertificateId,
    TextEditingController? nameCertificateController,
    TextEditingController? fromWhereController,
  }) {
    return EditCertificateState(
      nameCertificate: nameCertificate ?? this.nameCertificate,
      fromWhere: fromWhere ?? this.fromWhere,
      date: date ?? this.date,
      certificateImageFile: certificateImageFile ?? this.certificateImageFile,
      certificateImageUrl: certificateImageUrl ?? this.certificateImageUrl,
      isLoading: isLoading ?? this.isLoading,
      selectedCertificateId:
          selectedCertificateId ?? this.selectedCertificateId,
      nameCertificateController:
          nameCertificateController ?? this.nameCertificateController,
      fromWhereController: fromWhereController ?? this.fromWhereController,
    );
  }
}
