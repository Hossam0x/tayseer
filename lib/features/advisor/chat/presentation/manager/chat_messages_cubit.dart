import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/typinn_model.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_state.dart';
import 'package:tayseer/my_import.dart';

class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  final ChatRepo chatRepo;
  final tayseerSocketHelper socketHelper = getIt.get<tayseerSocketHelper>();
  Timer? _typingTimer;

  // ✅ Unique Listener ID لهذا الـ Cubit
  late final String _listenerId;

  // ✅ حفظ الـ chatRoomId الحالي
  String? _currentChatRoomId;

  ChatMessagesCubit(this.chatRepo) : super(ChatMessagesState()) {
    // إنشاء ID فريد لهذا الـ Cubit
    _listenerId =
        'ChatMessagesCubit_${DateTime.now().millisecondsSinceEpoch}_${hashCode}';
    log('🆔 ChatMessagesCubit created with ID: $_listenerId');
  }

  /// ✅ Safe emit - لا يعمل emit لو الـ Cubit مقفول
  void _safeEmit(ChatMessagesState newState) {
    if (!isClosed) {
      emit(newState);
    } else {
      log('⚠️ [$_listenerId] Attempted to emit after close');
    }
  }

  Future<void> getChatMessages(String chatRoomId) async {
    _currentChatRoomId = chatRoomId;
    log('📥 [$_listenerId] Getting messages for room: $chatRoomId');

    _safeEmit(state.copyWith(getChatMessages: CubitStates.loading));

    final result = await chatRepo.getChatMessages(chatRoomId);

    if (isClosed) {
      log('⚠️ [$_listenerId] Cubit closed during API call');
      return;
    }

    result.fold(
      (error) => _safeEmit(
        state.copyWith(
          getChatMessages: CubitStates.failure,
          errorMessage: error,
        ),
      ),
      (response) => _safeEmit(
        state.copyWith(
          getChatMessages: CubitStates.success,
          messages: response.data.messages,
          pagination: response.data.pagination,
        ),
      ),
    );
  }

  void addMessageLocally(ChatMessage message) {
    if (isClosed) {
      log('⚠️ [$_listenerId] Cannot add message - Cubit is closed');
      return;
    }

    final currentMessages = state.messages ?? [];
    final updatedMessages = [...currentMessages, message];
    _safeEmit(state.copyWith(messages: updatedMessages));
  }

  /// ✅ تعيين الرسالة للرد عليها
  void setReplyingToMessage(ChatMessage? message) {
    if (isClosed) return;
    log('📝 [$_listenerId] Setting replying to message: ${message?.id}');
    _safeEmit(
      state.copyWith(
        replyingToMessage: message,
        clearReplyingToMessage: message == null,
      ),
    );
  }

  /// ✅ إلغاء الرد
  void cancelReply() {
    if (isClosed) return;
    log('❌ [$_listenerId] Cancelling reply');
    _safeEmit(state.copyWith(clearReplyingToMessage: true));
  }

  void sendMessage(
    String receiverId,
    String message,
    String chatRoomId, {
    String? replyMessageId,
  }) {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    ReplyInfo? replyInfo;
    if (replyMessageId != null) {
      final originalMessage = state.messages?.firstWhere(
        (msg) => msg.id == replyMessageId,
        orElse: () => ChatMessage(
          id: '',
          chatRoomId: '',
          senderId: '',
          senderName: '',
          senderImage: '',
          senderType: '',
          isMe: false,
          contentList: [],
          messageType: '',
          createdAt: '',
          updatedAt: '',
          isRead: false,
        ),
      );
      replyInfo = ReplyInfo(
        replyMessageId: replyMessageId,
        replyMessage: originalMessage?.content,
        isReply: true,
      );
    }

    final localMessage = ChatMessage(
      id: tempId,
      chatRoomId: chatRoomId,
      senderId: receiverId,
      senderName: 'Me',
      senderImage: '',
      senderType: 'user',
      isMe: true,
      contentList: [message],
      messageType: 'text',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      isRead: false,
      status: MessageStatusEnum.sent,
      reply: replyInfo,
    );

    addMessageLocally(localMessage);

    final messageData = <String, dynamic>{
      'receiverId': receiverId,
      'content': message,
    };

    if (replyMessageId != null) {
      messageData['replyMessageId'] = replyMessageId;
    }

    socketHelper.send('send_message', messageData, (ack) {});
  }

  /// ✅ الاستماع للرسائل الجديدة
  void listenToNewMessages() {
    log('🎧 [$_listenerId] Setting up new_message listener');

    socketHelper.listenWithId('new_message', _listenerId, (data) {
      _handleNewMessage(data);
    });
  }

  /// ✅ معالجة الرسالة الجديدة
  void _handleNewMessage(dynamic data) {
    if (isClosed) {
      log('⚠️ [$_listenerId] Received message but Cubit is closed - ignoring');
      return;
    }

    if (_currentChatRoomId == null) {
      log('⚠️ [$_listenerId] No current chatRoomId - ignoring message');
      return;
    }

    log('📨 [$_listenerId] Processing new message');

    try {
      final newMessage = ChatMessage.fromJson(data);

      if (newMessage.chatRoomId != _currentChatRoomId) {
        log(
          '📭 [$_listenerId] Message is for different room (${newMessage.chatRoomId}), ignoring',
        );
        return;
      }

      log('✅ [$_listenerId] Message is for current room');

      if (newMessage.isMe) {
        _replaceLocalMessageWithServer(newMessage);
      } else {
        addMessageLocally(newMessage);
      }
    } catch (e, stackTrace) {
      log('❌ [$_listenerId] Error processing message: $e');
      log('StackTrace: $stackTrace');
    }
  }

  void _replaceLocalMessageWithServer(ChatMessage serverMessage) {
    if (isClosed) return;

    final currentMessages = state.messages ?? [];

    final localMessageIndex = currentMessages.lastIndexWhere((msg) {
      return msg.id.startsWith('temp_') &&
          msg.chatRoomId == serverMessage.chatRoomId &&
          msg.content == serverMessage.content &&
          msg.isMe == true;
    });

    if (localMessageIndex != -1) {
      log(
        '🔄 [$_listenerId] Replacing local message at index $localMessageIndex',
      );
      final updatedMessages = List<ChatMessage>.from(currentMessages);
      updatedMessages[localMessageIndex] = serverMessage;
      _safeEmit(state.copyWith(messages: updatedMessages));
    } else {
      log('📝 [$_listenerId] No local message found, adding server message');
      addMessageLocally(serverMessage);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ NEW: الاستماع لـ messages_read event
  // ═══════════════════════════════════════════════════════════════════════════

  /// ✅ الاستماع لحدث قراءة الرسائل
  void listenToMessagesRead() {
    log('🎧 [$_listenerId] Setting up messages_read listener');

    socketHelper.listenWithId('messages_read', _listenerId, (data) {
      _handleMessagesRead(data);
    });
  }

  /// ✅ معالجة حدث قراءة الرسائل
  void _handleMessagesRead(dynamic data) {
    if (isClosed) {
      log(
        '⚠️ [$_listenerId] Received messages_read but Cubit is closed - ignoring',
      );
      return;
    }

    log('👁️ [$_listenerId] Processing messages_read event: $data');

    try {
      final chatRoomId = data['chatRoomId']?.toString();
      final readByName = data['readByName']?.toString();

      if (chatRoomId == null) {
        log('❌ [$_listenerId] chatRoomId is null in messages_read');
        return;
      }

      // التحقق من أن الـ event للـ chatRoom الحالي
      if (chatRoomId != _currentChatRoomId) {
        log(
          '📭 [$_listenerId] messages_read is for different room ($chatRoomId), ignoring',
        );
        return;
      }

      log(
        '✅ [$_listenerId] Marking all my messages as read (read by: $readByName)',
      );

      _markAllMyMessagesAsRead();
    } catch (e, stackTrace) {
      log('❌ [$_listenerId] Error processing messages_read: $e');
      log('StackTrace: $stackTrace');
    }
  }

  /// ✅ تحديث كل رسائلي لتصبح مقروءة
  void _markAllMyMessagesAsRead() {
    if (isClosed) return;

    final currentMessages = state.messages;
    if (currentMessages == null || currentMessages.isEmpty) {
      log('⚠️ [$_listenerId] No messages to mark as read');
      return;
    }

    // تحديث كل رسائلي (isMe = true) لتصبح isRead = true و status = read
    final updatedMessages = currentMessages.map((message) {
      if (message.isMe &&
          (!message.isRead || message.status != MessageStatusEnum.read)) {
        log('✅ [$_listenerId] Marking message ${message.id} as read');
        return message.copyWith(isRead: true, status: MessageStatusEnum.read);
      }
      return message;
    }).toList();

    _safeEmit(state.copyWith(messages: updatedMessages));

    log('✅ [$_listenerId] All my messages marked as read');
  }

  // ═══════════════════════════════════════════════════════════════════════════

  /// ✅ الاستماع لـ typing
  void listenToUserTyping(String currentChatRoomId) {
    log(
      '🎧 [$_listenerId] Setting up user_typing listener for room: $currentChatRoomId',
    );

    socketHelper.listenWithId('user_typing', _listenerId, (data) {
      _handleUserTyping(data, currentChatRoomId);
    });
  }

  /// ✅ معالجة الـ typing
  void _handleUserTyping(dynamic data, String currentChatRoomId) {
    if (isClosed) {
      log('⚠️ [$_listenerId] Received typing but Cubit is closed - ignoring');
      return;
    }

    final userId = data['userId']?.toString();
    final userName = data['userName']?.toString();
    final chatRoomId = data['chatRoomId']?.toString();

    log('⌨️ [$_listenerId] Typing event - Room: $chatRoomId, User: $userName');

    if (chatRoomId == currentChatRoomId) {
      log('✅ [$_listenerId] Typing is for current room');

      _typingTimer?.cancel();

      _safeEmit(
        state.copyWith(
          isUserTyping: true,
          typingInfo: TypinnModel(
            userId: userId ?? '',
            userName: userName ?? '',
            chatRoomId: chatRoomId ?? '',
          ),
        ),
      );

      _typingTimer = Timer(const Duration(seconds: 3), () {
        resetTypingStatus();
      });
    } else {
      log('📭 [$_listenerId] Typing is for different room, ignoring');
    }
  }

  void resetTypingStatus() {
    if (isClosed) return;

    log('🔄 [$_listenerId] Resetting typing status');
    _safeEmit(state.copyWith(isUserTyping: false, clearTypingInfo: true));
  }

  Future<void> sendMediaMessage({
    required String chatRoomId,
    required String messageType,
    List<File>? images,
    List<File>? videos,
    String? replyMessageId,
  }) async {
    if (isClosed) return;

    _safeEmit(state.copyWith(sendMediaMessage: CubitStates.loading));

    final result = await chatRepo.sendMediaMessage(
      chatRoomId: chatRoomId,
      messageType: messageType,
      images: images,
      videos: videos,
      replyMessageId: replyMessageId,
    );

    if (isClosed) return;

    result.fold(
      (error) => _safeEmit(
        state.copyWith(
          sendMediaMessage: CubitStates.failure,
          errorMessage: error,
        ),
      ),
      (response) {
        final chatMessage = ChatMessage(
          id: response.data.id,
          chatRoomId: response.data.chatRoomId,
          senderId: response.data.senderId,
          senderName: response.data.senderName,
          senderImage: response.data.senderImage ?? '',
          senderType: response.data.senderType,
          isMe: response.data.isMe,
          contentList: response.data.contentList,
          messageType: response.data.messageType,
          createdAt: response.data.createdAt,
          updatedAt: response.data.updatedAt,
          isRead: response.data.isRead,
          reply: response.data.reply, // ✅ إضافة الـ reply من الـ response
        );

        final currentMessages = state.messages ?? [];
        final updatedMessages = [...currentMessages, chatMessage];

        _safeEmit(
          state.copyWith(
            sendMediaMessage: CubitStates.success,
            sentMessage: chatMessage,
            messages: updatedMessages,
          ),
        );
      },
    );
  }

  void typingstart(String chatRoomId) {
    log('🚀 [$_listenerId] Sending typing_start for room: $chatRoomId');

    socketHelper.send('typing_start', {'chatRoomId': chatRoomId}, (ack) {
      log('✅ typing_start ACK: $ack');
    });
  }

  void typingstop(String chatRoomId) {
    log('🚀 [$_listenerId] Sending typing_stop for room: $chatRoomId');

    socketHelper.send('typing_stop', {'chatRoomId': chatRoomId}, (ack) {
      log('✅ typing_stop ACK: $ack');
    });
  }

  @override
  Future<void> close() {
    log('🔴 [$_listenerId] Closing ChatMessagesCubit...');

    _typingTimer?.cancel();
    _typingTimer = null;

    socketHelper.offAllForListener(_listenerId);

    _currentChatRoomId = null;

    log('✅ [$_listenerId] ChatMessagesCubit closed and cleaned up');

    socketHelper.debugPrintListeners();

    return super.close();
  }
}
