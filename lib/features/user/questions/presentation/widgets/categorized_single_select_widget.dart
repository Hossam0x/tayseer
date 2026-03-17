// lib/features/user/questions/view/widget/categorized_single_select_widget.dart

import 'package:tayseer/my_import.dart';

class CategorizedSingleSelectWidget extends StatefulWidget {
  final Map<String, Map<String, String>> categorizedItems;
  final ValueChanged<Map<String, String>> onChanged;
  final Color primaryColor;
  final Color? defaultBackgroundColor;

  const CategorizedSingleSelectWidget({
    super.key,
    required this.categorizedItems,
    required this.onChanged,
    this.primaryColor = Colors.pink,
    this.defaultBackgroundColor,
  });

  @override
  State<CategorizedSingleSelectWidget> createState() =>
      _CategorizedSingleSelectWidgetState();
}

class _CategorizedSingleSelectWidgetState
    extends State<CategorizedSingleSelectWidget> {
  // ✅ Map لتخزين الاختيار لكل فئة {categoryKey: selectedItemKey}
  final Map<String, String> _selectedItems = {};

  void _selectItem(String categoryKey, String itemKey) {
    setState(() {
      _selectedItems[categoryKey] = itemKey;
    });

    // ✅ إرسال الاختيارات المحدثة
    widget.onChanged(_selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = widget.defaultBackgroundColor ?? HexColor('fdf5f8');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.categorizedItems.entries.map((categoryEntry) {
          final categoryKey = categoryEntry.key;
          final items = categoryEntry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ عنوان الفئة
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  context.tr(categoryKey),
                  style: Styles.textStyle18Bold.copyWith(
                    color: HexColor('160307'),
                  ),
                ),
              ),

              // ✅ عناصر الفئة
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: items.entries.map((itemEntry) {
                  final itemKey = itemEntry.key;
                  final emoji = itemEntry.value;
                  final isSelected = _selectedItems[categoryKey] == itemKey;

                  return GestureDetector(
                    onTap: () => _selectItem(categoryKey, itemKey),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.primaryColor
                            : defaultBgColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? widget.primaryColor
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            context.tr(itemKey),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.kgreyColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}
