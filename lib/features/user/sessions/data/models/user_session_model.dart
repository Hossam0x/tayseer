class UserSessionModel {
  final String sessionId;
  final String sessionStatus;
  final String paymentStatus;
  final String? paymentDate;
  final bool isAnonymous;
  final bool isNow;
  final bool isUpcoming;
  final bool isDone;
  final String date;
  final UserSessionUser user;
  final UserSessionAdvisor advisor;
  final UserSessionTimeRange timeRange;

  const UserSessionModel({
    required this.sessionId,
    required this.sessionStatus,
    required this.paymentStatus,
    this.paymentDate,
    required this.isAnonymous,
    required this.isNow,
    required this.isUpcoming,
    required this.isDone,
    required this.date,
    required this.user,
    required this.advisor,
    required this.timeRange,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    return UserSessionModel(
      sessionId: json['sessionId'] ?? '',
      sessionStatus: json['sessionStatus'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      paymentDate: json['paymentDate'],
      isAnonymous: json['isAnonymous'] ?? false,
      isNow: json['isNow'] ?? false,
      isUpcoming: json['isUpcoming'] ?? false,
      isDone: json['isDone'] ?? false,
      date: json['date'] ?? '',
      user: UserSessionUser.fromJson(json['user'] ?? {}),
      advisor: UserSessionAdvisor.fromJson(json['advisor'] ?? {}),
      timeRange: UserSessionTimeRange.fromJson(json['timeRange'] ?? {}),
    );
  }
}

class UserSessionUser {
  final String id;
  final String name;
  final String image;

  const UserSessionUser({
    required this.id,
    required this.name,
    required this.image,
  });

  factory UserSessionUser.fromJson(Map<String, dynamic> json) {
    return UserSessionUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class UserSessionAdvisor {
  final String id;
  final String name;
  final String userName;
  final String image;

  const UserSessionAdvisor({
    required this.id,
    required this.name,
    required this.userName,
    required this.image,
  });

  factory UserSessionAdvisor.fromJson(Map<String, dynamic> json) {
    return UserSessionAdvisor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userName: json['userName'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class UserSessionTimeRange {
  final String fromTimeUTC;
  final String toTimeUTC;
  final String from;
  final String to;

  const UserSessionTimeRange({
    required this.fromTimeUTC,
    required this.toTimeUTC,
    required this.from,
    required this.to,
  });

  factory UserSessionTimeRange.fromJson(Map<String, dynamic> json) {
    return UserSessionTimeRange(
      fromTimeUTC: json['fromTimeUTC'] ?? '',
      toTimeUTC: json['toTimeUTC'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }
}

class UserSessionsResponse {
  final bool success;
  final String message;
  final UserSessionsData data;

  const UserSessionsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UserSessionsResponse.fromJson(Map<String, dynamic> json) {
    return UserSessionsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: UserSessionsData.fromJson(json['data'] ?? {}),
    );
  }
}

class UserSessionsData {
  final List<UserSessionModel> sessions;
  final UserSessionsPagination pagination;

  const UserSessionsData({required this.sessions, required this.pagination});

  factory UserSessionsData.fromJson(Map<String, dynamic> json) {
    final sessionsList = (json['sessions'] as List<dynamic>? ?? [])
        .map((e) => UserSessionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return UserSessionsData(
      sessions: sessionsList,
      pagination: UserSessionsPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class UserSessionsPagination {
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  const UserSessionsPagination({
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory UserSessionsPagination.fromJson(Map<String, dynamic> json) {
    return UserSessionsPagination(
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
    );
  }
}
