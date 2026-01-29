// features/user/user_advisor_profile/views/widgets/navigate_to_chat_listener.dart
import 'dart:developer';

import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_state.dart';
import 'package:tayseer/my_import.dart';

class NavigateToChatListener extends StatelessWidget {
  const NavigateToChatListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserAdvisorProfileCubit, UserAdvisorProfileState>(
      listenWhen: (previous, current) =>
          previous.shouldNavigateToChat != current.shouldNavigateToChat &&
          current.shouldNavigateToChat == true,

      listener: (context, state) {
        if (state.shouldNavigateToChat == true) {
          log("test navigate to chat");
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
                'username': profile.name,
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
