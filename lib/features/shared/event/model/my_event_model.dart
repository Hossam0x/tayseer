class EventModel {
  final String id;
  final String title;
  final String date;
  final bool specialEvent;
  final String advisor;
  final String startTime;
  final int priceAfterDiscount;
  final int priceBeforeDiscount;
  final String location;
  final List<String> images; // ✅ بدل String
  final int totalReservedUsers;
  final List<ReservationModel> reservations;

  EventModel({
    required this.id,
    required this.title,
    required this.date,
    required this.specialEvent,
    required this.advisor,
    required this.startTime,
    required this.priceAfterDiscount,
    required this.priceBeforeDiscount,
    required this.location,
    required this.images, // ✅
    required this.totalReservedUsers,
    required this.reservations,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // ✅ images هندل الحالتين Array أو String
    final rawImages = json['images'];
    final List<String> parsedImages;

    if (rawImages is List) {
      parsedImages = rawImages
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (rawImages is String && rawImages.isNotEmpty) {
      parsedImages = [rawImages];
    } else {
      parsedImages = [];
    }

    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      specialEvent: json['specialEvent'] ?? false,
      advisor: json['advisor'] ?? '',
      startTime: json['startTime'] ?? '',
      priceAfterDiscount: json['priceAfterDiscount'] ?? 0,
      priceBeforeDiscount: json['priceBeforeDiscount'] ?? 0,
      location: json['location'] ?? '',
      images: parsedImages, // ✅
      totalReservedUsers: json['totalReservedUsers'] ?? 0,
      reservations: json['reservations'] != null
          ? (json['reservations'] as List)
                .map((e) => ReservationModel.fromJson(e))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'specialEvent': specialEvent,
      'advisor': advisor,
      'startTime': startTime,
      'priceAfterDiscount': priceAfterDiscount,
      'priceBeforeDiscount': priceBeforeDiscount,
      'location': location,
      'images': images, // ✅
      'totalReservedUsers': totalReservedUsers,
      'reservations': reservations.map((e) => e.toJson()).toList(),
    };
  }
}

class ReservationModel {
  final String image;

  ReservationModel({required this.image});

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(image: json['image'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'image': image};
  }
}
