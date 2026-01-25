import 'package:equatable/equatable.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/my_import.dart';

class UserProfileEditState extends Equatable {
  final CubitStates state;
  final UserProfileModel? profile;
  final String? errorMessage;

  final String name;
  final String username;
  final String description;
  final File? imageFile;
  final String? imagePreviewUrl;
  final bool isLoading;

  const UserProfileEditState({
    this.state = CubitStates.initial,
    this.profile,
    this.errorMessage,
    this.name = '',
    this.username = '',
    this.description = '',
    this.imageFile,
    this.imagePreviewUrl,
    this.isLoading = false,
  });

  UserProfileEditState copyWith({
    CubitStates? state,
    UserProfileModel? profile,
    String? errorMessage,
    String? name,
    String? username,
    String? description,
    File? imageFile,
    String? imagePreviewUrl,
    bool? isLoading,
  }) {
    return UserProfileEditState(
      state: state ?? this.state,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
      name: name ?? this.name,
      username: username ?? this.username,
      description: description ?? this.description,
      imageFile: imageFile ?? this.imageFile,
      imagePreviewUrl: imagePreviewUrl ?? this.imagePreviewUrl,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    state,
    profile,
    errorMessage,
    name,
    username,
    description,
    imageFile,
    imagePreviewUrl,
    isLoading,
  ];
}
