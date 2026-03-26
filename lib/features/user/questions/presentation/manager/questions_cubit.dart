import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:tayseer/core/utils/face%20_verification_service.dart';
import 'package:tayseer/features/user/questions/data/repo/questions_repo.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';
import 'package:tayseer/my_import.dart';

class QuestionsCubit extends Cubit<QuestionsState> {
  QuestionsCubit(this._repo) : super(const QuestionsState());
  final QuestionsRepo _repo;
  final FaceVerificationService _faceService = FaceVerificationService();

  final phoneController = TextEditingController();
  final countryCodeController = TextEditingController();
  final phoneFormKey = GlobalKey<FormState>();

  // ─────────────────────────────────────────────────────
  // Images
  // ─────────────────────────────────────────────────────

  void setMainImage(File image) {
    emit(state.copyWith(mainImage: image));
  }

  void setImages(List<File> images) {
    emit(state.copyWith(images: List<File>.from(images)));
  }

  // ─────────────────────────────────────────────────────
  // Upload Personal Info
  // ─────────────────────────────────────────────────────

  Future<void> uploadPersonalInfo({File? image, List<File>? images}) async {
    emit(state.copyWith(uploadPersonalInfoState: CubitStates.loading));

    final response = await _repo.uploadPersonalInfo(
      image: image,
      images: images,
    );

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            uploadPersonalInfoState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
        emit(
          state.copyWith(
            uploadPersonalInfoState: CubitStates.initial,
            errorMessage: null,
          ),
        );
      },
      (_) {
        setMainImage(image!);
        setImages(images!);
        emit(state.copyWith(uploadPersonalInfoState: CubitStates.success));
        emit(state.copyWith(uploadPersonalInfoState: CubitStates.initial));
      },
    );
  }

  // ─────────────────────────────────────────────────────
  // Answer Questions
  // ─────────────────────────────────────────────────────

  Future<void> sendAnswerQuestions({
    required String question,
    required String questionCategoryEnum,
    required int questionNumber,
    required List<Map<String, dynamic>> answers,
    bool? answerCompleted,
  }) async {
    emit(state.copyWith(answerQuestionsState: CubitStates.loading));

    final response = await _repo.answerQuestions(
      question: question,
      questionCategoryEnum: questionCategoryEnum,
      questionNumber: questionNumber,
      answers: answers,
      answerCompleted: answerCompleted,
    );

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            answerQuestionsState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
        emit(
          state.copyWith(
            answerQuestionsState: CubitStates.initial,
            errorMessage: null,
          ),
        );
      },
      (_) {
        emit(state.copyWith(answerQuestionsState: CubitStates.success));
        emit(state.copyWith(answerQuestionsState: CubitStates.initial));
      },
    );
  }

  // ─────────────────────────────────────────────────────
  // Face Verification (local camera)
  // ─────────────────────────────────────────────────────

  Future<void> verifyFaceLocally({
    required Uint8List capturedImageBytes,
  }) async {
    if (state.mainImage == null) {
      emit(
        state.copyWith(
          faceVerificationState: CubitStates.failure,
          faceVerificationError: 'no_main_image',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        faceVerificationState: CubitStates.loading,
        faceVerificationError: null,
      ),
    );

    try {
      final result = await _faceService.matchFaces(
        liveImageBytes: capturedImageBytes,
        uploadedImage: state.mainImage!,
      );

      if (result.success) {
        emit(
          state.copyWith(
            faceVerificationState: CubitStates.success,
            faceVerificationError: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            faceVerificationState: CubitStates.failure,
            faceVerificationError: result.errorKey,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          faceVerificationState: CubitStates.failure,
          faceVerificationError: 'verification_error',
        ),
      );
    }
  }

  void resetFaceVerification() {
    emit(
      state.copyWith(
        faceVerificationState: CubitStates.initial,
        faceVerificationError: null,
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Image Blur (unified toggle)
  // ─────────────────────────────────────────────────────

  /// Toggles image blur on or off.
  ///
  /// Previously split into `changeImageBlur()` and `disableBlur()`,
  /// now unified into a single method with an [enable] parameter.
  Future<void> toggleImageBlur({required bool enable}) async {
    emit(state.copyWith(changeImageBlurState: CubitStates.loading));

    final result = await _repo.changeImageBlur();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            changeImageBlurState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            changeImageBlurState: CubitStates.success,
            blurEnabled: enable,
          ),
        );
      },
    );

    emit(state.copyWith(changeImageBlurState: CubitStates.initial));
  }

  void resetBlurState() {
    emit(state.copyWith(changeImageBlurState: CubitStates.initial));
  }

  // ─────────────────────────────────────────────────────
  // Phone Number
  // ─────────────────────────────────────────────────────

  Future<void> sendPhoneNumber() async {
    if (!phoneFormKey.currentState!.validate()) return;

    emit(state.copyWith(phoneNumberState: CubitStates.loading));

    final result = await _repo.phoneNumber(
      phoneNumber: phoneController.text,
      countryCode: countryCodeController.text,
    );
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            phoneNumberState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(phoneNumberState: CubitStates.success));
      },
    );

    emit(state.copyWith(phoneNumberState: CubitStates.initial));
  }

  // ─────────────────────────────────────────────────────
  // Verify OTP
  // ─────────────────────────────────────────────────────

  Future<void> verifyOtp({required String otp}) async {
    emit(state.copyWith(verifyOtpState: CubitStates.loading));

    final result = await _repo.verifyOtp(otp: otp);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            verifyOtpState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(verifyOtpState: CubitStates.success));
        clear();
      },
    );

    emit(state.copyWith(verifyOtpState: CubitStates.initial));
  }

  // ─────────────────────────────────────────────────────
  // Last Question Number
  // ─────────────────────────────────────────────────────

  Future<void> fetchLastQuestionNumber() async {
    emit(state.copyWith(lastQuestionNumberState: CubitStates.loading));

    final result = await _repo.getLastQuestionNumber();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            lastQuestionNumberState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (responseModel) {
        emit(
          state.copyWith(
            lastQuestionNumberState: CubitStates.success,
            lastQuestionNumberResponse: responseModel,
          ),
        );
      },
    );

    emit(state.copyWith(lastQuestionNumberState: CubitStates.initial));
  }

  // ─────────────────────────────────────────────────────
  // Partner Filter
  // ─────────────────────────────────────────────────────

  void updatePartnerAgeRange(RangeValues values) {
    emit(state.copyWith(partnerAgeRange: values));
  }

  void updatePartnerCountry(String? country) {
    emit(state.copyWith(partnerCountry: country));
  }

  void updatePartnerNationality(String? nationality) {
    emit(state.copyWith(partnerNationality: nationality));
  }

  void resetPartnerFilter() {
    emit(
      state.copyWith(
        partnerAgeRange: const RangeValues(22, 35),
        clearPartnerCountry: true,
        clearPartnerNationality: true,
      ),
    );
  }

  Future<void> submitPartnerFilter() async {
    emit(state.copyWith(partnerFilterState: CubitStates.loading));

    final minAge = state.partnerAgeRange.start.round().toString();
    final maxAge = state.partnerAgeRange.end.round().toString();
    final country = state.partnerCountry ?? 'Egypt';
    final nationality = state.partnerNationality ?? 'Egyptian';

    final result = await _repo.addPreferenceFactors(
      minAge: minAge,
      maxAge: maxAge,
      country: country,
      nationality: nationality,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            partnerFilterState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
        emit(state.copyWith(partnerFilterState: CubitStates.initial));
      },
      (_) {
        emit(state.copyWith(partnerFilterState: CubitStates.success));
        emit(state.copyWith(partnerFilterState: CubitStates.initial));
      },
    );
  }

  // ─────────────────────────────────────────────────────
  // AI Text Enhancement (Gemini)
  // ─────────────────────────────────────────────────────

  /// Enhances user text using Gemini AI.
  ///
  /// **Refactored:** Removed [BuildContext] dependency.
  /// Error messages are now emitted via state instead of
  /// showing SnackBars directly from the cubit.
  Future<void> enhanceTextWithGemini(String currentText) async {
    if (currentText.trim().isEmpty) {
      emit(state.copyWith(aiErrorMessage: 'please_write_text_first'));
      return;
    }

    emit(state.copyWith(isAiLoading: true, aiErrorMessage: null));

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      emit(state.copyWith(
        isAiLoading: false,
        aiErrorMessage: 'Missing AI API key. Configure GEMINI_API_KEY in your .env',
      ));
      return;
    }

    try {
      final model = GenerativeModel(model: 'gemma-3-4b-it', apiKey: apiKey);
      final prompt = '''
You are a professional profile writer.

TASK:
Write a marriage CV (personal profile) for someone who intends to get married.

IMPORTANT RULES:
1. Detect the language of the input text.
2. Write the CV in THE SAME LANGUAGE as the input.
3. Make it respectful, sincere, and well-structured.
4. Include:
   - Brief personal introduction
   - Personality traits
   - Values and principles
   - Future goals and ambitions
   - Vision for marriage and family life
5. Make it emotionally intelligent and mature.
6. Do NOT translate the language.
7. Return ONLY the final CV text without explanations.

Use this information about the person:
"$currentText"
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        emit(
          state.copyWith(
            aiGeneratedText: response.text!,
            isAiLoading: false,
          ),
        );
      }
    } catch (e) {
      debugPrint('Gemini AI error: $e');
      emit(state.copyWith(
        isAiLoading: false,
        aiErrorMessage: 'AI Error: ${e.toString()}',
      ));
    }
  }

  // ─────────────────────────────────────────────────────
  // Cleanup
  // ─────────────────────────────────────────────────────

  void clear() {
    phoneController.clear();
    countryCodeController.clear();
  }
}
