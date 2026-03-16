import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/enum/cubit_states.dart';

class AddCertificateState {
  final CubitStates state;
  final String nameCertificate;
  final String fromWhere;
  final DateTime? date;
  final File? certificateImageFile;
  final bool isLoading;
  final TextEditingController? nameCertificateController;
  final TextEditingController? fromWhereController;
  final String? errorMessage;
  final String? successMessage;
  final CertificateModel? addedCertificate;

  const AddCertificateState({
    this.state = CubitStates.initial,
    this.nameCertificate = '',
    this.fromWhere = '',
    this.date,
    this.certificateImageFile,
    this.isLoading = false,
    this.nameCertificateController,
    this.fromWhereController,
    this.errorMessage,
    this.successMessage,
    this.addedCertificate,
  });

  AddCertificateState copyWith({
    CubitStates? state,
    String? nameCertificate,
    String? fromWhere,
    DateTime? date,
    File? certificateImageFile,
    bool? isLoading,
    TextEditingController? nameCertificateController,
    TextEditingController? fromWhereController,
    String? errorMessage,
    String? successMessage,
    CertificateModel? addedCertificate,
  }) {
    return AddCertificateState(
      state: state ?? this.state,
      nameCertificate: nameCertificate ?? this.nameCertificate,
      fromWhere: fromWhere ?? this.fromWhere,
      date: date ?? this.date,
      certificateImageFile: certificateImageFile ?? this.certificateImageFile,
      isLoading: isLoading ?? this.isLoading,
      nameCertificateController:
          nameCertificateController ?? this.nameCertificateController,
      fromWhereController: fromWhereController ?? this.fromWhereController,
      errorMessage:
          errorMessage, // Intentionally not keeping the previous error message
      successMessage:
          successMessage, // Intentionally not keeping the previous success message
      addedCertificate: addedCertificate ?? this.addedCertificate,
    );
  }
}
