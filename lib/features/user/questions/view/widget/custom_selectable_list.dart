import 'package:flutter/scheduler.dart';

import '../../../../../my_import.dart';

class SelectableListWidget extends StatefulWidget {
  final List<String> items;
  final void Function(String key, String translatedValue)? onChanged;
  final bool showSearch;
  final String? searchHintKey;
  final String? selectedKey; // ⭐ Controlled by parent
  final String? initialSelectedKey; // ⭐ Optional for first init
  final Color primaryColor;

  const SelectableListWidget({
    super.key,
    required this.items,
    this.onChanged,
    this.showSearch = true,
    this.searchHintKey,
    this.selectedKey,
    this.initialSelectedKey,
    this.primaryColor = Colors.pink,
  });

  @override
  State<SelectableListWidget> createState() => _SelectableListWidgetState();
}

class _SelectableListWidgetState extends State<SelectableListWidget> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final currentSelectedKey = widget.selectedKey ?? widget.initialSelectedKey;

    // Filtered list based on search
    final filteredList = widget.items.where((key) {
      final translatedText = context.tr(key).toLowerCase();
      return translatedText.contains(_search.toLowerCase());
    }).toList();

    return Column(
      children: [
        if (widget.showSearch)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onTapOutside: (event) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  FocusScope.of(context).unfocus();
                });
              },
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: widget.searchHintKey != null
                    ? context.tr(widget.searchHintKey!)
                    : 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: const UnderlineInputBorder(),
              ),
            ),
          ),
        if (widget.showSearch) const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: filteredList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final itemKey = filteredList[index];
              final isSelected = currentSelectedKey == itemKey;
              final translatedValue = context.tr(itemKey);

              return GestureDetector(
                onTap: () => widget.onChanged?.call(itemKey, translatedValue),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.primaryColor.withOpacity(.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: isSelected
                        ? Border.all(color: widget.primaryColor)
                        : null,
                  ),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 100),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: isSelected
                            ? Container(
                                key: const ValueKey('selected'),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.primaryColor,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('unselected'),
                              ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: isSelected ? 10 : 0,
                      ),
                      Expanded(
                        child: Text(translatedValue, style: Styles.textStyle16),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
