// lib/features/advisor_filter/data/repos/advisor_filter_repo.dart

import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../models/advisor_filter_request_model.dart';

// ─── Abstract ─────────────────────────────────────────────────────────────────

abstract class AdvisorFilterRepo {
  Future<Either<String, bool>> filterAdvisors(
    AdvisorFilterRequestModel request,
  );
}

// ─── Implementation ───────────────────────────────────────────────────────────

class AdvisorFilterRepoImpl implements AdvisorFilterRepo {
  @override
  Future<Either<String, bool>> filterAdvisors(
    AdvisorFilterRequestModel request,
  ) async {
    // ✅ طباعة البيانات في الـ log
    log('====== FILTER REQUEST ======', name: 'AdvisorFilter');
    log('min_price   : ${request.minPrice}', name: 'AdvisorFilter');
    log('max_price   : ${request.maxPrice}', name: 'AdvisorFilter');
    log('experience  : ${request.experience}', name: 'AdvisorFilter');
    log('rating      : ${request.rating}', name: 'AdvisorFilter');
    log('languages   : ${request.languages}', name: 'AdvisorFilter');
    log('badges      : ${request.badges}', name: 'AdvisorFilter');
    log('date        : ${request.date}', name: 'AdvisorFilter');
    log('page        : ${request.page}', name: 'AdvisorFilter');
    log('full JSON   : ${request.toJson()}', name: 'AdvisorFilter');
    log('============================', name: 'AdvisorFilter');

    // TODO: استبدل الـ log بالـ API call لما الـ backend يجهز الـ endpoint
    // final response = await _client.post(
    //   Uri.parse('$_baseUrl/advisors/filter'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(request.toJson()),
    // );

    return const Right(true);
  }
}