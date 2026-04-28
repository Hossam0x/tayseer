import 'package:tayseer/features/advisor/settings/data/models/offerings_model.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/shared/offerings_item_chip.dart';
import 'package:tayseer/my_import.dart';

class SummaryOfferingRow extends StatelessWidget {
  const SummaryOfferingRow({super.key, required this.offering, this.onDelete});

  final OfferingItemModel offering;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 13, color: Colors.red.shade400),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              offering.name,
              style: Styles.textStyle14.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Wrap(
            spacing: 4,
            children: [
              OfferingsItemChip(
                text: '${offering.price} ${offering.currency}',
                isGreen: true,
              ),
              OfferingsItemChip(
                text: '${offering.duration}${context.tr('minute_shortcut')}',
              ),
              if (offering.type == 'package' &&
                  offering.numberOfSessions != null)
                OfferingsItemChip(
                  text:
                      '${offering.numberOfSessions} ${context.tr('sessions_count')}',
                ),
              OfferingsItemChip(
                text: offering.type == 'package'
                    ? context.tr('package_type')
                    : context.tr('individual_type'),
                isPink: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
