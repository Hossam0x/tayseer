import 'package:equatable/equatable.dart';

class RoomInfoModel extends Equatable {
  final String chatRoomId;
  final bool isBlocked;
  final bool isHaveSession;

  const RoomInfoModel({
    required this.chatRoomId,
    required this.isBlocked,
    required this.isHaveSession,
  });

  factory RoomInfoModel.fromJson(Map<String, dynamic> json) {
    return RoomInfoModel(
      chatRoomId: json['chatRoomId']?.toString() ?? '',
      isBlocked: json['isBlocked'] ?? false,
      isHaveSession: json['isHaveSession'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'chatRoomId': chatRoomId,
    'isBlocked': isBlocked,
    'isHaveSession': isHaveSession,
  };

  RoomInfoModel copyWith({
    String? chatRoomId,
    bool? isBlocked,
    bool? isHaveSession,
  }) {
    return RoomInfoModel(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      isBlocked: isBlocked ?? this.isBlocked,
      isHaveSession: isHaveSession ?? this.isHaveSession,
    );
  }

  @override
  List<Object?> get props => [chatRoomId, isBlocked, isHaveSession];
}
