import 'package:tayseer/my_import.dart';

class SettingsRowItem extends StatelessWidget {
  final String label;
  final String? value;
  final bool isLast;

  const SettingsRowItem({
    super.key,
    required this.label,
    this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: label == 'stop_marriage' || label == 'anonymous'
                ? 1.h
                : 14.h,
          ),
          child: Row(
            children: [
              Text(
                label,
                style: Styles.textStyle16.copyWith(color: Colors.black87),
              ),
              const Spacer(),
              if (value != null && value!.isNotEmpty) ...[
                Container(
                  constraints: BoxConstraints(maxWidth: 100.w),
                  child: Text(
                    value!,
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
}
