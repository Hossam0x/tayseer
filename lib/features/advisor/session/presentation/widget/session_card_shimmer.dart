import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tayseer/my_import.dart'; // للـ Styles و AppColors

class SessionCardShimmer extends StatelessWidget {
  const SessionCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Row(
              children: [
                // دائرة الصورة
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: context.width * 0.03),
                // الاسم واليوزر
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: context.width * 0.3,
                      height: 16,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: context.width * 0.2,
                      height: 14,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                const Spacer(),
                // زر وهمي
                Container(
                  width: context.width * 0.25,
                  height: context.height * 0.05,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.height * 0.02),
            // التاريخ والوقت
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // التاريخ
                  Container(
                    width: context.width * 0.3,
                    height: 14,
                    color: Colors.grey.shade400,
                  ),
                  // الفاصل
                  Container(width: 1, height: 20, color: Colors.grey.shade400),
                  // الوقت
                  Container(
                    width: context.width * 0.2,
                    height: 14,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
