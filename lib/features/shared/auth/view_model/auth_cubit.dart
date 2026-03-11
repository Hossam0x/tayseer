// auth_cubit.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/functions/set_advisor_status.dart';
import 'package:tayseer/core/services/cache_cleanup_service.dart';
import 'package:tayseer/features/shared/auth/model/day_time_range_model.dart';
import 'package:tayseer/features/shared/auth/repo/auth_repo.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:crypto/crypto.dart';
import 'package:tayseer/firebase_options.dart';

import '../../../../my_import.dart';
import '../model/certificate_model.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(AuthState());
  final AuthRepo _repo;

  /// Controllers and Form Keys for Registration
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: DefaultFirebaseOptions.currentPlatform.iosClientId,
  );
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //// Controllers and Form Keys for Consultant
  final nameAsConsultantController = TextEditingController();
  final bioController = TextEditingController();
  // Certificates controllers/state
  final certificateNameController = TextEditingController();
  final institutionNameController = TextEditingController();
  XFile? pickedCertificate;
  DateTime? obtainDate;
  final List<CertificateModel> certificates = [];
  // National ID images (front/back or multiple files)
  final List<File> pickedNationalIds = [];
  String? selectedGender;
  XFile? pickedImage;
  XFile? pickedVideo;
  DateTime? birthDate;
  String? specialization;
  String? jobLevel;
  String? experienceYears;

  bool _isVideoLoading = false;

  bool get isVideoLoading => _isVideoLoading;

  void setVideoLoaded() {
    _isVideoLoading = false;
    emit(state.copyWith());
  }

  void setVideoLoading(bool isLoading) {
    _isVideoLoading = isLoading;
    emit(state.copyWith());
  }

  Future<void> logInUser({
    String? email,
    bool fromRegistrationScreen = false,
  }) async {
    if (email == null && !registerFormKey.currentState!.validate()) {
      return;
    }
    if (fromRegistrationScreen) {
      emit(
        state.copyWith(
          registerState: CubitStates.loading,
          fromScreen: 'register',
        ),
      );
    } else {
      emit(
        state.copyWith(
          registerState: CubitStates.loading,
          fromScreen: 'registration',
        ),
      );
    }

    final response = await _repo.logInUser(
      email: email ?? emailController.text.trim(),
    );

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            registerState: CubitStates.failure,
            errorMessage: failure.message,
            fromScreen: fromRegistrationScreen == true
                ? 'register'
                : 'registration',
          ),
        );
      },
      (data) {
        setAdvisorStatus(data.data?.approvalKey);
        emit(
          state.copyWith(
            registerState: CubitStates.success,
            verify: data.data?.verify,
            isNew: data.data?.isNew,
            fromScreen: fromRegistrationScreen == true
                ? 'register'
                : 'registration',
          ),
        );

        clearControllers();
      },
    );
  }

  Future<void> submitPersonalDataAsConsultant() async {
    emit(state.copyWith(personalDataState: CubitStates.loading));

    final response = await _repo.personalDataAsConsultant(
      name: nameAsConsultantController.text,
      dateOfBirth: birthDate == null ? '' : birthDate!.toIso8601String(),
      gender: selectedGender ?? '',
      professionalSpecialization: specialization ?? '',
      jobGrade: jobLevel ?? "",
      yearsOfExperience: experienceYears ?? "",
      aboutYou: bioController.text,
      image: pickedImage,
      video: pickedVideo,
    );

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            personalDataState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(personalDataState: CubitStates.success));
      },
    );
  }

  Future<void> addServiceProvider() async {
    emit(state.copyWith(addServiceProviderState: CubitStates.loading));

    final sessionTypes = {
      '30min': {
        'duration': 30,
        'price': int.tryParse(state.price30Min) ?? 0,
        'currency': 'SAR',
        'isEnabled': state.isThirtyMinutesSelected,
      },
      '60min': {
        'duration': 60,
        'price': int.tryParse(state.price60Min) ?? 0,
        'currency': 'SAR',
        'isEnabled': state.isSixtyMinutesSelected,
      },
    };

    final dayOrder = [
      'saturday',
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
    ];

    String formatTimeOfDay(TimeOfDay t) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }

    final weeklyAvailability = <Map<String, dynamic>>[];

    for (var i = 0; i < dayOrder.length; i++) {
      final key = dayOrder[i];
      final range = state.availableDays[key];
      if (range != null) {
        weeklyAvailability.add({
          'dayOfWeek': i,
          'isEnabled': true,
          'timeSlots': [
            {
              'start': formatTimeOfDay(range.from),
              'end': formatTimeOfDay(range.to),
            },
          ],
        });
      } else {
        weeklyAvailability.add({
          'dayOfWeek': i,
          'isEnabled': false,
          'timeSlots': [],
        });
      }
    }

    final body = {
      'sessionTypes': sessionTypes,
      'weeklyAvailability': weeklyAvailability,
      'timezone': 'Asia/Riyadh',
    };

    final response = await _repo.addServiceProvider(body: body);

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            addServiceProviderState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(addServiceProviderState: CubitStates.success));
      },
    );
  }

  Future<void> addCertificateAsConsultant() async {
    if (certificateNameController.text.trim().isEmpty ||
        institutionNameController.text.trim().isEmpty ||
        pickedCertificate == null ||
        obtainDate == null) {
      return;
    }
    emit(state.copyWith(addCertificateState: CubitStates.loading));

    final response = await _repo.addCertificateAsConsultant(
      nameCertificate: certificateNameController.text.trim(),
      fromWhere: institutionNameController.text.trim(),
      date: obtainDate!.toIso8601String(),
      image: pickedCertificate!,
    );

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            addCertificateState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        certificates.add(
          CertificateModel(
            name: certificateNameController.text.trim(),
            institution: institutionNameController.text.trim(),
            year: obtainDate!,
            image: pickedCertificate!,
          ),
        );

        certificateNameController.clear();
        institutionNameController.clear();
        pickedCertificate = null;
        obtainDate = null;

        emit(state.copyWith(addCertificateState: CubitStates.success));
        // reset to initial after success
        emit(state.copyWith(addCertificateState: CubitStates.initial));
      },
    );
  }

  Future<void> addNationalImage() async {
    if (pickedNationalIds.isEmpty) {
      return;
    }
    emit(state.copyWith(addNationalImageState: CubitStates.loading));

    try {
      final xfiles = pickedNationalIds.map((f) => XFile(f.path)).toList();

      final response = await _repo.addNationalImage(nationalImages: xfiles);

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              addNationalImageState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (_) {
          // success -> clear local list
          pickedNationalIds.clear();
          emit(state.copyWith(addNationalImageState: CubitStates.success));
        },
      );

      // reset to initial after success
      emit(state.copyWith(addNationalImageState: CubitStates.initial));
    } catch (e) {
      emit(
        state.copyWith(
          addNationalImageState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ✅ تم التعديل - إضافة userType parameter
  Future<void> signInWithGoogle({required UserTypeEnum userType}) async {
    emit(
      state.copyWith(
        signInWithGoogleState: CubitStates.loading,
        fromScreen: 'registration',
        currentAuthUserType: userType,
      ),
    );

    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        emit(
          state.copyWith(
            signInWithGoogleState: CubitStates.failure,
            errorMessage: "تم إلغاء العملية",
            currentAuthUserType: userType,
          ),
        );
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        emit(
          state.copyWith(
            signInWithGoogleState: CubitStates.failure,
            errorMessage: "فشل في الحصول على Firebase Token",
            currentAuthUserType: userType,
          ),
        );
        return;
      }

      // ⬅️ نكمل على backend
      await sendAuthGoogle(idToken: firebaseIdToken, userType: userType);
    } catch (e) {
      emit(
        state.copyWith(
          signInWithGoogleState: CubitStates.failure,
          errorMessage: e.toString(),
          currentAuthUserType: userType,
        ),
      );
    }
  }

  // ✅ تم التعديل - إضافة userType parameter
  Future<void> sendAuthGoogle({
    required String idToken,
    required UserTypeEnum userType,
  }) async {
    emit(
      state.copyWith(fromScreen: 'registration', currentAuthUserType: userType),
    );

    try {
      final response = await _repo.authGoogle(idToken: idToken);

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              authGoogleState: CubitStates.failure,
              signInWithGoogleState: CubitStates.failure,
              errorMessage: failure.message,
              fromScreen: 'registration',
              currentAuthUserType: userType,
            ),
          );
        },
        (result) {
          setAdvisorStatus(result.data?.approvalKey);
          emit(
            state.copyWith(
              authGoogleState: CubitStates.success,
              signInWithGoogleState: CubitStates.success,
              fromScreen: 'registration',
              currentAuthUserType: userType,
              isNew: result.data?.user?.isNew ?? true,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          authGoogleState: CubitStates.failure,
          signInWithGoogleState: CubitStates.failure,
          errorMessage: e.toString(),
          currentAuthUserType: userType,
        ),
      );
    }
  }

  Future<void> signInWithApple({required UserTypeEnum userType}) async {
    // امنع الضغط مرتين
    if (state.signInWithAppleState == CubitStates.loading) return;

    emit(
      state.copyWith(
        signInWithAppleState: CubitStates.loading,
        fromScreen: 'registration',
        currentAuthUserType: userType,
      ),
    );

    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // 🍎 Apple Sign In (بدون timeout)
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (appleCredential.identityToken == null) {
        throw Exception('Apple identityToken is null');
      }

      // 🔥 Firebase credential
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        oauthCredential,
      );

      final firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception('Failed to obtain Firebase ID token');
      }

      // ⬅️ Backend login
      await sendAuthApple(idToken: firebaseIdToken, userType: userType);
    } on SignInWithAppleAuthorizationException catch (e) {
      emit(
        state.copyWith(
          signInWithAppleState: CubitStates.failure,
          errorMessage: e.code == AuthorizationErrorCode.canceled
              ? 'تم إلغاء تسجيل الدخول'
              : e.message,
        ),
      );
    } on PlatformException catch (e) {
      emit(
        state.copyWith(
          signInWithAppleState: CubitStates.failure,
          errorMessage: e.message ?? 'Apple sign in failed',
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ signInWithApple error: $e');
      debugPrint('📍 stackTrace: $stackTrace');

      emit(
        state.copyWith(
          signInWithAppleState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ✅ تم التعديل - إضافة userType parameter
  Future<void> sendAuthApple({
    required String idToken,
    required UserTypeEnum userType,
  }) async {
    try {
      final response = await _repo.authApple(idToken: idToken);

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              authAppleState: CubitStates.failure,
              errorMessage: failure.message,
              fromScreen: 'registration',
              currentAuthUserType: userType,
            ),
          );
        },
        (result) {
          setAdvisorStatus(result.data?.approvalKey);
          emit(
            state.copyWith(
              authAppleState: CubitStates.success,
              signInWithAppleState: CubitStates.success,
              fromScreen: 'registration',
              currentAuthUserType: userType,
              isNew: result.data?.user?.isNew ?? true,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          authAppleState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
      debugPrint('sendAuthApple:::::::::$e');
    }
  }

  void resetAuthStates() {
    emit(
      state.copyWith(
        signInWithAppleState: CubitStates.initial,
        authAppleState: CubitStates.initial,
        signInWithGoogleState: CubitStates.initial,
        authGoogleState: CubitStates.initial,
        registerState: CubitStates.initial,
        errorMessage: null,
      ),
    );
  }

  Future<void> verifyOtp({required String otp}) async {
    emit(state.copyWith(verifyOtpState: CubitStates.loading));

    try {
      final response = await _repo.verifyOtp(otp: otp);

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              verifyOtpState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
          emit(state.copyWith(verifyOtpState: CubitStates.initial));
        },
        (verifyResponse) {
          emit(
            state.copyWith(
              verifyOtpState: CubitStates.success,
              isNew: verifyResponse.data?.user?.isNew ?? true,
            ),
          );
          emit(state.copyWith(verifyOtpState: CubitStates.initial));
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
  }

  Future<void> resendCode() async {
    emit(state.copyWith(resendCodeState: CubitStates.loading));

    try {
      final response = await _repo.resendOtp();

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              resendCodeState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (_) {
          emit(state.copyWith(resendCodeState: CubitStates.success));
          emit(state.copyWith(resendCodeState: CubitStates.initial));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          resendCodeState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> getLastLogIn() async {
    emit(state.copyWith(getLastLoginState: CubitStates.loading));

    try {
      final response = await _repo.getLastLogIn();

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              getLastLoginState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (lastLoginResponse) {
          emit(
            state.copyWith(
              getLastLoginState: CubitStates.success,
              lastLoginBy: lastLoginResponse.data?.lastLoginBY,
              lastLoginEmail: lastLoginResponse.data?.email,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          getLastLoginState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> logoutWithNavigation(BuildContext context) async {
    emit(state.copyWith(logoutState: CubitStates.loading));

    bool googleLoggedOut = false;
    bool cacheCleared = false;

    try {
      await _googleSignIn.signOut();

      await _firebaseAuth.signOut();

      googleLoggedOut = true;
      debugPrint('Google logout successful');
    } catch (e) {
      debugPrint('Google logout error: $e');
    }

    try {
      await CachNetwork.clearCache();
      await getIt<CacheCleanupService>().clearAllUserCache();
      cacheCleared = true;
      debugPrint('Cache cleared successfully');
    } catch (e) {
      debugPrint('Cache clear error: $e');
    }

    // تقييم النتيجة
    if (googleLoggedOut && cacheCleared) {
      emit(state.copyWith(logoutState: CubitStates.success));

      // تأخير ثم الانتقال لصفحة تسجيل الدخول
      await Future.delayed(const Duration(milliseconds: 500));

      if (context.mounted) {
        context.pushNamedAndRemoveUntil(
          AppRouter.kRegisterView,
          predicate: (route) => false,
        );
      }

      emit(state.copyWith(logoutState: CubitStates.initial));
    } else {
      emit(
        state.copyWith(
          logoutState: CubitStates.failure,
          errorMessage: 'لم يتم تسجيل الخروج بالكامل. حاول مرة أخرى',
        ),
      );

      await Future.delayed(const Duration(seconds: 3));
      emit(state.copyWith(logoutState: CubitStates.initial));
    }
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ---- UI helper setters for Professional Information screen ----
  void setSpecialization(String? value) {
    specialization = value;
    emit(state.copyWith());
  }

  void setJobLevel(String? value) {
    jobLevel = value;
    emit(state.copyWith());
  }

  void setExperienceYears(String? value) {
    experienceYears = value;
    emit(state.copyWith());
  }

  void setPickedVideo(XFile? video) {
    pickedVideo = video;
    emit(state.copyWith());
  }

  void removePickedVideo() {
    pickedVideo = null;
    emit(state.copyWith());
  }

  void setPickedCertificate(XFile? file) {
    pickedCertificate = file;
    emit(state.copyWith());
  }

  // National ID helpers
  void addNationalId(File image) {
    debugPrint('AuthCubit.addNationalId: adding image ${image.path}');
    pickedNationalIds.add(image);
    emit(state.copyWith());
  }

  void removeNationalId(int index) {
    if (index >= 0 && index < pickedNationalIds.length) {
      debugPrint('AuthCubit.removeNationalId: removing index $index');
      pickedNationalIds.removeAt(index);
      emit(state.copyWith());
    }
  }

  void setObtainDate(DateTime? date) {
    obtainDate = date;
    emit(state.copyWith());
  }

  void removeCertificate(CertificateModel certificate) {
    certificates.remove(certificate);
    emit(state.copyWith());
  }

  /// Duration
  void toggleThirtyMinutes() {
    emit(
      state.copyWith(isThirtyMinutesSelected: !state.isThirtyMinutesSelected),
    );
    emit(
      state.copyWith(isThirtyMinutesSelected: !state.isThirtyMinutesSelected),
    );
  }

  void toggleSixtyMinutes() {
    emit(state.copyWith(isSixtyMinutesSelected: !state.isSixtyMinutesSelected));
  }

  void toggle30Minutes(bool value) {
    emit(state.copyWith(isThirtyMinutesSelected: value));
  }

  void toggle60Minutes(bool value) {
    emit(state.copyWith(isSixtyMinutesSelected: value));
  }

  void set30MinPrice(String price) {
    emit(state.copyWith(price30Min: price));
  }

  void set60MinPrice(String price) {
    final shouldEnable = price.isNotEmpty;
    emit(
      state.copyWith(price60Min: price, isSixtyMinutesSelected: shouldEnable),
    );
  }

  /// Languages

  void toggleLanguage(String code) {
    final currentLanguages = List<String>.from(state.selectedLanguages);

    if (currentLanguages.contains(code)) {
      currentLanguages.remove(code);
    } else {
      currentLanguages.add(code);
    }

    emit(state.copyWith(selectedLanguages: currentLanguages));
  }

  Future<void> addLanguage() async {
    emit(state.copyWith(addLanguageState: CubitStates.loading));

    final response = await _repo.addLanguage(
      languages: state.selectedLanguages,
    );

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            addLanguageState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(addLanguageState: CubitStates.success));
        emit(state.copyWith(addLanguageState: CubitStates.initial));
      },
    );
  }

  /// Days
  void toggleDay(String day) {
    final map = Map<String, DayTimeRange>.from(state.availableDays);

    if (map.containsKey(day)) {
      map.remove(day);
    } else {
      map[day] = DayTimeRange(
        from: const TimeOfDay(hour: 9, minute: 0),
        to: const TimeOfDay(hour: 17, minute: 0),
      );
    }

    emit(AuthState(availableDays: map));
  }

  void updateFromTime(String day, TimeOfDay time) {
    final range = state.availableDays[day];
    if (range == null) return;

    emit(
      AuthState(
        availableDays: {
          ...state.availableDays,
          day: DayTimeRange(from: time, to: range.to),
        },
      ),
    );
  }

  void updateToTime(String day, TimeOfDay time) {
    final range = state.availableDays[day];
    if (range == null) return;

    emit(
      AuthState(
        availableDays: {
          ...state.availableDays,
          day: DayTimeRange(from: range.from, to: time),
        },
      ),
    );
  }

  void guestLogin() async {
    emit(state.copyWith(guestLoginState: CubitStates.loading));

    try {
      await CachNetwork.clearCache();
      final response = await _repo.guestLogin();

      response.fold(
        (failure) {
          emit(
            state.copyWith(
              guestLoginState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (guestResponse) {
          emit(
            state.copyWith(
              guestLoginState: CubitStates.success,
              guestData: guestResponse.data,
              message: guestResponse.message,
            ),
          );
          emit(state.copyWith(guestLoginState: CubitStates.initial));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          guestLoginState: CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Update the draft text from the UI
  void updateText(String text) {
    emit(state.copyWith(draftText: text));
  }

  ///  🧠✨ Gemini AI Content Generation for Bio
  Future<void> enhanceTextWithGemini(BuildContext context) async {
    final currentText = bioController.text;

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

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      emit(state.copyWith(isAiState: CubitStates.failure));
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: 'Missing AI API key. Configure GEMINI_API_KEY in your .env',
          isError: true,
        ),
      );
      return;
    }

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
        bioController.text = response.text!;
        emit(
          state.copyWith(
            draftText: response.text!,
            isAiState: CubitStates.success,
          ),
        );
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

  /// Seet Gender

  Future<void> setGender({required String gender}) async {
    emit(state.copyWith(setGenderState: CubitStates.loading));

    final response = await _repo.setGender(gender: gender);

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            setGenderState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(setGenderState: CubitStates.success));
      },
    );
  }

  ///// clear//////
  void clearControllers() {
    emailController.clear();
  }

  @override
  Future<void> close() {
    clearControllers();
    return super.close();
  }
}
