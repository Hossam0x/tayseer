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
      textDirection: TextDirection.ltr,
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
                label: BlocBuilder<PendingSessionCubit, PendingSessionState>(
                  builder: (context, state) {
                    if (isChatsSelected) {
                      return const Text("0");
                    }
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
            // ✅ تغيير العنوان حسب السيكشن (اختياري)
            isChatsSelected ? "محادثاتك" : "جلساتك",
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
