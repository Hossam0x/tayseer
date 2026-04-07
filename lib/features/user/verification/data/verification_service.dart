// ===============================
// verification_service.dart
// ===============================

import 'package:flutter/material.dart';
import 'package:tayseer/features/user/verification/data/models/Verification_result_model.dart';
import 'package:tayseer/my_import.dart';

class VerificationService {
  // ─────────────────────────────────────────────
  // Get WebView URL from backend
  // ─────────────────────────────────────────────
  static Future<String?> getVerificationUrl() async {
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.get(endPoint: '/user/verify-id-didit');

      if (response['success'] == true) {
        return response['data']['webview'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('❌ getVerificationUrl Error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Get current verification status from backend
  // ─────────────────────────────────────────────
  static Future<VerificationResult?> getUserVerificationStatus() async {
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.get(
        endPoint: '/user/get-user-verification-status',
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        return VerificationResult(
          isVerified: data['isVerified'] as bool? ?? false,
          rejectReasons: List<String>.from(data['rejectReasons'] ?? []),
        );
      }
      return null;
    } catch (e) {
      debugPrint('❌ getUserVerificationStatus Error: $e');
      return null;
    }
  }
}