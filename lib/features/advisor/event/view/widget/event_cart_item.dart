import 'dart:ui';
import 'package:tayseer/features/advisor/event/view/widget/app_media.dart';
import 'package:tayseer/my_import.dart';

class EventCardItem extends StatelessWidget {
  final String imageUrl;
  final String sessionTitle;
  final String location;
  final String advisorName;
  final String dateTime;
  final String price;
  final String oldPrice;

  final bool isFeatured;
  final List<String> attendeesImages;
  final int attendeesCount;

  const EventCardItem({
    super.key,
    required this.imageUrl,
    required this.sessionTitle,
    required this.location,
    required this.advisorName,
    required this.dateTime,
    required this.price,
    required this.oldPrice,
    this.isFeatured = false,
    this.attendeesImages = const [],
    this.attendeesCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.responsiveHeight(280),
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            /// 1. صورة الخلفية
            Positioned.fill(child: AppMedia(imageUrl, fit: BoxFit.cover)),

            /// 2. الجزء العلوي (مميز + صور الحضور)
            if (isFeatured)
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFDC830), Color(0xFFF37335)],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    context.tr('featured'),
                    style: Styles.textStyle14.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
              ),

            if (attendeesImages.isNotEmpty)
              Positioned(
                top: 15,
                left: 15,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$attendeesCount',
                      style: Styles.textStyle16.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                            blurRadius: 4,
                            color: Colors.black45,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    SizedBox(
                      height: 35,
                      width: 35.0 + ((attendeesImages.take(3).length - 1) * 20),
                      child: Stack(
                        children:
                            List.generate(attendeesImages.take(3).length, (
                              index,
                            ) {
                              return Positioned(
                                left: index * 20.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: AppImage(
                                      attendeesImages[index],
                                      width: 35,
                                      height: 35,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            }).reversed.toList(),
                      ),
                    ),
                  ],
                ),
              ),

            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 0.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF5E3F68).withOpacity(0.85),
                          const Color(0xFF2D1B36).withOpacity(0.70),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                sessionTitle,
                                style: Styles.textStyle14.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              _buildIconText(
                                Icons.location_on_outlined,
                                location,
                              ),
                              _buildIconText(Icons.person_outline, advisorName),
                              _buildIconText(
                                Icons.calendar_month_outlined,
                                dateTime,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.15),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.tr('session_price'),
                                style: Styles.textStyle10.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                price,
                                textDirection: TextDirection.ltr,
                                style: Styles.textStyle18Bold.copyWith(
                                  color: const Color(0xFFEFA6A8),
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${context.tr('instead_of')} $oldPrice',
                                style: Styles.textStyle10.copyWith(
                                  color: Colors.white70,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.white70,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildIconText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Styles.textStyle10.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class EventCardShimmer extends StatelessWidget {
  const EventCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // الألوان المستخدمة في الشيمار (رمادي فاتح وغامق)
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return Container(
      height: context.responsiveHeight(280),
      width: double.infinity,
      decoration: BoxDecoration(
        color:
            Theme.of(
              context,
            ).scaffoldBackgroundColor, // لون الخلفية عشان الظل يظهر
        borderRadius: BorderRadius.circular(20),
        // ✅ 1. نفس الظل الموجود في الكلاس الأصلي مع التدوير
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // لون ظل أخف قليلاً للشيمار
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              /// 1. خلفية الكارت (مكان الصورة)
              Container(
                color: baseColor,
                width: double.infinity,
                height: double.infinity,
              ),

              /// 2. مكان أيقونة القائمة (دائرة صغيرة)
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              /// 3. محاكاة الكونتينر الزجاجي العائم
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // لون شفاف قليلاً لتمييزه عن الخلفية
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      /// محاكاة الجزء الأيمن (التفاصيل)
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // عنوان الجلسة (مستطيل عريض)
                            _buildShimmerLine(width: 120, height: 14),
                            const SizedBox(height: 10),
                            // الموقع (مستطيل أصغر)
                            _buildShimmerLine(width: 90, height: 10),
                            const SizedBox(height: 6),
                            // المستشار
                            _buildShimmerLine(width: 80, height: 10),
                            const SizedBox(height: 6),
                            // التاريخ
                            _buildShimmerLine(width: 100, height: 10),
                          ],
                        ),
                      ),

                      // خط فاصل
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),

                      /// محاكاة الجزء الأيسر (السعر)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // كلمة سعر الجلسة
                            _buildShimmerLine(width: 40, height: 8),
                            const SizedBox(height: 6),
                            // السعر (مستطيل كبير)
                            _buildShimmerLine(width: 60, height: 16),
                            const SizedBox(height: 6),
                            // السعر القديم
                            _buildShimmerLine(width: 40, height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
