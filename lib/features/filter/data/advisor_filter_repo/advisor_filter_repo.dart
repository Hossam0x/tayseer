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
    

    // TODO: استبدل الـ log بالـ API call لما الـ backend يجهز الـ endpoint
    // final response = await _client.post(
    //   Uri.parse('$_baseUrl/advisors/filter'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode(request.toJson()),
    // );

    return const Right(true);
  }
}