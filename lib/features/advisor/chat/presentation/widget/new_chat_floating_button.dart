import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/request/request_list.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_state.dart';
import 'package:tayseer/my_import.dart';

class NewChatFloatingButton extends StatelessWidget {
  const NewChatFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Layer 1: subscription gate
    return BlocBuilder<InteractionsCubit, InteractionsState>(
      bloc: getIt<InteractionsCubit>(),
      buildWhen: (prev, curr) => prev.isSubscribed != curr.isSubscribed,
      builder: (context, subState) {
        // Subscribed users never see this button
        if (subState.isSubscribed) return const SizedBox.shrink();

        // Layer 2: pending requests gate
        return BlocBuilder<ChatListCubit, ChatListState>(
          buildWhen: (prev, curr) {
            final prevCount = prev.maybeMap(
              loaded: (s) => s.pendingRequestsCount,
              orElse: () => 0,
            );
            final currCount = curr.maybeMap(
              loaded: (s) => s.pendingRequestsCount,
              orElse: () => 0,
            );
            return prevCount != currCount;
          },
          builder: (context, chatState) {
            final pendingCount = chatState.maybeMap(
              loaded: (s) => s.pendingRequestsCount,
              orElse: () => 0,
            );

            // No pending requests — hide entirely
            if (pendingCount == 0) return const SizedBox.shrink();

            final screenWidth = MediaQuery.of(context).size.width;
            final isMobile = screenWidth < 600;

            return Container(
              margin: EdgeInsetsDirectional.only(
                end: isMobile ? 16.0 : 20.0,
                bottom: isMobile ? 70.0 : 80.0,
              ),
              child: FloatingActionButton.extended(
                onPressed: () => showSubscriptionRequiredDialog(
                  context,
                  pendingRequestsCount: pendingCount,
                ),
                backgroundColor: const Color(0xFFFFEBF0),
                foregroundColor: const Color(0xFFE96E88),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 12.0 : 15.0),
                  side: const BorderSide(color: Color(0xFFE96E88), width: 2),
                ),
                icon: Icon(
                  Icons.diamond_outlined,
                  color: Colors.amber,
                  size: isMobile ? 18 : 20,
                ),
                label: Text(
                  context.tr('add_new_chat'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
