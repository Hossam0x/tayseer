import 'package:tayseer/core/widgets/snack_bar_service.dart';
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
    _initialize();
  }

  void _initialize() {
    if (initialProfile != null) {
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

  Future<void> pickImage(BuildContext context) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // تحديث الحالة المحلية أولاً
        emit(
          state.copyWith(
            imageFile: file,
            imagePreviewUrl: null,
            isLoading: true,
          ),
        );

        // رفع الصورة إلى الخادم
        await _uploadImage(file, context);
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      debugPrint('❌ خطأ في اختيار الصورة: $e');
    }
  }

  Future<void> _uploadImage(File imageFile, BuildContext context) async {
    try {
      // ⭐ إرسال الصورة فقط لتجنب مشاكل التحقق في الحقول الأخرى (مثل الوصف)
      // نظرًا لأن هذا إجراء "تحديث صورة" منفصل
      final result = await _repository.updateUserProfile(
        imageFile: imageFile,
        // لا نرسل الحقول الأخرى لأننا نريد تحديث الصورة فقط هنا
        // هذا يعتمد على أن الـ Backend يدعم PATCH لتحديث جزئي
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: failure.message,
              imageFile: null,
            ),
          );
          showSafeSnackBar(
            context: context,
            text: failure.message,
            isError: true,
          );
        },
        (updatedProfile) {
          emit(
            state.copyWith(
              isLoading: false,
              profile: updatedProfile,
              imagePreviewUrl: updatedProfile.image,
              imageFile: null,
            ),
          );
          showSafeSnackBar(
            context: context,
            text: 'تم تحديث الصوره بنجاح',
            isSuccess: true,
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'حدث خطأ أثناء رفع الصورة: $e',
          imageFile: null,
        ),
      );
    }
  }

  Future<void> removeImage() async {
    if (state.profile?.image == null || state.profile!.image!.isEmpty) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final result = await _repository.updateUserProfile(
        name: state.name,
        username: state.username,
        description: state.description,
        imageFile: null, // إرسال null لحذف الصورة
      );

      result.fold(
        (failure) {
          emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        },
        (updatedProfile) {
          emit(
            state.copyWith(
              isLoading: false,
              profile: updatedProfile,
              imagePreviewUrl: '',
              imageFile: null,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'حدث خطأ أثناء حذف الصورة: $e',
        ),
      );
    }
  }

  void refresh() {
    _loadUserProfile();
  }
}
