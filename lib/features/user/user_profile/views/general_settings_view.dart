import 'package:flutter/cupertino.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/views/age_selection_view.dart';
import 'package:tayseer/features/user/user_profile/views/email_edit_view.dart';
import 'package:tayseer/features/user/user_profile/views/gender_selection_view.dart';
import 'package:tayseer/my_import.dart';

class GeneralSettingsView extends StatefulWidget {
  const GeneralSettingsView({super.key});

  @override
  State<GeneralSettingsView> createState() => _GeneralSettingsViewState();
}

class _GeneralSettingsViewState extends State<GeneralSettingsView> {
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
                child: SimpleAppBar(title: 'الإعدادات', isLargeTitle: true),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      Gap(30.h),
                      _buildPersonalSection(),
                      Gap(30.h),
                      _buildPrivacySection(),
                      Gap(40.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteCard2Back,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.h, right: 16.w, bottom: 8.h),
            child: Text(title, style: Styles.textStyle16Meduim),
          ),
          Gap(16.h),
          ...children,
        ],
      ),
    );
  }

  String currentAge = "35";
  String currentGender = "ذكر";
  String initialEmail = "ahmedlshennawy10@gmail.com";

  Widget _buildPersonalSection() {
    return _buildSectionContainer(
      title: "المعلومات الشخصية",
      children: [
        InkWell(
          onTap: () async {
            // الانتقال لصفحة السن وانتظار النتيجة
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AgeSelectionView(initialAge: int.parse(currentAge)),
              ),
            );

            // تحديث السن إذا تم اختيار قيمة
            if (result != null) {
              setState(() {
                currentAge = result;
              });
            }
          },
          child: _buildSettingRow(label: "السن", value: currentAge),
        ),
        InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    GenderSelectionView(initialGender: currentGender),
              ),
            );

            if (result != null) {
              setState(() {
                currentGender = result;
              });
            }
          },
          child: _buildSettingRow(label: "النوع", value: currentGender),
        ),

        InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmailEditView(initialEmail: initialEmail),
              ),
            );

            if (result != null) {
              setState(() {
                initialEmail = result;
              });
            }
          },
          child: _buildSettingRow(
            label: "البريد الالكتروني",
            value: initialEmail,
          ),
        ),
        _buildSettingRow(label: "رقم الهاتف", value: "", isLast: true),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSectionContainer(
      title: "الخصوصية",
      children: [
        _buildSwitchRow(label: "إيقاف الزواج", value: false),
        _buildSettingRow(label: "من يمكنه رؤية ملفك الشخصي"),
        _buildSettingRow(label: "رؤية صورة للملف الشخصي"),
        _buildSettingRow(label: "جهات الاتصال"),
        _buildSwitchRow(label: "مجهول الهوية", value: false, isLast: true),
      ],
    );
  }

  Widget _buildSettingRow({
    required String label,
    String? value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Text(
                label,
                style: Styles.textStyle16.copyWith(color: Colors.black87),
              ),
              const Spacer(),
              if (value != null && value.isNotEmpty) ...[
                Container(
                  constraints: BoxConstraints(maxWidth: 100.w),
                  child: Text(
                    value,
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.secondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
              Gap(10.w),
              Icon(
                Icons.arrow_forward_ios,
                size: 14.w,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1.h,
            color: Colors.grey.shade200,
            indent: 15,
            endIndent: 15,
          ),
        Gap(10.h),
      ],
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Gap(10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Text(
                label,
                style: Styles.textStyle16.copyWith(color: Colors.black87),
              ),
              const Spacer(),
              IgnorePointer(
                ignoring: false,
                child: Transform.scale(
                  scaleX: -0.8,
                  scaleY: 0.8,
                  child: CupertinoSwitch(
                    value: value,
                    activeColor: const Color(0xFFF06C88),
                    trackColor: AppColors.dropDownArrow,
                    onChanged: (val) {},
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Colors.grey.shade200,
            indent: 15,
            endIndent: 15,
          ),
        Gap(10.h),
      ],
    );
  }
}
