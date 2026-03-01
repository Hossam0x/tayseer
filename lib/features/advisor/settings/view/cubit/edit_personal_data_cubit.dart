import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/shared/network/local_network.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:tayseer/features/advisor/settings/data/models/edit_personal_data_models.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/edit_personal_data_repository.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/my_import.dart';
import 'edit_personal_data_state.dart';

class EditPersonalDataCubit extends Cubit<EditPersonalDataState> {
  final EditPersonalDataRepository _repository;

  EditPersonalDataCubit(this._repository)
    : super(EditPersonalDataState.initial()) {
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    try {
      emit(state.copyWith(state: CubitStates.loading, errorMessage: null));

      final result = await _repository.getAdvisorProfile();

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
          final yearsExp = profile.yearsOfExperience;

          final initialRequest = UpdatePersonalDataRequest(
            name: profile.name,
            username: profile.userName, // ⭐ أضف هذا
            dateOfBirth: profile.dateOfBirth,
            gender: profile.gender,
            professionalSpecialization: profile.professionalSpecialization,
            jobGrade: profile.jobGrade,
            yearsOfExperience: yearsExp,
            aboutYou: profile.aboutYou,
            image: profile.image,
            video: profile.video,
          );

          emit(
            state.copyWith(
              state: CubitStates.success,
              profile: profile,
              currentData: initialRequest,
              imagePreviewUrl: profile.image,
              videoPreviewUrl: profile.video,
              errorMessage: null,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          state: CubitStates.failure,
          errorMessage: 'حدث خطأ غير متوقع: ${e.toString()}',
        ),
      );
    }
  }

  void updateName(String name) {
    if (name != state.currentData.name) {
      emit(state.copyWith(currentData: state.currentData.copyWith(name: name)));
    }
  }

  void updateSpecialization(String specialization) {
    if (specialization != state.currentData.professionalSpecialization) {
      emit(
        state.copyWith(
          currentData: state.currentData.copyWith(
            professionalSpecialization: specialization,
          ),
        ),
      );
    }
  }

  void updatePosition(String position) {
    if (position != state.currentData.jobGrade) {
      emit(
        state.copyWith(
          currentData: state.currentData.copyWith(jobGrade: position),
        ),
      );
    }
  }

  void updateExperience(String experience) {
    if (experience != state.currentData.yearsOfExperience) {
      emit(
        state.copyWith(
          currentData: state.currentData.copyWith(
            yearsOfExperience: experience,
          ),
        ),
      );
    }
  }

  void updateUsername(String username) {
    if (username != state.currentData.username) {
      emit(
        state.copyWith(
          currentData: state.currentData.copyWith(username: username),
        ),
      );
    }
  }

  void updateBio(String bio) {
    if (bio != state.currentData.aboutYou) {
      emit(
        state.copyWith(currentData: state.currentData.copyWith(aboutYou: bio)),
      );
    }
  }

  void updateImageFile(File? file) {
    if (file != null) {
      emit(
        state.copyWith(
          imageFile: file,
          imagePreviewUrl: file.path, // عرض معاينة محلية
        ),
      );
    }
  }

  void updateVideoFile(File? file, {String? previewUrl}) {
    if (file != null) {
      emit(
        state.copyWith(
          videoFile: file,
          videoPreviewUrl: previewUrl ?? file.path,
        ),
      );
    }
  }

  // في الكوبيت
  void removeImage() {
    emit(
      state.copyWith(
        clearImage: true,
        // ⭐ إضافة flag للحذف
        currentData: state.currentData.copyWith(image: ""),
      ),
    );
  }

  void removeVideo() {
    emit(
      state.copyWith(
        clearVideo: true,
        // ⭐ إضافة flag للحذف
        currentData: state.currentData.copyWith(video: ""),
      ),
    );
  }

  Future<void> saveChanges() async {
    if (state.isSaving || !state.hasChanges) return;

    emit(
      state.copyWith(isSaving: true, errorMessage: null, uploadProgress: 0.0),
    );

    try {
      // ⭐ إرسال البيانات كما هي بدون تنظيف
      final requestToSend = state.currentData;

      final result = await _repository.updatePersonalData(
        request: requestToSend,
        imageFile: state.imageFile,
        videoFile: state.videoFile,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            if ((progress - state.uploadProgress).abs() > 0.01 ||
                progress == 1.0) {
              emit(state.copyWith(uploadProgress: progress));
            }
          }
        },
      );

