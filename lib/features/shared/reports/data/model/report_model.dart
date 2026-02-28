class ReportModel {
  final String id;
  final String reason;
  final List<String> reasonDetails;
  ReportModel({
    required this.id,
    required this.reason,
    required this.reasonDetails,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      reason: json['reason'] ?? '',
      reasonDetails: List<String>.from(json['reasonDetails'] ?? []),
    );
  }
}
