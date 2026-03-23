import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/my_import.dart';

class EditCertificateState extends Equatable {
  final CubitStates state;
  final String nameCertificate;
  final String fromWhere;
  final DateTime? date;
  final File? certificateImageFile;
  final String? certificateImageUrl;
  final bool isLoading;
  final String? selectedCertificateId;
  final String? errorMessage;
  final String? successMessage;
  final bool isImageRemoved;
  final bool isNavigationSuccess;
  final CertificateModel? updatedCertificate;

  const EditCertificateState({
    this.state = CubitStates.initial,
    this.nameCertificate = '',
    this.fromWhere = '',
    this.date,
    this.certificateImageFile,
    this.certificateImageUrl,
    this.isLoading = false,
    this.selectedCertificateId,
    this.errorMessage,
    this.successMessage,
    this.isImageRemoved = false,
    this.isNavigationSuccess = false,
    this.updatedCertificate,
  });

  EditCertificateState copyWith({
    CubitStates? state,
    String? nameCertificate,
    String? fromWhere,
    DateTime? date,
    File? certificateImageFile,
    String? certificateImageUrl,
    bool? isLoading,
    String? selectedCertificateId,
    String? errorMessage,
    String? successMessage,
    bool clearImageFile = false,
    bool clearImageUrl = false,
    bool? isImageRemoved,
    bool? isNavigationSuccess,
    CertificateModel? updatedCertificate,
  }) {
    return EditCertificateState(
      state: state ?? this.state,
      nameCertificate: nameCertificate ?? this.nameCertificate,
      fromWhere: fromWhere ?? this.fromWhere,
      date: date ?? this.date,
      certificateImageFile: clearImageFile
          ? null
          : (certificateImageFile ?? this.certificateImageFile),
      certificateImageUrl: clearImageUrl
          ? null
          : (certificateImageUrl ?? this.certificateImageUrl),
      isLoading: isLoading ?? this.isLoading,
      selectedCertificateId:
          selectedCertificateId ?? this.selectedCertificateId,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isImageRemoved: isImageRemoved ?? this.isImageRemoved,
      isNavigationSuccess: isNavigationSuccess ?? false,
      updatedCertificate: updatedCertificate ?? this.updatedCertificate,
    );
  }

  @override
  List<Object?> get props => [
    state,
    nameCertificate,
    fromWhere,
    date,
    certificateImageFile,
    certificateImageUrl,
    isLoading,
    selectedCertificateId,
    errorMessage,
    successMessage,
    isImageRemoved,
    isNavigationSuccess,
    updatedCertificate,
  ];
}