      result.fold(
        (failure) {
          emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        },
        (response) {
          final newImageUrl =
              response.data?['image'] as String? ?? state.profile?.image;
          final oldImageUrl = state.profile?.image;

          // ⭐ مسح cache الصورة القديمة (network URL الحقيقي وليس الـ local path)
          if (state.imageFile != null &&
              oldImageUrl != null &&
              oldImageUrl.isNotEmpty) {
            try {
              CachedNetworkImage.evictFromCache(oldImageUrl);
              debugPrint('🗑️ تم مسح cache الصورة القديمة: $oldImageUrl');
            } catch (e) {
              debugPrint('⚠️ خطأ في مسح cache الصورة: $e');
            }
          }

          // تحديث البروفايل بعد الحفظ الناجح
          final updatedProfile = state.profile?.copyWith(
            name: state.currentData.name ?? state.profile!.name,
            userName: state.currentData.username ?? state.profile!.userName,
            professionalSpecialization:
                state.currentData.professionalSpecialization ??
                state.profile!.professionalSpecialization,
            jobGrade: state.currentData.jobGrade ?? state.profile!.jobGrade,
            yearsOfExperience:
                state.currentData.yearsOfExperience ??
                state.profile!.yearsOfExperience,
            aboutYou: state.currentData.aboutYou ?? state.profile!.aboutYou,
            image: newImageUrl,
            video: response.data?['videoLink'] ?? state.profile!.video,
          );

          // ⭐ تحديث الكاش للصورة والاسم (للـ HomeAppBar)
          if (updatedProfile != null) {
            // ⭐ تحديث kCurrentUserData بالصورة الجديدة (reactive update)
            if (kCurrentUserData != null && newImageUrl != null) {
              kCurrentUserData = kCurrentUserData!.copyWith(image: newImageUrl);
            }

            CachNetwork.setData(
              key: kMyProfileImage,
              value: updatedProfile.image ?? '',
            );
            CachNetwork.setData(
              key: kMyProfileName,
              value: updatedProfile.name,
            );

            // ⭐ تحديث الـ HomeCubit والـ StoriesCubit فوراً
            getIt<HomeCubit>().refreshUserInfoFromCache();
            getIt<StoriesCubit>().fetchStoriesSilent();

            debugPrint('✅ تم تحديث كاش الصورة والاسم والـ HomeCubit');
          }

          if (response.success) {
            emit(
              state.copyWith(
                isSaving: false,
                errorMessage: null,
                profile: updatedProfile,
                state: CubitStates.success,
                successMessage: 'تم تحديث البيانات بنجاح',
                // مسح الملفات المؤقتة بعد الحفظ
                imageFile: null,
                videoFile: null,
              ),
            );
          } else {
            emit(state.copyWith(isSaving: false, errorMessage: 'فشل الحفظ'));
          }
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'حدث خطأ أثناء الحفظ: ${e.toString()}',
        ),
      );
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null));
    }
  }

  void clearSuccess() {
    if (state.successMessage != null) {
      emit(state.copyWith(successMessage: null));
    }
  }

  ///  🧠✨ Gemini AI Content Generation for Bio
  Future<void> enhanceTextWithGemini(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final currentText = controller.text;

    if (currentText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: context.tr('please_write_text_first'),
          isError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isAiState: CubitStates.loading));

    const apiKey = 'AIzaSyAzkpmYLG58vfNtxPGvfh8Ynix02VNWnUg';

    try {
      final model = GenerativeModel(model: 'gemma-3-4b-it', apiKey: apiKey);

      final prompt =
          '''
أنت كاتب محتوى متخصص في كتابة السِّيَر الذاتية (Bio) للمستشارين والمرشدين الأسريين.

المطلوب:
- اكتب بايو احترافي لمستشار/مرشد في العلاقات الأسرية بناءً على النص اللي هيكتبه المستخدم.
- البايو يكون مناسب لعرضه في تطبيق استشارات أسرية.

قواعد مهمة:
1. اكتشف لغة النص المُدخل واكتب البايو بنفس اللغة — لا تترجم أبدًا.
2. اجعل البايو احترافيًا، مطمئنًا، ويعكس الثقة والخبرة.
3. أبرز التخصص والخبرة في مجالات الإرشاد الأسري مثل:
   - الإرشاد الزواجي (الخلافات، التواصل، الثقة، الغيرة، إدارة المال، الخيانة)
   - الإرشاد قبل الزواج (اختيار الشريك، التوقعات، التوافق، الجاهزية النفسية والمالية)
   - الإرشاد التربوي والوالدي (أساليب التربية، العناد، الإدمان الرقمي)
   - مشكلات الأطفال والمراهقين
   - العلاقات العائلية الممتدة
   - إدارة الأزمات الأسرية
   - قضايا الطلاق وما بعده
   - الصحة النفسية داخل الأسرة
4. لا تذكر كل التخصصات — ركّز فقط على ما يتناسب مع كلام المستخدم.
5. اجعل الأسلوب دافئًا وإنسانيًا، يشعر القارئ بالأمان والراحة.
6. أضف إيموجي مناسبة باعتدال.
7. اجعل البايو مختصرًا (3-5 أسطر كحد أقصى).
8. أرجع البايو فقط — بدون أي شرح أو مقدمات أو تعليقات.

النص المُدخل من المستخدم: "$currentText"
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        controller.text = response.text!;
        updateBio(response.text!);
        emit(state.copyWith(isAiState: CubitStates.success));
        emit(state.copyWith(isAiState: CubitStates.initial));
      }
    } catch (e) {
      debugPrint('Gemini AI error: $e');
      emit(state.copyWith(isAiState: CubitStates.failure));

      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: 'AI Error: ${e.toString()}',
          isError: true,
        ),
      );
      emit(state.copyWith(isAiState: CubitStates.initial));
    }
  }
}
