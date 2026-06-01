import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/services/chat_socket_service.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/story_details_view.dart';
import 'package:tayseer/main.dart';

class NotificationHelper {
  static void handleNotificationClick({RemoteMessage? message}) {
    try {
      if (navigatorKey.currentState != null &&
          navigatorKey.currentState!.mounted) {
        try {
          _navigate(message);
        } catch (e) {
          debugPrint('❌ Navigation failed: $e');
          debugPrint('📍 Stack trace: ${StackTrace.current}');
          pendingNotificationMessage = message;
        }
      } else {
        debugPrint('⚠️ Navigator not ready, saving notification for later');
        debugPrint(
          '⚠️ Navigator mounted: ${navigatorKey.currentState?.mounted}',
        );
        pendingNotificationMessage = message;
      }
    } catch (e) {
      debugPrint('❌ Error in handleNotificationClick: $e');
      debugPrint('📍 Stack trace: ${StackTrace.current}');
      pendingNotificationMessage = message;
    }
  }

  static void _navigate(RemoteMessage? message) {
    final data = message?.data ?? {};
    final type = data['type'] as String?;
    final postId = data['postId'] as String?;
    final commentId = data['commentId'] as String?;
    final storyId = data["storyId"] as String?;
    final eventId = data['eventId'] as String?;
    final sessionId = data['sessionId'] as String?;
    final senderId = data['senderId'] as String?;
    final senderName = data['senderName'] as String?;
    final senderImage = data['senderImage'] as String?;
    final senderRef = data['senderRef'] as String?;
    final receiverId = data['receiverId'] as String?;
    final receiverRef = data['receiverRef'] as String?;
    final bool isAdvisor = receiverRef == 'Advisor';

    debugPrint('🔔 Notification type: $type | receiverRef: $receiverRef');

    switch (type) {
      //chat
      case 'new_chat':
      case 'new_message':
        if (isAdvisor) {
          getIt<ChatSocketService>().clearChatNotificationCount();
          navigatorKey.currentState!.pushNamed(
            AppRouter.kConversitionView,
            arguments: {
              'receiverid': senderId ?? '',
              'chatroomid': data['chatId'] as String?,
              'username': data['senderName'] as String?,
              'userimage': data['senderImage'] as String?,
              'isBlocked': false,
              'isHaveSession': true,
            },
          );
        } else {
          getIt<ChatSocketService>().clearChatNotificationCount();
          navigatorKey.currentState!.pushNamed(
            AppRouter.kUserChatView,
            arguments: {
              'receiverid': senderId ?? '',
              'chatroomid': data['chatId'] as String?,
              'username': data['senderName'] as String?,
              'userimage': data['senderImage'] as String?,
              'isBlocked': false,
            },
          );
        }
        break;
      // ─── POST ───────────────────────────────────────────
      //need to go to post details with post id and comment id if exist
      case 'post_like':
      case 'post_comment':
      case 'post_share':
      case 'new_post_from_following':
      case 'post_suggestion':
      case 'comment_like':
      case 'comment_reply':
      case 'reply_like':
        if (postId != null && postId!.isNotEmpty) {
          debugPrint('📍 Navigate to post: $postId');
          navigatorKey.currentState!.pushNamed(
            AppRouter.kPostDetailsView,
            arguments: {'postID': postId},
          );
        } else {
          debugPrint('❌ postId is null or empty!');
        }
        break;

      case 'story_like':
        if (storyId != null && storyId.isNotEmpty) {
          _navigateToStory(storyId);
        } else {
          navigatorKey.currentState!.pushNamed(
            isAdvisor
                ? AppRouter.kAdvisorLayoutView
                : AppRouter.kUserLayoutView,
            arguments: {'receiverRef': receiverRef},
          );
        }
        break;

      case 'story_view':
        navigatorKey.currentState!.pushNamed(
          isAdvisor ? AppRouter.kAdvisorLayoutView : AppRouter.kUserLayoutView,
          arguments: {'receiverRef': receiverRef},
        );
        break;
      // ─── EVENT ──────────────────────────────────────────

      case 'event_reservation':
      case 'event_share':
        //need event id

        navigatorKey.currentState!.pushNamed(
          AppRouter.kEventDetailView,
          arguments: {'eventId': eventId},
        );
        break;

      // ─── SESSION ────────────────────────────────────────

      case 'session_paid':

        //need session id
        navigatorKey.currentState!.pushNamed(
          AppRouter.incommingsessiondetails,
          arguments: sessionId,
        );
        break;

      // ─── FOLLOW ─────────────────────────────────────────

      case 'new_follower':
        // receiverRef يحدد نوع المستخدم 'User' أو 'Advisor'
        navigatorKey.currentState!.pushNamed(
          AppRouter.kFollowersView,
          arguments: receiverId,
        );
        break;

      // ─── SYSTEM ─────────────────────────────────────────

      case 'account_approved':
      case 'account_rejected':
        navigatorKey.currentState!.pushNamed(AppRouter.notification);
        break;

      // ─── AUTO ────────────────────────────────────────────

      case 'auto':
        final subType = data['subType'] as String?;
        if (subType == 'suggested_match') {
          final matchId = data['matchId'] as String?;
          if (matchId != null && matchId.isNotEmpty) {
            navigatorKey.currentState!.pushNamed(
              AppRouter.kMarriageView,
              arguments: {'personId': matchId},
            );
          } else {
            navigatorKey.currentState!.pushNamed(AppRouter.notification);
          }
        } else {
          navigatorKey.currentState!.pushNamed(AppRouter.notification);
        }
        break;

      // ─── IGNORED ────────────────────────────────────────

      case 'user_blocked':
      case 'content_reported':
      case 'system':
        debugPrint('ℹ️ Notification type $type - no navigation needed');
        break;

      // ─── DEFAULT ────────────────────────────────────────

      default:
        navigatorKey.currentState!.pushNamed(AppRouter.notification);
        break;
    }

    debugPrint('✅ Navigated for type: $type');
  }

  static Future<void> _navigateToStory(String storyId) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final storiesCubit = getIt<StoriesCubit>();
    final userStories = await storiesCubit.fetchStoriesForNavigation(
      advisorId: kCurrentUserData?.id,
    );

    if (userStories.isEmpty || !context.mounted) return;

    int userIndex = userStories.indexWhere(
      (us) => us.stories.any((s) => s.id == storyId),
    );
    if (userIndex == -1) userIndex = 0;

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (newContext, animation, secondaryAnimation) =>
            BlocProvider.value(
              value: storiesCubit,
              child: StoryDetailsView(
                usersStories: userStories,
                initialUserIndex: userIndex,
                initialStoryId: storyId,
              ),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}
