import 'package:flutter/cupertino.dart';
import 'package:tayseer/my_import.dart';

class SettingsSwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const SettingsSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
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
                  scaleX: -0.8.r,
                  scaleY: 0.8.r,
                  child: CupertinoSwitch(
                    value: value,
                    activeColor: const Color(0xFFF06C88),
                    trackColor: AppColors.dropDownArrow,
                    onChanged: onChanged,
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
