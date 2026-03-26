import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/overlay_manager.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/scroll_behavior_handler.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/state/chat_messages_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/typing/typing_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/typing/typing_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/message_shimmer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/selectable_message_list_view.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/typing_indicator.dart';
class ChatMessagesArea extends StatelessWidget {
  final bool isMobile;
  final ScrollController scrollController;
  final ScrollBehaviorHandler scrollHandler;
  final OverlayManager overlayManager;
  final VoidCallback onStateChanged;

  const ChatMessagesArea({
    super.key,
    required this.isMobile,
    required this.scrollController,
    required this.scrollHandler,
    required this.overlayManager,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatMessagesCubit, ChatMessagesState>(
      listenWhen: (previous, current) =>
          previous.messages.length != current.messages.length ||
          previous.loadingState != current.loadingState,
      listener: (context, state) {
        scrollHandler.handleMessageCountChange(
          currentCount: state.messages.length,
          isSuccess: state.loadingState == CubitStates.success,
        );
      },
      buildWhen: (previous, current) =>
          previous.loadingState != current.loadingState ||
          previous.messages != current.messages ||
          previous.freeChatMinutes != current.freeChatMinutes,
      builder: (context, state) {
        if (state.loadingState == CubitStates.loading) {
          return const MessageShimmer();
        }

        if (state.loadingState == CubitStates.success ||
            state.messages.isNotEmpty) {
          return Column(
            children: [
              if (!state.isOnline) _buildOfflineIndicator(),
              if (state.freeChatMinutes != null && state.freeChatMinutes! > 0)
                _FreeChatBanner(minutes: state.freeChatMinutes!),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification) {
                      final metrics = notification.metrics;
                      if (metrics.pixels >= metrics.maxScrollExtent - 100) {
                        context.read<ChatMessagesCubit>().loadOlderMessages();
                      }
                    }
                    return false;
                  },
                  child: SelectableMessageListView(
                    messages: state.messages,
                    scrollController: scrollController,
                    onMessageLongPress: (message, key) {
                      overlayManager.showOverlay(
                        message: message,
                        key: key,
                        onStateChanged: onStateChanged,
                      );
                    },
                    onReplyTap: (messageId, messages) {
                      if (messageId != null) {
                        overlayManager.scrollToMessage(
                          messageId: messageId,
                          allMessages: messages,
                        );
                      }
                    },
                  ),
                ),
              ),
              _buildTypingIndicator(),
            ],
          );
        }

        if (state.loadingState == CubitStates.failure) {
          return _ChatErrorState(errorMessage: state.errorMessage);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildOfflineIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.orange.shade100,
      child: const Text(
        'أنت غير متصل - سيتم إرسال الرسائل عند الاتصال',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.orange),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return BlocBuilder<TypingCubit, TypingState>(
      builder: (context, typingState) {
        if (typingState.isUserTyping && typingState.typingInfo != null) {
          return TypingIndicator(userName: typingState.typingInfo!.userName);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _FreeChatBanner extends StatelessWidget {
  final int minutes;

  const _FreeChatBanner({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xfffdf2f2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xfff8d7da).withValues(alpha: 0.5),
        ),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text:
                  'لديك $minutes دقيقة الآن لإرسال استفسارك ، وستحصل على إجابة مجانية من المستشار!\n',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            WidgetSpan(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.userticketSessionView);
                },
                child: const Text(
                  'احجز جلسة',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xffa94442),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const TextSpan(
              text: ' للحصول على المزيد من الاستشارات .',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ChatErrorState extends StatelessWidget {
  final String? errorMessage;

  const _ChatErrorState({this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'حدث خطأ ما',
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ChatMessagesCubit>().loadInitialMessages(
                    context.read<ChatMessagesCubit>().state.messages.first.chatRoomId,
                  );
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
