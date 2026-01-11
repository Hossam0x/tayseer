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
  final String image;

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
    required this.image,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
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
      image: json['images'] ?? '',
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
      'images': image,
    };
  }
}
