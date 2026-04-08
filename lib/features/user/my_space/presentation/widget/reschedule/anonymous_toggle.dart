// lib/features/user/my_space/presentation/widget/reschedule/anonymous_toggle.dart

import 'package:tayseer/my_import.dart';

class AnonymousToggle extends StatelessWidget {
  final bool isAnonymous;
  final ValueChanged<bool> onChanged;

  const AnonymousToggle({
    super.key,
    required this.isAnonymous,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 30.h),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ★ النص (يمين)
          Text(
            context.tr('enter_as_anonymous'),
            style: Styles.textStyle18Bold.copyWith(
              fontWeight: FontWeight.w600,
              color: isAnonymous ? AppColors.kprimaryColor : Colors.black87,
            ),
          ),
          // ★ السويتش (يسار)
          Transform.scale(
            scale: 0.95,
            child: Switch(
              value: isAnonymous,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: AppColors.kprimaryColor,
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade200,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
