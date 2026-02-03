import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/features/user/interactions/data/Model/history_response_model.dart';
import 'package:tayseer/features/user/interactions/data/Model/exploration_response_model.dart';
import 'package:tayseer/features/user/interactions/data/repos/interactions_repository.dart';

import '../Model/Iinteraction_usermodel .dart';


class InteractionsRepositoryImpl implements InteractionsRepository {
  final ApiService apiService;

  InteractionsRepositoryImpl(this.apiService);

  // ═══════════════════════════════════════════════════════════════════
  // EXPLORATION
  // ═══════════════════════════════════════════════════════════════════

  @override
  Future<Either<Failure, ExplorationResponseModel>> fetchExplorationUsers({
    required String category,
    required int page,
  }) async {
    try {
      // TODO: Replace with actual API call when backend is ready
      // final response = await apiService.get(
      //   endPoint: '/interactions/exploration',
      //   query: {
      //     'category': category,
      //     'page': page,
      //   },
      // );

      // ✅ Mock Data Response
      await Future.delayed(const Duration(milliseconds: 800));
      
      final mockResponse = _getMockExplorationResponse(category);
      return Right(mockResponse);

    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // HISTORY
  // ═══════════════════════════════════════════════════════════════════
// Add this constant at the top of the class
static const int _pageSize = 6;

@override
Future<Either<Failure, HistoryResponseModel>> fetchHistoryUsers({
  required String filter,
  required int page,
}) async {
  try {
    // ✅ Real API Call with type parameter
    final response = await apiService.get(
      endPoint: '/user/user-interactions',
      query: {
        'page': page.toString(),
        'limit': _pageSize.toString(),
        'type': _mapFilterToApiType(filter),
      },
    );

    final historyResponse = HistoryResponseModel.fromJson(response);
    return Right(historyResponse);

  } on DioException catch (e) {
    return Left(ServerFailure.fromDioError(e));
  } catch (e) {
    return Left(ServerFailure('حدث خطأ غير متوقع: ${e.toString()}'));
  }
}

// Helper method to map filter names to API types
String _mapFilterToApiType(String filter) {
  switch (filter) {
    case 'المفضلة':
      return 'favorites';
    case 'نال إعجابك':
      return 'likes';
    case 'صادفتهم':
      return 'encountered';
    case 'أرسلت مجاملة':
      return 'regards';
    case 'اُعجب بك':
      return 'likedMe';  // ✅ Fixed to match API
    default:
      return 'likes';
  }
}

  // ═══════════════════════════════════════════════════════════════════
  // ACTIONS - ✅ FIXED BASED ON POSTMAN SCREENSHOTS
  // ═══════════════════════════════════════════════════════════════════
@override
Future<Either<Failure, String>> toggleFavorite({
  required String userId,
  required bool isAdd,
}) async {
  try {
    if (isAdd) {
      // ✅ حالة الإضافة: بدون action parameter خالص
      // بناءً على صورة Postman الثالثة (201 Created)
      final Map<String, dynamic> bodyData = {
        'personInteractedWith': userId,
        'interactionType': 'favorite',
        // ⚠️ لاحظ: مفيش action هنا خالص
      };

      final response = await apiService.post(
        endPoint: '/user/user-interaction',
        data: bodyData,
      );

      final message = response['message'] ?? 'تمت الإضافة للمفضلة بنجاح';
      return Right(message);
      
    } else {
      // ✅ حالة الحذف: استخدام POST مع ?action=remove في الـ URL
      // بناءً على صورة Postman الأولى اللي بتستخدم query parameter
      final response = await apiService.post(
        endPoint: '/user/user-interaction?action=remove',  // ✅ في الـ URL نفسه
        data: {
          'personInteractedWith': userId,
          'interactionType': 'favorite',
          // ⚠️ بدون action في الـ body
        },
      );

      final message = response['message'] ?? 'تمت الإزالة من المفضلة بنجاح';
      return Right(message);
    }

  } on DioException catch (e) {
    return Left(ServerFailure.fromDioError(e));
  } catch (e) {
    return Left(ServerFailure('حدث خطأ: ${e.toString()}'));
  }
}

  @override
  Future<Either<Failure, String>> sendCompliment({
    required String userId,
  }) async {
    try {
      // TODO: Replace with actual API call when backend is ready
      // final response = await apiService.post(
      //   endPoint: '/interactions/compliment',
      //   data: {"userId": userId},
      // );

      // ✅ Mock Response
      await Future.delayed(const Duration(milliseconds: 700));
      return const Right('تم إرسال المجاملة بنجاح');

    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> likeUser({
    required String userId,
  }) async {
    try {
      // TODO: Replace with actual API call when backend is ready
      // final response = await apiService.post(
      //   endPoint: '/interactions/like',
      //   data: {"userId": userId},
      // );

      // ✅ Mock Response
      await Future.delayed(const Duration(milliseconds: 600));
      return const Right('تم الإعجاب بنجاح');

    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ: ${e.toString()}'));
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // MOCK DATA HELPERS (Same as before)
  // ═══════════════════════════════════════════════════════════════════

  ExplorationResponseModel _getMockExplorationResponse(String category) {
    final mockData = _getMockExplorationData();
    
    return ExplorationResponseModel(
      success: true,
      message: 'تم جلب البيانات بنجاح',
      users: mockData[category] ?? [],
      pagination: null,
    );
  }

  Map<String, List<InteractionUserModel>> _getMockExplorationData() {
    return {
      "من ضمن اختياراتك": [
        const InteractionUserModel(
          userId: '1',
          name: 'أحمد منصور',
          age: 24,
          country: 'مصر',
          day: 'اليوم',
          job: 'مهندس',
          image: AssetsData.kUserImage,
          likedMe: true,
          isverified: true,
        
        ),
        const InteractionUserModel(
          userId: '2',
          name: 'محمد علي',
          age: 27,
          country: 'مصر',
          day: 'اليوم',
          job: 'دكتور',
          image: AssetsData.kUserImage,
          likedMe: true,
          isverified: true,

        ),
        const InteractionUserModel(
          userId: '3',
          name: 'خالد أحمد',
          age: 26,
          country: 'مصر',
          day: 'امس',
          job: 'محامي',
          image: AssetsData.kUserImage,
          likedMe: true,
        ),
        const InteractionUserModel(
          userId: '4',
          name: 'عمر حسن',
          age: 25,
          country: 'مصر',
          day: 'اليوم',
          job: 'مبرمج',
          image: AssetsData.kUserImage,
          likedMe: true,
        ),
        const InteractionUserModel(
          userId: '5',
          name: 'يوسف سعيد',
          age: 28,
          country: 'مصر',
          day: 'اليوم',
          job: 'معلم',
          image: AssetsData.kUserImage,
          likedMe: true,
        ),
      ],
      
      "من خارج اختياراتك": [
        const InteractionUserModel(
          userId: '6',
          name: 'سامي كمال',
          age: 30,
          country: 'مصر',
          day: 'اليوم',
          job: 'صيدلي',
          image: AssetsData.kUserImage,
          likedMe: true,
        ),
        const InteractionUserModel(
          userId: '7',
          name: 'طارق فهمي',
          age: 29,
          country: 'مصر',
          day: 'امس',
          job: 'طبيب',
          image: AssetsData.kUserImage,
          likedMe: true,
        ),
      ],
      
      "يرغبون في التفاعل معك": [
        const InteractionUserModel(
          userId: '8',
          name: 'ياسر نبيل',
          age: 26,
          country: 'مصر',
          day: 'اليوم',
          job: 'مهندس',
          image: AssetsData.kUserImage,
          likedMe: false,
          isverified: true,

        ),
      ],
      
      "الزيارات المحفزة": [
        const InteractionUserModel(
          userId: '9',
          name: 'رامي صلاح',
          age: 27,
          country: 'مصر',
          day: 'اليوم',
          job: 'مصمم',
          image: AssetsData.kUserImage,
          likedMe: false,
        ),
        const InteractionUserModel(
          userId: '10',
          name: 'حسام الدين',
          age: 25,
          country: 'مصر',
          day: 'امس',
          job: 'محاسب',
          image: AssetsData.kUserImage,
          likedMe: false,
        ),
        const InteractionUserModel(
          userId: '11',
          name: 'وليد محمود',
          age: 28,
          country: 'مصر',
          day: 'اليوم',
          job: 'مدرس',
          image: AssetsData.kUserImage,
          likedMe: false,
        ),
      ],
      
      "منضم حديثاً": [
        const InteractionUserModel(
          userId: '12',
          name: 'إبراهيم فتحي',
          age: 24,
          country: 'مصر',
          day: 'اليوم',
          job: 'مهندس',
          image: AssetsData.kUserImage,
          likedMe: false,
          isRecentlyJoined: true,
          isverified: true,

        ),
        const InteractionUserModel(
          userId: '13',
          name: 'مصطفى عادل',
          age: 26,
          country: 'مصر',
          day: 'اليوم',
          job: 'طبيب',
          image: AssetsData.kUserImage,
          likedMe: false,
          isRecentlyJoined: true,
        ),
        const InteractionUserModel(
          userId: '14',
          name: 'كريم وليد',
          age: 25,
          country: 'مصر',
          day: 'اليوم',
          job: 'صيدلي',
          image: AssetsData.kUserImage,
          likedMe: false,
          isRecentlyJoined: true,
          isImageBlurred: true,
        ),
        const InteractionUserModel(
          userId: '15',
          name: 'إبراهيم فتحي',
          age: 24,
          country: 'مصر',
          day: 'اليوم',
          job: 'مهندس',
          image: AssetsData.kUserImage,
          likedMe: false,
          isRecentlyJoined: true,
        ),
      ],
      
      "ارسل تحية": [
        const InteractionUserModel(
          userId: '16',
          name: 'هشام جمال',
          age: 27,
          country: 'مصر',
          day: 'اليوم',
          job: 'محامي',
          image: AssetsData.kUserImage,
          likedMe: true,
          isverified: true,

        ),
        const InteractionUserModel(
          userId: '17',
          name: 'معتز أحمد',
          age: 29,
          country: 'مصر',
          day: 'امس',
          job: 'مهندس',
          image: AssetsData.kUserImage,
          likedMe: true,
        ),
      ],
    };
  }

  Map<String, List<InteractionUserModel>> _getMockHistoryData() {
    return {
      "المفضلة": [
        const InteractionUserModel(
          userId: '101',
          name: 'أحمد منصور',
          age: 24,
          country: 'مصر',
          day: 'اليوم',
          job: 'مهندس',
          image: AssetsData.kUserImage,
          isFavorite: true,
          isImageBlurred: false,
          likedHim: false,
          isverified: true
        ),
        const InteractionUserModel(
          userId: '102',
          name: 'محمد علي',
          age: 26,
          country: 'مصر',
          day: 'امس',
          job: 'دكتور',
          image: AssetsData.kUserImage,
          isFavorite: true,
          isImageBlurred: false,
          likedHim: false,
          isverified: true

        ),
        const InteractionUserModel(
          userId: '103',
          name: 'خالد حسن',
          age: 25,
          country: 'مصر',
          day: 'اليوم',
          job: 'محامي',
          image: AssetsData.kUserImage,
          isFavorite: true,
          isImageBlurred: true,
          likedHim: false,
        ),
                const InteractionUserModel(
          userId: '104',
          name: 'أحمد منصور',
          age: 24,
          country: 'مصر',
          day: 'اليوم',
          job: 'مهندس',
          image: AssetsData.kUserImage,
          isFavorite: true,
          isImageBlurred: false,
          likedHim: false,
          isverified: true

        ),
                const InteractionUserModel(
          userId: '105',
          name: 'أحمد منصور',
          age: 24,
          country: 'مصر',
          day: 'اليوم',
          job: 'مهندس',
          image: AssetsData.kUserImage,
          isFavorite: true,
          isImageBlurred: false,
          likedHim: false,
          isverified: true

        ),
                const InteractionUserModel(
          userId: '106',
          name: 'أحمد منصور',
          age: 24,
          country: 'مصر',
          day: 'اليوم',
          job: 'مهندس',
          image: AssetsData.kUserImage,
          isFavorite: true,
          isImageBlurred: false,
          likedHim: false,
        ),
                const InteractionUserModel(
          userId: '107',
          name: 'أحمد منصور',
          age: 24,
          country: 'مصر',
          day: 'اليوم',
          job: 'مهندس',
          image: AssetsData.kUserImage,
          isFavorite: true,
          isImageBlurred: false,
          likedHim: false,
        ),
      ],
      
      "نال إعجابك": [
        const InteractionUserModel(
          userId: '201',
          name: 'عمر سعيد',
          age: 27,
          country: 'مصر',
          day: 'اليوم',
          job: 'مهندس',
          image: AssetsData.kUserImage,
          isFavorite: false,
          isImageBlurred: false,
          likedHim: true,
        ),
        const InteractionUserModel(
          userId: '202',
          name: 'يوسف أحمد',
          age: 28,
          country: 'مصر',
          day: 'اليوم',
          job: 'طبيب',
          image: AssetsData.kUserImage,
          isFavorite: false,
          isImageBlurred: false,
          likedHim: true,
        ),
        const InteractionUserModel(
          userId: '203',
          name: 'سامي كمال',
          age: 25,
          country: 'مصر',
          day: 'امس',
          job: 'صيدلي',
          image: AssetsData.kUserImage,
          isFavorite: false,
          isImageBlurred: true,
          likedHim: true,
        ),
      ],
      
      "صادفتهم": [
        const InteractionUserModel(
          userId: '301',
          name: 'طارق فهمي',
          age: 26,
          country: 'مصر',
          day: 'امس',
          job: 'مهندس',
          image: AssetsData.kUserImage,
          isFavorite: false,
          isImageBlurred: false,
          likedHim: false,
        ),
      ],
      
      "أرسلت مجاملة": [
        const InteractionUserModel(
          userId: '401',
          name: 'رامي صلاح',
          age: 24,
          country: 'مصر',
          day: 'اليوم',
          job: 'مبرمج',
          image: AssetsData.kUserImage,
          isFavorite: false,
          isImageBlurred: false,
          likedHim: false,
          sentCompliment: true,
        ),
        const InteractionUserModel(
          userId: '402',
          name: 'حسام الدين',
          age: 27,
          country: 'مصر',
          day: 'اليوم',
          job: 'مصمم',
          image: AssetsData.kUserImage,
          isFavorite: false,
          isImageBlurred: false,
          likedHim: false,
          sentCompliment: true,
        ),
      ],
    };
  }
}