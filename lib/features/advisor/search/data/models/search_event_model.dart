// features/shared/search/data/models/search_event_model.dart
import 'package:equatable/equatable.dart';

class SearchEvent extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final String location;
  final String advisorName;
  final String dateTime;
  final String price;
  final String oldPrice;
  final int attendeesCount;
  final List<String> attendeesImages;
  final bool isFeatured;

  const SearchEvent({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.location,
    required this.advisorName,
    required this.dateTime,
    required this.price,
    required this.oldPrice,
    required this.attendeesCount,
    required this.attendeesImages,
    required this.isFeatured,
  });

  factory SearchEvent.fromJson(Map<String, dynamic> json) {
    return SearchEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: _extractImage(json),
      location: json['location'] ?? '',
      advisorName: json['advisorName'] ?? json['advisor']?['name'] ?? '',
      dateTime: json['date'] ?? json['dateTime'] ?? '',
      price: json['priceAfterDiscount']?.toString() ?? json['price']?.toString() ?? '0',
      oldPrice: json['priceBeforeDiscount']?.toString() ?? json['oldPrice']?.toString() ?? '0',
      attendeesCount: json['attendeesCount'] ?? json['numberOfReservations'] ?? 0,
      attendeesImages:
          (json['attendeesImages'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isFeatured: json['isFeatured'] ?? json['specialEvent'] ?? false,
    );
  }

  static String _extractImage(Map<String, dynamic> json) {
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      return (json['images'] as List).first.toString();
    } else if (json['image'] is String) {
      return json['image'];
    } else if (json['imageUrl'] is String) {
      return json['imageUrl'];
    }
    return '';
  }

  @override
  List<Object?> get props => [
    id,
    title,
    imageUrl,
    location,
    advisorName,
    dateTime,
    price,
    oldPrice,
    attendeesCount,
    attendeesImages,
    isFeatured,
  ];
}
