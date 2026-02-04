import 'dart:ui';
import 'package:tayseer/my_import.dart';

class VisitorItem extends StatelessWidget {
  final String name;
  final String imageUrl;

  const VisitorItem({super.key, required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 55.r,
                    height: 55.r,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://picsum.photos/200',
                        ), // صورة عشوائية
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // تأثير التشويش (Blur)
                  ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: Container(
                        width: 55.r,
                        height: 55.r,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              // الاسم
              Text(
                name,
                style: Styles.textStyle16.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              // الصورة مع Blur
              const Spacer(), // زر عرض (الوردي)
              CustomBotton(
                title: 'عرض',
                onPressed: () {},
                useGradient: true,
                width: 85.w,
                height: 45.h,
                radius: 10.r,
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade300, height: 1),
      ],
    );
  }
}
