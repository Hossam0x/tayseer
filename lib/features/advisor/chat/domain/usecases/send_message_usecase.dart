import 'package:uuid/uuid.dart';
import 'package:tayseer/core/database/entities/pending_message_entity.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/domain/repositories/i_chat_repository.dart';

/// Parameters for sending a text message
class SendMessageParams {
  final String receiverId;
  final String message;
  final String chatRoomId;
  final String? replyMessageId;

  const SendMessageParams({
    required this.receiverId,
    required this.message,
    required this.chatRoomId,
    this.replyMessageId,
  });
}

/// Result of sending a message (optimistic)
class SendMessageResult {
  final ChatMessage localMessage;
  final String localId;
  final String tempId;
  final Map<String, dynamic> socketData;

  const SendMessageResult({
    required this.localMessage,
    required this.localId,
    required this.tempId,
    required this.socketData,
  });
}

/// Use case for sending text messages
/// Handles optimistic UI: saves locally first, then sends via socket
class SendMessageUseCase {
  final IChatRepository _repository;

  const SendMessageUseCase(this._repository);

  /// Execute the use case
  /// Returns [SendMessageResult] with local message for immediate UI update
  /// The actual socket sending is done by the Cubit
  Future<SendMessageResult> call(SendMessageParams params) async {
    // Generate UUID for reliable server matching
    const uuid = Uuid();
    final tempId = uuid.v4();
    final localId = 'temp_$tempId';
    final now = DateTime.now().toIso8601String();

    // Create reply info if replying
    ReplyInfo? replyInfo;
    if (params.replyMessageId != null) {
      replyInfo = ReplyInfo(
        replyMessageId: params.replyMessageId,
        replyMessage: null, // Will be filled by caller if needed
        isReply: true,
      );
    }

    // Create optimistic message
    final localMessage = ChatMessage(
      id: localId,
      chatRoomId: params.chatRoomId,
      senderId: params.receiverId,
      senderName: 'Me',
      senderImage: '',
      senderType: 'user',
      isMe: true,
      contentList: [params.message],
      messageType: 'text',
      createdAt: now,
      updatedAt: now,
      isRead: false,
      status: MessageStatusEnum.pending,
      reply: replyInfo,
    );

    // Save to local DB
    await _repository.saveMessageLocally(localMessage, localId: localId);

    // Add to pending queue for offline retry
    await _repository.addToPendingQueue(
      PendingMessageEntity(
        localId: localId,
        chatRoomId: params.chatRoomId,
        receiverId: params.receiverId,
        content: params.message,
        messageType: 'text',
        replyMessageId: params.replyMessageId,
        createdAt: now,
      ),
    );

    // Prepare socket data
    final socketData = <String, dynamic>{
      'receiverId': params.receiverId,
      'content': params.message,
      'tempId': tempId,
    };

    // Only include replyMessageId if it's a real server ID (not temp_)
    if (params.replyMessageId != null &&
        !params.replyMessageId!.startsWith('temp_')) {
      socketData['replyMessageId'] = params.replyMessageId;
    }

    return SendMessageResult(
      localMessage: localMessage,
      localId: localId,
      tempId: tempId,
      socketData: socketData,
    );
  }
}
