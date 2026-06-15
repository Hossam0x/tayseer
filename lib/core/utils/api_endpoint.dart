class ApiEndPoint {
  static const String allStories = '/stories/all';
  static const String myStories = '/stories/my-stories';
  static String specialStories([String? advisorId]) =>
      '/stories/special/${advisorId ?? ''}';
  static const String guestLogin = '/guest/login';
  static const String likeStory = '/story-likes/toggle';
  static const String storyViews = '/stories/view/';
  static const String posts = '/posts/all';
  static const String like = '/likes';
  static const String getAllchatRooms = '/new-chat/rooms';
  static const String getArchivedChatRooms = '/new-chat/rooms/archived';
  static const String getChatMessages = '/new-chat/messages/room-messages';
  static const String getChatMessageDetails = '/new-chat/messages/details';
  static const String sendChatMedia = '/new-chat/messages/upload-media';
  static const String share = '/shares';
  static const String comments = '/comments';
  static const String replies = '/comment-replies/comment/';
  static const String createReply = '/comment-replies/create';
  static const String commentLike = '/comment-likes/toggle';
  static const String updateReply = '/comment-replies/update/';
  static const String reels = '/posts/reels';
  static const String nameAndImage = '/advisor/getNameAndImage';
  static const String deleteChatMessage = '/new-chat/messages/delete-message';
  static const String deleteChatRoom = '/new-chat/rooms/delete-chat-room';
  static const String archiveChatRoom = '/new-chat/rooms/archive';
  static const String unarchiveChatRoom = '/new-chat/rooms/unarchive';
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
  static String getOfferingsBooking(String advisorId) =>
      '/advisor/offerings/$advisorId';
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
  static const String advisorStatistics = '/advisor/statistics';
  static const String vote = '/votes';
  //  // ✅ Interactions (NEW)
  // static const String explorationUsers = '/interactions/exploration';
  // static const String historyUsers = '/interactions/history';
  // static const String toggleFavorite = '/interactions/favorite';
  // static const String sendCompliment = '/interactions/compliment';
  // static const String likeUser = '/interactions/like';
  static const String rateApp = '/app-rate/rate';
  static const String followAdvisor = '/advisor/toggle-follow/';
  static const String changeIsAvaliableForSessions =
      '/advisor/changeIsAvaliableForSessions';
  static const String wallet = '/new-wallet/';
  static const String walletTransactions = '/new-wallet/transaction-history';
  static const String walletEarnings = '/new-wallet/advisor-earnings';
  static const String balancePackages = '/balance-packages';
  static const String initiatePurchase = '/iap/initiate-purchase';
  static const String withdrawMethods = '/advisor/withdraw/methods';
  static const String withdraw = '/advisor/withdraw/request';
  static const String initiateSubscriptionPurchase = '/iap/initiate-purchase';
  static const String reportReasons = '/report-reasons';
  static const String sendReport = "/reports/";
  static const String getChatRequests = '/advisor/chat-requests';
  static const String searchChatRooms = '/new-chat/rooms/search';
  static const String myAdvisorSubscription =
      '/new-advisor-sub/my-subscription';
  static const String cancelAdvisorSubscription =
      '/new-advisor-sub/cancel-my-subscription';
  static const String userSubscriptions = '/new-user-sub';
  static const String myUserSubscription = '/new-user-sub/my-subscription';
  static const String cancelUserSubscription =
      '/new-user-sub/cancel-my-subscription';
  static const String regardsPackages = '/regards-package';
  static const String userChatRegardRequests = '/user-chat/regards/incoming';
  static const String userChatAcceptRegard = '/user-chat/regards/accept';
  static const String userChatRejectRegard = '/user-chat/regards/reject';
  static const String userChatMatchingList = '/user-chat/rooms/matching-list';
  static const String userChatRoomState = '/user-chat/rooms/state';
  static const String userChatCancelMatch = '/user-chat/rooms/cancel';
  static const String sharePostToStory = '/stories/share-post';
  static const String pastMatches = '/user/past-matches';
  static const String setSocialStatus = '/user/set-social-status';
  static const String bestAdvisors = '/advisor/best';
  static const String similarUsers = '/user/similar-users';
  static const String chatDurationExtensions = '/chat-duration-extension';
  static const String iapRestorePurchase = '/iap/restore-purchase';
  static const String iapTransferSubscription = '/iap/transfer-subscription';
  static const String confirmSubscriptionPurchase = '/iap/confirm-purchase';

  // Google / Paymob Android subscriptions
  static const String initiateGoogleSubscriptionPayment =
      '/new-paymob/initiate-google-subscription-payment';
  static const String cancelAndroidAutoRenewal =
      '/new-paymob/cancel-auto-renewal';

  // Google Play consumable verification
  static const String verifyGoogleConsumable =
      '/iap/verify-google-consumable';

  // Paymob Android one-time purchases (regards, chat duration, etc.)
  static const String initiateOneTimePayment =
      '/new-paymob/initiate-one-time-payment';

  // Paymob: check purchase status by orderId
  static String paymobPurchaseStatus(int orderId) =>
      '/new-paymob/purchase-status/$orderId';

  // Force Update
  static const String checkForUpdateIos = '/version/check-for-update';
  static const String checkForUpdateAndroid =
      '/version/check-for-update-android';

  // User Sessions
  static const String getUserSessions = '/session/get-all-for-user';

  // Zego Credentials
  static const String zegoCredentials = '/session/zego-cred';
}
