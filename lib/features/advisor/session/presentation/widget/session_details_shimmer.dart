import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tayseer/my_import.dart';

class SessionDetailsShimmer extends StatelessWidget {
  const SessionDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            // --- بيانات الشخص ---
            _buildSectionTitle(context),
            _buildCard(
              context,
              height: 80,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 120, height: 16, color: Colors.white),
                      const Gap(8),
                      Container(width: 80, height: 12, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            // --- بيانات الجلسة ---
            _buildSectionTitle(context),
            _buildCard(
              context,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(width: 20, height: 20, color: Colors.white),
                      const Gap(8),
                      Container(width: 150, height: 16, color: Colors.white),
                    ],
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      Container(width: 20, height: 20, color: Colors.white),
                      const Gap(8),
                      Container(width: 100, height: 16, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            // --- بيانات السعر ---
            _buildSectionTitle(context),
            _buildCard(
              context,
              height: 200,
              child: Column(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 100, height: 14, color: Colors.white),
                        Container(width: 60, height: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.height * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [Container(width: 100, height: 16, color: Colors.white)],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required double height,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
