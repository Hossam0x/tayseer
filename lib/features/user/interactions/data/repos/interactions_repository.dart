import 'package:dartz/dartz.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/features/user/interactions/data/Model/history_response_model.dart';
import 'package:tayseer/features/user/interactions/data/Model/exploration_response_model.dart';


abstract class InteractionsRepository {
  // Exploration
  Future<Either<Failure, ExplorationResponseModel>> fetchExplorationUsers({
    required String category, // "من ضمن اختياراتك", etc.
    required int page,
  });

  // History
  Future<Either<Failure, HistoryResponseModel>> fetchHistoryUsers({
    required String filter, // "نال إعجابك", "المفضلة", etc.
    required int page,
  });

  // Actions
  Future<Either<Failure, String>> toggleFavorite({
    required String userId,
    required bool isAdd,
  });

    Future<Either<Failure, void>> sendCompliment({
    required String personId,
    String? text,
  });

  Future<Either<Failure, String>> likeUser({
    required String userId,
  });
  Future<Either<Failure, NotificationCountModel>> fetchInteractionNotificationCount();
Future<Either<Failure, void>> resetLikesNotificationCount();
Future<Either<Failure, void>> resetFavoritesNotificationCount();
Future<Either<Failure, void>> resetRegardsNotificationCount();
Future<Either<Failure, PastMatchesResponse>> fetchPastMatches({int page = 1});
}