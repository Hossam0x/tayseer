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
      // ✅ حسب اللغة بدل rtl ثابت
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(sectionTitle, style: Styles.textStyle16Bold),
            ),
            ...items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final isLast = idx == items.length - 1;
              return _buildInfoRow(context, item, isLast);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    FilterItemModel item,
    bool isLast,
  ) {
    return InkWell(
      onTap: item.onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ العنوان — حجم ثابت
                Expanded(
                  flex: 2,
                  child: Text(
                    item.title,
                    style: Styles.textStyle16.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // ✅ القيمة + أيقونة — تاخد المساحة المتبقية وتلتف لو طويلة
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          item.value,
                          style: Styles.textStyle14.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.end,
                          // ✅ يكمل في السطر اللي تحت لو طويل
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isArabic
                            ? Icons.arrow_forward_ios
                            : Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
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
