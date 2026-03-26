import 'package:equatable/equatable.dart';
import 'package:tayseer/features/shared/profile/data/models/certificate_model.dart';
import 'package:tayseer/my_import.dart';

class AddCertificateState extends Equatable {
  final CubitStates state;
  final String nameCertificate;
  final String fromWhere;
  final DateTime? date;
  final File? certificateImageFile;
  final bool isLoading;
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
      errorMessage: errorMessage,
      successMessage: successMessage,
      addedCertificate: addedCertificate ?? this.addedCertificate,
    );
  }

  @override
  List<Object?> get props => [
    state,
    nameCertificate,
    fromWhere,
    date,
    certificateImageFile,
    isLoading,
    errorMessage,
    successMessage,
    addedCertificate,
  ];
}
