enum MessageStatusEnum { pending, sent, delivered, read, failed }

// Extension for parsing from string
extension MessageStatusExtension on MessageStatusEnum {
  static MessageStatusEnum fromString(String? status) {
    if (status == null) return MessageStatusEnum.sent;

    final lowerStatus = status.toLowerCase();
    
    switch (lowerStatus) {
      case 'pending':
        return MessageStatusEnum.pending;
      case 'sent':
        return MessageStatusEnum.sent;
      case 'delivered':
      case 'received': // RECEIVED = DELIVERED
        return MessageStatusEnum.delivered;
      case 'read':
        return MessageStatusEnum.read;
      case 'failed':
        return MessageStatusEnum.failed;
      default:
        // Log unknown status for debugging
        print('⚠️ Unknown message status: $status, defaulting to sent');
        return MessageStatusEnum.sent;
    }
  }

  String toApiString() {
    switch (this) {
      case MessageStatusEnum.pending:
        return 'pending';
      case MessageStatusEnum.sent:
        return 'sent';
      case MessageStatusEnum.delivered:
        return 'delivered';
      case MessageStatusEnum.read:
        return 'read';
      case MessageStatusEnum.failed:
        return 'failed';
    }
  }
}
