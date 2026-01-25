import 'package:dartz/dartz.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/features/user/interactions/data/Model/HistoryResponseModel.dart';
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

  Future<Either<Failure, String>> sendCompliment({
    required String userId,
  });

  Future<Either<Failure, String>> likeUser({
    required String userId,
  });
}