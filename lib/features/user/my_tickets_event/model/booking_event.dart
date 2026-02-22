class BookingEvent {
  final String eventId;
  final String title;
  final String location;
  final String advisorName;
  final DateTime date;
  final String time;

  BookingEvent({
    required this.eventId,
    required this.title,
    required this.location,
    required this.advisorName,
    required this.date,
    required this.time,
  });

  factory BookingEvent.fromJson(Map<String, dynamic> json) {
    return BookingEvent(
      eventId: json['eventId'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      advisorName: json['advisorName'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      time: json['time'] ?? '',
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
    };
  }
}
