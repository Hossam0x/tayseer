import '../../../../my_import.dart';

class ContentSwitcher extends StatefulWidget {
  const ContentSwitcher({
    super.key,
    required this.options,
    required this.onOptionSelected,
    this.selectedOption, // 🔑 أضف الـ parameter ده
  });

  final List<String> options;
  final Function(String selectedOption) onOptionSelected;
  final String? selectedOption; // 🔑 هنا

  @override
  State<ContentSwitcher> createState() => _ContentSwitcherState();
}

class _ContentSwitcherState extends State<ContentSwitcher> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
  }

  @override
  void didUpdateWidget(ContentSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🔑 لو الـ selectedOption اتغير من برة، حدّث الـ index
    if (oldWidget.selectedOption != widget.selectedOption) {
      _updateSelectedIndex();
    }
  }

  // 🔑 Function جديدة عشان تحدث الـ index بناءً على الـ selectedOption
  void _updateSelectedIndex() {
    if (widget.selectedOption != null) {
      final index = widget.options.indexWhere(
        (option) => option.trim() == widget.selectedOption!.trim(),
      );
      if (index != -1) {
        setState(() {
          selectedIndex = index;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: context.width * 0.07),
        height: context.height * 0.07,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          border: Border.all(
            color: HexColor('eb7a91').withOpacity(0.2),
            width: 1.5,
          ),
          color: AppColors.kWhiteColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / widget.options.length;

            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  right: selectedIndex * itemWidth,
                  top: 0,
                  bottom: 0,
                  width: itemWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: HexColor('eb7a91'),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                /// 🟢 النصوص (ثابتة)
                Row(
                  children: List.generate(widget.options.length, (index) {
                    final isSelected = selectedIndex == index;
                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() => selectedIndex = index);
                          widget.onOptionSelected(widget.options[index]);
                        },
                        child: Center(
                          child: Text(
                            widget.options[index],
                            overflow: TextOverflow.ellipsis,
                            style: Styles.textStyle16SemiBold.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}