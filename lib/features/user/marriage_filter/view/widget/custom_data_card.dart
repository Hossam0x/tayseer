import 'package:tayseer/my_import.dart';

class FilterItemModel {
  final String title;
  final String value;
  final VoidCallback? onTap;

  FilterItemModel({required this.title, required this.value, this.onTap});
}

class CustomDataCard extends StatelessWidget {
  final String sectionTitle;
  final List<FilterItemModel> items;

  const CustomDataCard({
    super.key,
    required this.sectionTitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان الرئيسي
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(sectionTitle, style: Styles.textStyle16Bold),
            ),

            ...items.asMap().entries.map((entry) {
              int idx = entry.key;
              FilterItemModel item = entry.value;
              bool isLast = idx == items.length - 1;

              return _buildInfoRow(item, isLast);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(FilterItemModel item, bool isLast) {
    return InkWell(
      onTap: item.onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: Styles.textStyle16.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      item.value,
                      style: Styles.textStyle14.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isLast)
            Divider(height: 1, thickness: 0.8, color: Colors.grey[100]),
        ],
      ),
    );
  }
}
