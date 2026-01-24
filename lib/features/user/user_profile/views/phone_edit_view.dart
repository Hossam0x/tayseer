import 'package:flutter/material.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/my_import.dart';

class PhoneEditView extends StatefulWidget {
  final String initialPhone;
  const PhoneEditView({super.key, this.initialPhone = ""});

  @override
  State<PhoneEditView> createState() => _PhoneEditViewState();
}

class _PhoneEditViewState extends State<PhoneEditView> {
  late TextEditingController phoneController;

  // الحالة الخاصة بالدولة المختارة
  String countryCode = "+966";
  String countryFlag = "🇸🇦";
  String countryName = "السعودية";

  // قائمة الدول (يمكنك زيادتها حسب حاجتك)
  final List<Map<String, String>> countries = [
    {"name": "السعودية", "code": "+966", "flag": "🇸🇦"},
    {"name": "مصر", "code": "+20", "flag": "🇪🇬"},
    {"name": "الإمارات", "code": "+971", "flag": "🇦🇪"},
    {"name": "الكويت", "code": "+965", "flag": "🇰🇼"},
    {"name": "قطر", "code": "+974", "flag": "🇶🇦"},
    {"name": "الأردن", "code": "+962", "flag": "🇯🇴"},
  ];

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.initialPhone);
  }

  // دالة إظهار قائمة الدول
  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("اختر الدولة", style: Styles.textStyle18Meduim),
              Gap(10.h),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final item = countries[index];
                    return ListTile(
                      leading: Text(
                        item['flag']!,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                      title: Text(item['name']!, style: Styles.textStyle16),
                      // trailing: Text(item['code']!, dir: TextDirection.ltr),
                      onTap: () {
                        setState(() {
                          countryCode = item['code']!;
                          countryFlag = item['flag']!;
                          countryName = item['name']!;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
                child: SimpleAppBar(title: 'رقم الهاتف', isLargeTitle: true),
              ),
              Gap(8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'سنرسل لك رمز تحقق علي رقم هاتفك لتأكيد رقمك الجديد',
                  textAlign: TextAlign.center,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.primary800,
                  ),
                ),
              ),
              Gap(100.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: _buildPhoneInputField(),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 30.h),
                child: CustomBotton(
                  height: 53.h,
                  width: double.infinity,
                  title: 'التالي',
                  useGradient: true,
                  onPressed: () {
                    if (phoneController.text.isNotEmpty) {
                      Navigator.pop(
                        context,
                        "$countryCode${phoneController.text}",
                      );
                    }
                  },
                ),
              ),
              Gap(MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Row(
        children: [
          // أيقونة الهاتف
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Icon(
              Icons.phone_outlined,
              color: AppColors.primary100,
              size: 22.w,
            ),
          ),
          Container(height: 24.h, width: 2, color: AppColors.primary100),
          Gap(8.w),
          // حقل رقم الهاتف
          Expanded(
            child: TextFormField(
              controller: phoneController,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.phone,
              style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
              decoration: InputDecoration(
                hintText: 'رقم الهاتف',
                hintStyle: Styles.textStyle14.copyWith(
                  color: AppColors.primary200,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
          // الخط الفاصل
          Container(height: 24.h, width: 1, color: AppColors.primary100),
          // زر اختيار الدولة
          InkWell(
            onTap: _showCountryPicker,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                    size: 18.w,
                  ),
                  Gap(4.w),
                  Text(
                    countryCode,
                    // dir: TextDirection.ltr,
                    style: Styles.textStyle14,
                  ),
                  Gap(4.w),
                  Text(countryFlag, style: TextStyle(fontSize: 18.sp)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
