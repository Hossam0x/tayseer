// features/user/user_profile/views/cubit/marriage_profile_cubit.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/marriage_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
import 'package:tayseer/my_import.dart';

class MarriageProfileCubit extends Cubit<MarriageProfileState> {
  final MarriageProfileRepository _repository;

  MarriageProfileCubit(this._repository) : super(const MarriageProfileState());

  // ⭐ تحميل البروفايل
  Future<void> loadProfile() async {
    emit(state.copyWith(
      state: CubitStates.loading,
      isLoading: true,
    ));

    final result = await _repository.getMarriageProfile();

    result.fold(
      (failure) {
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (profile) {
        emit(state.copyWith(
          state: CubitStates.success,
          profile: profile,
          isLoading: false,
        ));
      },
    );
  }

  // ⭐ حفظ البروفايل
  Future<void> saveProfile() async {
    if (state.profile == null) {
      emit(state.copyWith(
        state: CubitStates.failure,
        errorMessage: 'لا توجد بيانات للحفظ',
      ));
      return;
    }

    emit(state.copyWith(
      state: CubitStates.loading,
      isUpdating: true,
    ));

    final result = await _repository.updateMarriageProfile(state.profile!);

    result.fold(
      (failure) {
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isUpdating: false,
        ));
      },
      (updatedProfile) {
        emit(state.copyWith(
          state: CubitStates.success,
          profile: updatedProfile,
          successMessage: 'تم حفظ التغييرات بنجاح',
          isUpdating: false,
        ));
      },
    );
  }

  // ⭐ تحديث حقل معين
  void updateField(String fieldKey, dynamic value) {
    if (state.profile == null) return;

    MarriageUserProfileModel updatedProfile = state.profile!;

    switch (fieldKey) {
      case 'country':
        updatedProfile = updatedProfile.copyWith(country: value as String);
        break;
      case 'nationality':
        updatedProfile = updatedProfile.copyWith(nationality: value as String);
        break;
      case 'religion':
        updatedProfile = updatedProfile.copyWith(religion: value as String);
        break;
      case 'age':
        updatedProfile = updatedProfile.copyWith(age: value as int);
        break;
      case 'height':
        updatedProfile = updatedProfile.copyWith(height: value as String);
        break;
      case 'ethnicity':
        updatedProfile = updatedProfile.copyWith(ethnicity: value as String);
        break;
      case 'maritalStatus':
        updatedProfile = updatedProfile.copyWith(maritalStatus: value as String);
        break;
      case 'financialStatus':
        updatedProfile = updatedProfile.copyWith(financialStatus: value as String);
        break;
      case 'smoking':
        updatedProfile = updatedProfile.copyWith(smoking: value as String);
        break;
      case 'occupation':
        updatedProfile = updatedProfile.copyWith(occupation: value as String);
        break;
      case 'jobTitle':
        updatedProfile = updatedProfile.copyWith(jobTitle: value as String);
        break;
      case 'professionalLevel':
        updatedProfile = updatedProfile.copyWith(professionalLevel: value as String);
        break;
      case 'religiosity':
        updatedProfile = updatedProfile.copyWith(religiosity: value as String);
        break;
      default:
        debugPrint('⚠️ Unknown field: $fieldKey');
        return;
    }

    emit(state.copyWith(profile: updatedProfile));
    debugPrint('✅ تم تحديث $fieldKey إلى: $value');
  }

  // ⭐ رفع صورة
  Future<void> uploadImage(File imageFile) async {
    emit(state.copyWith(
      state: CubitStates.loading,
      isLoading: true,
    ));

    final result = await _repository.uploadMarriageImage(imageFile);

    result.fold(
      (failure) {
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (imageUrl) {
        if (state.profile != null) {
          final currentImages = List<String>.from(state.profile!.marriageImages);
          currentImages.add(imageUrl);

          final updatedProfile = state.profile!.copyWith(
            marriageImages: currentImages,
          );

          emit(state.copyWith(
            state: CubitStates.success,
            profile: updatedProfile,
            successMessage: 'تم رفع الصورة بنجاح',
            isLoading: false,
          ));
        }
      },
    );
  }

  // ⭐ حذف صورة
  Future<void> deleteImage(String imageUrl) async {
    emit(state.copyWith(
      state: CubitStates.loading,
      isLoading: true,
    ));

    final result = await _repository.deleteMarriageImage(imageUrl);

    result.fold(
      (failure) {
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (_) {
        if (state.profile != null) {
          final currentImages = List<String>.from(state.profile!.marriageImages);
          currentImages.remove(imageUrl);

          final updatedProfile = state.profile!.copyWith(
            marriageImages: currentImages,
          );

          emit(state.copyWith(
            state: CubitStates.success,
            profile: updatedProfile,
            successMessage: 'تم حذف الصورة بنجاح',
            isLoading: false,
          ));
        }
      },
    );
  }

  // ⭐ تفعيل/إلغاء تفعيل متاح للزواج
  void toggleAvailability(bool value) {
    if (state.profile == null) return;

    final updatedProfile = state.profile!.copyWith(
      isAvailableForMarriage: value,
    );

    emit(state.copyWith(profile: updatedProfile));
    debugPrint('✅ تم ${value ? "تفعيل" : "إلغاء"} متاح للزواج');
  }

  // ⭐ إعادة تعيين الحالة
  void resetState() {
    emit(state.copyWith(
      state: CubitStates.initial,
      errorMessage: null,
      successMessage: null,
    ));
  }
}