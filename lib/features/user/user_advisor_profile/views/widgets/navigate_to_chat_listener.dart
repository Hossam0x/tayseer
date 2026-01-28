// features/user/user_advisor_profile/views/widgets/navigate_to_chat_listener.dart
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_state.dart';
import 'package:tayseer/my_import.dart';

class NavigateToChatListener extends StatelessWidget {
  const NavigateToChatListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserAdvisorProfileCubit, UserAdvisorProfileState>(
      listenWhen: (previous, current) =>
          previous.shouldNavigateToChat  != current.shouldNavigateToChat  &&
          current.shouldNavigateToChat  == true,
      listener: (context, state) {
        if (state.shouldNavigateToChat  == true &&
            state.profile != null &&
            state.profile!.room != null) {
          final profile = state.profile!;
          final room = profile.room!;

          // ⭐ إعادة تعيين حالة التنقل
          context.read<UserAdvisorProfileCubit>().resetNavigation();

          // ⭐ استخدام Future.microtask للانتقال في الدورة القادمة
          Future.microtask(() {
            context.pushNamed(
              AppRouter.kConversitionView,
              arguments: {
                'chatroomid': room.chatRoomId,
                'receiverid': profile.id,
                'username': profile.username,
                'userimage': profile.image,
                'isBlocked': room.isBlocked,
                'isHaveSession': room.isHaveSession,
              },
            );
          });
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}
