import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';
import 'package:tayseer/features/user/marriage/repositories/marriage_repository.dart';
import 'package:tayseer/my_import.dart';

class MarriageRepositoryImpl implements MarriageRepository {
  final ApiService _apiService;

  MarriageRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, UsersMarriageResponse>> getMarriageProfile(
    String? page, {
    Map<String, dynamic>? filters, // ✅
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        if (filters != null && filters.isNotEmpty) ...filters, // ✅
      };

      final response = await _apiService.get(
        endPoint: '/user/users-for-marry',
        query: query,
      );

      if (response['success'] == true) {
        return Right(UsersMarriageResponse.fromJson(response));
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب الملف'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> userInteraction({
    required String personId,
    required String interactionType,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: '/user/user-interaction',
        data: {
          'personInteractedWith': personId,
          'interactionType': interactionType,
        },
      );

      if (response['success'] == true) {
        return Right(null);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل التفاعل مع المستخدم'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendRegard({
    required String personId,
    String? text,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: '/user/send-regards',
        data: {
          'personInteractedWith': personId,
          if (text != null) 'text': text,
        },
      );

      if (response['success'] == true) {
        return Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل ارسال التحيه'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
