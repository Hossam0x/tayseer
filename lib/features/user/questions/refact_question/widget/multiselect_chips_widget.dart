// lib/core/widgets/multi_select_chips_widget.dart

import '../../../../../my_import.dart';

class MultiSelectChipsWidget extends StatefulWidget {
  /// قائمة العناصر مع الأيقونات {key: iconPath}
  final Map<String, String> itemsWithIcons;

  /// callback يرجع قائمة العناصر المختارة (translated values)
  final ValueChanged<List<String>> onChanged;

  /// اللون الأساسي
  final Color primaryColor;

  /// لون الخلفية الافتراضي
  final Color? defaultBackgroundColor;

  const MultiSelectChipsWidget({
    super.key,
    required this.itemsWithIcons,
    required this.onChanged,
    this.primaryColor = Colors.pink,
    this.defaultBackgroundColor,
  });

  @override
  State<MultiSelectChipsWidget> createState() => _MultiSelectChipsWidgetState();
}

class _MultiSelectChipsWidgetState extends State<MultiSelectChipsWidget> {
  final Set<String> _selectedKeys = {};

  void _toggleSelection(String key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });

    final translatedValues = _selectedKeys
        .map((key) => context.tr(key))
        .toList();
    widget.onChanged(translatedValues);
  }

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = widget.defaultBackgroundColor ?? HexColor('fdf5f8');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: widget.itemsWithIcons.entries.map((entry) {
          final key = entry.key;
          final iconPath = entry.value;
          final isSelected = _selectedKeys.contains(key);

          return GestureDetector(
            onTap: () => _toggleSelection(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? widget.primaryColor : defaultBgColor,
                border: Border.all(
                  color: isSelected ? widget.primaryColor : defaultBgColor,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppImage(
                    iconPath,
                    width: 20,
                    height: 20,
                    color: isSelected ? Colors.white : AppColors.kgreyColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.tr(key),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.kgreyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
