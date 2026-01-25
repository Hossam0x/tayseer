import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MessageShimmer extends StatelessWidget {
  const MessageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: 12,
      physics:
          const NeverScrollableScrollPhysics(), // تعطيل السكرول أثناء التحميل
      itemBuilder: (context, index) {
        // منطق عشوائي لتحديد المرسل والمستقبل لتنويع الشكل
        final bool isMe = index % 2 == 0;

        // عرض عشوائي للفقاعة لتبدو واقعية (بين 30% و 70% من الشاشة)
        final double bubbleWidth =
            screenWidth * (0.3 + (Random().nextDouble() * 0.4));

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Align(
            alignment: isMe
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Shimmer.fromColors(
              baseColor: isMe
                  ? Colors.grey.shade200
                  : const Color(0xFFE96E88).withOpacity(0.1),
              highlightColor: isMe
                  ? Colors.grey.shade50
                  : const Color(0xFFE96E88).withOpacity(0.05),
              child: Container(
                width: bubbleWidth,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // سطر طويل
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // سطر قصير عشوائي
                    if (index % 3 != 0) // بعض الفقاعات سيكون فيها سطرين فقط
                      Container(
                        height: 10,
                        width: bubbleWidth * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
