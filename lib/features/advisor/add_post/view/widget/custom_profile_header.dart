import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/core/models/category_model.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_cubit.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_state.dart';
import 'package:tayseer/my_import.dart';

class CustomProfileHeader extends StatefulWidget {
  final String name;
  final String initialSubtitle;
  final String? imageUrl;
  final bool isVerified;
  final List<CategoryModel>? groups;
  final Function(String)? onGroupSelectedId;
  final AddPostCubit cubit;
  const CustomProfileHeader({
    super.key,
    required this.name,
    required this.initialSubtitle,
    this.imageUrl,
    this.isVerified = false,
    this.groups,
    this.onGroupSelectedId,
    required this.cubit,
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
   final bool isSelected = selectedSubtitle !=  context.tr('select_group');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          /// الصورة الشخصية
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: MyProfileImage(size: 60, imageUrl: widget.imageUrl),
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

                /// زر اختيار المجموعة (BottomSheet)
                GestureDetector(
                  onTap: () async {
                    final result = await showModalBottomSheet<CategoryModel>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) => CategoryBottomSheet(cubit: widget.cubit),
                    );

                    if (result != null) {
                      setState(() => selectedSubtitle = result.name);

                      widget.onGroupSelectedId?.call(result.id);
                    }
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
                            color: isSelected ? AppColors.kprimaryColor : AppColors.kGreyColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: isSelected ? AppColors.kprimaryColor : AppColors.kGreyColor,
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

class CategoryBottomSheet extends StatefulWidget {
  final AddPostCubit cubit;
  const CategoryBottomSheet({super.key, required this.cubit});

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.cubit.state.categories.isEmpty) {
      widget.cubit.getALLCategory();
    }

    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200) {
        widget.cubit.loadMoreCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocBuilder<AddPostCubit, AddPostState>(
        builder: (context, state) {
          return SizedBox(
            height: context.height * 0.7,
            child: Column(
              children: [
                const SizedBox(height: 12),

                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  context.tr('select_category'),
                  style: Styles.textStyle16SemiBold,
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: state.categoryState == CubitStates.loading
                      ? const Center(child: CustomloadingApp())
                      : ListView.builder(
                          controller: _controller,
                          itemCount: state.categories.length + 1,
                          itemBuilder: (context, index) {
                            if (index < state.categories.length) {
                              final category = state.categories[index];

                              return ListTile(
                                title: Text(
                                  category.name,
                                  style: Styles.textStyle16SemiBold,
                                ),
                                onTap: () {
                                  Navigator.pop(context, category);
                                },
                              );
                            } else {
                              return state.isLoadingMore
                                  ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(child: CustomloadingApp()),
                                    )
                                  : const SizedBox();
                            }
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
