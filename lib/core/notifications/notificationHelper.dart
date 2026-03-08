import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
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
        break;
      // ─── POST ───────────────────────────────────────────
      //need to go to post details with post id and comment id if exist
      case 'post_like':
      case 'post_comment':
      case 'post_share':
      case 'new_post_from_following':
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

      // ─── IGNORED ────────────────────────────────────────

      case 'user_blocked':
      case 'content_reported':
        debugPrint('ℹ️ Notification type $type - no navigation needed');
        break;

      // ─── DEFAULT ────────────────────────────────────────

      default:
        navigatorKey.currentState!.pushNamed(AppRouter.notification);
        break;
    }

    debugPrint('✅ Navigated for type: $type');
  }
}
