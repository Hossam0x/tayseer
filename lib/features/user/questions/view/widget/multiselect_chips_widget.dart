// lib/core/widgets/multi_select_chips_widget.dart

import '../../../../../my_import.dart';

class MultiSelectChipsWidget extends StatefulWidget {
  final Map<String, String> itemsWithEmoji;
  final ValueChanged<List<String>> onChanged;
  final Color primaryColor;
  final Color? defaultBackgroundColor;

  const MultiSelectChipsWidget({
    super.key,
    required this.itemsWithEmoji,
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

    // ✅ إرجاع قائمة الـ keys المختارة
    widget.onChanged(_selectedKeys.toList());
  }

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = widget.defaultBackgroundColor ?? HexColor('fdf5f8');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: widget.itemsWithEmoji.entries.map((entry) {
          final key = entry.key;
          final emoji = entry.value;
          final isSelected = _selectedKeys.contains(key);

          return GestureDetector(
            onTap: () => _toggleSelection(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? widget.primaryColor : defaultBgColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? widget.primaryColor : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Text(
                '$emoji ${context.tr(key)}',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.kgreyColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
