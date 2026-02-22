import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_cubit.dart';
import 'package:tayseer/my_import.dart';

class SendGreetingDialog extends StatefulWidget {
  final String receiverName;
  final String receiverId;
  final UserPublicProfileCubit cubit;

  const SendGreetingDialog({
    super.key,
    required this.receiverName,
    required this.receiverId,
    required this.cubit,
  });

  static void show(
    BuildContext context, {
    required String receiverName,
    required String receiverId,
    required UserPublicProfileCubit cubit,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: SendGreetingDialog(
          receiverName: receiverName,
          receiverId: receiverId,
          cubit: cubit,
        ),
      ),
    );
  }

  @override
  State<SendGreetingDialog> createState() => _SendGreetingDialogState();
}

class _SendGreetingDialogState extends State<SendGreetingDialog> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // العنوان
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // close icon
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: 24.w,
                    color: AppColors.secondary600,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.h),
                  child: Text(
                    context.tr('send_greeting'),
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: AppColors.primary800,
                    ),
                  ),
                ),
                SizedBox(width: 40.w),
              ],
            ),

            Gap(28.h),

            // حقل إدخال الرسالة
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.secondary200, width: 1.2),
              ),
              child: TextFormField(
                controller: _messageController,
                maxLines: 8,
                minLines: 6,
                maxLength: 500,
                textAlignVertical: TextAlignVertical.top,
                style: Styles.textStyle16.copyWith(
                  color: AppColors.secondary800,
                ),
                decoration: InputDecoration(
                  hintText: context.tr('type_your_message'),
                  hintStyle: Styles.textStyle16.copyWith(
                    color: AppColors.secondary400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.w),
                  counterStyle: Styles.textStyle12.copyWith(
                    color: AppColors.secondary400,
                  ),
                  counterText: '',
                ),
              ),
            ),
            Gap(32.h),
            CustomBotton(
              title: _isSending ? context.tr('sending') : context.tr('send'),
              onPressed: _isSending ? null : () => _sendGreeting(),
              useGradient: true,
            ),
            Gap(28.h),
          ],
        ),
      ),
    );
  }

  Future<void> _sendGreeting() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      if (mounted) {
        showSafeSnackBar(
          context: context,
          text: context.tr('please_enter_message'),
          isError: true,
        );
      }
      return;
    }

    if (message.length > 500) {
      if (mounted) {
        showSafeSnackBar(
          context: context,
          text: context.tr('message_too_long_error'),
          isError: true,
        );
      }
      return;
    }

    setState(() => _isSending = true);

    try {
      // ⭐ استخدام الـ receiverId من الـ Model
      await widget.cubit.sendGreeting(
        receiverId: widget.receiverId, // ⭐ هذا هو الـ personInteractedWith
        message: message, // ⭐ هذا هو الـ text
      );

      if (mounted) {
        Navigator.pop(context);

        // ✅ Show success animation like GreetingProfileCard
        final parentContext = Navigator.of(
          context,
          rootNavigator: true,
        ).context;

        if (parentContext.mounted) {
          _showSuccessAnimation(parentContext);
        }
      }
    } catch (e) {
      if (mounted) {
        showSafeSnackBar(
          context: context,
          text: context.tr('error_sending_greeting'),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showSuccessAnimation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Opacity(
          opacity: 0.8,
          child: Center(
            child: AppImage(AssetsData.kSuccessMarriageAnimationsLottie),
          ),
        );
      },
    );
    Future.delayed(const Duration(seconds: 4), () {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }
}
