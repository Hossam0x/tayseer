import '../../my_import.dart';

abstract class Failure {
  final String message;

  Failure(this.message);
}

//كلاس للتعامل مع مشاكل السيرفر
class ServerFailure extends Failure {
  ServerFailure(super.message);

  factory ServerFailure.fromDioError(DioError error) {
    debugPrint('DioError: ${error.toString()}');
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure('Connection timeout with ApiServer');
      case DioExceptionType.sendTimeout:
        return ServerFailure('Send timeout with ApiServer');
      case DioExceptionType.receiveTimeout:
        return ServerFailure('Receive timeout with ApiServer');
      case DioExceptionType.badCertificate:
        return ServerFailure('Bad certificate with ApiServer');
      case DioExceptionType.cancel:
        return ServerFailure('Request to ApiServer was cancelled');
      case DioExceptionType.connectionError:
        return ServerFailure('تأكد من الاتصال بالانترنت');
      case DioExceptionType.unknown:
        if (error.response != null) {
          return ServerFailure.fromResponse(
            statusCode: error.response!.statusCode!,
            response: error.response!.data,
          );
        } else {
          return ServerFailure('Unknown server error');
        }
      default:
        return ServerFailure('Unexpected error occurred');
    }
  }

  factory ServerFailure.fromResponse({
    required int statusCode,
    required dynamic response,
  }) {
    if (statusCode == 404) {
      return ServerFailure('الطلب غير موجود، يرجى المحاولة لاحقًا');
    } else if (statusCode == 500) {
      return ServerFailure('هناك مشكلة في الخادم، يرجى المحاولة لاحقًا');
    } else if (statusCode == 400 ||
        statusCode == 401 ||
        statusCode == 403 ||
        statusCode == 422) {
      return ServerFailure(response["message"]);
    } else {
      return ServerFailure('عذرًا، حدث خطأ ما. يرجى المحاولة لاحقًا');
    }
  }
}

//كلاس للتعامل مع مشاكل الكاش
//class CacheFailure extends Failure {}
