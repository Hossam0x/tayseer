import 'dart:ui';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_state.dart';
import 'package:tayseer/my_import.dart';

class UserPublicProfileGreetingSection extends StatefulWidget {
  const UserPublicProfileGreetingSection({super.key});

  @override
  State<UserPublicProfileGreetingSection> createState() =>
      _UserPublicProfileGreetingSectionState();
}

class _UserPublicProfileGreetingSectionState
    extends State<UserPublicProfileGreetingSection> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserPublicProfileCubit, UserPublicProfileState>(
      listenWhen: (previous, current) =>
          previous.greetingSuccess != current.greetingSuccess ||
          previous.greetingMessage != current.greetingMessage,
      listener: (context, state) {
        if (state.greetingSuccess) {
          showSafeSnackBar(
            context: context,
            text: state.greetingMessage ?? 'تم إرسال التحية بنجاح',
            isSuccess: true,
          );
          _messageController.clear();
          context.read<UserPublicProfileCubit>().clearGreetingState();
        } else if (state.greetingMessage != null && !state.greetingSuccess) {
          showSafeSnackBar(
            context: context,
            text: state.greetingMessage!,
            isError: true,
          );
          context.read<UserPublicProfileCubit>().clearGreetingState();
        }
      },
      buildWhen: (previous, current) =>
          previous.profile != current.profile ||
          previous.isSendingGreeting != current.isSendingGreeting,
      builder: (context, state) {
        if (state.profile == null || state.profile!.isMe) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.08),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.white.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Profile Image (Exactly like GreetingProfileCard)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: AppImage(
                          state.profile!.image ?? '',
                          width: 80.w,
                          height: 80.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Gap(16.w),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.profile!.name,
                              style: Styles.textStyle16SemiBold.copyWith(
                                color: AppColors.primary900,
                              ),
                            ),
                            Gap(4.h),
                            Text(
                              'أرسل تحية ودية لبدء المحادثة',
                              style: Styles.textStyle14.copyWith(
                                color: AppColors.secondary600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Star Button (Send Action) - Replicating exactly
                      GestureDetector(
                        onTap: state.isSendingGreeting
                            ? null
                            : () => _sendGreeting(context, state.profile!.id),
                        child: Container(
                          width: 55.w,
                          height: 55.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary200,
                                AppColors.primary400,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF48174E).withOpacity(0.2),
                                offset: const Offset(0, 2.87),
                                blurRadius: 37.85,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: state.isSendingGreeting
                              ? Padding(
                                  padding: EdgeInsets.all(14.w),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 30.r,
                                ),
                        ),
                      ),
                    ],
                  ),
                  Gap(16.h),
                  // Message Input Field (Glassmorphic style)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                    ),
                    child: TextFormField(
                      controller: _messageController,
                      maxLines: 2,
                      maxLength: 500,
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.secondary800,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة التحية هنا...',
                        hintStyle: Styles.textStyle14.copyWith(
                          color: AppColors.secondary400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        counterText: '',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _sendGreeting(BuildContext context, String receiverId) {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      showSafeSnackBar(
        context: context,
        text: 'يرجى كتابة رسالة قبل الإرسال',
        isError: true,
      );
      return;
    }

    context.read<UserPublicProfileCubit>().sendGreeting(
      receiverId: receiverId,
      message: message,
    );
  }
}
