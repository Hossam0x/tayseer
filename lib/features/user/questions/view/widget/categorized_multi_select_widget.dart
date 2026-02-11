// lib/core/widgets/categorized_multi_select_widget.dart

import '../../../../../my_import.dart';

class CategorizedMultiSelectWidget extends StatefulWidget {
  final Map<String, Map<String, String>> categorizedItems;
  final ValueChanged<List<String>> onChanged;
  final Color primaryColor;
  final Color? defaultBackgroundColor;

  const CategorizedMultiSelectWidget({
    super.key,
    required this.categorizedItems,
    required this.onChanged,
    this.primaryColor = Colors.pink,
    this.defaultBackgroundColor,
  });

  @override
  State<CategorizedMultiSelectWidget> createState() =>
      _CategorizedMultiSelectWidgetState();
}

class _CategorizedMultiSelectWidgetState
    extends State<CategorizedMultiSelectWidget> {
  final Set<String> _selectedKeys = {};

  void _toggleSelection(String key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });

    widget.onChanged(_selectedKeys.toList());
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
                  final key = itemEntry.key;
                  final emoji = itemEntry.value;
                  final isSelected = _selectedKeys.contains(key);

                  return GestureDetector(
                    onTap: () => _toggleSelection(key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
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
                      child: Text(
                        '$emoji ${context.tr(key)}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.kgreyColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }
}
