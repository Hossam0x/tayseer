import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';

abstract class ContactRepository {
  Future<Either<Failure, void>> sendContactMessage(String message);
}

class ContactRepositoryImpl implements ContactRepository {
  final ApiService _apiService;

  ContactRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, void>> sendContactMessage(String message) async {
    try {
      final response = await _apiService.post(
        endPoint: '/contact',
        data: {'message': message},
      );

      if (response['status'] == 'success' || response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message']?.toString() ?? 'فشل إرسال الرسالة'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
