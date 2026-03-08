import 'package:flutter/services.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/otp/otp_cubit.dart';
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
            if (state.errorMessage.isNotEmpty) {
              AppToast.error(context, context.tr(state.errorMessage));
              context.read<PhoneEditCubit>().clearMessages();
            } else if (state.successMessage.isNotEmpty &&
                state.updatePhoneStatus == CubitStates.success) {
              AppToast.success(context, context.tr(state.successMessage));

              // Navigate to OTP and return to GeneralSettingsView on success
              Future.delayed(const Duration(milliseconds: 1500), () async {
                if (!mounted) return;

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtpViewUser(
                      phoneNumber: state.fullPhoneNumber,
                      isPhoneUpdate: true,
                      otpSource: OtpSource.editPhone,
                    ),
                  ),
                );

                // If OTP was successful, pop back to GeneralSettingsView
                if (mounted && result == null) {
                  Navigator.pop(context);
                }

                if (mounted) {
                  context.read<PhoneEditCubit>().resetError();
                }
              });
              context.read<PhoneEditCubit>().clearMessages();
            }
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
                        title: context.tr('phone_title'),
                        isLargeTitle: true,
                      ),
                    ),
                    Gap(8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        context.tr('phone_verification_hint'),
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
                                context.tr(state.phoneError),
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
                        title: state.isLoading
                            ? context.tr('sending_status')
                            : context.tr('next'),
                        useGradient: true,
                        backGroundcolor: state.canProceed && !state.isLoading
                            ? Colors.transparent
                            : Colors.grey,
                        onPressed: state.isLoading || !state.canProceed
                            ? null
                            : () {
                                context.read<PhoneEditCubit>().updatePhone();
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
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            InkWell(
              onTap: () => _showCountryPicker(context),
              child: Container(
                padding: EdgeInsetsDirectional.only(
                  start: 12.w,
                  top: 14.h,
                  bottom: 14.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: state.phoneError.isNotEmpty
                          ? Colors.red
                          : Colors.grey,
                      size: 18.w,
                    ),
                    Gap(4.w),
                    Text(
                      state.selectedCountryFlag,
                      style: TextStyle(fontSize: 18.sp),
                    ),
                    Gap(4.w),
                    Text(
                      state.selectedCountryCode,
                      style: Styles.textStyle14.copyWith(
                        color: state.phoneError.isNotEmpty
                            ? Colors.red
                            : AppColors.primary600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                  hintText: context.tr('phone_hint'),
                  hintStyle: Styles.textStyle14.copyWith(
                    color: AppColors.primary200,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14.h,
                    horizontal: 12.w,
                  ),
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
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    final cubit = context.read<PhoneEditCubit>();
    String searchText = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = cubit.countries.where((c) {
              final name = c['name']!.toLowerCase();
              final code = c['code']!.toLowerCase();
              final query = searchText.toLowerCase();
              return name.contains(query) || code.contains(query);
            }).toList();

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
                        hintText: context.tr('search_country_hint'),
                        hintTextDirection: TextDirection.rtl,
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.primary300,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          searchText = value.trim();
                        });
                      },
                    ),
                  ),
                  Gap(16.h),
                  Text(
                    context.tr('choose_country_val'),
                    style: Styles.textStyle18Meduim,
                  ),
                  Gap(10.h),
                  const Divider(),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(child: Text(context.tr('no_results')))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return ListTile(
                                leading: Text(
                                  item['flag']!,
                                  style: TextStyle(fontSize: 24.sp),
                                ),
                                title: Text(
                                  item['name']!,
                                  style: Styles.textStyle16,
                                ),
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
      },
    );
  }
}
