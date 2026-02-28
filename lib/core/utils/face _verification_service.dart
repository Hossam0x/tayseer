import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:image/image.dart' as img;

class FaceVerificationService {
  static final FaceVerificationService _instance =
      FaceVerificationService._internal();

  factory FaceVerificationService() => _instance;
  FaceVerificationService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (!_isInitialized) {
      await FaceSDK.instance.initialize();
      _isInitialized = true;
    }
  }

  /// ✅ تعديل الصورة من الكاميرا الأمامية (فك المرآة)
  Uint8List _fixMirroredImage(Uint8List imageBytes) {
    try {
      final original = img.decodeImage(imageBytes);
      if (original == null) return imageBytes;

      // ✅ عكس الصورة أفقياً (لأن الكاميرا الأمامية بتكون معكوسة)
      final flipped = img.flipHorizontal(original);

      return Uint8List.fromList(img.encodeJpg(flipped, quality: 90));
    } catch (e) {
      debugPrint('Error fixing mirrored image: $e');
      return imageBytes;
    }
  }

  Future<VerificationResult> matchFaces({
    required Uint8List liveImageBytes,
    required File uploadedImage,
    bool isFromFrontCamera = true,
  }) async {
    await initialize();

    // ✅ لو الصورة من الكاميرا الأمامية، نعكسها
    final Uint8List processedLiveImage = isFromFrontCamera
        ? _fixMirroredImage(liveImageBytes)
        : liveImageBytes;

    final uploadedBytes = uploadedImage.readAsBytesSync();

    debugPrint('📸 Live image size: ${processedLiveImage.length} bytes');
    debugPrint('📸 Uploaded image size: ${uploadedBytes.length} bytes');

    // ✅ استخدام ImageType.LIVE للصورتين
    final request = MatchFacesRequest([
      MatchFacesImage(processedLiveImage, ImageType.LIVE),
      MatchFacesImage(uploadedBytes, ImageType.PRINTED),
    ]);

    final response = await FaceSDK.instance.matchFaces(request);

    debugPrint('📊 Match results count: ${response.results.length}');

    // ✅ لو مفيش نتائج خالص = مقدرش يكتشف وجه
    if (response.results.isEmpty) {
      debugPrint('❌ No face detected in one or both images');
      return VerificationResult(
        success: false,
        errorKey: 'no_face_detected',
        similarity: 0.0,
      );
    }

    // ✅ طباعة كل النتائج للتشخيص
    for (var result in response.results) {
      debugPrint('📊 Similarity: ${result.similarity}');
    }

    final split = await FaceSDK.instance.splitComparedFaces(
      response.results,
      0.75,
    );

    debugPrint('✅ Matched faces: ${split.matchedFaces.length}');
    debugPrint('❌ Unmatched faces: ${split.unmatchedFaces.length}');

    if (split.matchedFaces.isNotEmpty) {
      final similarity = split.matchedFaces.first.similarity;
      debugPrint('✅ MATCHED! Similarity: $similarity');
      return VerificationResult(
        success: true,
        errorKey: null,
        similarity: similarity,
      );
    }

    final unmatchedSimilarity = split.unmatchedFaces.isNotEmpty
        ? split.unmatchedFaces.first.similarity
        : 0.0;

    debugPrint('❌ NOT MATCHED! Similarity: $unmatchedSimilarity');

    return VerificationResult(
      success: false,
      errorKey: 'face_not_matched',
      similarity: unmatchedSimilarity,
    );
  }
}

class VerificationResult {
  final bool success;
  final String? errorKey;
  final double similarity;

  VerificationResult({
    required this.success,
    required this.errorKey,
    required this.similarity,
  });
}
