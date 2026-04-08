import 'package:tayseer/features/user/my_space/data/model/advisor_offering_model.dart';
import 'package:tayseer/my_import.dart';

class OfferingCard extends StatelessWidget {
  final AdvisorOfferingModel offering;
  final bool isSelected;
  final VoidCallback onSelect;

  const OfferingCard({
    super.key,
    required this.offering,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: GestureDetector(
        onTap: onSelect,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color.fromRGBO(252, 233, 237, 0.42),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.kprimaryColor
                  : AppColors.primary100,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.04),
                blurRadius: 6,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ─── 1. Title ───
              Align(
                alignment: isArabic
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  isArabic ? offering.typeAr : offering.typeEn,
                  style: Styles.textStyle16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── 2. Row (Mirrored) ───
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: isArabic
                    ? [
                        _OfferingRadio(isSelected: isSelected),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDetails(isArabic, context)),
                      ]
                    : [
                        Expanded(child: _buildDetails(isArabic, context)),
                        const SizedBox(width: 12),
                        _OfferingRadio(isSelected: isSelected),
                      ],
              ),

              const SizedBox(height: 20),

              // ─── 3. Duration ───
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.kprimaryColor.withOpacity(0.05)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.kprimaryColor
                        : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    isArabic ? offering.durationAr : offering.durationEn,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.kprimaryColor
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(bool isArabic, BuildContext context) {
    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          offering.name,
          style: Styles.textStyle14,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
        ),
        const SizedBox(height: 4),

        // السعر (Mirrored)
        RichText(
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          text: TextSpan(
            children: isArabic
                ? [
                    TextSpan(
                      text: offering.priceWithCurrency,
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.kprimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' :${context.tr('session_price_label')}',
                      style: Styles.textStyle14,
                    ),
                  ]
                : [
                    TextSpan(
                      text: '${context.tr('session_price_label')}: ',
                      style: Styles.textStyle14,
                    ),
                    TextSpan(
                      text: offering.priceWithCurrency,
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.kprimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
          ),
        ),
      ],
    );
  }
}

// Radio
class _OfferingRadio extends StatelessWidget {
  final bool isSelected;

  const _OfferingRadio({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.kprimaryColor : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kprimaryColor,
                ),
              ),
            )
          : null,
    );
  }
}

class OfferingCardShimmer extends StatelessWidget {
  const OfferingCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ─── 1. النوع ───
            _shimmerBox(width: 120, height: 18),

            const SizedBox(height: 16),

            // ─── 2. الراديو + التفاصيل ───
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الراديو
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                ),

                const SizedBox(width: 12),

                // التفاصيل
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _shimmerBox(width: 150, height: 14),
                      const SizedBox(height: 8),
                      _shimmerBox(width: 180, height: 14),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ─── 3. المدة ───
            Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class OfferingsShimmerList extends StatelessWidget {
  final int count;

  const OfferingsShimmerList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList.separated(
        itemCount: count,
        separatorBuilder: (_, __) => Gap(context.responsiveHeight(16)),
        itemBuilder: (_, __) => const OfferingCardShimmer(),
      ),
    );
  }
}
