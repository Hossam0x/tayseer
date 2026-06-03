/// Response model for GET /new-chat/messages/details
class MessageDetailsModel {
  /// Timestamp when the message was delivered to the recipient's device.
  final DateTime? receivedAt;

  /// Timestamp when the recipient read the message. Null means not read yet.
  final DateTime? readAt;

  const MessageDetailsModel({this.receivedAt, this.readAt});

  factory MessageDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return MessageDetailsModel(
      receivedAt: _parseDate(data['receivedAt']),
      readAt: _parseDate(data['readAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
