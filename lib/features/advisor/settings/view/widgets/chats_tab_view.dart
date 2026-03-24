import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_states.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/chats_tab_ui_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/chats/chat_item_widget.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/chats/chats_skeleton.dart';
import 'package:tayseer/my_import.dart';

class ChatsTabView extends StatelessWidget {
  const ChatsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatsTabUiCubit()..loadCurrentUserId(),
      child: const _ChatsTabViewBody(),
    );
  }
}

class _ChatsTabViewBody extends StatelessWidget {
  const _ChatsTabViewBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsTabUiCubit, ChatsTabUiState>(
      builder: (context, uiState) {
        return BlocConsumer<ArchivedChatsCubit, ArchivedChatsState>(
          listener: (context, state) {
            if (state.errorMessage != null &&
                state.state == CubitStates.failure) {
              AppToast.error(context, state.errorMessage!);
              context.read<ArchivedChatsCubit>().clearError();
            }
            if (state.unarchiveActionState == CubitStates.success) {
              if (state.unarchiveMessage != null) {
                AppToast.success(context, context.tr(state.unarchiveMessage!));
              }
              context.read<ArchivedChatsCubit>().resetUnarchiveState();
            } else if (state.unarchiveActionState == CubitStates.failure) {
              if (state.unarchiveMessage != null) {
                AppToast.error(context, state.unarchiveMessage!);
              }
              context.read<ArchivedChatsCubit>().resetUnarchiveState();
            }
          },
          builder: (context, state) {
            if (uiState.isLoading || uiState.currentUserId == null) {
              return const ChatsSkeleton();
            }

            switch (state.state) {
              case CubitStates.loading:
                return const ChatsSkeleton();
              case CubitStates.failure:
                return CustomErrorView(
                  message: state.errorMessage,
                  onRetry: () => context.read<ArchivedChatsCubit>().refresh(),
                );
              case CubitStates.success:
                if (state.chatRooms.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildChatsList(context, state, uiState.currentUserId!);
              default:
                return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AssetsData.emptyChatImage, width: 150.w, height: 150.w),
          Gap(20.h),
          Text(
            context.tr('no_archived_chats'),
            style: Styles.textStyle18.copyWith(color: AppColors.secondary600),
          ),
          Gap(8.h),
          Text(
            context.tr('no_archived_chats_message'),
            style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsList(
    BuildContext context,
    ArchivedChatsState state,
    String currentUserId,
  ) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (state.hasMore && !state.isLoadingMore) {
            context.read<ArchivedChatsCubit>().fetchArchivedChats(
              loadMore: true,
            );
          }
        }
        return false;
      },
      child: RefreshIndicator.adaptive(
        onRefresh: () => context.read<ArchivedChatsCubit>().refresh(),
        color: AppColors.kprimaryColor,
        backgroundColor: AppColors.kWhiteColor,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          itemCount: state.chatRooms.length + (state.hasMore ? 1 : 0),
          separatorBuilder: (_, __) =>
              Divider(color: AppColors.secondary100, height: 1),
          itemBuilder: (context, index) {
            if (index == state.chatRooms.length) {
              return state.isLoadingMore
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.kprimaryColor,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            }
            return ChatItemWidget(
              key: ValueKey('chat_${state.chatRooms[index].id}'),
              chatRoom: state.chatRooms[index],
              currentUserId: currentUserId,
            );
          },
        ),
      ),
    );
  }
}
