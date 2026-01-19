import 'package:tayseer/my_import.dart';

class AddCertificateState {
  final String nameCertificate;
  final String fromWhere;
  final DateTime? date;
  final File? certificateImageFile;
  final bool isLoading;

  const AddCertificateState({
    this.nameCertificate = '',
    this.fromWhere = '',
    this.date,
    this.certificateImageFile,
    this.isLoading = false,
  });

  TextEditingController get nameCertificateController =>
      TextEditingController(text: nameCertificate);

  TextEditingController get fromWhereController =>
      TextEditingController(text: fromWhere);

  AddCertificateState copyWith({
    String? nameCertificate,
    String? fromWhere,
    DateTime? date,
    File? certificateImageFile,
    bool? isLoading,
  }) {
    return AddCertificateState(
      nameCertificate: nameCertificate ?? this.nameCertificate,
      fromWhere: fromWhere ?? this.fromWhere,
      date: date ?? this.date,
      certificateImageFile: certificateImageFile ?? this.certificateImageFile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
