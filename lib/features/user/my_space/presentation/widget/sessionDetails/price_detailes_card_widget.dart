import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';
import 'package:tayseer/my_import.dart';

class PriceDetailsCard extends StatelessWidget {
  final PricingModelResponse pricing;
  final String? currency;

  const PriceDetailsCard({super.key, required this.pricing, this.currency});

  @override
  Widget build(BuildContext context) {
    final currencyLabel = currency ?? context.tr('currency_sar');
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _PriceRow(
            label: context.tr('session_price'),
            value: "${pricing.sessionPrice} $currencyLabel",
          ),
          _PriceRow(
            label: context.tr('taxes'),
            value: "${pricing.taxes} $currencyLabel",
          ),
          _PriceRow(
            label: context.tr('discount'),
            value: "-${pricing.discount} $currencyLabel",
            isDiscount: true,
          ),
          _buildDivider(),
          _buildTotalRow(context, currencyLabel),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 30.h, color: Colors.grey[300]);
  }

  Widget _buildTotalRow(BuildContext context, String currencyLabel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.tr('total'),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        Text(
          "${pricing.total} $currencyLabel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: const Color(0xFFD65A73),
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDiscount ? Colors.green : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
