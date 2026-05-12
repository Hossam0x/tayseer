import 'package:chewie/chewie.dart';
import 'package:tayseer/core/utils/advisor_video_cache.dart';
import 'package:tayseer/core/utils/advisor_video_event_bus.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_state.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_ui_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/edit_personal_data/edit_personal_data_form.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/edit_personal_data/edit_personal_data_skeleton.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/edit_personal_data/edit_personal_data_unsaved_dialog.dart';
import 'package:tayseer/my_import.dart';

class EditPersonalDataView extends StatefulWidget {
  const EditPersonalDataView({super.key});

  @override
  State<EditPersonalDataView> createState() => _EditPersonalDataViewState();
}

class _EditPersonalDataViewState extends State<EditPersonalDataView> {
  late final TextEditingController _nameController;
  late final TextEditingController _idController;
  late final TextEditingController _bioController;
  late final TextEditingController _usernameController;
  late final EditPersonalDataUiCubit _uiCubit;

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _currentVideoUrl;
  bool _controllersInitialized = false;

  static const _experienceYearsKeys = [
    'experience_0_2',
    'experience_2_5',
    'experience_5_10',
    'experience_10_plus',
  ];

  bool get _isFormValid {
    return _uiCubit.state.nameError == null &&
        _uiCubit.state.usernameError == null;
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
      _chewieController?.pause();
      _chewieController?.dispose();
      _chewieController = null;
      await _videoPlayerController?.pause();
      await _videoPlayerController?.dispose();
      _videoPlayerController = null;
      _currentVideoUrl = null;
    } catch (e) {
      debugPrint('Error disposing video player: $e');
    }
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    if (_currentVideoUrl == videoUrl &&
        _videoPlayerController?.value.isInitialized == true)
      return;

    await _disposeVideoPlayer();
    _currentVideoUrl = videoUrl;
    if (!mounted) return;

    if (videoUrl.startsWith('http')) {
      AdvisorVideoCache.instance.updateUrl(videoUrl);
      return;
    }

