import 'package:tayseer/my_import.dart';

class PersonCardItem extends StatelessWidget {
  const PersonCardItem({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.email,
    required this.phone,
    required this.country,
    required this.numberOfTickets,
  });

  final String name;
  final String imageUrl;
  final String email;
  final String? phone;
  final String country;
  final int numberOfTickets;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.kprimaryColor.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        // ✅ الحل الأول: خلي الـ Column كلها تبدأ من الـ start
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🖼️ صورة الشخص
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AppImage(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 📝 البيانات
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.all(context.responsiveWidth(8)),
              child: Column(
                // ✅ الحل التاني: البيانات كلها تبدأ من الـ start
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // الاسم - في النص
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      name,
                      style: Styles.textStyle14Bold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Gap(context.responsiveHeight(8)),

                  // البريد الإلكتروني
                  _InfoRowItem(text: email, icon: Icons.email_outlined),
                  Gap(context.responsiveHeight(4)),

                  // الهاتف
                  if (phone != null && phone!.isNotEmpty) ...[
                    _InfoRowItem(text: phone!, icon: Icons.phone_outlined),
                    Gap(context.responsiveHeight(4)),
                  ],

                  // البلد
                  _InfoRowItem(text: country, icon: Icons.location_on_outlined),
                  Gap(context.responsiveHeight(4)),

                  // عدد التذاكر
                  _InfoRowItem(
                    text: '${context.tr('tickets_count')}: $numberOfTickets',
                    icon: Icons.confirmation_number_outlined,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRowItem extends StatelessWidget {
  const _InfoRowItem({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.kgreyColor),
        Gap(context.responsiveWidth(4)),
        Expanded(
          child: Text(
            text,
            // ✅ الحل التالت: النص يبدأ من الـ start مش الـ end
            style: Styles.textStyle12.copyWith(color: AppColors.kgreyColor),
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class PersonCardItemShimmer extends StatelessWidget {
  const PersonCardItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.kprimaryColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // 🖼️ مكان الصورة
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
            ),

            // 📝 مكان البيانات
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(context.responsiveWidth(8)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // الاسم
                    _ShimmerBox(
                      height: context.responsiveHeight(16),
                      width: context.responsiveWidth(80),
                    ),
                    Gap(context.responsiveHeight(8)),

                    // الإيميل
                    _ShimmerRowItem(),
                    Gap(context.responsiveHeight(4)),

                    // الهاتف
                    _ShimmerRowItem(),
                    Gap(context.responsiveHeight(4)),

                    // الموقع
                    _ShimmerRowItem(),
                    Gap(context.responsiveHeight(4)),

                    // التذاكر
                    _ShimmerRowItem(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ويدجت للصف الواحد (أيقونة + نص)
class _ShimmerRowItem extends StatelessWidget {
  const _ShimmerRowItem();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // مكان النص
        Expanded(
          child: Container(
            height: context.responsiveHeight(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Gap(context.responsiveWidth(4)),
        // مكان الأيقونة
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

// ويدجت للـ Box العام
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.height, required this.width});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
