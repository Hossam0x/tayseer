// features/user/user_public_profile/views/cubit/user_public_profile_state.dart
import 'package:equatable/equatable.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart'; // ⭐ Model موحد
import 'package:tayseer/my_import.dart';

class UserPublicProfileState extends Equatable {
  final CubitStates state;
  final UserProfileModel? profile; // ⭐ Model موحد
  final String? errorMessage;
  final bool isLoadingDelete;

  const UserPublicProfileState({
    this.state = CubitStates.initial,
    this.profile,
    this.errorMessage,
    this.isLoadingDelete = false,
  });

  UserPublicProfileState copyWith({
    CubitStates? state,
    UserProfileModel? profile,
    String? errorMessage,
    bool? isLoadingDelete,
  }) {
    return UserPublicProfileState(
      state: state ?? this.state,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingDelete: isLoadingDelete ?? this.isLoadingDelete,
    );
  }

  @override
  List<Object?> get props => [state, profile, errorMessage, isLoadingDelete];
}
