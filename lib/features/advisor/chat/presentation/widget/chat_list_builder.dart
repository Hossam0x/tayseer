import 'package:tayseer/features/advisor/chat/presentation/manager/chat_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/chat_list_item.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/my_import.dart';

class ChatListBuilder extends StatelessWidget {
  const ChatListBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        // حالة التحميل
        if (state.getallchatrooms == CubitStates.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE96E88)),
          );
        }

        // حالة الخطأ
        if (state.getallchatrooms == CubitStates.failure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ?? 'حدث خطأ ما',
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
                    context.read<ChatCubit>().fetchChatRooms();
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

        // حالة النجاح
        if (state.getallchatrooms == CubitStates.success) {
          // إذا كانت القائمة فارغة
          if (state.chatRoom?.rooms == null || state.chatRoom!.rooms!.isEmpty) {
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

          // عرض القائمة
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ChatCubit>().fetchChatRooms();
            },
            color: const Color(0xFFE96E88),
            child: ListView.separated(
              padding: EdgeInsets.only(bottom: screenHeight * 0.01),
              itemCount: state.chatRoom!.rooms!.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade200,
                height: isMobile ? 0.5 : 1,
              ),
              itemBuilder: (context, index) {
                final chatRoom = state.chatRoom!.rooms![index];
                return ChatListItem(index: index, chatRoom: chatRoom);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
