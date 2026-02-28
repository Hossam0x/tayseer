class ReservationDetails {
  final String eventId;
  final String title;
  final String location;
  final String advisorName;
  final DateTime date;
  final String time;
  final num price;
  final num tax;
  final num total;
  final num discount;

  ReservationDetails({
    required this.eventId,
    required this.title,
    required this.location,
    required this.advisorName,
    required this.date,
    required this.time,
    required this.price,
    required this.tax,
    required this.total,
    required this.discount,
  });

  factory ReservationDetails.fromJson(Map<String, dynamic> json) {
    return ReservationDetails(
      eventId: json['eventId'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      advisorName: json['advisorName'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      time: json['time'] ?? '',
      price: json['price'] ?? 0,
      tax: json['tax'] ?? 0,
      total: json['total'] ?? 0,
      discount: json['discount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'title': title,
      'location': location,
      'advisorName': advisorName,
      'date': date.toIso8601String(),
      'time': time,
      'price': price,
      'tax': tax,
      'total': total,
      'discount': discount,
    };
  }
}
