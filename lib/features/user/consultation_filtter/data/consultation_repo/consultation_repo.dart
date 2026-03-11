// lib/features/user/consultation/data/repos/consultation_repo.dart

import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../models/advisor_model.dart';
import 'package:tayseer/features/filter/data/models/advisor_filter_request_model.dart';

abstract class ConsultationFiltterRepo {
  Future<Either<String, PaginatedAdvisorsModel>> getFilteredAdvisors(
    AdvisorFilterRequestModel request,
  );
}

class ConsultationFiltterRepoImpl implements ConsultationFiltterRepo {
  final http.Client _client;
  final String _baseUrl;

  ConsultationFiltterRepoImpl({
    http.Client? client,
    String baseUrl = 'https://your-api.com/api/v1', // TODO: replace
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl;

  @override
  Future<Either<String, PaginatedAdvisorsModel>> getFilteredAdvisors(
    AdvisorFilterRequestModel request,
  ) async {
    try {
      // ✅ Log للتطوير — هتشيله لما الـ API يجهز
      log('====== FILTER REQUEST ======', name: 'Consultation');
      log('${request.toJson()}', name: 'Consultation');

      final uri = Uri.parse('$_baseUrl/advisors/filter');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return Right(PaginatedAdvisorsModel.fromJson(decoded));
      } else {
        final decoded = jsonDecode(response.body);
        final message =
            decoded['message'] as String? ?? 'Error ${response.statusCode}';
        return Left(message);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}