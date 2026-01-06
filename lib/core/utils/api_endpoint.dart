class ApiEndPoint {
  static const String stories = '/stories/all';
  static const String guestLogin = '/guest/login';
  static const String likeStory = '/story-likes/toggle';
  static const String storyViews = '/stories/view/';
  static const String posts = '/posts/all';
  static const String like = '/likes';
  static const String getAllchatRooms = '/chat';
  static String getChatMessages(String chatRoomId) =>
      '/chat/$chatRoomId/messages';
  static const String sendChatMedia = '/chat/messages/media';
}
