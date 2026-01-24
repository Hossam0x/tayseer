import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile_edit_state.dart';
import 'package:tayseer/my_import.dart';

class UserProfileEditCubit extends Cubit<UserProfileEditState> {
  final UserProfileRepository _repository;
  final ImagePicker _imagePicker = ImagePicker();
  final UserProfileModel? initialProfile;

  UserProfileEditCubit(this._repository, {this.initialProfile})
    : super(const UserProfileEditState()) {
    if (initialProfile != null) {
      // استخدام البيانات الأولية إذا مررت من الصفحة السابقة
      emit(
        state.copyWith(
          state: CubitStates.success,
          profile: initialProfile,
          name: initialProfile!.name,
          username: initialProfile!.username,
          description: initialProfile!.description ?? '',
          imagePreviewUrl: initialProfile!.image,
          isLoading: false,
        ),
      );
    } else {
      _loadUserProfile();
    }
  }
  Future<void> _loadUserProfile() async {
    emit(state.copyWith(state: CubitStates.loading));

    try {
      final result = await _repository.getUserProfile();

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (profile) {
          emit(
            state.copyWith(
              state: CubitStates.success,
              profile: profile,
              name: profile.name,
              username: profile.username,
              description: profile.description ?? '',
              imagePreviewUrl: profile.image,
              isLoading: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          state: CubitStates.failure,
          errorMessage: 'حدث خطأ في تحميل البيانات: $e',
        ),
      );
    }
  }

  void updateName(String name) {
    emit(state.copyWith(name: name));
  }

  void updateUsername(String username) {
    emit(state.copyWith(username: username));
  }

  void updateDescription(String description) {
    emit(state.copyWith(description: description));
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        emit(
          state.copyWith(
            imageFile: file,
            imagePreviewUrl: null, // إخفاء الصورة القديمة عند اختيار صورة جديدة
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ خطأ في اختيار الصورة: $e');
    }
  }

  void updateImage(String imageUrl) {
    emit(state.copyWith(imagePreviewUrl: imageUrl));
  }

  void removeImage() {
    emit(state.copyWith(imageFile: null, imagePreviewUrl: ''));
  }

  // في UserProfileEditCubit
  Future<void> saveProfile(BuildContext context) async {
    if (state.isLoading) return;

    // تحقق من صحة البيانات
    if (state.name.isEmpty) {
      AppToast.error(context, 'الاسم مطلوب');
      return;
    }

    if (state.username.isEmpty) {
      AppToast.error(context, 'اسم المستخدم مطلوب');
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final result = await _repository.updateUserProfile(
        name: state.name,
        username: state.username,
        description: state.description,
        imageFile: state.imageFile,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(isLoading: false));
          AppToast.error(context, failure.message);
        },
        (updatedProfile) {
          emit(
            state.copyWith(
              isLoading: false,
              profile: updatedProfile,
              imagePreviewUrl: updatedProfile.image,
            ),
          );

          AppToast.success(context, 'تم حفظ التغييرات بنجاح');

          // الرجوع للصفحة السابقة بعد الحفظ
          Navigator.pop(context, updatedProfile);
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      AppToast.error(context, 'حدث خطأ أثناء الحفظ: $e');
    }
  }

  void refresh() {
    _loadUserProfile();
  }
}
