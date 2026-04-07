import 'package:tayseer/my_import.dart';

class AddSessionsEmptyState extends StatelessWidget {
  const AddSessionsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.pink.shade100, width: 2),
              ),
              child: Icon(
                Icons.check_box_outlined,
                color: Colors.pink.shade200,
                size: 36,
              ),
            ),
            Gap(10.h),
            Text(
              context.tr('choose_session_type_first'),
              style: Styles.textStyle14.copyWith(
                color: AppColors.kprimaryColor,
              ),
            ),
            Text(
              context.tr('can_choose_one_or_both'),
              style: Styles.textStyle10.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
