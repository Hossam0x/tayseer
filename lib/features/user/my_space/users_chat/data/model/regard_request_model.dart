class RegardRequestModel {
  final String id;
  final String message;
  final String status;
  final DateTime? createdAt;
  final RegardSenderModel sender;

  RegardRequestModel({
    required this.id,
    required this.message,
    required this.status,
    this.createdAt,
    required this.sender,
  });

  factory RegardRequestModel.fromJson(Map<String, dynamic> json) {
    return RegardRequestModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      sender: RegardSenderModel.fromJson(
        json['sender'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class RegardSenderModel {
  final String id;
  final String name;
  final String? image;

  RegardSenderModel({
    required this.id,
    required this.name,
    this.image,
  });

  factory RegardSenderModel.fromJson(Map<String, dynamic> json) {
    return RegardSenderModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }
}
