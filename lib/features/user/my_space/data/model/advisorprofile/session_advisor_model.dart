class SessionAdvisorModel {
  final String id;
  final String name;
  final String userName;
  final String image;

  SessionAdvisorModel({
    required this.id,
    required this.name,
    required this.userName,
    required this.image,
  });

  factory SessionAdvisorModel.fromJson(Map<String, dynamic> json) {
    return SessionAdvisorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userName: json['userName'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
