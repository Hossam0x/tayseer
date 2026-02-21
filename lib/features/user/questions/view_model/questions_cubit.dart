// lib/features/user/questions/view_model/questions_cubit.dart

import 'dart:typed_data';
import 'package:tayseer/core/utils/face%20_verification_service.dart';
import 'package:tayseer/features/user/questions/repo/questions_repo.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';
import 'package:tayseer/my_import.dart';

class QuestionsCubit extends Cubit<QuestionsState> {
  QuestionsCubit(this._repo) : super(const QuestionsState());
  final QuestionsRepo _repo;
  final FaceVerificationService _faceService = FaceVerificationService();

  final phoneController = TextEditingController();
  final countryCodeController = TextEditingController();
  final phoneFormKey = GlobalKey<FormState>();

  // -------------------------------------
  // الصور
  // -------------------------------------

  void setMainImage(File image) {
    emit(state.copyWith(mainImage: image));
  }

  void setImages(List<File> images) {
    final copied = List<File>.from(images);
    emit(state.copyWith(images: copied));
  }

  // -------------------------------------
  // uploadPersonalInfo
  // -------------------------------------

  Future<void> uploadPersonalInfo({File? image, List<File>? images}) async {
    emit(state.copyWith(uploadPersonalInfoState: CubitStates.loading));

    try {
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
    } catch (e) {
      emit(
        state.copyWith(
          uploadPersonalInfoState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // -------------------------------------
  // answer questions
  // -------------------------------------

  Future<void> sendAnswerQuestions({
    required String question,
    required String questionCategoryEnum,
    required int questionNumber,
    required List<Map<String, dynamic>> answers,
    bool? answerCompleted,
  }) async {
    emit(state.copyWith(answerQuestionsState: CubitStates.loading));

    try {
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
    } catch (e) {
      emit(
        state.copyWith(
          answerQuestionsState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // -------------------------------------
  // ✅ Face Verification - محلي بالكاميرا
  // -------------------------------------

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
    } catch (e) {
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

  // -------------------------------------
  // change image blur
  // -------------------------------------

  Future<void> changeImageBlur() async {
    emit(state.copyWith(changeImageBlurState: CubitStates.loading));

    try {
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
              blurEnabled: true,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          changeImageBlurState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }

    emit(state.copyWith(changeImageBlurState: CubitStates.initial));
  }

  void resetBlurState() {
    emit(state.copyWith(changeImageBlurState: CubitStates.initial));
  }

  Future<void> disableBlur() async {
    emit(state.copyWith(changeImageBlurState: CubitStates.loading));

    try {
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
              blurEnabled: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          changeImageBlurState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }

    emit(state.copyWith(changeImageBlurState: CubitStates.initial));
  }

  // -------------------------------------
  // phone number
  // -------------------------------------

  Future<void> sendPhoneNumber() async {
    if (!phoneFormKey.currentState!.validate()) {
      return;
    }
    emit(state.copyWith(phoneNumberState: CubitStates.loading));

    try {
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
    } catch (e) {
      emit(
        state.copyWith(
          phoneNumberState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }

    emit(state.copyWith(phoneNumberState: CubitStates.initial));
  }

  // -------------------------------------
  // verify OTP
  // -------------------------------------

  Future<void> verifyOtp({required String otp}) async {
    emit(state.copyWith(verifyOtpState: CubitStates.loading));

    try {
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
    } catch (e) {
      emit(
        state.copyWith(
          verifyOtpState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }

    emit(state.copyWith(verifyOtpState: CubitStates.initial));
  }

  // -------------------------------------
  // get last question number
  // -------------------------------------

  Future<void> fetchLastQuestionNumber() async {
    emit(state.copyWith(lastQuestionNumberState: CubitStates.loading));

    try {
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
    } catch (e) {
      emit(
        state.copyWith(
          lastQuestionNumberState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }

    emit(state.copyWith(lastQuestionNumberState: CubitStates.initial));
  }

  // -------------------------------------
  // Partner Filter
  // -------------------------------------

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

    try {
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
    } catch (e) {
      emit(
        state.copyWith(
          partnerFilterState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
      emit(state.copyWith(partnerFilterState: CubitStates.initial));
    }
  }

  void clear() {
    phoneController.clear();
    countryCodeController.clear();
  }
}
