import 'package:tayseer/features/user/my_space/presentation/view/My_Space_Consultatioin_Content.dart';
import 'package:tayseer/my_import.dart';

class ConsultationStandalonePage extends StatelessWidget {
  const ConsultationStandalonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdvisorBackground(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ), // ✅ مش 0
          child: Column(
            children: [
              Text(context.tr("Consulting"), style: Styles.textStyle20Bold),
              SizedBox(height: 24.h),
              CustomSearchBar(
                isReadOnly: false,
                onFilterTap: () => context.pushNamed(AppRouter.kMarriageFilterView),
                onTap: () {
                  // هنا ممكن تضيف أكشن للبحث لو حبيت
                },
              ),
              const Expanded(child: MySpaceConsultationContent()),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  final bool isReadOnly;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final TextEditingController? controller;

  const CustomSearchBar({
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
        // textAlign: TextAlign.right,
        // textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'بحث',
          hintStyle: Styles.textStyle14Meduim.copyWith(
            color: AppColors.secondary400,
            fontSize: fontSize,
          ),

          // ✅ أيقونة البحث على اليمين (suffix لـ RTL)
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
                opacity: 0.6, // ✅ غير القيمة من 0.0 إلى 1.0
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
