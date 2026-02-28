
import 'package:tayseer/my_import.dart';

class SearchBarWithFilter extends StatelessWidget {
  final bool isReadOnly;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final TextEditingController? controller;

  const SearchBarWithFilter({
    super.key,
    this.isReadOnly = false,
    this.onTap,
    this.onFilterTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final height = isMobile ? 44.h : 50.h;
    final borderRadius = isMobile ? 25.0 : 30.0;
    final fontSize = isMobile ? 13.0 : 15.0;
    final iconSize = isMobile ? 21.0 : 23.0;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        onTap: () {
          if (isReadOnly && onTap != null) onTap!();
        },
    
        decoration: InputDecoration(
          hintText: context.tr("search_by_experience"),
          hintStyle: Styles.textStyle14Meduim.copyWith(
            color: AppColors.secondary400,
            fontSize: fontSize,
          ),

        
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[400],
            size: iconSize,
          ),

          suffixIcon: GestureDetector(
            onTap: onFilterTap,
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Opacity(
                opacity: 0.6,
                child: AppImage(
                  AssetsData.filter2Icon,
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
