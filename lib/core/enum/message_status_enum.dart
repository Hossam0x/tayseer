enum MessageStatusEnum { sent, delivered, read }

// Extension for parsing from string
extension MessageStatusExtension on MessageStatusEnum {
  static MessageStatusEnum fromString(String? status) {
    if (status == null) return MessageStatusEnum.sent;

    switch (status.toLowerCase()) {
      case 'sent':
        return MessageStatusEnum.sent;
      case 'delivered':
        return MessageStatusEnum.delivered;
      case 'read':
        return MessageStatusEnum.read;
      default:
        return MessageStatusEnum.sent;
    }
  }

  String toApiString() {
    switch (this) {
      case MessageStatusEnum.sent:
        return 'sent';
      case MessageStatusEnum.delivered:
        return 'delivered';
      case MessageStatusEnum.read:
        return 'read';
    }
  }
}
