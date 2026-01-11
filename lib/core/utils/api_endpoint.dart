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
  static const String share = '/shares';
  static const String comments = '/comments';
  static const String replies = '/comment-replies/comment/';
  static const String createReply = '/comment-replies/create';
  static const String commentLike = '/comment-likes/toggle';
  static const String updateReply = '/comment-replies/update/';
  static const String reels = '/posts/reels';
}
