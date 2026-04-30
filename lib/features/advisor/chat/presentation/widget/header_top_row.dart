import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_state.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/pending_session_cubit/pending_session_cubit.dart';
import 'package:tayseer/features/advisor/session/presentation/manager/pending_session_cubit/pending_session_state.dart';
import 'package:tayseer/my_import.dart';

class HeaderTopRow extends StatelessWidget {
  final bool isChatsSelected;

  const HeaderTopRow({super.key, required this.isChatsSelected});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final fontSize = isMobile ? 18.0 : 22.0;
    final padding = isMobile ? 6.0 : 8.0;
    final iconSize = isMobile ? 35.0 : 45.0;
    final spacing = isMobile ? 30.0 : 40.0;

    return Directionality(
      textDirection: isArabic ? TextDirection.ltr : TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              if (isChatsSelected) {
                context.pushNamed(AppRouter.kChatRequest);
              } else {
                context.read<PendingSessionCubit>().resetCountHelper();
                context.pushNamed(AppRouter.pendingsession);
              }
            },
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: const Color(0xFFF5D1D7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Badge(
                label: isChatsSelected
                    ? BlocSelector<ChatListCubit, ChatListState, int>(
                        selector: (state) {
                          return state.maybeWhen(
                            loaded: (_, pendingRequestsCount) =>
                                pendingRequestsCount,
                            orElse: () => 0,
                          );
                        },
                        builder: (context, count) {
                          return Text("$count");
                        },
                      )
                    : BlocBuilder<PendingSessionCubit, PendingSessionState>(
                        builder: (context, state) {
                          final count = state.pendingSessionData?.count ?? 0;
                          return Text("$count");
                        },
                      ),
                backgroundColor: const Color(0xFFE96E88),
                child: AppImage(
                  AssetsData.chatNotificationIcon,
                  width: iconSize,
                  height: iconSize,
                ),
              ),
            ),
          ),
          Text(
            isChatsSelected
                ? context.tr('your_chats')
                : context.tr('your_sessions'),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: spacing),
        ],
      ),
    );
  }
}
