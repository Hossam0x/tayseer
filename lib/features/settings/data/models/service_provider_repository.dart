import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../models/service_provider_models.dart';

abstract class ServiceProviderRepository {
  Future<Either<Failure, ServiceProviderResponse>> getServiceProvider();
  Future<Either<Failure, ServiceProviderResponse>> updateServiceProvider({
    required ServiceProviderRequest request,
  });
  Future<Either<Failure, ServiceProviderResponse>> createServiceProvider({
    required ServiceProviderRequest request,
  });
}

class ServiceProviderRepositoryImpl implements ServiceProviderRepository {
  final ApiService _apiService;

  ServiceProviderRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, ServiceProviderResponse>> getServiceProvider() async {
    try {
      final response = await _apiService.get(
        endPoint: '/advisor/addServiceProvider',
      );

      if (response['success'] == true) {
        final serviceProvider = ServiceProviderResponse.fromJson(response);
        return Right(serviceProvider);
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ?? 'فشل جلب بيانات مقدم الخدمة',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceProviderResponse>> updateServiceProvider({
    required ServiceProviderRequest request,
  }) async {
    try {
      final response = await _apiService.patch(
        endPoint: '/advisor/addServiceProvider',
        data: request.toJson(),
      );

      if (response['success'] == true) {
        final serviceProvider = ServiceProviderResponse.fromJson(response);
        return Right(serviceProvider);
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ?? 'فشل تحديث بيانات مقدم الخدمة',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceProviderResponse>> createServiceProvider({
    required ServiceProviderRequest request,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: '/advisor/addServiceProvider',
        data: request.toJson(),
      );

      if (response['success'] == true) {
        final serviceProvider = ServiceProviderResponse.fromJson(response);
        return Right(serviceProvider);
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ?? 'فشل إنشاء بيانات مقدم الخدمة',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
