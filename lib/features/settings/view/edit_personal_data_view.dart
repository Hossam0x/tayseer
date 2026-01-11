import 'package:tayseer/my_import.dart';

class EditPersonalDataView extends StatefulWidget {
  const EditPersonalDataView({super.key});

  @override
  State<EditPersonalDataView> createState() => _EditPersonalDataViewState();
}

class _EditPersonalDataViewState extends State<EditPersonalDataView> {
  // البيانات الأولية
  String _name = "Dr /Anna Mary";
  String _id = "@annanoo";
  String _specialization = "استشاري نفسي وعلاقات زوجية";
  String _position = "استشاري";
  String _experience = "سنتين";
  String _bio =
      "استشاري نفسي مع خبرة تزيد عن [عدد السنوات] سنوات في تقديم الدعم النفسي والإرشاد للأفراد. أساعد الأشخاص في التغلب على تحديات مثل القلق، الاكتئاب، ضغوط الحياة، ومشكلات العلاقات باستخدام العلاج المعرفي السلوكي (CBT).";

  // قوائم الاختيار
  String? _selectedPosition;
  String? _selectedExperience;
  String? _selectedSpecialization;

  // ملفات
  File? _videoFile;
  File? _avatarImageFile;
  double _videoSizeMB = 0.0;

  // محركات النصوص
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = _name;
    _idController.text = _id;
    _bioController.text = _bio;

    // تعيين القيم الافتراضية
    _selectedPosition = _position;
    _selectedExperience = _experience;
    _selectedSpecialization = _specialization;

    // قوائم الاختيار
    _positions = ["استشاري", "أخصائي", "مدرب", "محاضر"];
    _experiences = [
      "سنتين",
      "3 سنوات",
      "5 سنوات",
      "10 سنوات",
      "أكثر من 10 سنوات",
    ];
    _specializations = [
      "استشاري نفسي وعلاقات زوجية",
      "طبيب نفسي",
      "أخصائي نفسي",
      "مدرب حياة",
      "مستشار أسري",
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // قوائم الاختيار
  late List<String> _positions;
  late List<String> _experiences;
  late List<String> _specializations;

  // دالة لرفع الفيديو
  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSizeInBytes = await file.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 4) {
        // عرض رسالة خطأ إذا كان الفيديو أكبر من 4 ميجابايت
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: 'حجم الفيديو يجب أن يكون أقل من 4 ميجابايت',
            isError: true,
          ),
        );
        return;
      }

      setState(() {
        _videoFile = file;
        _videoSizeMB = double.parse(fileSizeInMB.toStringAsFixed(2));
      });
    }
  }

  // دالة لرفع الصورة الشخصية
  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _avatarImageFile = File(pickedFile.path);
      });
    }
  }

  // دالة لحذف الفيديو
  void _removeVideo() {
    setState(() {
      _videoFile = null;
      _videoSizeMB = 0.0;
    });
  }

  // دالة لحذف الصورة الشخصية
  void _removeAvatarImage() {
    setState(() {
      _avatarImageFile = null;
    });
  }

  // دالة لحفظ البيانات
  void _saveData() {
    setState(() {
      _name = _nameController.text;
      _id = _idController.text;
      _bio = _bioController.text;
      _position = _selectedPosition ?? _position;
      _experience = _selectedExperience ?? _experience;
      _specialization = _selectedSpecialization ?? _specialization;
    });

    // عرض رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(context, text: 'تم حفظ البيانات بنجاح', isSuccess: true),
    );

    // العودة للخلف بعد ثانية
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AdvisorBackground(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // زر العودة
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.blackColor,
                        size: 24.w,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      // العنوان
                      Gap(8.h),
                      Text(
                        'تعديل البيانات الشخصية',
                        style: Styles.textStyle20Bold.copyWith(
                          color: AppColors.secondary800,
                        ),
                      ),

                      Gap(32.h),

                      // قسم الصورة الشخصية (مضاف جديداً)
                      _buildAvatarImageSection(),

                      Gap(20.h),

                      // حقل الاسم
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'أدخل اسمك',
                      ),

                      Gap(11.h),

                      // حقل المعرف
                      _buildTextField(
                        controller: _idController,
                        hintText: 'أدرف المعرف',
                        prefixText: '@',
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
                        },
                        hint: 'اختر سنوات الخبرة',
                      ),

                      Gap(11.h),

                      // حقل السيرة الذاتية
                      _buildBioField(),

                      Gap(25.h),

                      // قسم رفع الفيديو
                      _buildVideoSection(),

                      Gap(35.h),

                      // زر الحفظ
                      CustomBotton(
                        width: context.width * 0.9,
                        useGradient: true,
                        title: 'حفظ',
                        onPressed: _saveData,
                      ),

                      Gap(40.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // قسم الصورة الشخصية (مشابه لقسم الشهادة)
  Widget _buildAvatarImageSection() {
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
              child: _avatarImageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(32.r),
                      child: Image.file(
                        _avatarImageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(32.r),
                      child: AppImage(
                        AssetsData.kUserImage,
                        height: 150.h,
                        width: 155.w,
                        fit: BoxFit.fill,
                      ),
                    ),
            ),

            Positioned(
              bottom: 6,
              right: 6,
              child: GestureDetector(
                onTap: _pickAvatarImage,
                child: AppImage(AssetsData.addCertificateImage),
              ),
            ),

            // زر حذف الصورة (في الأعلى) - يظهر فقط إذا كانت هناك صورة مرفوعة
            if (_avatarImageFile != null)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: _removeAvatarImage,
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

  // واجهة حقل النص
  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          textAlign: TextAlign.right,
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
            fillColor: AppColors.kWhiteColor,
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

  // واجهة Dropdown
  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String hint,
  }) {
    return Column(
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
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary500,
                size: 24.w,
              ),
              elevation: 16,
              style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
              hint: Text(
                hint,
                style: Styles.textStyle14.copyWith(
                  color: AppColors.secondary400,
                ),
                textAlign: TextAlign.right,
              ),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, textAlign: TextAlign.right),
                );
              }).toList(),
              dropdownColor: AppColors.kWhiteColor,
            ),
          ),
        ),
      ],
    );
  }

  // واجهة السيرة الذاتية
  Widget _buildBioField() {
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
            maxLines: 6,
            maxLength: 250,
            textAlign: TextAlign.right,
            onChanged: (value) {
              setState(() {});
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

  // قسم رفع الفيديو
  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_videoFile != null)
          // عرض الفيديو المرفوع
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
                    // صورة مصغرة للفيديو أو أيقونة
                    Container(
                      width: double.infinity,
                      height: 250.h,
                      decoration: BoxDecoration(
                        color: AppColors.secondary100,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_rounded,
                              size: 50.w,
                              color: AppColors.primary500,
                            ),
                            Gap(8.h),
                            Text(
                              'فيديو مرفوع',
                              style: Styles.textStyle14.copyWith(
                                color: AppColors.secondary600,
                              ),
                            ),
                            Gap(4.h),
                            Text(
                              '${_videoSizeMB.toStringAsFixed(2)} MB',
                              style: Styles.textStyle12.copyWith(
                                color: AppColors.secondary400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // زر حذف الفيديو
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeVideo,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.kWhiteColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.primary500,
                            size: 22.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          // زر رفع الفيديو
          GestureDetector(
            onTap: _pickVideo,
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
