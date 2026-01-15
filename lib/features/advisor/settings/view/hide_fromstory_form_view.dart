import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/story_visibility_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/story_visibility_state.dart';
import 'package:tayseer/my_import.dart';

class HideStoryFromView extends StatefulWidget {
  const HideStoryFromView({super.key});

  @override
  State<HideStoryFromView> createState() => _HideStoryFromViewState();
}

class _HideStoryFromViewState extends State<HideStoryFromView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final cubit = context.read<StoryVisibilityCubit>();
    cubit.updateSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StoryVisibilityCubit>(
      create: (_) => getIt<StoryVisibilityCubit>(),
      child: BlocConsumer<StoryVisibilityCubit, StoryVisibilityState>(
        listener: (context, state) {
          // معالجة الأخطاء
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(context, text: state.errorMessage!, isError: true),
            );
            context.read<StoryVisibilityCubit>().clearError();
          }

          // عرض رسالة النجاح بعد إلغاء التقييد
          // if (state.isUnrestricting == false &&
          //     state.errorMessage == null &&
          //     state.state == CubitStates.success) {
          //   // نتحقق من أن العملية تمت بنجاح
          //   Future.delayed(Duration.zero, () {
          //     if (state.hasSelections == false) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   CustomSnackBar(
          //     context,
          //     text: 'تم إلغاء الإخفاء بنجاح',
          //     isSuccess: true,
          //   ),
          // );
          //     }
          //   });
          // }
        },
        builder: (context, state) {
          final cubit = context.read<StoryVisibilityCubit>();

          return Scaffold(
            body: Stack(
              children: [
                // الخلفية العلوية
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 100.h,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AssetsData.homeBarBackgroundImage),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),

                // المحتوى
                SafeArea(
                  child: Column(
                    children: [
                      // Header مع زر إغلاق
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: AppColors.blackColor,
                                  size: 24.w,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'إخفاء القصة من',
                                style: Styles.textStyle24Meduim.copyWith(
                                  color: AppColors.secondary700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // حقل البحث
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: TextField(
                          controller: _searchController,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'بحث عن مستخدم...',
                            hintStyle: Styles.textStyle16.copyWith(
                              color: AppColors.gray2,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.gray2,
                              size: 20.sp,
                            ),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 40.w,
                              minHeight: 20.h,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            suffixIcon: state.isLoading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.w),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary300,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),

                      Gap(16.h),

                      // زر اختيار الكل
                      if (state.state == CubitStates.success &&
                          state.users.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => cubit.selectAllUsers(),
                                child: Text(
                                  state.hasSelections &&
                                          state.selectedUsers.length ==
                                              state.users.length
                                      ? 'إلغاء اختيار الكل'
                                      : 'اختيار الكل',
                                  style: Styles.textStyle14.copyWith(
                                    color: AppColors.primary400,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      Gap(8.h),

                      // قائمة المستخدمين
                      Expanded(child: _buildUsersList(context, state, cubit)),

                      // زر التأكيد في الأسفل
                      if (state.hasSelections)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.w,
                            vertical: 16.h,
                          ),
                          child: CustomBotton(
                            title: state.isUnrestricting
                                ? 'جاري الإلغاء...'
                                : 'إلغاء الإخفاء عن ${state.selectedUsers.length} مستخدم',
                            onPressed: state.isUnrestricting
                                ? null
                                : () => _showConfirmationDialog(
                                    context,
                                    cubit,
                                    state,
                                  ),
                            useGradient: true,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsersList(
    BuildContext context,
    StoryVisibilityState state,
    StoryVisibilityCubit cubit,
  ) {
    if (state.state == CubitStates.loading) {
      return _buildSkeletonLoading();
    }

    if (state.state == CubitStates.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
            Gap(16.h),
            Text(
              state.errorMessage ?? 'حدث خطأ في تحميل المستخدمين',
              textAlign: TextAlign.center,
              style: Styles.textStyle16.copyWith(color: AppColors.kRedColor),
            ),
            Gap(24.h),
            ElevatedButton(
              onPressed: () => cubit.loadRestrictedUsers(),
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state.state == CubitStates.success && state.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64.w, color: AppColors.gray2),
            Gap(16.h),
            Text(
              state.searchQuery.isEmpty
                  ? 'لا يوجد مستخدمين مخفيين'
                  : 'لا توجد نتائج للبحث',
              style: Styles.textStyle16.copyWith(color: AppColors.gray2),
            ),
            if (state.searchQuery.isNotEmpty)
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  cubit.updateSearchQuery('');
                },
                child: Text('مسح البحث'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      itemCount: state.users.length,
      itemBuilder: (context, index) {
        final user = state.users[index];

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                cubit.toggleUserSelection(user.userId);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Row(
                  children: [
                    // الصورة
                    _buildUserAvatar(user.image),

                    Gap(12.w),

                    // الاسم + اليوزرنيم
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Styles.textStyle16.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary800,
                            ),
                          ),
                          if (user.userName.isNotEmpty)
                            Text(
                              user.userName,
                              style: Styles.textStyle14.copyWith(
                                color: AppColors.gray2,
                              ),
                            ),
                          if (user.email != null && user.email!.isNotEmpty)
                            Text(
                              user.email!,
                              style: Styles.textStyle12.copyWith(
                                color: AppColors.gray2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),

                    Spacer(),

                    // زر التحديد
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: user.isSelected
                            ? const Color(0xFFD65670)
                            : Colors.transparent,
                        border: Border.all(
                          color: user.isSelected
                              ? const Color(0xFFD65670)
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: user.isSelected
                          ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            Divider(color: Colors.grey.shade100, height: 1),
          ],
        );
      },
    );
  }

  Widget _buildSkeletonLoading() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Row(
                  children: [
                    // صورة Skeleton
                    Container(
                      width: 52.r,
                      height: 52.r,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                    ),

                    Gap(12.w),

                    // معلومات Skeleton
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120.w,
                            height: 18.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          Gap(6.h),
                          Container(
                            width: 80.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Spacer(),

                    // زر Skeleton
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: Colors.grey.shade200),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserAvatar(String? imageUrl) {
    return CircleAvatar(
      radius: 26.r,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: imageUrl != null && imageUrl.isNotEmpty
          ? NetworkImage(imageUrl) as ImageProvider
          : AssetImage(AssetsData.avatarImage),
      child: imageUrl == null || imageUrl.isEmpty
          ? Icon(Icons.person, color: Colors.grey.shade400, size: 24.sp)
          : null,
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    StoryVisibilityCubit cubit,
    StoryVisibilityState state,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'تأكيد الإلغاء',
            style: Styles.textStyle18Bold.copyWith(
              color: AppColors.secondary800,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'هل تريد إلغاء إخفاء القصة عن ${state.selectedUsers.length} مستخدم؟',
                style: Styles.textStyle14.copyWith(
                  color: AppColors.secondary600,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(12.h),
              if (state.selectedUsers.length <= 3)
                Column(
                  children: state.selectedUsers
                      .map(
                        (user) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Text(
                            '• ${user.name}',
                            style: Styles.textStyle14.copyWith(
                              color: AppColors.secondary700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'إلغاء',
                      style: Styles.textStyle14.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD65670),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await cubit.unrestrictSelectedUsers(context);
                    },
                    child: Text(
                      'تأكيد',
                      style: Styles.textStyle14Bold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
