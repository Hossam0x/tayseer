class TypingModel {
  final String userId;
  final String userName;
  final String chatRoomId;

  TypingModel({
    required this.userId,
    required this.userName,
    required this.chatRoomId,
  });

  factory TypingModel.fromJson(Map<String, dynamic> json) {
    return TypingModel(
      userId: json['userId']?.toString() ?? "",
      userName: json['userName']?.toString() ?? "",
      chatRoomId: json['chatRoomId']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'userName': userName, 'chatRoomId': chatRoomId};
  }
}
