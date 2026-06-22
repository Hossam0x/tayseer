// lib/features/user/questions/presentation/manager/questions_cubit.dart

import 'package:tayseer/core/services/groq_service.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart' as di;
import 'package:didit_sdk/sdk_flutter.dart';
import 'package:tayseer/features/user/questions/data/repo/questions_repo.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';
import 'package:tayseer/my_import.dart';

class QuestionsCubit extends Cubit<QuestionsState> {
  QuestionsCubit(this._repo) : super(const QuestionsState());
  final QuestionsRepo _repo;

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
  // Face Verification with Didit SDK
  // ─────────────────────────────────────────────────────

  Future<void> verifyFaceWithDidit() async {
    emit(
      state.copyWith(
        faceVerificationState: CubitStates.loading,
        clearFaceVerificationError: true,
      ),
    );

    try {
      // Step 1: اطلب Session Token من الـ Backend
      final sessionResult = await _repo.createFaceVerificationSession();

      String? sessionToken;

      sessionResult.fold(
        (failure) {
          emit(
            state.copyWith(
              faceVerificationState: CubitStates.failure,
              faceVerificationError: 'session_creation_failed',
            ),
          );
        },
        (token) {
          sessionToken = token;
        },
      );

      if (sessionToken == null) return;

      // Step 2: افتح Didit SDK
      final result = await DiditSdk.startVerification(
        sessionToken!,
        config: DiditConfig(
          languageCode: selectedLanguage ?? 'ar',
          loggingEnabled: true,
        ),
      );

      // Step 3: عالج النتيجة
      switch (result) {
        case VerificationCompleted(:final session):
          switch (session.status) {
            case VerificationStatus.approved:
              debugPrint('✅ Approved! Session: ${session.sessionId}');
              emit(
                state.copyWith(
                  faceVerificationState: CubitStates.success,
                  clearFaceVerificationError: true,
                ),
              );

            case VerificationStatus.declined:
              debugPrint('❌ Declined. Session: ${session.sessionId}');
              emit(
                state.copyWith(
                  faceVerificationState: CubitStates.failure,
                  faceVerificationError: 'face_mismatch',
                ),
              );

            case VerificationStatus.pending:
              debugPrint('⏳ Pending. Session: ${session.sessionId}');
              emit(
                state.copyWith(
                  faceVerificationState: CubitStates.failure,
                  faceVerificationError: 'verification_pending',
                ),
              );
          }

        case VerificationCancelled():
          debugPrint('⚠️ User cancelled');
          emit(
            state.copyWith(
              faceVerificationState: CubitStates.failure,
              faceVerificationError: 'verification_cancelled',
            ),
          );

        case VerificationFailed(:final error):
          debugPrint('❌ Error: ${error.type} - ${error.message}');
          emit(
            state.copyWith(
              faceVerificationState: CubitStates.failure,
              faceVerificationError: _mapDiditError(error.type),
            ),
          );
      }
    } catch (e) {
      debugPrint('❌ Verification error: $e');
      emit(
        state.copyWith(
          faceVerificationState: CubitStates.failure,
          faceVerificationError: 'verification_error',
        ),
      );
    }
  }

  String _mapDiditError(VerificationErrorType type) {
    switch (type) {
      case VerificationErrorType.sessionExpired:
        return 'session_expired';
      case VerificationErrorType.networkError:
        return 'network_error';
      case VerificationErrorType.cameraAccessDenied:
        return 'camera_access_denied';
      case VerificationErrorType.apiError:
        return 'api_error';
      default:
        return 'verification_error';
    }
  }

  void resetFaceVerification() {
    emit(
      state.copyWith(
        faceVerificationState: CubitStates.initial,
        clearFaceVerificationError: true,
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // Image Blur
  // ─────────────────────────────────────────────────────

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

  Future<void> sendPhoneNumber({String otpMethod = 'whatsapp'}) async {
    emit(state.copyWith(phoneNumberState: CubitStates.loading));

    final result = await _repo.phoneNumber(
      phoneNumber: phoneController.text,
      countryCode: countryCodeController.text,
      otpMethod: otpMethod,
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
  // AI Text Enhancement (Groq)
  // ─────────────────────────────────────────────────────

  Future<void> enhanceTextWithGemini(String currentText) async {
    if (currentText.trim().isEmpty) {
      emit(state.copyWith(aiErrorMessage: 'please_write_text_first'));
      return;
    }

    emit(state.copyWith(isAiLoading: true, aiErrorMessage: null));

    try {
      final groq = di.getIt<GroqService>();
      final prompt =
          'You are a professional profile writer.\n'
          'TASK: Write a marriage CV (personal profile) for someone who intends to get married.\n'
          'IMPORTANT RULES:\n'
          '1. Detect the language of the input text.\n'
          '2. Write the CV in THE SAME LANGUAGE as the input.\n'
          '3. Make it respectful, sincere, and well-structured.\n'
          '4. Include: Brief personal introduction, Personality traits, Values and principles, Future goals, Vision for marriage and family life.\n'
          '5. Make it emotionally intelligent and mature.\n'
          '6. Do NOT translate the language.\n'
          '7. Return ONLY the final CV text without explanations.\n'
          'Use this information about the person: "$currentText"';

      final result = await groq.generateText(prompt);
      emit(state.copyWith(aiGeneratedText: result, isAiLoading: false));
    } catch (e) {
      debugPrint('Groq AI error: $e');
      emit(
        state.copyWith(
          isAiLoading: false,
          aiErrorMessage: 'AI Error: ${e.toString()}',
        ),
      );
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
