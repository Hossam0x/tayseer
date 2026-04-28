import 'package:tayseer/features/advisor/settings/data/models/offerings_model.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/shared/offerings_item_chip.dart';
import 'package:tayseer/my_import.dart';

class AddSessionsAddedCard extends StatelessWidget {
  const AddSessionsAddedCard({
    super.key,
    required this.item,
    required this.index,
    required this.cubit,
  });

  final OfferingItemModel item;
  final int index;
  final UpdateOfferingsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => cubit.removeOffering(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 14, color: Colors.red.shade400),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: Styles.textStyle14.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Wrap(
            spacing: 4,
            children: [
              OfferingsItemChip(
                text:
                    '${item.price} ${context.tr('currency_${item.currency.toLowerCase()}')}',
                isGreen: true,
              ),
              OfferingsItemChip(
                text: '${item.duration}${context.tr('minute_shortcut')}',
              ),
              OfferingsItemChip(
                text: context.tr('session_type_${item.type}'),
                isPink: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
