import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';
import 'package:tayseer/my_import.dart';

abstract class MarriageRepository {
  Future<Either<Failure, UsersMarriageResponse>> getMarriageProfile(
    String? page, {
    Map<String, dynamic>? filters, // ✅
  });
  Future<Either<Failure, void>> userInteraction({
    required String personId,
    required String interactionType,
  });
  Future<Either<Failure, void>> sendRegard({
    required String personId,
    String? text,
  });
   Future<Either<Failure, String>> blockUser({required String personId});

  Future<Either<Failure, void>> toggleFavorite({
  required String userId,
  required bool isAdd,
});
Future<Either<Failure, List<String>>> getFavoriteIds();
}
