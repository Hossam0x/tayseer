import 'package:image_picker/image_picker.dart';

class CertificateModelProfile {
  final String? id;

  final String degree;
  final String university;
  final int graduationYear;

  final String? imageUrl;
  final XFile? localImageFile;

  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? uploadedBy;

  CertificateModelProfile({
    this.id,
    required this.degree,
    required this.university,
    required this.graduationYear,
    this.imageUrl,
    this.localImageFile,
    DateTime? createdAt,
    this.updatedAt,
    this.uploadedBy,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CertificateModelProfile.newCertificate({
    required String degree,
    required String university,
    required int graduationYear,
    required XFile imageFile,
    XFile? videoFile,
  }) {
    return CertificateModelProfile(
      degree: degree,
      university: university,
      graduationYear: graduationYear,
      localImageFile: imageFile,
    );
  }

  factory CertificateModelProfile.fromMap(
    Map<String, dynamic> map, {
    String? id,
  }) {
    return CertificateModelProfile(
      id: id,
      degree: map['degree'] as String? ?? '',
      university: map['university'] as String? ?? '',
      graduationYear: map['graduationYear'] as int? ?? 0,
      imageUrl: map['imageUrl'] as String?,
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString())
          : null,
      uploadedBy: map['uploadedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'degree': degree,
      'university': university,
      'graduationYear': graduationYear,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (uploadedBy != null) 'uploadedBy': uploadedBy,
    };
  }

  String get displayYear => graduationYear.toString();

  bool get hasImage => imageUrl != null || localImageFile != null;

  String? get bestImagePath {
    if (localImageFile != null) return localImageFile!.path;
    return imageUrl;
  }

  @override
  String toString() {
    return 'CertificateModelProfile(degree: $degree, university: $university, year: $graduationYear, '
        'hasImage: $hasImage, id: $id)';
  }
}
