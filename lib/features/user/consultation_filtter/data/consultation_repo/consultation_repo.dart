// lib/features/user/consultation/data/repos/consultation_repo.dart

import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/my_import.dart';
import '../models/advisor_model.dart';
import 'package:tayseer/features/filter/data/models/advisor_filter_request_model.dart';

abstract class ConsultationFiltterRepo {
  Future<Either<String, PaginatedAdvisorsModel>> getFilteredAdvisors(
    AdvisorFilterRequestModel request,
  );
}

class ConsultationFiltterRepoImpl implements ConsultationFiltterRepo {
  final ApiService _apiService;

  ConsultationFiltterRepoImpl()
      : _apiService = getIt<ApiService>();

  @override
  Future<Either<String, PaginatedAdvisorsModel>> getFilteredAdvisors(
    AdvisorFilterRequestModel request,
  ) async {
    try {
      log('====== FILTER REQUEST ======', name: 'Consultation');
      log('${request.toQueryParams()}', name: 'Consultation');

      // ✅ GET request مع query params
      final response = await _apiService.get(
        endPoint: '/advisor/available',
        query: request.toQueryParams(),
      );

      if (response['success'] == true) {
        return Right(PaginatedAdvisorsModel.fromJson(response));
      } else {
        return Left(response['message'] as String? ?? 'حدث خطأ ما');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}