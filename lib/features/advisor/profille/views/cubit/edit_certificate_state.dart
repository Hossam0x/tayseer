import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/enum/cubit_states.dart'; // Ensure enum is imported

class EditCertificateState {
  final CubitStates state; // Add CubitStates
  final String nameCertificate;
  final String fromWhere;
  final DateTime? date;
  final File? certificateImageFile;
  final String? certificateImageUrl;
  final bool isLoading;
  final String? selectedCertificateId;
  final TextEditingController? nameCertificateController;
  final TextEditingController? fromWhereController;
  final String? errorMessage; // Add errorMessage
  final String? successMessage; // Add successMessage
  final bool isImageRemoved;
  final bool isNavigationSuccess; // Add helper for navigation
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
    this.nameCertificateController,
    this.fromWhereController,
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
    TextEditingController? nameCertificateController,
    TextEditingController? fromWhereController,
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
      nameCertificateController:
          nameCertificateController ?? this.nameCertificateController,
      fromWhereController: fromWhereController ?? this.fromWhereController,
      errorMessage: errorMessage, // Intentionally not keeping previous
      successMessage: successMessage, // Intentionally not keeping previous
      isImageRemoved: isImageRemoved ?? this.isImageRemoved,
      isNavigationSuccess: isNavigationSuccess ?? false,
      updatedCertificate: updatedCertificate ?? this.updatedCertificate,
    );
  }
}
