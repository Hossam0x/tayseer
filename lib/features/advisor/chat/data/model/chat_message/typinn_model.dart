class TypinnModel {
  final String userId;
  final String userName;
  final String chatRoomId;

  TypinnModel({
    required this.userId,
    required this.userName,
    required this.chatRoomId,
  });

  factory TypinnModel.fromJson(Map<String, dynamic> json) {
    return TypinnModel(
      userId: json['userId']?.toString() ?? "",
      userName: json['userName']?.toString() ?? "",
      chatRoomId: json['chatRoomId']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'userName': userName, 'chatRoomId': chatRoomId};
  }
}
