import 'package:tayseer/core/models/pagination_model.dart';
import 'package:tayseer/features/user/interactions/data/Model/InteractionUserModel%20.dart';

class HistoryResponseModel {
  final bool success;
  final String message;
  final List<InteractionUserModel> users;
  final PaginationModel? pagination;

  HistoryResponseModel({
    required this.success,
    required this.message,
    required this.users,
    this.pagination,
  });

  factory HistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return HistoryResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      users: (json['data']?['users'] as List<dynamic>?)
              ?.map((e) => InteractionUserModel.fromJson(e))
              .toList() ??
          [],
      pagination: json['data']?['pagination'] != null
          ? PaginationModel.fromJson(json['data']['pagination'])
          : null,
    );
  }
}