import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/core/widgets/profile_text_field.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data_state.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data_ui_cubit.dart';
import 'package:tayseer/my_import.dart';
import 'package:video_player/video_player.dart';

class EditPersonalDataView extends StatefulWidget {
  const EditPersonalDataView({super.key});

  @override
  State<EditPersonalDataView> createState() => _EditPersonalDataViewState();
}

class _EditPersonalDataViewState extends State<EditPersonalDataView> {
  late TextEditingController _nameController;
  late TextEditingController _idController;
  late TextEditingController _bioController;
  late TextEditingController _usernameController;
  late EditPersonalDataUiCubit _uiCubit;

  // ⭐ خرائط تحويل للمناصب
  final Map<String, String> _positionMapping = {
    "advisor": "job_consultant_title",
    "senior": "job_senior",
    "junior": "job_specialist",
    "trainer": "job_trainer",
    "lecturer": "job_lecturer",
  };

  // ⭐ خرائط تحويل للتخصصات
  final Map<String, String> _specializationMapping = {
    "doctor": "spec_psychiatrist",
    "psychology": "spec_psych_counseling",
    "psychiatrist": "spec_psychiatrist",
    "psychologist": "spec_psychologist",
    "life_coach": "spec_life_coach",
    "family_counselor": "spec_family_counselor",
    "specialist": "spec_specialist",
    "consultant": "spec_consultant",
  };

  final List<String> _positions = [
    "job_consultant_title",
    "job_senior",
    "job_specialist",
    "job_trainer",
    "job_lecturer",
  ];

  final Map<String, String> _experienceMapping = {
    "2": "exp_2_years",
    "3": "exp_3_years",
    "5": "exp_5_years",
    "10": "exp_10_years",
    "11": "exp_more_than_10_years",
  };

  final List<String> _specializations = [
    "spec_psych_counseling",
    "spec_psychiatrist",
    "spec_psychologist",
    "spec_life_coach",
    "spec_family_counselor",
  ];

  final List<Map<String, String>> _experienceOptions = [
    {"display": "exp_2_years", "value": "2"},
    {"display": "exp_3_years", "value": "3"},
    {"display": "exp_5_years", "value": "5"},
    {"display": "exp_10_years", "value": "10"},
    {"display": "exp_more_than_10_years", "value": "11"},
  ];

  String? _mapFromBackend(String? backendValue, Map<String, String> mapping) {
    if (backendValue == null) return null;
    if (mapping.containsKey(backendValue)) {
      return mapping[backendValue];
    }
    final matchingEntry = mapping.entries.firstWhere(
      (entry) => entry.value == backendValue,
      orElse: () => const MapEntry("", ""),
    );
    if (matchingEntry.key.isNotEmpty) {
      return matchingEntry.value;
    }
    return backendValue;
  }

  String? _mapToBackend(String? displayValue, Map<String, String> mapping) {
    if (displayValue == null) return null;
    final matchingEntry = mapping.entries.firstWhere(
      (entry) => entry.value == displayValue,
      orElse: () => const MapEntry("", ""),
    );
    if (matchingEntry.key.isNotEmpty) {
      return matchingEntry.key;
    }
    final directMatch = mapping.entries.firstWhere(
      (entry) => entry.key == displayValue,
      orElse: () => const MapEntry("", ""),
    );
    return directMatch.key.isNotEmpty ? directMatch.key : displayValue;
  }

  String? _normalizeExperienceFromBackend(String? backendValue) {
    if (backendValue == null) return null;
    final normalized = backendValue.replaceAll(" من الخبرة", "");
    if (_experienceMapping.values.contains(normalized)) {
      return normalized;
    }
    final match = RegExp(r'(\d+)').firstMatch(backendValue);
    if (match != null) {
      final years = match.group(1);
      return _experienceMapping[years] ?? backendValue;
    }
    return backendValue;
  }

