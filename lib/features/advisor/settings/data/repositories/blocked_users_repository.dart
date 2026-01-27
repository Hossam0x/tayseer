import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../models/blocked_user_model.dart';

abstract class BlockedUsersRepository {
  Future<Either<Failure, List<BlockedUserModel>>> getBlockedUsers();
  Future<Either<Failure, void>> blockUser(String blockedId);
  Future<Either<Failure, void>> unblockUser(String blockedId);
}

class BlockedUsersRepositoryImpl implements BlockedUsersRepository {
  final ApiService _apiService;

  BlockedUsersRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, List<BlockedUserModel>>> getBlockedUsers() async {
    try {
      final response = await _apiService.get(endPoint: '/blocks/my-blocked');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        final blockedUsers = data
            .map((item) => BlockedUserModel.fromJson(item))
            .toList();
        return Right(blockedUsers);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل جلب قائمة المحظورين'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> blockUser(String blockedId) async {
    try {
      final response = await _apiService.post(
        endPoint: '/blocks/block',
        data: {'blockedId': blockedId},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل حظر المستخدم'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unblockUser(String blockedId) async {
    try {
      final response = await _apiService.delete(
        endPoint: '/blocks/unblock',
        data: {'blockedId': blockedId},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل إلغاء حظر المستخدم'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
