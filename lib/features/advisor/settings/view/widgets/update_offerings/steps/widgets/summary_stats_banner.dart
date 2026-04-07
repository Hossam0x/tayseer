import 'package:tayseer/features/advisor/settings/data/models/offerings_model.dart';
import 'package:tayseer/my_import.dart';

class SummaryStatsBanner extends StatelessWidget {
  const SummaryStatsBanner({super.key, required this.data});

  final List<CountryOfferingsModel> data;

  @override
  Widget build(BuildContext context) {
    final total = data.fold(0, (sum, c) => sum + c.offerings.length);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.pink.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFA62A3B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
          Column(
            children: [
              Text(
                context.tr('sessions_ready'),
                style: Styles.textStyle14.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFA62A3B),
                ),
              ),
              Text(
                '${data.length} ${context.tr('countries_word')} · $total ${context.tr('session_word')}',
                style: Styles.textStyle10.copyWith(color: Colors.pink.shade300),
              ),
            ],
          ),
          const Icon(
            Icons.assignment_turned_in,
            color: Color(0xFFA62A3B),
            size: 22,
          ),
        ],
      ),
    );
  }
}
