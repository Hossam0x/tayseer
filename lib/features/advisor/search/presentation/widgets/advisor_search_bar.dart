import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_state.dart';

class AdvisorSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onSearchChanged;
  final VoidCallback onClearSearch;
  final String? initialQuery;
  final SearchState state;

  const AdvisorSearchBar({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.state,
    this.initialQuery,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasAncestorHero = context.findAncestorWidgetOfExactType<Hero>() != null;

    Widget content = Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          end: 20.w,
          top: 12.h,
          bottom: 12.h,
        ),
        child: Row(
          children: [
            // زر الرجوع
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 24.w,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Container(
                height: 47.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    // أيقونة البحث / اللودينج
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      child: state.isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.kprimaryColor,
                              ),
                            )
                          : Icon(
                              Icons.search,
                              color: AppColors.kGreyB3,
                              size: 20.sp,
                            ),
                    ),

                    // حقل النص
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        autofocus: false, // تم تعطيلها لصالح الطلب اليدوي بتأخير
                        textAlign: TextAlign.start,
                        style: Styles.textStyle14SemiBold,
                        onChanged: (_) => onSearchChanged(),
                        decoration: InputDecoration(
                          hintText: initialQuery?.isNotEmpty == true
                              ? initialQuery
                              : context.tr("search_hint"),
                          hintStyle: Styles.textStyle14.copyWith(
                            color: AppColors.kGreyB3,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsetsDirectional.symmetric(
                            vertical: 10.h,
                          ),
                        ),
                      ),
                    ),

                    // زر المسح
                    if (searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 20.w,
                          color: Colors.grey,
                        ),
                        onPressed: onClearSearch,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!hasAncestorHero) {
      content = Hero(
        tag: 'search_bar_tag',
        child: content,
      );
    }

    return content;
  }
}
