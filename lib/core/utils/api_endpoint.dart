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
  static const String nameAndImage = '/advisor/getNameAndImage';
  static const String deleteChatMessage = '/chat/messages/';
  static String deleteChatRoom(String chatRoomId) => '/chat/$chatRoomId';
  static String archiveChatRoom(String chatRoomId) =>
      '/chat/$chatRoomId/archive';
  static const String blockuser = '/blocks/block';
  static const String unblockuser = '/blocks/unblock';
  static const String profileData = '/advisor/getProfile';
  static const String category = '/category';

  static const String savePost = '/saved-posts';
  static const String deletePost = '/posts/delete/';
  static const String hidePost = '/hidden/post';
  static const String advisorUserChat = '/chat/advisor-user';
  static String advisorChatProfile(String userId) =>
      '/session/user-sessions/$userId';
  static String sessionDetails(String sessionId) =>
      '/session/session-details/$sessionId';
  static String cancelSession(String sessionId) => "/session/cancel/$sessionId";
  static String getValidDaysAndHours(String sessionId, int month) =>
      "/session/valid-days-and-hours/$sessionId?month=$month";
  static const String createSession = "/session/create";
  static const String discountcodeValidate = "/discount-code/isValidCode";
  static const String paysession = "/session/pay";
  static const String rateadvisor = "/advisor-rating";
  static String updatesession(String sessionId) => "/session/update/$sessionId";
  static const String advisorsession = "/session/advisor-sessions";
  static const String getpendingsession = "/session/advisor-pending-sessions";
  static String acceptordeclinesession(String sessionId) =>
      "/session/advisor-session-status/$sessionId";
  static String advisorSessionDetails(String sessionId) =>
      "/session/advisor-session-details/$sessionId";
  static const String archivePost = '/posts/archive/';
  static const String deleteReply = '/comment-replies/delete/';

  static const String hideComment = '/hidden/comment';
  static const String hideReply = '/hidden/reply';

  //  // ✅ Interactions (NEW)
  // static const String explorationUsers = '/interactions/exploration';
  // static const String historyUsers = '/interactions/history';
  // static const String toggleFavorite = '/interactions/favorite';
  // static const String sendCompliment = '/interactions/compliment';
  // static const String likeUser = '/interactions/like';
}
