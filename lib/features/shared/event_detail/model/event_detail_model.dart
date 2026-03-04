class EventDetailModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final String duration;
  final int numberOfReservations;
  final int numberOfAttendees;
  final int numberOfTickets;
  final String advisor;
  final bool isMyEvent;
  final String startTime;
  final String endTime;
  final double latitude;
  final double longitude;
  final List<String> reservationsImages;
  final double priceAfterDiscount;
  final double priceBeforeDiscount;
  final String location;

  /// ✅ الآن أصبحت قائمة صور
  final List<String> images;

  EventDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.duration,
    required this.numberOfReservations,
    required this.numberOfAttendees,
    required this.numberOfTickets,
    required this.advisor,
    required this.isMyEvent,
    required this.startTime,
    required this.endTime,
    required this.latitude,
    required this.longitude,
    required this.reservationsImages,
    required this.priceAfterDiscount,
    required this.priceBeforeDiscount,
    required this.location,
    required this.images,
  });

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    final reservations = json['reservations'] as List<dynamic>?;

    return EventDetailModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      numberOfReservations:
          int.tryParse(json['numberOfReservations']?.toString() ?? '0') ?? 0,
      numberOfAttendees:
          int.tryParse(json['numberOfAttendees']?.toString() ?? '0') ?? 0,
      numberOfTickets:
          int.tryParse(json['numberOfTickets']?.toString() ?? '0') ?? 0,
      advisor: json['advisor']?.toString() ?? '',
      isMyEvent: json['isMyEvent'] == true,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,

      reservationsImages: reservations == null
          ? []
          : reservations
                .map(
                  (e) => (e as Map<String, dynamic>)['image']?.toString() ?? '',
                )
                .where((s) => s.isNotEmpty)
                .toList(),

      priceAfterDiscount:
          double.tryParse(json['priceAfterDiscount']?.toString() ?? '0') ?? 0.0,
      priceBeforeDiscount:
          double.tryParse(json['priceBeforeDiscount']?.toString() ?? '0') ??
          0.0,

      location: json['location']?.toString() ?? '',

      /// ✅ معالجة الصور كـ List
      images: json['images'] == null
          ? []
          : json['images'] is List
          ? List<String>.from(json['images'])
          : [json['images'].toString()],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'date': date,
    'duration': duration,
    'numberOfReservations': numberOfReservations,
    'numberOfAttendees': numberOfAttendees,
    'numberOfTickets': numberOfTickets,
    'advisor': advisor,
    'isMyEvent': isMyEvent,
    'startTime': startTime,
    'endTime': endTime,
    'latitude': latitude,
    'longitude': longitude,
    'reservations': reservationsImages.map((i) => {'image': i}).toList(),
    'priceAfterDiscount': priceAfterDiscount,
    'priceBeforeDiscount': priceBeforeDiscount,
    'location': location,

    /// ✅ الآن ترجع كـ List
    'images': images,
  };
}
