// features/shared/search/data/models/search_advisor_model.dart
import 'package:equatable/equatable.dart';

class SearchAdvisor extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String specialization;
  final int followersCount;
  final bool isFollowing;
  final bool isVerified;

  const SearchAdvisor({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.specialization,
    required this.followersCount,
    required this.isFollowing,
    this.isVerified = false,
  });

  SearchAdvisor copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? specialization,
    int? followersCount,
    bool? isFollowing,
    bool? isVerified,
  }) {
    return SearchAdvisor(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      specialization: specialization ?? this.specialization,
      followersCount: followersCount ?? this.followersCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrl,
    specialization,
    followersCount,
    isFollowing,
    isVerified,
  ];
}
