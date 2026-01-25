class TimeRangeModel {
  final String from;
  final String to;

  TimeRangeModel({required this.from, required this.to});

  factory TimeRangeModel.fromJson(Map<String, dynamic> json) {
    return TimeRangeModel(from: json['from'] ?? '', to: json['to'] ?? '');
  }

  // ✅ أضف copyWith
  TimeRangeModel copyWith({String? from, String? to}) {
    return TimeRangeModel(from: from ?? this.from, to: to ?? this.to);
  }
}
