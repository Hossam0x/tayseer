import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil

class InteractiveRatingStars extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final int maxStars;

  const InteractiveRatingStars({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxStars, (index) {
        bool isSelected = index < rating;

        return GestureDetector(
          onTap: () {
            onRatingChanged(index + 1);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w), // مسافة أفقية
            child: Icon(
              Icons.star_rounded,
              size: 40.sp, // حجم النجمة
              color: isSelected ? Colors.amber : Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
