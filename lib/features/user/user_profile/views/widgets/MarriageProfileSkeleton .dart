// lib/features/user/user_profile/views/widgets/marriage_profile_skeleton.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tayseer/my_import.dart';

class MarriageProfileSkeleton extends StatelessWidget {
  const MarriageProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.0.w),
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          // ════════════════════════════════════════════════════════
          // ⭐ Header Image Skeleton
          // ════════════════════════════════════════════════════════
          SliverToBoxAdapter(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Main Image Skeleton
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 650.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(33.r),
                      ),
                    ),
                  ),
                ),

                // Completion Card Skeleton
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 24.h),
                  child: Shimmer.fromColors(
                    baseColor: Colors.white.withOpacity(0.9),
                    highlightColor: Colors.white.withOpacity(0.7),
                    child: Container(
                      height: 200.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ════════════════════════════════════════════════════════
          // ⭐ About Me Section Skeleton
          // ════════════════════════════════════════════════════════
          _buildSliverPadding(
            child: _buildSectionCardSkeleton(
              height: 150.h,
              itemsCount: 4,
            ),
          ),

          // ════════════════════════════════════════════════════════
          // ⭐ Education Section Skeleton
          // ════════════════════════════════════════════════════════
          _buildSliverPadding(
            child: _buildSectionCardSkeleton(
              height: 120.h,
              itemsCount: 2,
            ),
          ),

          // ════════════════════════════════════════════════════════
          // ⭐ Goals Timeline Skeleton
          // ════════════════════════════════════════════════════════
          _buildSliverPadding(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 180.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),

          // ════════════════════════════════════════════════════════
          // ⭐ Additional Image Skeleton
          // ════════════════════════════════════════════════════════
          _buildSliverPadding(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          ),

          // ════════════════════════════════════════════════════════
          // ⭐ Religious Section Skeleton
          // ════════════════════════════════════════════════════════
          _buildSliverPadding(
            child: _buildSectionCardSkeleton(
              height: 120.h,
              itemsCount: 2,
            ),
          ),

          // ════════════════════════════════════════════════════════
          // ⭐ Video Section Skeleton
          // ════════════════════════════════════════════════════════
          _buildSliverPadding(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 250.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 60.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),

          // ════════════════════════════════════════════════════════
          // ⭐ Interests Section Skeleton
          // ════════════════════════════════════════════════════════
          _buildSliverPadding(
            child: _buildSectionCardSkeleton(
              height: 140.h,
              itemsCount: 4,
            ),
          ),

          // ════════════════════════════════════════════════════════
          // ⭐ Bio Section Skeleton
          // ════════════════════════════════════════════════════════
          _buildSliverPadding(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 150.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ Helper: Sliver Padding
  // ════════════════════════════════════════════════════════════════
  Widget _buildSliverPadding({required Widget child}) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      sliver: SliverToBoxAdapter(child: child),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ Helper: Section Card Skeleton
  // ════════════════════════════════════════════════════════════════
  Widget _buildSectionCardSkeleton({
    required double height,
    required int itemsCount,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Skeleton
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 100.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Items Skeleton
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemsCount,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Row(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        width: 150.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}