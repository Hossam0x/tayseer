import 'package:tayseer/my_import.dart';

class AddCertificateState {
  final String nameCertificate;
  final String fromWhere;
  final DateTime? date;
  final File? certificateImageFile;
  final bool isLoading;
  final TextEditingController? nameCertificateController;
  final TextEditingController? fromWhereController;

  const AddCertificateState({
    this.nameCertificate = '',
    this.fromWhere = '',
    this.date,
    this.certificateImageFile,
    this.isLoading = false,
    this.nameCertificateController,
    this.fromWhereController,
  });

  AddCertificateState copyWith({
    String? nameCertificate,
    String? fromWhere,
    DateTime? date,
    File? certificateImageFile,
    bool? isLoading,
    TextEditingController? nameCertificateController,
    TextEditingController? fromWhereController,
  }) {
    return AddCertificateState(
      nameCertificate: nameCertificate ?? this.nameCertificate,
      fromWhere: fromWhere ?? this.fromWhere,
      date: date ?? this.date,
      certificateImageFile: certificateImageFile ?? this.certificateImageFile,
      isLoading: isLoading ?? this.isLoading,
      nameCertificateController:
          nameCertificateController ?? this.nameCertificateController,
      fromWhereController: fromWhereController ?? this.fromWhereController,
    );
  }
}
