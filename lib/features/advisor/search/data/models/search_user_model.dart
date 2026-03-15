// features/shared/search/data/models/search_user_model.dart
import 'package:equatable/equatable.dart';

class SearchUser extends Equatable {
  final String id;
  final String name;
  final String? username;
  final String imageUrl;
  final bool imageBlur;

  const SearchUser({
    required this.id,
    required this.name,
    this.username,
    required this.imageUrl,
    this.imageBlur = false,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json) {
    return SearchUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? json['userName'],
      imageUrl: json['image'] ?? '',
      imageBlur: json['imageBlur'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, username, imageUrl, imageBlur];
}
