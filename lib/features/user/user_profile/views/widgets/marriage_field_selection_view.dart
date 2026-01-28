// features/user/user_profile/views/marriage_edit_views/marriage_field_selection_view.dart

import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/my_import.dart';

class MarriageFieldSelectionView extends StatefulWidget {
  final String fieldName;
  final String? currentValue;
  final Function(dynamic) onValueSelected;

  const MarriageFieldSelectionView({
    super.key,
    required this.fieldName,
    required this.currentValue,
    required this.onValueSelected,
  });

  @override
  State<MarriageFieldSelectionView> createState() =>
      _MarriageFieldSelectionViewState();
}

class _MarriageFieldSelectionViewState
    extends State<MarriageFieldSelectionView> {
  late String? selectedValue;
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.currentValue;
    textController = TextEditingController(text: widget.currentValue ?? '');
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  String get fieldTitle {
    switch (widget.fieldName) {
      case 'country':
        return 'البلد';
      case 'nationality':
        return 'الجنسية';
      case 'religion':
        return 'الدين';
      case 'age':
        return 'السن';
      case 'height':
        return 'الطول';
      case 'ethnicity':
        return 'بنية الجسم';
      case 'maritalStatus':
        return 'الحالة الصحية';
      case 'financialStatus':
        return 'الوضع المالي';
      case 'smoking':
        return 'التدخين';
      case 'occupation':
        return 'الوظيفة';
      case 'jobTitle':
        return 'الوصف الوظيفي';
      case 'professionalLevel':
        return 'الدرجة الوظيفية';
      case 'religiosity':
        return 'التدين';
      default:
        return '';
    }
  }

  List<String> get fieldOptions {
    switch (widget.fieldName) {
      case 'country':
        return [
          'مصر',
          'السعودية',
          'الإمارات',
          'الكويت',
          'قطر',
          'البحرين',
          'عمان',
          'الأردن',
          'فلسطين',
          'لبنان',
          'سوريا',
          'العراق',
          'اليمن',
          'ليبيا',
          'تونس',
          'الجزائر',
          'المغرب',
          'السودان',
          'الصومال',
          'جيبوتي',
          'موريتانيا',
          'جزر القمر',
        ];
      case 'nationality':
        return [
          'مصري',
          'سعودي',
          'إماراتي',
          'كويتي',
          'قطري',
          'بحريني',
          'عماني',
          'أردني',
          'فلسطيني',
          'لبناني',
          'سوري',
          'عراقي',
          'يمني',
          'ليبي',
          'تونسي',
          'جزائري',
          'مغربي',
          'سوداني',
          'صومالي',
          'جيبوتي',
          'موريتاني',
        ];
      case 'religion':
        return [
          'مسلم',
          'مسيحي',
          'يهودي',
          'آخر',
        ];
      case 'height':
        return [
          'أقل من 150 سم',
          '150 - 160 سم',
          '160 - 170 سم',
          '170 - 180 سم',
          '180 - 190 سم',
          'أكثر من 190 سم',
        ];
      case 'ethnicity':
        return [
          'نحيف',
          'رياضي',
          'متوسط',
          'ممتلئ',
          'سمين',
        ];
      case 'maritalStatus':
        return [
          'سليم',
          'مريض مزمن',
          'من ذوي الاحتياجات الخاصة',
        ];
      case 'financialStatus':
        return [
          'ممتاز',
          'جيد جداً',
          'جيد',
          'متوسط',
          'ضعيف',
        ];
      case 'smoking':
        return [
          'لا',
          'نعم',
          'أحياناً',
        ];
      case 'professionalLevel':
        return [
          'مدير عام',
          'مدير',
          'رئيس قسم',
          'موظف',
          'متدرب',
        ];
      case 'religiosity':
        return [
          'متدين جداً',
          'متدين',
          'متوسط',
          'غير متدين',
        ];
      default:
        return [];
    }
  }

  bool get isTextField {
    return widget.fieldName == 'occupation' || widget.fieldName == 'jobTitle';
  }

  bool get isAgeField {
    return widget.fieldName == 'age';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Column(
            children: [
              Gap(16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SimpleAppBar(
                  title: fieldTitle,
                  isLargeTitle: true,
                ),
              ),
              Gap(40.h),
              Expanded(
                child: isTextField
                    ? _buildTextFieldInput()
                    : isAgeField
                        ? _buildAgeSelector()
                        : _buildOptionsList(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 30.h),
                child: CustomBotton(
                  height: 53.h,
                  width: double.infinity,
                  title: 'تأكيد',
                  useGradient: true,
                  onPressed: _handleConfirm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 35.w),
      itemCount: fieldOptions.length,
      separatorBuilder: (context, index) => Gap(16.h),
      itemBuilder: (context, index) {
        final option = fieldOptions[index];
        final isSelected = selectedValue == option;
        return _buildOptionCard(option, isSelected);
      },
    );
  }

  Widget _buildOptionCard(String option, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedValue = option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary50 : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary400 : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              option,
              style: Styles.textStyle16.copyWith(
                color: AppColors.secondary800,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary400,
                size: 24.w,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أدخل ${fieldTitle}',
            style: Styles.textStyle14.copyWith(
              color: AppColors.secondary700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap(12.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.whiteCard2Back,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primary100),
            ),
            child: TextField(
              controller: textController,
              style: Styles.textStyle14.copyWith(
                color: AppColors.secondary800,
              ),
              maxLines: widget.fieldName == 'jobTitle' ? 3 : 1,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(16.w),
                border: InputBorder.none,
                hintText: 'أدخل ${fieldTitle}',
                hintStyle: Styles.textStyle14.copyWith(
                  color: AppColors.primary200,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        children: [
          Text(
            'اختر العمر',
            style: Styles.textStyle16Meduim.copyWith(
              color: AppColors.blueText,
            ),
          ),
          Gap(40.h),
          Expanded(
            child: ListView.builder(
              itemCount: 56, // From 15 to 70
              itemBuilder: (context, index) {
                final age = 15 + index;
                final isSelected = selectedValue == age.toString();
                return GestureDetector(
                  onTap: () => setState(() => selectedValue = age.toString()),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                    margin: EdgeInsets.only(bottom: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary50
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary400
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$age سنة',
                          style: Styles.textStyle16.copyWith(
                            color: AppColors.secondary800,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary400,
                            size: 24.w,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleConfirm() {
    if (isTextField) {
      if (textController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: 'يرجى إدخال ${fieldTitle}',
            isError: true,
          ),
        );
        return;
      }
      widget.onValueSelected(textController.text.trim());
    } else if (isAgeField) {
      if (selectedValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: 'يرجى اختيار ${fieldTitle}',
            isError: true,
          ),
        );
        return;
      }
      widget.onValueSelected(int.parse(selectedValue!));
    } else {
      if (selectedValue == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: 'يرجى اختيار ${fieldTitle}',
            isError: true,
          ),
        );
        return;
      }
      widget.onValueSelected(selectedValue);
    }
    Navigator.pop(context);
  }
}