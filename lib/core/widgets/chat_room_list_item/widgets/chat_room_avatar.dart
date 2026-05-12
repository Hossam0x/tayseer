import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/colors.dart';

/// صورة المستخدم مع overlay الحظر
class ChatRoomAvatar extends StatelessWidget {
  final String? imageUrl;
  final bool isBlocked;
  final String fallbackAsset;

  const ChatRoomAvatar({
    super.key,
    this.imageUrl,
    this.isBlocked = false,
    required this.fallbackAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary100,
            border: Border.all(color: AppColors.secondary200, width: 1),
          ),
          child: ClipOval(child: _buildImage()),
        ),
        if (isBlocked)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
              ),
              child: const Center(
                child: Icon(Icons.block, color: Colors.white, size: 20),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        memCacheWidth: 112, // 56 * 2x pixel ratio
        memCacheHeight: 112,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (_, __) =>
            Container(width: 56, height: 56, color: AppColors.secondary200),
        errorWidget: (_, __, ___) =>
            Image.asset(fallbackAsset, fit: BoxFit.cover),
      );
    }
    return Image.asset(fallbackAsset, fit: BoxFit.cover);
  }
}