    _uiCubit.setVideoLoading(true);
    _uiCubit.updateProgress(0.0);
    _simulateProgress();

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      await _videoPlayerController!.initialize();
      if (mounted) {
        _chewieController = _buildChewieController(_videoPlayerController!);
        _uiCubit.updateProgress(1.0);
        _uiCubit.setVideoLoading(false);
      }
    } catch (_) {
      if (mounted) {
        _chewieController = null;
        _videoPlayerController = null;
        _uiCubit.updateProgress(0.0);
        _uiCubit.setVideoLoading(false);
      }
    }
  }

  ChewieController _buildChewieController(VideoPlayerController vpc) {
    return ChewieController(
      videoPlayerController: vpc,
      autoPlay: false,
      looping: false,
      showControls: true,
      allowFullScreen: true,
      allowMuting: true,
      showControlsOnInitialize: false,
    );
  }

  void _simulateProgress() {
    for (int i = 1; i <= 20; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted && _uiCubit.state.isVideoLoading) {
          _uiCubit.updateProgress(i / 20);
        }
      });
    }
  }

  Future<void> _pickVideo(EditPersonalDataCubit cubit) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final sizeInMB = await file.length() / (1024 * 1024);

    if (sizeInMB > 10) {
      if (mounted) {
        showSafeSnackBar(
          context: context,
          text: context.tr("video_size_error_10mb"),
          isError: true,
        );
      }
      return;
    }

    cubit.updateVideoFile(file, previewUrl: pickedFile.path);
    if (!mounted) return;
    _uiCubit.setVideoLoading(true);
    _uiCubit.updateProgress(0.0);
    await _disposeVideoPlayer();
    _simulateProgress();

    try {
      _videoPlayerController = VideoPlayerController.file(file);
      await _videoPlayerController!.initialize();
      if (mounted) {
        _currentVideoUrl = pickedFile.path;
        _chewieController = _buildChewieController(_videoPlayerController!);
        _uiCubit.updateProgress(1.0);
        _uiCubit.setVideoLoading(false);
      }
    } catch (_) {
      if (mounted) {
        _chewieController = null;
        _videoPlayerController = null;
        _uiCubit.updateProgress(0.0);
        _uiCubit.setVideoLoading(false);
        showSafeSnackBar(
          context: context,
          text: context.tr("video_load_error"),
          isError: true,
        );
      }
    }
  }

  Future<void> _pickAvatarImage(EditPersonalDataCubit cubit) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) cubit.updateImageFile(File(pickedFile.path));
  }

  Future<void> _removeVideo(EditPersonalDataCubit cubit) async {
    cubit.removeVideo();
    _uiCubit.updateProgress(0.0);
    _uiCubit.setVideoLoading(false);
    await _disposeVideoPlayer();
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

    _uiCubit.initializeFields(
      position: _mapFromBackend(state.currentData.jobGrade, const [
        'junior_counselor',
        'senior_counselor',
        'specialist_consultant',
        'lead_consultant',
      ]),
      specialization:
          _mapFromBackend(state.currentData.professionalSpecialization, const [
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
          ]),
      experienceDisplay: _mapFromBackend(
        state.currentData.yearsOfExperience,
        _experienceYearsKeys,
      ),
      experienceValue: _mapFromBackend(
        state.currentData.yearsOfExperience,
        _experienceYearsKeys,
      ),
    );

    _controllersInitialized = true;
    if (mounted) setState(() {});

    final videoUrl = state.videoPreviewUrl;
    if (videoUrl != null &&
        videoUrl.isNotEmpty &&
        videoUrl.startsWith('http')) {
      _initializeVideoPlayer(videoUrl);
    }
  }

  String? _mapFromBackend(String? value, List<String> keys) {
    if (value == null || value.isEmpty) return null;
    if (keys.contains(value)) return value;
    if (keys == _experienceYearsKeys) {
      if (['2', '0', '0-2'].contains(value)) return 'experience_0_2';
      if (['5', '3', '2-5'].contains(value)) return 'experience_2_5';
      if (['10', '5-10'].contains(value)) return 'experience_5_10';
      if (['11', '10+'].contains(value)) return 'experience_10_plus';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<EditPersonalDataCubit>()..loadProfileData(),
        ),
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
                text: context.tr(state.successMessage!),
                isSuccess: true,
              );
              context.read<EditPersonalDataCubit>().clearSuccess();

              final newVideoUrl = state.videoPreviewUrl ?? '';
              if (newVideoUrl.isNotEmpty && newVideoUrl.startsWith('http')) {
                AdvisorVideoCache.instance.updateUrl(newVideoUrl);
                AdvisorVideoEventBus.instance.fire(newVideoUrl);
              }
              if (state.profile != null && mounted) {
                Navigator.pop(context, state.profile);
              }
            }

            if (state.profile != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_controllersInitialized) _initializeControllers(state);
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
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop || state.isSaving) return;
              final shouldPop = await _showUnsavedChangesDialog(context, cubit);
              if (shouldPop && context.mounted) Navigator.pop(context);
            },
            child: Scaffold(
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: AdvisorBackground(
                  child: SingleChildScrollView(
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 105.h,
                          child: DecoratedBox(
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
                                        const EditPersonalDataSkeleton()
                                      else if (state.state ==
                                          CubitStates.failure)
                                        CustomErrorView(
                                          verticalPadding: 100,
                                          message:
                                              state.errorMessage ??
                                              context.tr("data_load_error"),
                                          onRetry: cubit.loadProfileData,
                                        )
                                      else
                                        EditPersonalDataForm(
                                          cubit: cubit,
                                          state: state,
                                          uiCubit: _uiCubit,
                                          nameController: _nameController,
                                          bioController: _bioController,
                                          usernameController:
                                              _usernameController,
                                          chewieController: _chewieController,
                                          onPickImage: () =>
                                              _pickAvatarImage(cubit),
                                          onPickVideo: () => _pickVideo(cubit),
                                          onRemoveVideo: () =>
                                              _removeVideo(cubit),
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
      builder: (_) => EditPersonalDataUnsavedDialog(isFormValid: _isFormValid),
    );

    if (result == 'save' && context.mounted) {
      await cubit.saveChanges();
      return false;
    }
    return result == 'discard';
  }
}
