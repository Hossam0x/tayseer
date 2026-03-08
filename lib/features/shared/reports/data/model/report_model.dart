class ReportModel {
  final String id;
  final String reason;
  final List<ReasonDetail> reasonDetails;
  ReportModel({
    required this.id,
    required this.reason,
    required this.reasonDetails,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      reason: json['reason'] ?? '',
      reasonDetails: (json['reasonDetails'] as List<dynamic>? ?? [])
          .map((e) => ReasonDetail.fromJson(e))
          .toList(),
    );
  }
}

class ReasonDetail {
  final String id;
  final String reason;
  ReasonDetail({required this.id, required this.reason});
  factory ReasonDetail.fromJson(Map<String, dynamic> json) =>
      ReasonDetail(id: json['id'] ?? '', reason: json['reason'] ?? '');
}
