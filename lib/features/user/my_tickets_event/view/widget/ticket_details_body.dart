import 'package:tayseer/my_import.dart';

class TicketDetailsBody extends StatelessWidget {
  const TicketDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 2. الـ App Bar الشفاف
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          pinned: false,
          floating: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),

        // 3. مسافة من فوق + الـ QR Code
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: context.responsiveHeight(20)),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                // هنا حط صورة الـ QR كـ Asset أو Icon
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: context.responsiveHeight(130),
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: context.responsiveHeight(30)),
            ],
          ),
        ),

        // 4. كارت تفاصيل الجلسة
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveWidth(16),
          ),
          sliver: SliverToBoxAdapter(
            child: _buildSectionCard(
              context: context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  RichText(
                    textDirection: TextDirection.rtl,
                    text: TextSpan(
                      style: Styles.textStyle16SemiBold.copyWith(
                        color: Colors.black,
                      ),
                      children: [
                        const TextSpan(text: "جلسة : "),
                        TextSpan(
                          text: "تحسين مهارات التواصل",
                          style: Styles.textStyle16SemiBold.copyWith(
                            color: const Color(0xFFD65A73),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    "نادي المهندسين , دمياط الجديدة , مصر",
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.person_outline, "مستشار / علي عباس"),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    "يوم 13 يناير 2024 الساعة 5:00 Am",
                  ),
                ],
              ),
            ),
          ),
        ),

        // 5. عنوان "تفاصيل السعر"
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              right: context.responsiveWidth(20),
              top: context.responsiveHeight(24),
              bottom: context.responsiveHeight(10),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "تفاصيل السعر",
                style: Styles.textStyle16SemiBold.copyWith(
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
        ),

        // 6. كارت الأسعار
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveWidth(16),
          ),
          sliver: SliverToBoxAdapter(
            child: _buildSectionCard(
              context: context,
              child: Column(
                children: [
                  _buildPriceRow("سعر التذاكر", "180 ر.س"),
                  _buildPriceRow("الرسوم", "10 ر.س"),
                  _buildPriceRow("ضريبة القيمة المضافة", "20 ر.س"),
                  _buildPriceRow("الخصم", "-50 ر.س"),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.grey, thickness: 0.2),
                  ),

                  // الإجمالي
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "180 ر.س",
                        style: Styles.textStyle18Bold.copyWith(
                          color: const Color(0xFFD65A73),
                        ),
                      ),
                      Text(
                        "الإجمالي",
                        style: Styles.textStyle16SemiBold.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // 7. عنوان "طريقة الدفع"
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              right: context.responsiveWidth(20),
              top: context.responsiveHeight(24),
              bottom: context.responsiveHeight(10),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "طريقة الدفع",
                style: Styles.textStyle16SemiBold.copyWith(
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
        ),

        // 8. كارت الدفع
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveWidth(16),
          ),
          sliver: SliverToBoxAdapter(
            child: _buildSectionCard(
              context: context,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Insta Pay",
                    style: Styles.textStyle14SemiBold.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // استبدل الكونتينر ده بصورة اللوجو Image.asset
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A148C), // لون إنستاباي
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "IP",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // مسافة أخيرة عشان المحتوى مايلزقش تحت
        SliverToBoxAdapter(
          child: SizedBox(height: context.responsiveHeight(40)),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.responsiveWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(text, style: Styles.textStyle12.copyWith(color: Colors.grey[600])),
        const SizedBox(width: 8),
        Icon(icon, size: 16, color: Colors.grey[400]),
      ],
    );
  }

  Widget _buildPriceRow(String title, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            price,
            style: Styles.textStyle14.copyWith(color: Colors.grey[600]),
          ),
          Text(
            title,
            style: Styles.textStyle14.copyWith(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
