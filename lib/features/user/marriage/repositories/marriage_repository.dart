import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/interactions/data/Model/history_response_model.dart';
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
<<<<<<< HEAD
    required String userId,
    required bool isAdd,
  });
  Future<Either<Failure, List<String>>> getFavoriteIds();
  Future<Either<Failure, UserItem>> getProfileById(String userId);
  Future<Either<Failure, int>> getInteractionNotificationCount();
  Future<Either<Failure, void>> setUserLocation({
    required double lat,
    required double lng,
  });
=======
  required String userId,
  required bool isAdd,
});
Future<Either<Failure, List<String>>> getFavoriteIds();
Future<Either<Failure, UserItem>> getProfileById(String userId);

Future<Either<Failure, void>> resetAllNotificationCounts();
Future<Either<Failure, NotificationCountModel>> getInteractionNotificationCount();
 Future<Either<Failure, void>> resetLikesNotificationCount();
 Future<Either<Failure, void>> resetFavoritesNotificationCount();
Future<Either<Failure, void>> resetRegardsNotificationCount();
>>>>>>> c8a365470b0148595ce23c2a1d4e5324f5ab7164
}
