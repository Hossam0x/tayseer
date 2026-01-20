import 'package:equatable/equatable.dart';

class CertificateModel extends Equatable {
  final String id;
  final String nameCertificate;
  final String fromWhere;
  final DateTime date;
  final String? image;
  final String? degree; // إضافة حقل الدرجة العلمية
  final String? university; // إضافة حقل الجامعة
  final int? graduationYear; // إضافة حقل سنة التخرج

  const CertificateModel({
    required this.id,
    required this.nameCertificate,
    required this.fromWhere,
    required this.date,
    this.image,
    this.degree,
    this.university,
    this.graduationYear,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      id: json['id'] as String,
      nameCertificate: json['nameCertificate'] as String,
      fromWhere: json['fromWhere'] as String,
      date: DateTime.parse(json['date'] as String),
      image: json['image'] as String?,
      degree: json['degree'] as String?,
      university: json['university'] as String?,
      graduationYear: json['graduationYear'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameCertificate': nameCertificate,
    'fromWhere': fromWhere,
    'date': date.toIso8601String(),
    'image': image,
    'degree': degree,
    'university': university,
    'graduationYear': graduationYear,
  };

  CertificateModel copyWith({
    String? id,
    String? nameCertificate,
    String? fromWhere,
    DateTime? date,
    String? image,
    String? degree,
    String? university,
    int? graduationYear,
  }) {
    return CertificateModel(
      id: id ?? this.id,
      nameCertificate: nameCertificate ?? this.nameCertificate,
      fromWhere: fromWhere ?? this.fromWhere,
      date: date ?? this.date,
      image: image ?? this.image,
      degree: degree ?? this.degree,
      university: university ?? this.university,
      graduationYear: graduationYear ?? this.graduationYear,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nameCertificate,
    fromWhere,
    date,
    image,
    degree,
    university,
    graduationYear,
  ];
}

class CertificatesAndVideosResponse extends Equatable {
  final List<CertificateModel> certificates;
  final String? videos;
  final bool isMe;

  const CertificatesAndVideosResponse({
    required this.certificates,
    this.videos,
    required this.isMe,
  });

  factory CertificatesAndVideosResponse.fromJson(Map<String, dynamic> json) {
    final certificatesList = (json['certificates'] as List)
        .map(
          (cert) => CertificateModel.fromJson(Map<String, dynamic>.from(cert)),
        )
        .toList();

    return CertificatesAndVideosResponse(
      certificates: certificatesList,
      videos: json['videos'] as String?,
      isMe: json['isMe'] as bool,
    );
  }

  @override
  List<Object?> get props => [certificates, videos, isMe];
}
