import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/chat_list_content.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/chat_list_shimmer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/my_import.dart';

class ChatListBuilder extends StatelessWidget {
  const ChatListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return BlocBuilder<ChatListCubit, ChatListState>(
      builder: (context, state) {
        return state.maybeMap(
          loading: (_) => const ChatListShimmer(),
          failure: (s) => _buildFailureState(context, s.message),
          loaded: (s) {
            if (s.chatRooms.isEmpty) {
              return _buildEmptyState(isMobile);
            }
            return ChatListContent(
              chatRooms: s.chatRooms,
              screenHeight: screenHeight,
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildFailureState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ChatListCubit>().loadChatRooms();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE96E88),
            ),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return SharedEmptyState(
      title: "لا توجد محادثات حتى الآن",
      subTitleWidget: Text(
        "ابدأ محادثة جديدة الآن",
        style: TextStyle(
          color: Colors.grey,
          fontFamily: 'Cairo',
          fontSize: isMobile ? 12 : 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
