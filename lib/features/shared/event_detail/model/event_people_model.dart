class EventPeopleModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String country;
  final String image;
  final int numberOfTicketsUserReserved;

  const EventPeopleModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.country,
    required this.image,
    required this.numberOfTicketsUserReserved,
  });

  factory EventPeopleModel.fromJson(Map<String, dynamic> json) {
    return EventPeopleModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      country: json['country'] ?? '',
      image: json['image'] ?? '',
      numberOfTicketsUserReserved:
          int.tryParse(
            json['numberOfTicketsUserReserved']?.toString() ?? '0',
          ) ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'country': country,
      'image': image,
      'numberOfTicketsUserReserved': numberOfTicketsUserReserved,
    };
  }
}
