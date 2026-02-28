class AdvisorModel {
  final String id;
  final String name;
  final String image;
  final dynamic rate;
  final int sessions;
  final String yearsOfExperience;
  final int followers;

  AdvisorModel({
    required this.id,
    required this.name,
    required this.image,
    required this.rate,
    required this.sessions,
    required this.yearsOfExperience,
    required this.followers,
  });

  factory AdvisorModel.fromJson(Map<String, dynamic> json) {
    return AdvisorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      rate: json['rate'] ?? 0,
      sessions: json['sessions'] ?? 0,
      yearsOfExperience: json['yearsOfExperience'] ?? '0',
      followers: json['followers'] ?? 0,
    );
  }
}
