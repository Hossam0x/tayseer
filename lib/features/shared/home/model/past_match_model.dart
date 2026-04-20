class PastMatchesResponse {
  final bool? success;
  final String? message;
  final PastMatchesData? data;

  PastMatchesResponse({this.success, this.message, this.data});

  factory PastMatchesResponse.fromJson(Map<String, dynamic> json) {
    return PastMatchesResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? PastMatchesData.fromJson(json['data']) : null,
    );
  }
}

class PastMatchesData {
  final List<PastMatchModel>? data;

  PastMatchesData({this.data});

  factory PastMatchesData.fromJson(Map<String, dynamic> json) {
    return PastMatchesData(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => PastMatchModel.fromJson(i)).toList()
          : null,
    );
  }
}

class PastMatchModel {
  final String? id;
  final String? name;
  final int? matchRate;
  final String? image;

  PastMatchModel({this.id, this.name, this.matchRate, this.image});

  factory PastMatchModel.fromJson(Map<String, dynamic> json) {
    return PastMatchModel(
      id: json['id'],
      name: json['name'],
      matchRate: json['matchRate'],
      image: json['image'], // Added image if available in reality or for UI
    );
  }
}
