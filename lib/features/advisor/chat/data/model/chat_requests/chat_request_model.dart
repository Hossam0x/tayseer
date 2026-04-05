import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_request_model.freezed.dart';

@freezed
class ChatRequestsResponse with _$ChatRequestsResponse {
  const factory ChatRequestsResponse({
    required bool success,
    required String message,
    required ChatRequestsData data,
  }) = _ChatRequestsResponse;

  factory ChatRequestsResponse.fromJson(Map<String, dynamic> json) {
    return ChatRequestsResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: ChatRequestsData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

@freezed
class ChatRequestsData with _$ChatRequestsData {
  const factory ChatRequestsData({
    required List<ChatRequestModel> requests,
    required RequestPagination pagination,
  }) = _ChatRequestsData;

  factory ChatRequestsData.fromJson(Map<String, dynamic> json) {
    return ChatRequestsData(
      requests: (json['requests'] as List?)
              ?.map((e) => ChatRequestModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: RequestPagination.fromJson(
          json['pagination'] as Map<String, dynamic>),
    );
  }
}

@freezed
class ChatRequestModel with _$ChatRequestModel {
  const factory ChatRequestModel({
    required String userId,
    required String name,
    required String image,
    required String socialImage,
    required bool imageBlur,
  }) = _ChatRequestModel;

  factory ChatRequestModel.fromJson(Map<String, dynamic> json) {
    return ChatRequestModel(
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      socialImage: json['socialImage']?.toString() ?? '',
      imageBlur: json['imageBlur'] ?? false,
    );
  }
}

@freezed
class RequestPagination with _$RequestPagination {
  const factory RequestPagination({
    required int totalCount,
    required int totalPages,
    required int currentPage,
    required int pageSize,
  }) = _RequestPagination;

  factory RequestPagination.fromJson(Map<String, dynamic> json) {
    return RequestPagination(
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
    );
  }
}
