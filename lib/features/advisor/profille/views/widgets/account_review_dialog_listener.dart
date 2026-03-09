import 'package:tayseer/core/widgets/account_review_content.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_state.dart';
import 'package:tayseer/my_import.dart';

class AccountReviewDialogListener extends StatelessWidget {
  const AccountReviewDialogListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) {
        final isApproved = current.profile?.isApproved ?? true;

        // فقط إذا كان الحساب غير موافق عليه
        if (!isApproved) {
          // نتحقق من أي action تم تنفيذه (loading state يعني المستخدم حاول يعمل action)
          final hasActionStarted =
              (previous.shareActionState != current.shareActionState &&
                  current.shareActionState == CubitStates.loading) ||
              (previous.saveActionState != current.saveActionState &&
                  current.saveActionState == CubitStates.loading) ||
              (previous.deletePostActionState !=
                      current.deletePostActionState &&
                  current.deletePostActionState == CubitStates.loading) ||
              (previous.archivePostActionState !=
                      current.archivePostActionState &&
                  current.archivePostActionState == CubitStates.loading) ||
              (previous.blockUserActionState != current.blockUserActionState &&
                  current.blockUserActionState == CubitStates.loading);

          return hasActionStarted;
        }

        return false;
      },
      listener: (context, state) {
        // نعرض الـ dialog عند أي action
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const AccountReviewContent(isDialog: true, showButton: true),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
