import 'package:tayseer/core/models/pagination_model.dart';
import 'package:tayseer/features/user/interactions/data/Model/InteractionUserModel%20.dart';

class ExplorationResponseModel {
  final bool success;
  final String message;
  final List<InteractionUserModel> users;
  final PaginationModel? pagination;

  ExplorationResponseModel({
    required this.success,
    required this.message,
    required this.users,
    this.pagination,
  });

  factory ExplorationResponseModel.fromJson(Map<String, dynamic> json) {
    return ExplorationResponseModel(
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