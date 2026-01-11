import 'package:dartz/dartz.dart';

/// Chat Feature Failures
/// Using sealed class for exhaustive pattern matching
sealed class ChatFailure {
  const ChatFailure();

  String get message;
}

/// Network connection failure
class NetworkFailure extends ChatFailure {
  final String? errorMessage;

  const NetworkFailure([this.errorMessage]);

  @override
  String get message => errorMessage ?? 'فشل الاتصال بالخادم';
}

/// Failed to send text message
class SendMessageFailure extends ChatFailure {
  final String? errorMessage;

  const SendMessageFailure([this.errorMessage]);

  @override
  String get message => errorMessage ?? 'فشل إرسال الرسالة';
}

/// Failed to send media message
class SendMediaFailure extends ChatFailure {
  final String? errorMessage;

  const SendMediaFailure([this.errorMessage]);

  @override
  String get message => errorMessage ?? 'فشل إرسال الوسائط';
}

/// Failed to load messages
class LoadMessagesFailure extends ChatFailure {
  final String? errorMessage;

  const LoadMessagesFailure([this.errorMessage]);

  @override
  String get message => errorMessage ?? 'فشل تحميل الرسائل';
}

/// Failed to delete message(s)
class DeleteMessageFailure extends ChatFailure {
  final String? errorMessage;

  const DeleteMessageFailure([this.errorMessage]);

  @override
  String get message => errorMessage ?? 'فشل حذف الرسالة';
}

/// Failed to block user
class BlockUserFailure extends ChatFailure {
  final String? errorMessage;

  const BlockUserFailure([this.errorMessage]);

  @override
  String get message => errorMessage ?? 'فشل حظر المستخدم';
}

/// Failed to unblock user
class UnblockUserFailure extends ChatFailure {
  final String? errorMessage;

  const UnblockUserFailure([this.errorMessage]);

  @override
  String get message => errorMessage ?? 'فشل إلغاء حظر المستخدم';
}

/// Cache operation failure
class CacheFailure extends ChatFailure {
  final String? errorMessage;

  const CacheFailure([this.errorMessage]);

  @override
  String get message => errorMessage ?? 'فشل عملية التخزين المؤقت';
}

/// Type alias for cleaner Either usage
typedef ChatResult<T> = Either<ChatFailure, T>;
