import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/colors.dart';

/// صورة المستخدم مع overlay الحظر
class ChatRoomAvatar extends StatelessWidget {
  final String? imageUrl;
  final bool isImageBlurred;
  final bool isBlocked;
  final String fallbackAsset;
  final bool showOnlineDot;
  final bool isOnline;

  const ChatRoomAvatar({
    super.key,
    this.imageUrl,
    this.isImageBlurred = false,
    this.isBlocked = false,
    required this.fallbackAsset,
    this.showOnlineDot = false,
    this.isOnline = false,
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
        if (!isBlocked && showOnlineDot)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isOnline ? const Color(0xFF4CD964) : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
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
    final image = imageUrl != null && imageUrl!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            memCacheWidth: 80, // 56 * 2x pixel ratio
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            placeholder: (_, __) =>
                Container(width: 56, height: 56, color: AppColors.secondary200),
            errorWidget: (_, __, ___) =>
                Image.asset(fallbackAsset, fit: BoxFit.cover),
          )
        : Image.asset(fallbackAsset, fit: BoxFit.cover);

    if (!isImageBlurred) return image;

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: image,
    );
  }
}
