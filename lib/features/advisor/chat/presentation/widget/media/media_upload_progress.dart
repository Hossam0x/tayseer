import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/app_strings.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';

/// Media Upload Progress Indicator
///
/// Shows upload progress on images/videos while they're being uploaded
class MediaUploadProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final VoidCallback? onCancel;

  const MediaUploadProgress({super.key, required this.progress, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular progress indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Upload text
          Text(
            context.tr(AppStrings.uploading),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          // Cancel button (optional)
          if (onCancel != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onCancel,
              child: Text(
                context.tr(AppStrings.cancel),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
