import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_service.dart';
import 'package:tayseer/my_import.dart';

/// Global session start dialog shown when sessionStarted socket event fires
void showSessionStartDialog({
  required BuildContext context,
  required String sessionId,
  required String participantName,
  required int duration,
  required String participantId,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'session_start',
    barrierColor: Colors.black.withOpacity(0.6),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return ScaleTransition(
        scale: curvedAnimation,
        child: FadeTransition(
          opacity: animation,
          child: _SessionStartDialogContent(
            sessionId: sessionId,
            participantName: participantName,
            duration: duration,
            participantId: participantId,
          ),
        ),
      );
    },
  );
}

class _SessionStartDialogContent extends StatefulWidget {
  final String sessionId;
  final String participantName;
  final int duration;
  final String participantId;

  const _SessionStartDialogContent({
    required this.sessionId,
    required this.participantName,
    required this.duration,
    required this.participantId,
  });

  @override
  State<_SessionStartDialogContent> createState() =>
      _SessionStartDialogContentState();
}

class _SessionStartDialogContentState
    extends State<_SessionStartDialogContent> {
  bool _isLoading = false;

  Future<void> _handleJoin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Fetch Zego credentials
      final repo = getIt<MySpaceRepo>();
      final result = await repo.getZegoCredentials();

      if (!mounted) return;

      await result.fold(
        (failure) async {
          setState(() => _isLoading = false);
          AppToast.error(context, failure.message);
        },
        (credentials) async {
          // Get current user info
          final userId = await UserService.getCurrentUserId() ?? 'unknown';
          final userName = kCurrentUserData?.name ?? 'User';
          final userAvatar = kCurrentUserData?.image ?? '';

          if (!mounted) return;

          // Close dialog
          Navigator.of(context).pop();

          // Navigate to call screen
          context.pushNamed(
            AppRouter.voiceCallView,
            arguments: {
              'callID': widget.sessionId,
              'currentUserID': userId,
              'currentUserName': userName,
              'currentUserAvatarUrl': userAvatar,
              'advisorId': widget.participantId,
              'advisorName': widget.participantName,
              'advisorAvatarUrl': '', // Will be fetched from participants
              'isUserSide': true,
              'isAnonymous': false,
              'participants': [
                {
                  'id': widget.participantId,
                  'name': widget.participantName,
                  'avatarUrl': '',
                },
              ],
            },
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppToast.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        width: 380.w,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage(AssetsData.homeBackgroundImage),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.kprimaryColor.withOpacity(0.1),
              ),
              child: Icon(
                Icons.video_call_rounded,
                size: 40.sp,
                color: AppColors.kprimaryColor,
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              context.tr('session_ready'),
              style: Styles.textStyle20Meduim.copyWith(
                color: AppColors.primary500,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Message
            Text(
              context
                  .tr('session_ready_message')
                  .replaceAll('{participant}', widget.participantName),
              style: Styles.textStyle16Meduim.copyWith(
                color: AppColors.secondary600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),

            // Duration
            Text(
              context
                  .tr('session_duration')
                  .replaceAll('{duration}', widget.duration.toString()),
              style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // Buttons
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: AppColors.kprimaryColor,
                ),
              )
            else
              Row(
                children: [
                  // Join Button
                  Expanded(
                    child: CustomBotton(
                      title: context.tr('join'),
                      onPressed: _handleJoin,
                      useGradient: true,
                      height: 50.h,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Cancel Button
                  Expanded(
                    child: CustomOutlineButton(
                      text: context.tr('cancel'),
                      onTap: () => Navigator.of(context).pop(),
                      height: 50.h,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
