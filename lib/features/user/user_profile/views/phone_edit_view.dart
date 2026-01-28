import 'package:flutter/services.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/phone/phone_edit_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/otp_view_user.dart';
import 'package:tayseer/my_import.dart';

class PhoneEditView extends StatefulWidget {
  final String initialPhone;
  const PhoneEditView({super.key, this.initialPhone = ""});

  @override
  State<PhoneEditView> createState() => _PhoneEditViewState();
}

class _PhoneEditViewState extends State<PhoneEditView> {
  late TextEditingController _phoneController;
  FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PhoneEditCubit(),
      child: Scaffold(
        body: BlocConsumer<PhoneEditCubit, PhoneEditState>(
          listener: (context, state) {
            // التنقل عند النجاح فقط
            if (state.updatePhoneStatus == CubitStates.success) {
              Future.delayed(Duration(milliseconds: 1500), () {
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OtpViewUser(
                        phoneNumber: state.fullPhoneNumber,
                        isPhoneUpdate: true,
                      ),
                    ),
                  );
                  context.read<PhoneEditCubit>().resetError();
                }
              });
            }

            // لا حاجة لعرض SnackBar هنا لأن الكيوبت يتولى ذلك
          },
          builder: (context, state) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (widget.initialPhone.isNotEmpty && state.phoneNumber.isEmpty) {
                context.read<PhoneEditCubit>().initializePhone(
                  widget.initialPhone,
                );
              }
            });

            if (_phoneController.text != state.phoneNumber) {
              _phoneController.text = state.phoneNumber;
              _phoneController.selection = TextSelection.fromPosition(
                TextPosition(offset: state.phoneNumber.length),
              );
            }

            return AdvisorBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    Gap(16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: SimpleAppBar(
                        title: 'رقم الهاتف',
                        isLargeTitle: true,
                      ),
                    ),
                    Gap(8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        'سنرسل لك رمز تحقق علي رقم هاتفك لتأكيد رقمك الجديد',
                        textAlign: TextAlign.center,
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.primary800,
                        ),
                      ),
                    ),
                    Gap(100.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPhoneInputField(context, state),

                          if (state.phoneError.isNotEmpty) ...[
                            Gap(8.h),
                            Padding(
                              padding: EdgeInsets.only(right: 12.w),
                              child: Text(
                                state.phoneError,
                                style: Styles.textStyle12.copyWith(
                                  color: Colors.red,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 50.w,
                        vertical: 30.h,
                      ),
                      child: CustomBotton(
                        height: 53.h,
                        width: double.infinity,
                        title: state.isLoading ? 'جاري الإرسال...' : 'التالي',
                        useGradient: true,
                        backGroundcolor: state.canProceed && !state.isLoading
                            ? Colors.transparent
                            : Colors.grey,
                        onPressed: state.isLoading || !state.canProceed
                            ? null
                            : () {
                                context.read<PhoneEditCubit>().updatePhone(
                                  context,
                                );
                              },
                      ),
                    ),

                    Gap(MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhoneInputField(BuildContext context, PhoneEditState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: state.phoneError.isNotEmpty
              ? Colors.red
              : AppColors.primary100,
          width: state.phoneError.isNotEmpty ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              textAlign: TextAlign.left,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              style: Styles.textStyle14.copyWith(
                color: AppColors.secondary800,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintTextDirection: TextDirection.rtl,
                hintText: 'أدخل رقم الهاتف',
                hintStyle: Styles.textStyle14.copyWith(
                  color: AppColors.primary200,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                errorText: null,
              ),
              onChanged: (value) {
                context.read<PhoneEditCubit>().updatePhoneNumber(value);
              },
              onTap: () {
                _phoneController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _phoneController.text.length),
                );
              },
            ),
          ),

          InkWell(
            onTap: () => _showCountryPicker(context),
            child: Container(
              padding: EdgeInsets.only(left: 12.w, top: 14.h, bottom: 14.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Gap(4.w),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      state.selectedCountryCode,
                      style: Styles.textStyle14.copyWith(
                        color: state.phoneError.isNotEmpty
                            ? Colors.red
                            : AppColors.primary600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Gap(4.w),
                  Text(
                    state.selectedCountryFlag,
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: state.phoneError.isNotEmpty
                        ? Colors.red
                        : Colors.grey,
                    size: 18.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    final cubit = context.read<PhoneEditCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextField(
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن الدولة...',
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: Styles.textStyle14.copyWith(
                      color: AppColors.primary300,
                    ),
                    prefixIcon: Icon(Icons.search, color: AppColors.primary300),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                  onChanged: (value) {},
                ),
              ),
              Gap(16.h),

              Text("اختر الدولة", style: Styles.textStyle18Meduim),
              Gap(10.h),
              const Divider(),

              Expanded(
                child: ListView.builder(
                  itemCount: cubit.countries.length,
                  itemBuilder: (context, index) {
                    final item = cubit.countries[index];
                    return ListTile(
                      leading: Text(
                        item['flag']!,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                      title: Text(item['name']!, style: Styles.textStyle16),
                      trailing: Text(
                        item['code']!,
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.primary600,
                        ),
                      ),
                      onTap: () {
                        cubit.updateCountry(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
