import 'package:chewie/chewie.dart';
import 'package:tayseer/core/widgets/profile_text_field.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
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

  // ⭐ خرائط تحويل للتخصصات
  final Map<String, String> _specializationMapping = {
    "doctor": "طبيب نفسي",
    "psychology": "استشاري نفسي وعلاقات زوجية",
    "psychiatrist": "طبيب نفسي",
    "psychologist": "أخصائي نفسي",
    "life_coach": "مدرب حياة",
    "family_counselor": "مستشار أسري",
  };

  // ⭐ خرائط تحويل للمناصب
  final Map<String, String> _positionMapping = {
    "advisor": "استشاري",
    "junior": "أخصائي",
    "trainer": "مدرب",
    "lecturer": "محاضر",
  };

  // ⭐ خرائط تحويل لسنوات الخبرة
  final Map<String, String> _experienceMapping = {
    "2": "سنتين",
    "3": "3 سنوات",
    "5": "5 سنوات",
    "10": "10 سنوات",
    "11": "أكثر من 10 سنوات",
  };

  final List<String> _positions = ["استشاري", "أخصائي", "مدرب", "محاضر"];
  final List<String> _specializations = [
    "استشاري نفسي وعلاقات زوجية",
    "طبيب نفسي",
    "أخصائي نفسي",
    "مدرب حياة",
    "مستشار أسري",
  ];

  final List<Map<String, String>> _experienceOptions = [
    {"display": "سنتين", "value": "2"},
    {"display": "3 سنوات", "value": "3"},
    {"display": "5 سنوات", "value": "5"},
    {"display": "10 سنوات", "value": "10"},
    {"display": "أكثر من 10 سنوات", "value": "11"},
  ];

  String? _selectedPosition;
  String? _selectedSpecialization;
  String? _selectedExperienceDisplay;
  String? _selectedExperienceValue;

  // ⭐ دالة لتحويل القيمة من الباكند إلى قيمة للعرض
  String? _mapFromBackend(String? backendValue, Map<String, String> mapping) {
    if (backendValue == null) return null;

    // أولاً: تحقق إذا كانت القيمة موجودة مباشرة في الـ mapping
    if (mapping.containsKey(backendValue)) {
      return mapping[backendValue];
    }

    // ثانياً: تحقق إذا كانت القيمة موجودة في القيم (العكس)
    final matchingKey = mapping.entries
        .firstWhere(
          (entry) => entry.value == backendValue,
          orElse: () => MapEntry("", ""),
        )
        .key;

    return matchingKey.isNotEmpty ? mapping[matchingKey] : backendValue;
  }

  // ⭐ دالة لتحويل القيمة من الواجهة إلى قيمة للباكند
  String? _mapToBackend(String? displayValue, Map<String, String> mapping) {
    if (displayValue == null) return null;

    // ابحث عن الـ key الذي يحتوي على الـ value
    final matchingEntry = mapping.entries.firstWhere(
      (entry) => entry.value == displayValue,
      orElse: () => MapEntry("", ""),
    );

    return matchingEntry.key.isEmpty ? displayValue : matchingEntry.key;
  }

  // ⭐ دالة خاصة لسنوات الخبرة (بسبب الـ " من الخبرة")
  String? _normalizeExperienceFromBackend(String? backendValue) {
    if (backendValue == null) return null;

    // تحويل "10 سنوات من الخبرة" → "10 سنوات"
    final normalized = backendValue.replaceAll(" من الخبرة", "");

    // تحقق في الـ mapping
    if (_experienceMapping.values.contains(normalized)) {
      return normalized;
    }

    // إذا كانت تحتوي على رقم، حاول إيجاد أقرب تطابق
    final match = RegExp(r'(\d+)').firstMatch(backendValue);
    if (match != null) {
      final years = match.group(1);
      return _experienceMapping[years] ?? backendValue;
    }

    return backendValue;
  }

  // ⭐ دالة لاستخراج القيمة الرقمية من نص الخبرة
  String _getValueFromExperience(String displayValue) {
    if (displayValue.contains("سنتين")) return "2";
    if (displayValue.contains("3 سنوات")) return "3";
    if (displayValue.contains("5 سنوات")) return "5";
    if (displayValue.contains("10 سنوات")) return "10";
    if (displayValue.contains("أكثر من")) return "11";

    final match = RegExp(r'(\d+)').firstMatch(displayValue);
    return match?.group(1) ?? displayValue;
  }

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _currentVideoUrl;
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
    if (_currentVideoUrl == videoUrl && _videoPlayerController != null) {
      return;
    }

    _disposeVideoPlayer();
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
                  size: 50.w,
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
          SnackBar(
            content: Text(
              'حجم الفيديو يجب أن يكون أقل من 4 ميجابايت',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      _disposeVideoPlayer();

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
          SnackBar(
            content: Text(
              'تعذر تحميل الفيديو',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
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
    cubit.removeVideo();
    setState(() {
      _currentVideoUrl = null;
    });
  }

  void _initializeControllers(EditPersonalDataState state) {
    if (_controllersInitialized || state.profile == null) return;

    _nameController.text = state.profile!.name;
    _idController.text = state.profile!.userName;
    _bioController.text = state.profile!.aboutYou ?? '';

    // ⭐ تحويل القيم من الباكند إلى قيم للعرض
    _selectedPosition = _mapFromBackend(
      state.currentData.jobGrade,
      _positionMapping,
    );

    _selectedSpecialization = _mapFromBackend(
      state.currentData.professionalSpecialization,
      _specializationMapping,
    );

    // ⭐ معالجة سنوات الخبرة بشكل خاص
    final yearsExp = state.currentData.yearsOfExperience;
    if (yearsExp != null && yearsExp.isNotEmpty) {
      _selectedExperienceDisplay = _normalizeExperienceFromBackend(yearsExp);
      _selectedExperienceValue = _getValueFromExperience(
        _selectedExperienceDisplay!,
      );
    }

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
    return BlocProvider<EditPersonalDataCubit>(
      create: (_) => getIt<EditPersonalDataCubit>(),
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

          if (state.state == CubitStates.success && state.profile != null) {
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

                                        // حقل الاسم باستخدام ProfileTextField
                                        ProfileTextField(
                                          controller: _nameController,
                                          onChanged: (value) =>
                                              cubit.updateName(value),
                                          hint: 'أدخل اسمك',
                                        ),
                                        Gap(11.h),
                                        Gap(11.h),
                                        ProfileTextField(
                                          controller: TextEditingController(
                                            text: state.profile?.userName ?? '',
                                          ),
                                          onChanged: (value) =>
                                              cubit.updateUsername(value),
                                          hint: 'اسم المستخدم',
                                        ),
                                        Gap(11.h),

                                        // Dropdown للتخصص
                                        _buildSpecializationDropdown(cubit),
                                        Gap(11.h),

                                        // Dropdown للمنصب
                                        _buildPositionDropdown(cubit),
                                        Gap(11.h),

                                        // Dropdown للخبرة
                                        _buildExperienceDropdown(cubit),
                                        Gap(11.h),
                                        // حقل السيرة الذاتية باستخدام ProfileTextField
                                        ProfileTextField(
                                          controller: _bioController,
                                          onChanged: (value) =>
                                              cubit.updateBio(value),
                                          hint: 'اكتب سيرتك الذاتية هنا...',
                                          maxLines: 4,
                                        ),
                                        Gap(6.h),
                                        Text(
                                          '${_bioController.text.length}/250',
                                          style: Styles.textStyle14.copyWith(
                                            color:
                                                _bioController.text.length > 250
                                                ? AppColors.kRedColor
                                                : AppColors.secondary400,
                                          ),
                                        ),
                                        Gap(25.h),

                                        // قسم رفع الفيديو
                                        _buildVideoSection(cubit, state),
                                        Gap(35.h),

                                        // زر الحفظ
                                        CustomBotton(
                                          height: 54.h,
                                          width: double.infinity,
                                          useGradient: true,
                                          title: state.isSaving
                                              ? 'جاري الحفظ...'
                                              : 'حفظ',
                                          onPressed:
                                              state.isSaving ||
                                                  !state.hasChanges
                                              ? null
                                              : () =>
                                                    cubit.saveChanges(context),
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
            Container(
              height: 150.h,
              width: 155.w,
              decoration: BoxDecoration(
                color: AppColors.hintText,
                borderRadius: BorderRadius.circular(32.r),
              ),
              child: isImageDeleted
                  ? _buildDefaultAvatar() // ⭐ عرض الصورة الافتراضية إذا تم الحذف
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
    bool isExperience = false, // ⭐ إضافة باراميتر للتمييز
  }) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    // ⭐ إذا كان dropdown الخبرة وكانت القيمة غير موجودة، نضيفها مؤقتاً
    List<String> effectiveItems = List.from(items);
    if (isExperience && value != null && !effectiveItems.contains(value)) {
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
            hint,
            style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
            textAlign: TextAlign.right,
          ),
          onChanged: onChanged,
          items: effectiveItems.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, textAlign: TextAlign.right),
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
    final videoFile = state.videoFile;
    final videoPreviewUrl = state.videoPreviewUrl;
    // ⭐ تحقق إذا كان الفيديو محذوفاً
    final isVideoDeleted = state.currentData.video == "";
    final hasVideo =
        !isVideoDeleted &&
        (videoFile != null ||
            (videoPreviewUrl != null && videoPreviewUrl.isNotEmpty));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasVideo)
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
                  Icon(
                    Icons.video_camera_back_rounded,
                    size: 40.w,
                    color: AppColors.primary300,
                  ),
                  Gap(12.h),
                  Text(
                    isVideoDeleted
                        ? 'تم حذف الفيديو (اضغط لإضافة فيديو جديد)'
                        : 'اضغط لرفع فيديو التعريف',
                    style: Styles.textStyle16.copyWith(
                      color: isVideoDeleted
                          ? AppColors.kRedColor
                          : AppColors.secondary600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Gap(8.h),
        Text(
          'يجب أن يكون حجم الفيديو أقل من 4 MB',
          style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
        ),
      ],
    );
  }

  // ⭐ دالة منفصلة لكل dropdown
  Widget _buildSpecializationDropdown(EditPersonalDataCubit cubit) {
    return _buildDropdown(
      value: _selectedSpecialization,
      items: _specializations,
      onChanged: (displayValue) {
        setState(() {
          _selectedSpecialization = displayValue;
        });
        if (displayValue != null) {
          // تحويل القيمة للباكند
          final backendValue = _mapToBackend(
            displayValue,
            _specializationMapping,
          );
          cubit.updateSpecialization(backendValue ?? displayValue);
        }
      },
      hint: 'اختر التخصص',
    );
  }

  Widget _buildPositionDropdown(EditPersonalDataCubit cubit) {
    return _buildDropdown(
      value: _selectedPosition,
      items: _positions,
      onChanged: (displayValue) {
        setState(() {
          _selectedPosition = displayValue;
        });
        if (displayValue != null) {
          // تحويل القيمة للباكند
          final backendValue = _mapToBackend(displayValue, _positionMapping);
          cubit.updatePosition(backendValue ?? displayValue);
        }
      },
      hint: 'اختر المنصب',
    );
  }

  Widget _buildExperienceDropdown(EditPersonalDataCubit cubit) {
    return _buildDropdown(
      value: _selectedExperienceDisplay,
      items: _experienceOptions.map((e) => e["display"]!).toList(),
      onChanged: (displayValue) {
        setState(() {
          _selectedExperienceDisplay = displayValue;
          final selected = _experienceOptions.firstWhere(
            (e) => e["display"] == displayValue,
            orElse: () => {
              "value": _getValueFromExperience(displayValue ?? ""),
            },
          );
          _selectedExperienceValue = selected["value"];
        });

        if (_selectedExperienceValue != null &&
            _selectedExperienceValue!.isNotEmpty) {
          cubit.updateExperience(_selectedExperienceValue!);
        }
      },
      hint: 'اختر سنوات الخبرة',
    );
  }
}
