// features/shared/search/data/models/search_group_model.dart
import 'package:equatable/equatable.dart';

class SearchGroup extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final int membersCount;
  final int postsCount;
  final bool isJoined;

  const SearchGroup({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.membersCount,
    required this.postsCount,
    required this.isJoined,
  });

  SearchGroup copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? description,
    int? membersCount,
    int? postsCount,
    bool? isJoined,
  }) {
    return SearchGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      membersCount: membersCount ?? this.membersCount,
      postsCount: postsCount ?? this.postsCount,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    description,
    membersCount,
    postsCount,
    isJoined,
  ];
}
