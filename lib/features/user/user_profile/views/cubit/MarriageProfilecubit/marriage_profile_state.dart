import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';

class MarriageProfileState extends Equatable {
  final CubitStates state;
  final MarriageUserProfileModel? profile;
  final String? errorMessage;
  final String? successMessage;
  final bool isLoading;
  final bool isUpdating; // ⭐ Added missing field

  const MarriageProfileState({
    this.state = CubitStates.initial,
    this.profile,
    this.errorMessage,
    this.successMessage,
    this.isLoading = false,
    this.isUpdating = false, // ⭐ Added missing field
  });

  MarriageProfileState copyWith({
    CubitStates? state,
    MarriageUserProfileModel? profile,
    String? errorMessage,
    String? successMessage,
    bool? isLoading,
    bool? isUpdating, // ⭐ Added missing field
    bool clearMessages = false,
  }) {
    return MarriageProfileState(
      state: state ?? this.state,
      profile: profile ?? this.profile,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages
          ? null
          : (successMessage ?? this.successMessage),
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating, // ⭐ Added missing field
    );
  }

  @override
  List<Object?> get props => [
        state,
        profile,
        errorMessage,
        successMessage,
        isLoading,
        isUpdating, // ⭐ Added missing field
      ];
}