import 'package:chewie/chewie.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data_state.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data_cubit.dart';
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

  String? _selectedPosition;
  String? _selectedExperience;
  String? _selectedSpecialization;

  // قوائم الاختيار
  final List<String> _positions = ["استشاري", "أخصائي", "مدرب", "محاضر"];
  final List<String> _experiences = [
    "سنتين",
    "3 سنوات",
    "5 سنوات",
    "10 سنوات",
    "أكثر من 10 سنوات",
  ];
  final List<String> _specializations = [
    "استشاري نفسي وعلاقات زوجية",
    "طبيب نفسي",
    "أخصائي نفسي",
    "مدرب حياة",
    "مستشار أسري",
  ];

  // Video player controllers
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // Track video URL to avoid reinitializing
  String? _currentVideoUrl;

  // Track if controllers are initialized
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _idController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _bioController.dispose();
    _disposeVideoPlayer();
    super.dispose();
  }

  void _disposeVideoPlayer() async {
    if (_chewieController != null) {
      _chewieController!.dispose();
      _chewieController = null;
    }
    if (_videoPlayerController != null) {
      await _videoPlayerController!.dispose();
      _videoPlayerController = null;
    }
    _currentVideoUrl = null;
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    // Don't reinitialize if it's the same video
    if (_currentVideoUrl == videoUrl && _videoPlayerController != null) {
      return;
    }

    // Dispose old player
    _disposeVideoPlayer();

    // Set current video URL
    _currentVideoUrl = videoUrl;

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      await _videoPlayerController!.initialize();

      if (mounted) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: false,
            looping: false,
            showControls: true,
            placeholder: Container(
              color: AppColors.secondary100,
              child: Center(
                child: Icon(
                  Icons.video_library,
                  size: 50,
                  color: AppColors.primary300,
                ),
              ),
            ),
            errorBuilder: (context, errorMessage) {
              return Center(
                child: Text(
                  'تعذر تحميل الفيديو',
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.kRedColor,
                  ),
                ),
              );
            },
          );
        });
      }
    } catch (e) {
      print('Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _chewieController = null;
          _videoPlayerController = null;
        });
      }
    }
  }

  Future<void> _pickVideo(EditPersonalDataCubit cubit) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSizeInBytes = await file.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: 'حجم الفيديو يجب أن يكون أقل من 4 ميجابايت',
            isError: true,
          ),
        );
        return;
      }

      // Dispose old video player
      _disposeVideoPlayer();

      // Initialize video player for local file
      try {
        _videoPlayerController = VideoPlayerController.file(file);

        await _videoPlayerController!.initialize();

        if (mounted) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController!,
              autoPlay: false,
              looping: false,
              showControls: true,
              placeholder: Container(
                color: AppColors.secondary100,
                child: Center(
                  child: Icon(
                    Icons.video_library,
                    size: 50,
                    color: AppColors.primary300,
                  ),
                ),
              ),
            );
          });
        }

        cubit.updateVideoFile(file, previewUrl: pickedFile.path);
      } catch (e) {
        print('Error initializing local video player: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(context, text: 'تعذر تحميل الفيديو', isError: true),
        );
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
    _disposeVideoPlayer();

    // استدعاء دالة الحذف في الـ Cubit
    cubit.removeVideo();

    setState(() {
      _currentVideoUrl = null;
    });
  }

  void _initializeControllers(EditPersonalDataState state) {
    if (_controllersInitialized || state.profile == null) return;

    // Initialize controllers once
    _nameController.text = state.profile!.name;
    _idController.text = state.profile!.userName;
    _bioController.text = state.profile!.aboutYou ?? '';

    // Set dropdown values from currentData
    _selectedPosition = state.currentData.jobGrade;
    _selectedExperience = state.currentData.yearsOfExperience;
    _selectedSpecialization = state.currentData.professionalSpecialization;

    _controllersInitialized = true;

    // Initialize video player
    final videoUrl = state.videoPreviewUrl;
    if (videoUrl != null &&
        videoUrl.isNotEmpty &&
        videoUrl.startsWith('http')) {
      _initializeVideoPlayer(videoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditPersonalDataCubit>(
      create: (_) => getIt<EditPersonalDataCubit>(),
      child: BlocConsumer<EditPersonalDataCubit, EditPersonalDataState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(context, text: state.errorMessage!, isError: true),
            );
            context.read<EditPersonalDataCubit>().clearError();
          }

          // Initialize controllers when data is loaded
          if (state.state == CubitStates.success && state.profile != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_controllersInitialized) {
                _initializeControllers(state);
              }

              // Update video player if URL changed
              final videoUrl = state.videoPreviewUrl;
              if (videoUrl != null &&
                  videoUrl.isNotEmpty &&
                  videoUrl.startsWith('http') &&
                  _currentVideoUrl != videoUrl) {
                _initializeVideoPlayer(videoUrl);
              }
            });
          }

          // // عرض رسالة النجاح بعد الحفظ
          // if (state.isSaving == false && state.errorMessage == null) {
          //   if (state.state == CubitStates.success &&
          //       state.hasChanges == false) {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       CustomSnackBar(
          //         context,
          //         text: 'تم حفظ البيانات بنجاح',
          //         isSuccess: true,
          //       ),
          //     );

          //     Future.delayed(const Duration(seconds: 1), () {
          //       if (mounted) Navigator.pop(context);
          //     });
          //   }
          // }
        },
        builder: (context, state) {
          final cubit = context.read<EditPersonalDataCubit>();

          return Scaffold(
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
                              title: 'تعديل البيانات الشخصية',
                              isLargeTitle: true,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                              ),
                              child: Column(
                                children: [
                                  Gap(32.h),

                                  // Loading state with Skeleton
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
                                                'حدث خطأ في تحميل البيانات',
                                            textAlign: TextAlign.center,
                                            style: Styles.textStyle14.copyWith(
                                              color: AppColors.secondary600,
                                            ),
                                          ),
                                          Gap(24.h),
                                          CustomBotton(
                                            width: context.width * 0.6,
                                            title: 'إعادة المحاولة',
                                            onPressed: () =>
                                                cubit.loadProfileData(),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Column(
                                      children: [
                                        // قسم الصورة الشخصية
                                        _buildAvatarImageSection(cubit, state),

                                        Gap(20.h),

                                        // حقل الاسم
                                        _buildTextField(
                                          controller: _nameController,
                                          hintText: 'أدخل اسمك',
                                          onChanged: (value) =>
                                              cubit.updateName(value),
                                        ),

                                        Gap(11.h),

                                        // حقل المعرف
                                        _buildTextField(
                                          controller: _idController,
                                          hintText: 'أدرف المعرف',
                                          prefixText: '@',
                                          readOnly: true,
                                        ),

                                        Gap(11.h),

                                        // Dropdown للتخصص
                                        _buildDropdown(
                                          value: _selectedSpecialization,
                                          items: _specializations,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedSpecialization = value;
                                            });
                                            if (value != null) {
                                              cubit.updateSpecialization(value);
                                            }
                                          },
                                          hint: 'اختر التخصص',
                                        ),

                                        Gap(11.h),

                                        // Dropdown للمنصب
                                        _buildDropdown(
                                          value: _selectedPosition,
                                          items: _positions,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedPosition = value;
                                            });
                                            if (value != null) {
                                              cubit.updatePosition(value);
                                            }
                                          },
                                          hint: 'اختر المنصب',
                                        ),

                                        Gap(11.h),

                                        // Dropdown للخبرة
                                        _buildDropdown(
                                          value: _selectedExperience,
                                          items: _experiences,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedExperience = value;
                                            });
                                            if (value != null) {
                                              cubit.updateExperience(value);
                                            }
                                          },
                                          hint: 'اختر سنوات الخبرة',
                                        ),

                                        Gap(11.h),

                                        // حقل السيرة الذاتية
                                        _buildBioField(cubit, state),

                                        Gap(25.h),

                                        // قسم رفع الفيديو مع Preview
                                        _buildVideoSection(cubit, state),

                                        Gap(35.h),

                                        // زر الحفظ
                                        CustomBotton(
                                          width: context.width * 0.9,
                                          useGradient: true,
                                          title: state.isSaving
                                              ? 'جاري الحفظ...'
                                              : 'حفظ',
                                          onPressed:
                                              state.isSaving ||
                                                  !state.hasChanges
                                              ? null
                                              : () => cubit.saveChanges(),
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
          );
        },
      ),
    );
  }

  // ============================================
  // 📌 WIDGET: SKELETON LOADING
  // ============================================
  Widget _buildSkeletonLoading() {
    return Column(
      children: [
        // Skeleton for avatar
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

        // Skeleton for text fields
        _buildSkeletonField(height: 48.h),
        Gap(11.h),
        _buildSkeletonField(height: 48.h),
        Gap(11.h),
        _buildSkeletonField(height: 48.h),
        Gap(11.h),
        _buildSkeletonField(height: 48.h),
        Gap(11.h),
        _buildSkeletonField(height: 48.h),
        Gap(11.h),

        // Skeleton for bio field
        Container(
          height: 150.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secondary100,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),

        Gap(25.h),

        // Skeleton for video section
        Container(
          height: 250.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secondary100,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.video_camera_back_rounded,
                  size: 40.w,
                  color: AppColors.secondary300,
                ),
                Gap(12.h),
                Text(
                  'جاري تحميل البيانات...',
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.secondary400,
                  ),
                ),
              ],
            ),
          ),
        ),

        Gap(35.h),

        // Skeleton for save button
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

  Widget _buildSkeletonField({required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondary100,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }

  Widget _buildAvatarImageSection(
    EditPersonalDataCubit cubit,
    EditPersonalDataState state,
  ) {
    final imageUrl = state.imagePreviewUrl;
    final imageFile = state.imageFile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            Container(
              height: 150.h,
              width: 155.w,
              decoration: BoxDecoration(
                color: AppColors.hintText,
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: imageFile != null
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
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                  : _buildDefaultAvatar(),
            ),

            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _pickAvatarImage(cubit),
                child: AppImage(AssetsData.addCertificateImage, width: 30.w),
              ),
            ),

            // زر حذف الصورة
            if (imageFile != null || (imageUrl != null && imageUrl.isNotEmpty))
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    cubit.removeImage();
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.kWhiteColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    String? prefixText,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
          readOnly: readOnly,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Styles.textStyle14.copyWith(
              color: AppColors.secondary400,
            ),
            prefixText: prefixText,
            prefixStyle: Styles.textStyle14.copyWith(
              color: AppColors.secondary800,
            ),
            filled: true,
            fillColor: readOnly ? AppColors.primary50 : AppColors.kWhiteColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary100, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary500, width: 2.0),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 10.h,
            ),
          ),
          style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: AppColors.kWhiteColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primary100, width: 1.0),
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
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.secondary800,
                  ),
                  hint: Text(
                    hint,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondary400,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  onChanged: onChanged,
                  items: items.map<DropdownMenuItem<String>>((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, textAlign: TextAlign.right),
                    );
                  }).toList(),
                  dropdownColor: AppColors.kWhiteColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBioField(
    EditPersonalDataCubit cubit,
    EditPersonalDataState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.kWhiteColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary100, width: 1.0),
          ),
          child: TextFormField(
            controller: _bioController,
            maxLines: 4,
            maxLength: 250,
            textAlign: TextAlign.right,
            onChanged: (value) {
              cubit.updateBio(value);
            },
            decoration: InputDecoration(
              hintText: 'اكتب سيرتك الذاتية هنا...',
              hintStyle: Styles.textStyle14.copyWith(
                color: AppColors.secondary400,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              counterText: '',
            ),
            style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
          ),
        ),
        Gap(6.h),
        Text(
          '${_bioController.text.length}/250',
          style: Styles.textStyle14.copyWith(
            color: _bioController.text.length > 250
                ? AppColors.kRedColor
                : AppColors.secondary400,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection(
    EditPersonalDataCubit cubit,
    EditPersonalDataState state,
  ) {
    final videoFile = state.videoFile;
    final videoPreviewUrl = state.videoPreviewUrl;
    final hasVideo =
        videoFile != null ||
        (videoPreviewUrl != null && videoPreviewUrl.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasVideo)
          // عرض الفيديو مع Preview
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
                    // Video Preview
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
                                        ? 'جاري تحميل الفيديو الجديد...'
                                        : 'جاري تحميل الفيديو...',
                                    style: Styles.textStyle14.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),

                    // زر حذف الفيديو
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
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
                          'تم اختيار فيديو جديد',
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
          // زر رفع الفيديو
          GestureDetector(
            onTap: () => _pickVideo(cubit),
            child: Container(
              height: 250.h,
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppColors.kWhiteColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.primary100,
                  width: 1.0,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_camera_back_rounded,
                    size: 40.w,
                    color: AppColors.primary300,
                  ),
                  Gap(12.h),
                  Text(
                    'اضغط لرفع فيديو التعريف',
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondary600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // رسالة حجم الفيديو
        Gap(8.h),
        Text(
          'يجب أن يكون حجم الفيديو أقل من 4 MB',
          style: Styles.textStyle14.copyWith(
            color: AppColors.secondary400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
