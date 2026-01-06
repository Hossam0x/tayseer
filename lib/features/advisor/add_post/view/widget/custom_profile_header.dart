import 'package:tayseer/features/advisor/add_post/model/category_model.dart';
import 'package:tayseer/my_import.dart';

class CustomProfileHeader extends StatefulWidget {
  final String name;
  final String initialSubtitle;
  final String? imageUrl;
  final bool isVerified;
  final List<CategoryModel>? groups;
  final Function(String)? onGroupSelectedId;

  const CustomProfileHeader({
    super.key,
    required this.name,
    required this.initialSubtitle,
    this.imageUrl,
    this.isVerified = false,
    this.groups,
    this.onGroupSelectedId,
  });

  @override
  State<CustomProfileHeader> createState() => _CustomProfileHeaderState();
}

class _CustomProfileHeaderState extends State<CustomProfileHeader> {
  late String selectedSubtitle;

  @override
  void initState() {
    super.initState();
    selectedSubtitle = widget.initialSubtitle;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          /// الصورة الشخصية
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                ? AppImage(
                    widget.imageUrl!,
                    width: context.responsiveWidth(48),
                    height: context.responsiveWidth(48),
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: context.responsiveWidth(48),
                    height: context.responsiveWidth(48),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
          ),
          Gap(context.responsiveWidth(12)),

          /// معلومات الاسم + المجموعة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// الاسم + علامة التوثيق
                Row(
                  children: [
                    Text(widget.name, style: Styles.textStyle16SemiBold),
                    if (widget.isVerified) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: AppColors.kBlueColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 6),

                /// زر اختيار المجموعة
                PopupMenuButton<String>(
                  enabled: widget.groups != null && widget.groups!.isNotEmpty,
                  onSelected: (value) {
                    final selected = widget.groups?.firstWhere(
                      (g) => g.id == value,
                      orElse: () => widget.groups!.first,
                    );
                    setState(() => selectedSubtitle = selected!.name);
                    widget.onGroupSelectedId?.call(value);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) {
                    return widget.groups!
                        .map(
                          (e) => PopupMenuItem<String>(
                            value: e.id,
                            child: Text(e.name),
                          ),
                        )
                        .toList();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: HexColor('f2f2f2').withOpacity(0.7),
                      border: Border.all(
                        color: AppColors.kWhiteColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedSubtitle,
                          style: Styles.textStyle12.copyWith(
                            color: HexColor('666666'),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: HexColor('666666'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
