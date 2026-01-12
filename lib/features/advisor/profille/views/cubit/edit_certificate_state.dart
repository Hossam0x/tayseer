import 'package:tayseer/my_import.dart';

class EditCertificateState {
  final String degree;
  final String university;
  final int? graduationYear;
  final File? certificateImageFile;
  final String? certificateImageUrl;
  final bool isLoading;

  const EditCertificateState({
    this.degree = '',
    this.university = '',
    this.graduationYear,
    this.certificateImageFile,
    this.certificateImageUrl,
    this.isLoading = false,
  });

  EditCertificateState copyWith({
    String? degree,
    String? university,
    int? graduationYear,
    File? certificateImageFile,
    String? certificateImageUrl,
    bool? isLoading,
  }) {
    return EditCertificateState(
      degree: degree ?? this.degree,
      university: university ?? this.university,
      graduationYear: graduationYear ?? this.graduationYear,
      certificateImageFile: certificateImageFile ?? this.certificateImageFile,
      certificateImageUrl: certificateImageUrl ?? this.certificateImageUrl,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
