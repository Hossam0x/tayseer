class EventDetailModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final int numberOfReservations;
  final int numberOfTickets;
  final String advisor;
  final String startTime;
  final String endTime;
  final double latitude;
  final double longitude;
  final List<String> reservationsImages;
  final double priceAfterDiscount;
  final double priceBeforeDiscount;
  final String location;
  final String images;

  /// 🆕 Added duration
  final String duration;

  EventDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.numberOfReservations,
    required this.numberOfTickets,
    required this.advisor,
    required this.startTime,
    required this.endTime,
    required this.latitude,
    required this.longitude,
    required this.reservationsImages,
    required this.priceAfterDiscount,
    required this.priceBeforeDiscount,
    required this.location,
    required this.images,
    required this.duration,
  });

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    final reservations = json['reservations'] as List<dynamic>?;

    /// 🧮 حساب الديوريشن
    final start = json['startTime']?.toString() ?? '';
    final end = json['endTime']?.toString() ?? '';
    String durationStr = '';

    try {
      if (start.isNotEmpty && end.isNotEmpty) {
        final startParts = start.split(':');
        final endParts = end.split(':');

        final startDt = DateTime(0, 0, 0,
            int.parse(startParts[0]), int.parse(startParts[1]));
        final endDt = DateTime(0, 0, 0,
            int.parse(endParts[0]), int.parse(endParts[1]));

        final diff = endDt.difference(startDt);
        durationStr =
            "${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}";
      }
    } catch (_) {
      durationStr = '';
    }

    return EventDetailModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      numberOfReservations: int.tryParse(json['numberOfReservations']?.toString() ?? '0') ?? 0,
      numberOfTickets: int.tryParse(json['numberOfTickets']?.toString() ?? '0') ?? 0,
      advisor: json['advisor']?.toString() ?? '',
      startTime: start,
      endTime: end,
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      reservationsImages: reservations == null
          ? []
          : reservations
              .map((e) => (e as Map<String, dynamic>)['image']?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList(),
      priceAfterDiscount:
          double.tryParse(json['priceAfterDiscount']?.toString() ?? '0') ?? 0.0,
      priceBeforeDiscount:
          double.tryParse(json['priceBeforeDiscount']?.toString() ?? '0') ?? 0.0,
      location: json['location']?.toString() ?? '',
      images: json['images']?.toString() ?? '',
      duration: durationStr,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date,
        'numberOfReservations': numberOfReservations,
        'numberOfTickets': numberOfTickets,
        'advisor': advisor,
        'startTime': startTime,
        'endTime': endTime,
        'latitude': latitude,
        'longitude': longitude,
        'reservations': reservationsImages.map((i) => {'image': i}).toList(),
        'priceAfterDiscount': priceAfterDiscount,
        'priceBeforeDiscount': priceBeforeDiscount,
        'location': location,
        'images': images,
        'duration': duration, // 🆕 Added
      };
}
