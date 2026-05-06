import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';

abstract class LanguageRepository {
  /// يرسل اللغة المختارة للـ API حسب نوع المستخدم (user أو advisor)
  Future<Either<Failure, void>> setLanguage(String languageCode);
}

class LanguageRepositoryImpl implements LanguageRepository {
  final ApiService _apiService;

  LanguageRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, void>> setLanguage(String languageCode) async {
    try {
      // تحديد الـ endpoint حسب نوع المستخدم
      final endpoint = isAdvisor
          ? '/advisor/set-language'
          : '/user/set-language';

      final response = await _apiService.patch(
        endPoint: endpoint,
        data: {'language': languageCode},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message']?.toString() ?? 'فشل تحديث اللغة'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
