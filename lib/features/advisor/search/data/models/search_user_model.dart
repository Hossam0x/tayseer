// features/shared/search/data/models/search_user_model.dart
import 'package:equatable/equatable.dart';

class SearchUser extends Equatable {
  final String id;
  final String name;
  final String imageUrl;

  const SearchUser({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json) {
    return SearchUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, imageUrl];
}
