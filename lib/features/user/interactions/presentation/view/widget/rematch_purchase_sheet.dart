import 'package:tayseer/features/user/marriage/model/regards_package_model.dart';
import 'package:tayseer/features/user/marriage/view_model/regards_packages_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/regards_package_cubit/regards_package_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/regards_package_cubit/regards_package_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/regards_purchase_sheet.dart';
import 'package:tayseer/my_import.dart';

void showRematchPurchaseSheet(
  BuildContext context, {
  required String userName,
  required String userImage,
  required VoidCallback onSuccess,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<RegardsPackagesCubit>()..fetchPackages(),
        ),
        BlocProvider(create: (_) => getIt<RegardsPackagePurchaseCubit>()),
      ],
      child: _RematchSheet(
        userName: userName,
        userImage: userImage,
        onSuccess: onSuccess,
      ),
    ),
  );
}

class _RematchSheet extends StatefulWidget {
  final String userName;
  final String userImage;
  final VoidCallback onSuccess;

  const _RematchSheet({
    required this.userName,
    required this.userImage,
    required this.onSuccess,
  });

  @override
  State<_RematchSheet> createState() => _RematchSheetState();
}

class _RematchSheetState extends State<_RematchSheet> {
  int _selectedIndex = 1;

  void _onPay(BuildContext context, List<PurchasePackage> packages) {
    if (packages.isEmpty) return;
    final idx = _selectedIndex.clamp(0, packages.length - 1);
    final selected = packages[idx];
    final rawPackage = RegardsPackageModel(
      id: selected.id,
      appleProductId: selected.appleProductId,
      amount: selected.count,
      price: selected.price,
      currency: selected.currency,
      priceForOne: selected.priceForOne,
    );
    context.read<RegardsPackagePurchaseCubit>().purchasePackage(rawPackage);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegardsPackagePurchaseCubit, RegardsPackagePurchaseState>(
      listener: (context, state) {
        if (state.status == RegardsPackagePurchaseStatus.success) {
          Navigator.pop(context);
          widget.onSuccess();
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: 'تمت إعادة التوافق بنجاح', isSuccess: true),
          );
        } else if (state.status == RegardsPackagePurchaseStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: state.error!, isError: true),
          );
          context.read<RegardsPackagePurchaseCubit>().resetStatus();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: BlocBuilder<RegardsPackagesCubit, RegardsPackagesState>(
          builder: (context, pkgState) {
            final packages = pkgState.status == CubitStates.success
                ? PurchasePackage.fromApiPackages(pkgState.packages)
                : <PurchasePackage>[];
            final isLoading = pkgState.status == CubitStates.loading;

            return BlocBuilder<RegardsPackagePurchaseCubit, RegardsPackagePurchaseState>(
              builder: (context, purchaseState) {
                final isPurchasing = purchaseState.status == RegardsPackagePurchaseStatus.purchasing;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.secondary200,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // User avatar + name
                    CircleAvatar(
                      radius: 36.r,
                      backgroundImage: widget.userImage.isNotEmpty
                          ? NetworkImage(widget.userImage)
                          : null,
                      backgroundColor: AppColors.secondary100,
                      child: widget.userImage.isEmpty
                          ? Icon(Icons.person, color: AppColors.secondary400, size: 32.w)
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'إعادة التوافق مع ${widget.userName}',
                      style: Styles.textStyle20Meduim.copyWith(
                        color: AppColors.kscandryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'اختر باقة التحيات لإعادة التواصل مع هذا الشخص',
                      style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),

                    if (isLoading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: const CircularProgressIndicator(),
                      )
                    else
                      ...packages.asMap().entries.map(
                        (e) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: _buildPackageCard(context, e.key, e.value),
                        ),
                      ),

                    SizedBox(height: 20.h),
                    CustomBotton(
                      title: isPurchasing ? '' : 'إعادة التوافق',
                      height: 54.h,
                      width: double.infinity,
                      useGradient: true,
                      isLoading: isPurchasing,
                      onPressed: isPurchasing || packages.isEmpty
                          ? null
                          : () => _onPay(context, packages),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, int index, PurchasePackage pkg) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                top: (pkg.hasDiscount && pkg.discountPercent != null) ? 14.h : 0,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary50 : Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary300 : AppColors.secondary100,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${pkg.count} ',
                    style: Styles.textStyle32Meduim.copyWith(
                      color: AppColors.kscandryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تحية',
                          style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
                        ),
                        SizedBox(height: 4.h),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '${pkg.price.toStringAsFixed(0)} ${pkg.currency}',
                            style: Styles.textStyle12SemiBold.copyWith(color: AppColors.secondary400),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary400 : AppColors.secondary300,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.primary400 : Colors.white,
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 14.w, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
            if (pkg.hasDiscount && pkg.discountPercent != null)
              Positioned(
                top: 0,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEB7A91), Color.fromRGBO(245, 192, 3, 1)],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.r),
                      topLeft: Radius.circular(6.r),
                      bottomRight: Radius.circular(6.r),
                      bottomLeft: Radius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    'وفر ${pkg.discountPercent}%',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
