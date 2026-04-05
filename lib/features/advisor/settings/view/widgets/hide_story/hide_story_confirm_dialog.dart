import 'package:tayseer/features/advisor/settings/view/cubit/story_visibility/story_visibility_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/story_visibility/story_visibility_state.dart';
import 'package:tayseer/my_import.dart';

class HideStoryConfirmDialog extends StatelessWidget {
  final StoryVisibilityCubit cubit;
  final StoryVisibilityState state;

  const HideStoryConfirmDialog({
    super.key,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        context.tr('confirmation'),
        style: Styles.textStyle18Bold.copyWith(color: AppColors.secondary800),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${context.tr('want_to_unhide_from')} ${state.selectedUsers.length} ${context.tr('user')}',
            style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
            textAlign: TextAlign.center,
          ),
          Gap(12.h),
          if (state.selectedUsers.length <= 3)
            Column(
              children: state.selectedUsers
                  .map(
                    (user) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Text(
                        '• ${user.name}',
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.secondary700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.tr('cancel'),
                  style: Styles.textStyle14.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            Gap(12.w),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD65670),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await cubit.unrestrictSelectedUsers();
                },
                child: Text(
                  context.tr('confirm'),
                  style: Styles.textStyle14Bold.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
