// features/user/user_profile/views/cubit/marriage_profile_state.dart

import 'package:equatable/equatable.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/my_import.dart';

class MarriageProfileState extends Equatable {
  final CubitStates state;
  final MarriageUserProfileModel? profile;
  final String? errorMessage;
  final String? successMessage;
  final bool isLoading;
  final bool isUpdating;

  const MarriageProfileState({
    this.state = CubitStates.initial,
    this.profile,
    this.errorMessage,
    this.successMessage,
    this.isLoading = false,
    this.isUpdating = false,
  });

  MarriageProfileState copyWith({
    CubitStates? state,
    MarriageUserProfileModel? profile,
    String? errorMessage,
    String? successMessage,
    bool? isLoading,
    bool? isUpdating,
  }) {
    return MarriageProfileState(
      state: state ?? this.state,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [
        state,
        profile,
        errorMessage,
        successMessage,
        isLoading,
        isUpdating,
      ];
}