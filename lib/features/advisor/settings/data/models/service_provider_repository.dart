import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import 'service_provider_models.dart';

abstract class ServiceProviderRepository {
  Future<Either<Failure, ServiceProviderResponse>> getServiceProvider();
  Future<Either<Failure, ServiceProviderResponse>> updateServiceProvider({
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
        endPoint: '/advisor/getServiceProvider',
      );

      print('📌 Get Service Provider Response: $response');

      if (response['success'] == true) {
        // التحقق من وجود data وليست فارغة
        final data = response['data'];
        ServiceProviderRequest? serviceProvider;

        if (data != null && data is Map && data.isNotEmpty) {
          serviceProvider = ServiceProviderRequest.fromJson(
            data as Map<String, dynamic>,
          );
        }

        final serviceProviderResponse = ServiceProviderResponse(
          success: true,
          message:
              response['message']?.toString() ?? 'data_fetched_successfully',
          data: serviceProvider,
        );

        return Right(serviceProviderResponse);
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ??
                'failed_to_fetch_service_provider',
          ),
        );
      }
    } on DioException catch (e) {
      print('❌ Get Service Provider Error: ${e.message}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      print('❌ Get Service Provider Exception: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceProviderResponse>> updateServiceProvider({
    required ServiceProviderRequest request,
  }) async {
    try {
      print('📤 Update Service Provider Request: ${request.toJson()}');

      final response = await _apiService.patch(
        endPoint: '/advisor/updateServiceProvider',
        data: request.toJson(),
      );

      print('📥 Update Service Provider Response: $response');

      if (response['success'] == true) {
        // عند التحديث الناجح، نعيد نفس الـ request كـ data
        final serviceProviderResponse = ServiceProviderResponse(
          success: true,
          message:
              response['message']?.toString() ?? 'data_updated_successfully',
          data: request,
        );

        return Right(serviceProviderResponse);
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ??
                'failed_to_update_service_provider',
          ),
        );
      }
    } on DioException catch (e) {
      print('❌ Update Service Provider Error: ${e.message}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      print('❌ Update Service Provider Exception: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
