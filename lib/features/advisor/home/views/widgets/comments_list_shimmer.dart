import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart'; // تأكد من إضافة مكتبة shimmer في pubspec.yaml

class CommentsShimmerList extends StatelessWidget {
  const CommentsShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const _CommentShimmerItem(),
        childCount: 6, // عدد العناصر الوهمية
      ),
    );
  }
}

class _CommentShimmerItem extends StatelessWidget {
  const _CommentShimmerItem();

  @override
  Widget build(BuildContext context) {
    // الألوان المستخدمة في الشيمر
    final baseColor = Colors.grey.shade300;
    final highlightColor = Colors.grey.shade100;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Shimmer
            Container(
              width: 40.r,
              height: 40.r,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            Gap(10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Shimmer
                  Container(
                    width: 120.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(8.h),
                  // Content Line 1
                  Container(
                    width: double.infinity,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(6.h),
                  // Content Line 2 (Shorter)
                  Container(
                    width: 150.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
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