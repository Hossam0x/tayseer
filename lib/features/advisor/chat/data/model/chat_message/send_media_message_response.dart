import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';

/// Response for POST /new-chat/messages/upload-media
class SendMessageResponse {
  final bool success;
  final ChatMessage message;

  SendMessageResponse({required this.success, required this.message});

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    // New structure: { "success": true, "data": { "message": { ... } } }
    final dataObj = json['data'];
    final messageData = (dataObj is Map<String, dynamic>)
        ? (dataObj['message'] ?? dataObj)
        : (json['message'] ?? json);

    return SendMessageResponse(
      success: json['success'] ?? false,
      message: ChatMessage.fromJson(messageData as Map<String, dynamic>),
    );
  }
}
