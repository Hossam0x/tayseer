import 'package:chewie/chewie.dart';
import 'package:tayseer/core/widgets/custtom_glass_button.dart';
import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/core/widgets/profile_text_field.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data_state.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data_ui_cubit.dart';
import 'package:tayseer/my_import.dart';

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

  final List<String> specializationKeys = [
    'marital_counseling',
    'premarital_counseling',
    'parenting_counseling',
    'children_issues',
    'adolescent_issues',
    'extended_family_relations',
    'domestic_violence_protection',
    'family_crisis_management',
    'divorce_counseling',
    'marital_sexual_counseling',
    'family_addiction',
    'family_mental_health',
  ];

  final List<String> jobLevelKeys = [
    'junior_counselor',
    'senior_counselor',
    'specialist_consultant',
    'lead_consultant',
  ];

  final List<String> experienceYearsKeys = [
    'experience_0_2',
    'experience_2_5',
    'experience_5_10',
    'experience_10_plus',
  ];

  String? _mapFromBackend(String? backendValue, List<String> allowedKeys) {
    if (backendValue == null || backendValue.isEmpty) return null;
    if (allowedKeys.contains(backendValue)) {
      return backendValue;
    }

    // Map numeric or bound-based values to keys for experience
    if (allowedKeys == experienceYearsKeys) {
      if (backendValue == '2' || backendValue == '0' || backendValue == '0-2') {
        return 'experience_0_2';
      }
      if (backendValue == '5' || backendValue == '3' || backendValue == '2-5') {
        return 'experience_2_5';
      }
      if (backendValue == '10' || backendValue == '5-10') {
        return 'experience_5_10';
      }
      if (backendValue == '11' || backendValue == '10+') {
        return 'experience_10_plus';
      }
    }

    return backendValue; // Fallback
  }

  String? _mapToBackend(String? displayValue) {
    return displayValue; // Since display is the key now
  }

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _currentVideoUrl;
  bool _controllersInitialized = false;

  bool get _isFormValid {
    final bioLength = _bioController.text.trim().length;
    final isBioValid = bioLength >= 3 && bioLength <= 250;
    return _uiCubit.state.nameError == null &&
        _uiCubit.state.usernameError == null &&
        isBioValid;
  }

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

    String? jobGradeDisplay = _mapFromBackend(
      state.currentData.jobGrade,
      jobLevelKeys,
    );

    String? specializationDisplay = _mapFromBackend(
      state.currentData.professionalSpecialization,
      specializationKeys,
    );

    String? experienceDisplay = _mapFromBackend(
      state.currentData.yearsOfExperience,
      experienceYearsKeys,
    );

    _uiCubit.initializeFields(
      position: jobGradeDisplay,
      specialization: specializationDisplay,
      experienceDisplay: experienceDisplay,
      experienceValue: experienceDisplay, // Fixed to same key
    );

    _controllersInitialized = true;
    if (mounted) {
      setState(() {});
    }

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
            canPop: !state.hasChanges && !state.isSaving,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;

              if (state.isSaving) return; // Prevent navigation during saving

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
                                              return ProfileTextField(
                                                controller: _nameController,
                                                maxLength: 24,
                                                minLength: 4,
                                                showCharacterCount: true,
                                                validationErrorKey:
                                                    'full_name_length_error',
                                                onChanged: (value) {
                                                  _uiCubit.validateName(
                                                    value,
                                                    context.tr(
                                                      'full_name_length_error',
                                                    ),
                                                  );
                                                  cubit.updateName(value);
                                                },
                                                hint: context.tr("enter_name"),
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
                                            maxLength: 250,
                                            minLength: 3,
                                            showCharacterCount: true,
                                            validationErrorKey:
                                                'bio_min_3_chars',
                                          ),
                                          Gap(12.h),
                                          CusttomGlassButton(
                                            text: context.tr(
                                              'generate_ai_content',
                                            ),
                                            showIcon:
                                                state.isAiState ==
                                                CubitStates.loading,

                                            onTap: () {
                                              cubit.enhanceTextWithGemini(
                                                context,
                                                _bioController,
                                              );
                                            },
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
                        _uiCubit.validateUsername(
                          value,
                          context.tr('username_length_error'),
                        );
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
                  !state.isSaving &&
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Upload Progress Ring (Like Add Story)
                    if (state.isSaving)
                      SizedBox(
                        width: 160.w,
                        height: 160.h,
                        child: CircularProgressIndicator(
                          value: state.uploadProgress > 0
                              ? state.uploadProgress
                              : null,
                          strokeWidth: 4,
                          color: AppColors.kprimaryColor,
                          backgroundColor: AppColors.secondary200,
                        ),
                      ),
                    Container(
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
                    // Percentage Text Overlay
                    if (state.isSaving)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          '${(state.uploadProgress * 100).toInt()}%',
                          style: Styles.textStyle14.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (!state.isSaving)
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _pickAvatarImage(cubit),
                  child: AppImage(AssetsData.addCertificateImage, width: 30.w),
                ),
              ),
            if (!state.isSaving &&
                !isImageDeleted &&
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
          items: specializationKeys,
          onChanged: (displayValue) {
            _uiCubit.updateSelectedSpecialization(displayValue);
            if (displayValue != null) {
              final backendValue = _mapToBackend(displayValue);
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
        return _buildDropdown(
          context: context,
          value: uiState.selectedPosition,
          items: jobLevelKeys,
          onChanged: (displayValue) {
            _uiCubit.updateSelectedPosition(displayValue);
            if (displayValue != null) {
              final backendValue = _mapToBackend(displayValue);
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
          items: experienceYearsKeys,
          onChanged: (displayValue) {
            _uiCubit.updateSelectedExperience(displayValue, displayValue);

            if (displayValue != null && displayValue.isNotEmpty) {
              cubit.updateExperience(displayValue);
            }
          },
          hint: 'select_experience_years',
        );
      },
    );
  }
}
