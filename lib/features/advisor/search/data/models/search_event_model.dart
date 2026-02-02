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
