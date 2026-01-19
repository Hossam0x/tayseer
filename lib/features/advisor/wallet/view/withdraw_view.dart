import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/wallet/data/cubit/withdraw_cubit.dart';
import 'package:tayseer/features/advisor/wallet/data/cubit/withdraw_state.dart';
import 'package:tayseer/features/advisor/wallet/data/models/withdraw_model.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/balance_card.dart';
import 'package:tayseer/my_import.dart';

class WithdrawView extends StatelessWidget {
  const WithdrawView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WithdrawCubit(),
      child: Scaffold(
        backgroundColor: AppColors.kScaffoldColor,
        body: AdvisorBackground(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 105.h,
                child: Image.asset(
                  AssetsData.homeBarBackgroundImage,
                  fit: BoxFit.fill,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Gap(16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: SimpleAppBar(title: 'سحب'),
                    ),
                    Gap(16.h),
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: BlocBuilder<WithdrawCubit, WithdrawState>(
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Current Balance
                                BalanceCard(),
                                SizedBox(height: 30.h),
                                // Amount Input
                                _buildAmountInput(context, state),
                                SizedBox(height: 10.h),
                                // Fees Section
                                _buildFeesSection(state),
                                SizedBox(height: 20.h),
                                // Withdraw Method
                                _buildWithdrawMethod(context, state),
                                SizedBox(height: 24.h),
                                // Account Details
                                _buildAccountDetails(state, context),
                                SizedBox(height: 24.h),
                                // Notes
                                _buildNotesSection(),
                                SizedBox(height: 20.h),
                                // Submit Button
                                _buildSubmitButton(context, state),
                                SizedBox(height: 40.h),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(BuildContext context, WithdrawState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المبلغ المراد سحبه',
          style: Styles.textStyle16.copyWith(color: AppColors.primaryText),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: AppColors.whiteCardBack,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: AppImage(AssetsData.amountIcon, width: 24.w),
              ),
              Expanded(
                child: TextFormField(
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  style: Styles.textStyle20Bold.copyWith(
                    color: AppColors.primaryText,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: Styles.textStyle16.copyWith(
                      color: AppColors.inactiveColor,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),

                    suffixStyle: Styles.textStyle20Bold.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  onChanged: (value) {
                    final amount = double.tryParse(value) ?? 0;
                    context.read<WithdrawCubit>().updateAmount(amount);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Text(
                  'ر.س',
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeesSection(WithdrawState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fees Info
        Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: Text(
            '*تتم خصم نسبة من المبلغ المراد سحبه رسوم سحب',
            style: Styles.textStyle14.copyWith(color: AppColors.secondaryText),
          ),
        ),
        SizedBox(height: 16.h),
        // After Fees Amount
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
          decoration: BoxDecoration(
            color: AppColors.whiteCardBack,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Color.fromRGBO(133, 20, 43, 0.08)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'بعد خصم نسبة التطبيق',
                style: Styles.textStyle16.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              GradientText(text: '325 ر.س', style: Styles.textStyle20Bold),
              // Text(
              //   // '${state.netAmount.toStringAsFixed(0)} ر.س',
              //   '325 ر.س',
              //   style: Styles.textStyle20Bold.copyWith(
              //     color: AppColors.primary400,
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawMethod(BuildContext context, WithdrawState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طريقة السحب',
          style: Styles.textStyle16.copyWith(color: AppColors.primaryText),
        ),
        SizedBox(height: 8.h),
        // Bank Account Option
        _buildMethodOption(
          context,
          title: 'حساب بنكي',
          icon: AssetsData.icBank,
          isSelected: state.method == WithdrawMethod.bankAccount,
          onTap: () {
            context.read<WithdrawCubit>().changeMethod(
              WithdrawMethod.bankAccount,
            );
          },
        ),
        SizedBox(height: 12.h),
        // STC Pay Option
        _buildMethodOption(
          context,
          title: 'STC Pay',
          icon: AssetsData.stcPay,
          isSelected: state.method == WithdrawMethod.stcPay,
          onTap: () {
            context.read<WithdrawCubit>().changeMethod(WithdrawMethod.stcPay);
          },
        ),
        SizedBox(height: 12.h),
        // InstaPay Pay Option
        _buildMethodOption(
          context,
          title: 'Insta Pay',
          icon: AssetsData.instaPay,
          isSelected: state.method == WithdrawMethod.instaPay,
          onTap: () {
            context.read<WithdrawCubit>().changeMethod(WithdrawMethod.instaPay);
          },
        ),
        SizedBox(height: 12.h),
        // Vodafone Cash Pay Option
        _buildMethodOption(
          context,
          title: 'فودافون كاش',
          icon: AssetsData.vodafoneCash,
          isSelected: state.method == WithdrawMethod.vodafoneCash,
          onTap: () {
            context.read<WithdrawCubit>().changeMethod(
              WithdrawMethod.vodafoneCash,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMethodOption(
    BuildContext context, {
    required String title,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary100 : AppColors.whiteCardBack,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary400 : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            icon == AssetsData.icBank
                ? AppImage(icon, width: 22.w, color: AppColors.primary400)
                : AppImage(
                    icon,
                    width: icon == AssetsData.vodafoneCash ? 20.w : 40.w,
                  ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: Styles.textStyle16.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetails(WithdrawState state, BuildContext context) {
    final isBank = state.method == WithdrawMethod.bankAccount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBank ? 'رقم الحساب البنكي' : 'رقم الهاتف',
          style: Styles.textStyle16.copyWith(color: AppColors.primaryText),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.whiteCardBack,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                isBank ? AssetsData.icBank : AssetsData.phoneIcon,
                width: 22.w,
                color: AppColors.primary300,
              ),
              Gap(10.w),
              Expanded(
                child: Text(
                  state.accountNumber,
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.inactiveColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // إضافة قسم رفع الصور فقط للحساب البنكي
        if (isBank) ...[
          SizedBox(height: 24.h),
          _buildImageUploadSection(context, state),
        ],
      ],
    );
  }

  Widget _buildImageUploadSection(BuildContext context, WithdrawState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // مستطيل رفع الصور
        GestureDetector(
          onTap: () => context.read<WithdrawCubit>().pickImagesFromGallery(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 70.w, vertical: 16.h),
            // height: 160.h,
            decoration: BoxDecoration(
              color: AppColors.whiteCardBack,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary100),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImage(AssetsData.uplaodCertificate, width: 35.w),
                  Gap(12.h),
                  Text(
                    textAlign: TextAlign.center,
                    'يرجى رفع صورتك الشخصية مع صورة البطاقة (الوجه والظهر).',
                    style: Styles.textStyle16Meduim.copyWith(
                      color: AppColors.mentionBlue,
                    ),
                  ),
                  Gap(12.h),
                  Text(
                    'PNG, JPG, GIF UP TO 5 MB',
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondary400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // عرض الصور المرفوعة
        if (state.images.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: List.generate(state.images.length, (index) {
              return Container(
                width: 180.w,
                height: 130.h,
                decoration: BoxDecoration(
                  color: AppColors.mainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.mainColor),
                ),
                child: _buildImagePreview(context, state.images[index], index),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context, File image, int index) {
    return Stack(
      children: [
        Center(
          child: Container(
            width: 148.w,
            height: 110.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              image: DecorationImage(
                image: FileImage(image),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: AppColors.mainColor),
            ),
          ),
        ),
        Positioned(
          top: 14,
          right: 18,
          child: GestureDetector(
            onTap: () => context.read<WithdrawCubit>().removeImage(index),
            child: Container(
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(Icons.close, size: 20.r, color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'الحد الأدنى للسحب 50 ر.س',
            style: Styles.textStyle14.copyWith(color: AppColors.secondaryText),
          ),
          SizedBox(height: 8.h),
          Text(
            'يتم تحويل الأموال خلال 2-7 أيام عمل',
            style: Styles.textStyle14.copyWith(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, WithdrawState state) {
    return BlocConsumer<WithdrawCubit, WithdrawState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          // عرض رسالة النجاح
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );

          // العودة للخلف بعد تأخير
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            if (state.errorMessage != null)
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Text(
                  state.errorMessage!,
                  style: Styles.textStyle14.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomBotton(
                height: 54.h,
                width: double.infinity,
                title: state.isLoading ? 'يتم الطلب...' : 'سحب',
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRouter.kWithdrawSuccessView,
                  );
                },
                useGradient: true,
                isLoading: state.isLoading,
              ),
            ),
          ],
        );
      },
    );
  }
}