  String _getValueFromExperience(String displayValue) {
    if (displayValue == "exp_2_years" || displayValue.contains("سنتين"))
      return "2";
    if (displayValue == "exp_3_years" || displayValue.contains("3 سنوات"))
      return "3";
    if (displayValue == "exp_5_years" || displayValue.contains("5 سنوات"))
      return "5";
    if (displayValue == "exp_10_years" || displayValue.contains("10 سنوات"))
      return "10";
    if (displayValue == "exp_more_than_10_years" ||
        displayValue.contains("أكثر من"))
      return "11";
    final match = RegExp(r'(\d+)').firstMatch(displayValue);
    return match?.group(1) ?? displayValue;
  }

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _currentVideoUrl;
  bool _controllersInitialized = false;

  bool get _isFormValid =>
      _uiCubit.state.nameError == null && _uiCubit.state.usernameError == null;

  @override
  void initState() {
    super.initState();
    _uiCubit = EditPersonalDataUiCubit();
    _nameController = TextEditingController();
    _idController = TextEditingController();
    _bioController = TextEditingController();
    _usernameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    _disposeVideoPlayer();
    _uiCubit.close();
    super.dispose();
  }

  Future<void> _disposeVideoPlayer() async {
    try {
      if (_chewieController != null) {
        _chewieController!.pause();
        _chewieController!.dispose();
        _chewieController = null;
      }
      if (_videoPlayerController != null) {
        await _videoPlayerController!.pause();
        await _videoPlayerController!.dispose();
        _videoPlayerController = null;
      }
      _currentVideoUrl = null;
    } catch (e) {
      debugPrint('Error disposing video player: $e');
    }
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    if (_currentVideoUrl == videoUrl &&
        _videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      return;
    }

    await _disposeVideoPlayer();
    _currentVideoUrl = videoUrl;

    if (!mounted) return;

    _uiCubit.setVideoLoading(true);
    _uiCubit.updateProgress(0.0);

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      _simulateProgress();

      await _videoPlayerController!.initialize();

      if (mounted) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: false,
          looping: false,
          showControls: true,
          allowFullScreen: true,
          allowMuting: true,
          showControlsOnInitialize: false,
          placeholder: Container(
            color: AppColors.secondary100,
            child: Center(
              child: Icon(
                Icons.video_library,
                size: 50.w,
                color: AppColors.primary300,
              ),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                context.tr("video_load_error"),
                style: Styles.textStyle14.copyWith(color: AppColors.kRedColor),
              ),
            );
          },
        );
        _uiCubit.updateProgress(1.0);
        _uiCubit.setVideoLoading(false);
      }
    } catch (e) {
      if (mounted) {
        _chewieController = null;
        _videoPlayerController = null;
        _uiCubit.updateProgress(0.0);
        _uiCubit.setVideoLoading(false);
      }
    }
  }

  void _simulateProgress() {
    _uiCubit.updateProgress(0.0);
    const steps = 20;
    const duration = Duration(milliseconds: 100);

    for (int i = 1; i <= steps; i++) {
      // Warning: this loop creates multiple futures.
      // It's better to cancel value if unmounted but loop runs locally.
      Future.delayed(duration * i, () {
        if (mounted && _uiCubit.state.isVideoLoading) {
          _uiCubit.updateProgress(i / steps);
        }
      });
    }
  }

  Future<void> _pickVideo(EditPersonalDataCubit cubit) async {
    final SnackBarService snackBarService = SnackBarService();
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final int fileSizeInBytes = await file.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 10) {
        if (mounted) {
          snackBarService.showSnackBar(
            context: context,
            text: context.tr("video_size_error_10mb"),
            isError: true,
          );
        }
        return;
      }

      cubit.updateVideoFile(file, previewUrl: pickedFile.path);

      if (mounted) {
        _uiCubit.setVideoLoading(true);
        _uiCubit.updateProgress(0.0);
      }

      await _disposeVideoPlayer();

      try {
        _videoPlayerController = VideoPlayerController.file(file);

        _simulateProgress();

        await _videoPlayerController!.initialize();

        if (mounted) {
          _currentVideoUrl = pickedFile.path;
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: false,
            looping: false,
            showControls: true,
            allowFullScreen: true,
            allowMuting: true,
            showControlsOnInitialize: false,
            placeholder: Container(
              color: AppColors.secondary100,
              child: Center(
                child: Icon(
                  Icons.video_library,
                  size: 50.w,
                  color: AppColors.primary300,
                ),
              ),
            ),
          );
          _uiCubit.updateProgress(1.0);
          _uiCubit.setVideoLoading(false);
        }
      } catch (e) {
        if (mounted) {
          _uiCubit.updateProgress(0.0);
          _uiCubit.setVideoLoading(false);
          _chewieController = null;
          _videoPlayerController = null;

          snackBarService.showSnackBar(
            context: context,
            text: context.tr("video_load_error"),
            isError: true,
          );
        }
      }
    }
  }

  Future<void> _pickAvatarImage(EditPersonalDataCubit cubit) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      cubit.updateImageFile(File(pickedFile.path));
    }
  }

  void _removeVideo(EditPersonalDataCubit cubit) async {
    cubit.removeVideo();

    if (mounted) {
      _uiCubit.updateProgress(0.0);
      _uiCubit.setVideoLoading(false);
    }

    await _disposeVideoPlayer();

    if (mounted) {
      _currentVideoUrl = null;
      _chewieController = null;
      _videoPlayerController = null;
      // Force rebuild to remove video player widget
      _uiCubit.setVideoLoading(
        false,
      ); // Emit again or different? Just ensure state reflects 'no video'.
      // Actually _uiCubit.state.isVideoLoading is false already.
      // But parent widget rebuilds because of `cubit` (Main Logic Cubit) state change potentially?
      // Yes, main cubit emitted changes.
      // But _chewieController is local.
      // We need to ensure _buildVideoSection sees null controller.
      // The build method reads _chewieController directly.
      // Since main cubit emits, build() is called.
    }
  }

  void _initializeControllers(EditPersonalDataState state) {
    if (_controllersInitialized || state.profile == null) return;

    _nameController.text = state.profile!.name;
    _idController.text = state.profile!.userName;
    _bioController.text = state.profile!.aboutYou ?? '';
    final username = state.profile!.userName;
    _usernameController.text = username.startsWith('@')
        ? username.substring(1)
        : username;

    String? jobGradeDisplay;
    final jobGrade = state.currentData.jobGrade;
    if (jobGrade != null && jobGrade.isNotEmpty) {
      jobGradeDisplay = _mapFromBackend(jobGrade, _positionMapping);
      if (jobGradeDisplay == null || jobGradeDisplay.isEmpty) {
        jobGradeDisplay = jobGrade;
      }
    }

    String? specializationDisplay;
    final specialization = state.currentData.professionalSpecialization;
    if (specialization != null && specialization.isNotEmpty) {
      specializationDisplay = _mapFromBackend(
        specialization,
        _specializationMapping,
      );
      if (specializationDisplay == null || specializationDisplay.isEmpty) {
        specializationDisplay = specialization;
      }
    }

    String? experienceDisplay;
    String? experienceValue;
    final yearsExp = state.currentData.yearsOfExperience;
    if (yearsExp != null && yearsExp.isNotEmpty) {
      experienceDisplay = _normalizeExperienceFromBackend(yearsExp);
      experienceValue = _getValueFromExperience(experienceDisplay!);
    }

    _uiCubit.initializeFields(
      position: jobGradeDisplay,
      specialization: specializationDisplay,
      experienceDisplay: experienceDisplay,
      experienceValue: experienceValue,
    );

    _controllersInitialized = true;

    final videoUrl = state.videoPreviewUrl;
    if (videoUrl != null &&
        videoUrl.isNotEmpty &&
        videoUrl.startsWith('http')) {
      _initializeVideoPlayer(videoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<EditPersonalDataCubit>()),
        BlocProvider.value(value: _uiCubit),
      ],
      child: BlocConsumer<EditPersonalDataCubit, EditPersonalDataState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            showSafeSnackBar(
              context: context,
              text: state.errorMessage!,
              isError: true,
            );
            context.read<EditPersonalDataCubit>().clearError();
          }

          if (state.state == CubitStates.success) {
            if (state.successMessage != null) {
              showSafeSnackBar(
                context: context,
                text: state.successMessage!,
                isSuccess: true,
              );
              context.read<EditPersonalDataCubit>().clearSuccess();
              // ⭐ إرجاع البروفايل المحدث للصفحة السابقة
              if (state.profile != null) {
                Navigator.pop(context, state.profile);
              }
            }

            if (state.profile != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_controllersInitialized) {
                  _initializeControllers(state);
                }

                final videoUrl = state.videoPreviewUrl;
                if (videoUrl != null &&
                    videoUrl.isNotEmpty &&
                    videoUrl.startsWith('http') &&
                    _currentVideoUrl != videoUrl) {
                  _initializeVideoPlayer(videoUrl);
                }
              });
            }
          }
        },
        builder: (context, state) {
          final cubit = context.read<EditPersonalDataCubit>();

          return PopScope(
            canPop: !state.hasChanges || state.isSaving,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              final shouldPop = await _showUnsavedChangesDialog(context, cubit);
              if (shouldPop && context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Scaffold(
              body: AdvisorBackground(
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 105.h,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                AssetsData.homeBarBackgroundImage,
                              ),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SimpleAppBar(
                                title: context.tr("edit_personal_data"),
                                isLargeTitle: true,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25.0,
                                ),
                                child: Column(
                                  children: [
                                    Gap(32.h),

                                    if (state.state == CubitStates.loading)
                                      _buildSkeletonLoading()
                                    else if (state.state == CubitStates.failure)
                                      Center(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: AppColors.kRedColor,
                                              size: 48.w,
                                            ),
                                            Gap(16.h),
                                            Text(
                                              state.errorMessage ??
                                                  context.tr("data_load_error"),
                                              textAlign: TextAlign.center,
                                              style: Styles.textStyle14
                                                  .copyWith(
                                                    color:
                                                        AppColors.secondary600,
                                                  ),
                                            ),
                                            Gap(24.h),
                                            CustomBotton(
                                              width: context.width * 0.6,
                                              title: context.tr("retry"),
                                              onPressed: () =>
                                                  cubit.loadProfileData(),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: _buildAvatarImageSection(
                                              cubit,
                                              state,
                                            ),
                                          ),
                                          Gap(20.h),

                                          BlocBuilder<
                                            EditPersonalDataUiCubit,
                                            EditPersonalDataUiState
                                          >(
                                            builder: (context, uiState) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ProfileTextField(
                                                    controller: _nameController,
                                                    maxLength: 24,
                                                    onChanged: (value) {
                                                      _uiCubit.validateName(
                                                        value,
                                                      );
                                                      cubit.updateName(value);
                                                    },
                                                    hint: context.tr(
                                                      "enter_name",
                                                    ),
                                                  ),
                                                  if (uiState.nameError != null)
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        top: 4.h,
                                                        right: 8.w,
                                                      ),
                                                      child: Text(
                                                        uiState.nameError!,
                                                        style: Styles
                                                            .textStyle12
                                                            .copyWith(
                                                              color: AppColors
                                                                  .kRedColor,
                                                            ),
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                          ),
                                          Gap(11.h),
                                          _buildUsernameField(cubit),
                                          Gap(11.h),

                                          _buildSpecializationDropdown(cubit),
                                          Gap(11.h),

                                          _buildPositionDropdown(cubit),
                                          Gap(11.h),

                                          _buildExperienceDropdown(cubit),
                                          Gap(11.h),

                                          ProfileTextField(
                                            controller: _bioController,
                                            onChanged: (value) =>
                                                cubit.updateBio(value),
                                            hint: context.tr("bio_hint"),
                                            maxLines: 4,
                                          ),
                                          Gap(6.h),
                                          Text(
                                            '${_bioController.text.length}/250',
                                            style: Styles.textStyle14.copyWith(
                                              color:
                                                  _bioController.text.length >
                                                      250
                                                  ? AppColors.kRedColor
                                                  : AppColors.secondary400,
                                            ),
                                          ),
                                          Gap(25.h),

                                          _buildVideoSection(cubit, state),
                                          Gap(35.h),

                                          BlocBuilder<
                                            EditPersonalDataUiCubit,
                                            EditPersonalDataUiState
                                          >(
                                            builder: (context, uiState) {
                                              return CustomBotton(
                                                height: 54.h,
                                                width: double.infinity,
                                                useGradient: true,
                                                title: state.isSaving
                                                    ? context.tr("saving")
                                                    : context.tr("save"),
                                                onPressed:
                                                    state.isSaving ||
                                                        !state.hasChanges ||
                                                        !_isFormValid
                                                    ? null
                                                    : () => cubit.saveChanges(),
                                              );
                                            },
                                          ),
                                          Gap(40.h),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showUnsavedChangesDialog(
    BuildContext context,
    EditPersonalDataCubit cubit,
  ) async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          context.tr("unsaved_changes_title"),
          textAlign: TextAlign.center,
          style: Styles.textStyle18SemiBold.copyWith(
            color: AppColors.primary800,
          ),
        ),
        content: Text(
          context.tr("unsaved_changes_message"),
          textAlign: TextAlign.center,
          style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomBotton(
                  height: 48.h,
                  width: double.infinity,
                  useGradient: true,
                  title: context.tr("save_and_exit"),
                  onPressed: () => Navigator.pop(context, 'save'),
                ),
                Gap(12.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomBotton(
                        height: 48.h,
                        title: context.tr("discard_and_exit"),
                        backGroundcolor: AppColors.secondary100,
                        titleColor: AppColors.kRedColor,
                        onPressed: () => Navigator.pop(context, 'discard'),
                        elevation: 0,
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: CustomBotton(
                        height: 48.h,
                        title: context.tr("keep_editing"),
                        backGroundcolor: AppColors.secondary100,
                        titleColor: AppColors.secondary700,
                        onPressed: () => Navigator.pop(context, 'keep'),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (result == 'save') {
      if (context.mounted) {
        await cubit.saveChanges();
      }
      return false;
    } else if (result == 'discard') {
      return true;
    }
    return false;
  }

  Widget _buildUsernameField(EditPersonalDataCubit cubit) {
    return BlocBuilder<EditPersonalDataUiCubit, EditPersonalDataUiState>(
      builder: (context, uiState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.kWhiteColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: uiState.usernameError != null
                      ? AppColors.kRedColor
                      : AppColors.primary100,
                ),
              ),
              child: Row(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      '@',
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.primary200,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _usernameController,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      maxLength: 24,
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.secondary800,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: context.tr("enter_username"),
                        hintStyle: Styles.textStyle14.copyWith(
                          color: AppColors.primary200,
                        ),
                        counterText: "",
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      onChanged: (value) {
                        if (value.contains('@')) {
                          final cleaned = value.replaceAll('@', '');
                          _usernameController.value = _usernameController.value
                              .copyWith(
                                text: cleaned,
                                selection: TextSelection.collapsed(
                                  offset: cleaned.length,
                                ),
                              );
                          value = cleaned;
                        }
                        _uiCubit.validateUsername(value);
                        cubit.updateUsername('@$value');
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (uiState.usernameError != null)
              Padding(
                padding: EdgeInsets.only(top: 4.h, right: 8.w),
                child: Text(
                  uiState.usernameError!,
                  style: Styles.textStyle12.copyWith(
                    color: AppColors.kRedColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSkeletonLoading() {
    return Column(
      children: [
        Center(
          child: Container(
            height: 150.h,
            width: 155.w,
            decoration: BoxDecoration(
              color: AppColors.secondary100,
              borderRadius: BorderRadius.circular(32.r),
            ),
            child: Center(
              child: Icon(
                Icons.person,
                size: 50.w,
                color: AppColors.secondary300,
              ),
            ),
          ),
        ),
        Gap(20.h),
        Container(
          height: 48.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secondary100,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        // ... (truncated parts of skeleton, I will use simplified or standard if needed, or stick to what I saw)
        // I will copy what I saw in previous view
        Gap(11.h),
        Container(
          height: 48.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secondary100,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        Gap(11.h),
        Container(
          height: 48.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secondary100,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        Gap(11.h),
        Container(
          height: 150.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secondary100,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        Gap(25.h),
        Container(
          height: 250.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secondary100,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        Gap(35.h),
        Container(
          height: 48.h,
          width: context.width * 0.9,
          decoration: BoxDecoration(
            color: AppColors.secondary100,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarImageSection(
    EditPersonalDataCubit cubit,
    EditPersonalDataState state,
  ) {
    final imageUrl = state.imagePreviewUrl;
    final imageFile = state.imageFile;
    // ⭐ تحقق إذا كانت الصورة محذوفة
    final isImageDeleted = state.currentData.image == "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap:
                  !isImageDeleted &&
                      (imageFile != null ||
                          (imageUrl != null && imageUrl.isNotEmpty))
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageView(
                            imageUrl: imageUrl,
                            imageFile: imageFile,
                            heroTag: 'advisor_edit_profile_avatar',
                            userName: state.profile?.name,
                          ),
                        ),
                      );
                    }
                  : null,
              child: Hero(
                tag: 'advisor_edit_profile_avatar',
                child: Container(
                  height: 150.h,
                  width: 155.w,
                  decoration: BoxDecoration(
                    color: AppColors.hintText,
                    borderRadius: BorderRadius.circular(32.r),
                  ),
                  child: isImageDeleted
                      ? _buildDefaultAvatar()
                      : imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(32.r),
                          child: Image.file(
                            imageFile,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          ),
                        )
                      : imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(32.r),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          ),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _pickAvatarImage(cubit),
                child: AppImage(AssetsData.addCertificateImage, width: 30.w),
              ),
            ),
            if (!isImageDeleted &&
                (imageFile != null ||
                    (imageUrl != null && imageUrl.isNotEmpty)))
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => cubit.removeImage(),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.kWhiteColor,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.primary500,
                      size: 18.w,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32.r),
      child: Container(
        color: AppColors.primary100,
        child: Center(
          child: Icon(Icons.person, size: 60.w, color: AppColors.primary300),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
    required BuildContext
    context, // Pass context explicitly if needed, but we occupy class method
    bool isPosition = false,
  }) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    List<String> effectiveItems = List.from(items);
    if (value != null && !effectiveItems.contains(value)) {
      effectiveItems = [value, ...effectiveItems];
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: isTablet ? 12.h : 0,
      ),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          borderRadius: BorderRadius.circular(12.r),
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.inactiveColor,
            size: 24.w,
          ),
          elevation: 16,
          style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
          hint: Text(
            context.tr(hint),
            style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
            textAlign: TextAlign.right,
          ),
          onChanged: onChanged,
          items: effectiveItems.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                context.tr(item),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: Styles.textStyle14.copyWith(
                  color: !items.contains(item)
                      ? AppColors.secondary400
                      : AppColors.secondary800,
                  fontStyle: !items.contains(item)
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            );
          }).toList(),
          dropdownColor: AppColors.kWhiteColor,
        ),
      ),
    );
  }

  Widget _buildVideoSection(
    EditPersonalDataCubit cubit,
    EditPersonalDataState state,
  ) {
    return BlocBuilder<EditPersonalDataUiCubit, EditPersonalDataUiState>(
      builder: (context, uiState) {
        final videoFile = state.videoFile;
        final videoPreviewUrl = state.videoPreviewUrl;
        final isVideoDeleted = state.currentData.video == "";

        final hasVideo =
            videoFile != null ||
            (!isVideoDeleted &&
                videoPreviewUrl != null &&
                videoPreviewUrl.isNotEmpty &&
                _chewieController != null);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (uiState.isVideoLoading)
              Container(
                width: double.infinity,
                height: 250.h,
                decoration: BoxDecoration(
                  color: AppColors.kWhiteColor,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.primary100, width: 1.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 60.w,
                        height: 60.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 60.w,
                              height: 60.w,
                              child: CircularProgressIndicator(
                                value: uiState.uploadProgress,
                                color: AppColors.primary500,
                                backgroundColor: AppColors.primary100,
                                strokeWidth: 4,
                              ),
                            ),
                            Text(
                              '${(uiState.uploadProgress * 100).toInt()}%',
                              style: Styles.textStyle14.copyWith(
                                color: AppColors.primary500,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(16.h),
                      Text(
                        context.tr("loading_video"),
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.secondary600,
                        ),
                      ),
                      Gap(8.h),
                      Text(
                        '${(uiState.uploadProgress * 100).toInt()}%',
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.secondary400,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (hasVideo)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.kWhiteColor,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.primary100, width: 1.0),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 250.h,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child:
                              _chewieController != null &&
                                  _chewieController!
                                      .videoPlayerController
                                      .value
                                      .isInitialized
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Chewie(controller: _chewieController!),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.video_library_rounded,
                                        size: 50.w,
                                        color: Colors.white70,
                                      ),
                                      Gap(8.h),
                                      Text(
                                        videoFile != null
                                            ? context.tr("loading_new_video")
                                            : context.tr("loading_video"),
                                        style: Styles.textStyle14.copyWith(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => _removeVideo(cubit),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.kWhiteColor,
                              ),
                              child: Icon(
                                Icons.close,
                                color: AppColors.primary500,
                                size: 18.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (videoFile != null)
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16.sp,
                              color: AppColors.primary500,
                            ),
                            Gap(4.w),
                            Text(
                              context.tr("new_video_selected"),
                              style: Styles.textStyle12.copyWith(
                                color: AppColors.secondary600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: () => _pickVideo(cubit),
                child: Container(
                  height: 250.h,
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: AppColors.kWhiteColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.primary100, width: 1.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppImage(
                        AssetsData.kvideoIcon,
                        width: 60.w,
                        height: 60.h,
                      ),
                      Gap(12.h),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          textAlign: TextAlign.center,
                          isVideoDeleted
                              ? context.tr("video_deleted_click_to_add")
                              : context.tr("click_to_upload_intro_video"),
                          style: Styles.textStyle16.copyWith(
                            color: isVideoDeleted
                                ? AppColors.kRedColor
                                : AppColors.secondary600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Gap(8.h),
            Text(
              context.tr("video_size_limit_10mb"),
              style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpecializationDropdown(EditPersonalDataCubit cubit) {
    return BlocBuilder<EditPersonalDataUiCubit, EditPersonalDataUiState>(
      builder: (context, uiState) {
        return _buildDropdown(
          context: context,
          value: uiState.selectedSpecialization,
          items: _specializations,
          onChanged: (displayValue) {
            _uiCubit.updateSelectedSpecialization(displayValue);
            if (displayValue != null) {
              final backendValue = _mapToBackend(
                displayValue,
                _specializationMapping,
              );
              cubit.updateSpecialization(backendValue ?? displayValue);
            }
          },
          hint: 'select_specialization',
        );
      },
    );
  }

  Widget _buildPositionDropdown(EditPersonalDataCubit cubit) {
    return BlocBuilder<EditPersonalDataUiCubit, EditPersonalDataUiState>(
      builder: (context, uiState) {
        // Effective items logic in drop down takes care of it? No, need to pass it.
        // Wait, the dropdown widget handles effective items if I kept that logic.
        // Let's rely on _buildDropdown logic I wrote above.
        // But I need to handle effective items in _buildDropdown.
        return _buildDropdown(
          context: context,
          value: uiState.selectedPosition,
          items: _positions,
          onChanged: (displayValue) {
            _uiCubit.updateSelectedPosition(displayValue);
            if (displayValue != null) {
              final backendValue = _mapToBackend(
                displayValue,
                _positionMapping,
              );
              cubit.updatePosition(backendValue ?? displayValue);
            }
          },
          hint: 'select_position',
          isPosition: true,
        );
      },
    );
  }

  Widget _buildExperienceDropdown(EditPersonalDataCubit cubit) {
    return BlocBuilder<EditPersonalDataUiCubit, EditPersonalDataUiState>(
      builder: (context, uiState) {
        return _buildDropdown(
          context: context,
          value: uiState.selectedExperienceDisplay,
          items: _experienceOptions.map((e) => e["display"]!).toList(),
          onChanged: (displayValue) {
            final selected = _experienceOptions.firstWhere(
              (e) => e["display"] == displayValue,
              orElse: () => {
                "value": _getValueFromExperience(displayValue ?? ""),
              },
            );
            final val = selected["value"];
            _uiCubit.updateSelectedExperience(displayValue, val);

            if (val != null && val.isNotEmpty) {
              cubit.updateExperience(val);
            }
          },
          hint: 'select_experience_years',
        );
      },
    );
  }
}
