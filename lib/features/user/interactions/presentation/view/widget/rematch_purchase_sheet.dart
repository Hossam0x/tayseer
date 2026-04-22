import 'dart:async';

import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/features/user/interactions/data/model/chat_duration_package_model.dart';
import 'package:tayseer/features/user/interactions/view_model/chat_duration_packages_cubit.dart';
import 'package:tayseer/my_import.dart';

// ─── Purchase state ──────────────────────────────────────────────────────────

enum _PurchaseStatus { initial, purchasing, success, canceled, error }

class _PurchaseState {
  final _PurchaseStatus status;
  final String? error;

  const _PurchaseState({
    this.status = _PurchaseStatus.initial,
    this.error,
  });

  _PurchaseState copyWith({_PurchaseStatus? status, String? error}) =>
      _PurchaseState(status: status ?? this.status, error: error);
}

class _PurchaseCubit extends Cubit<_PurchaseState> {
  final IAPService _iapService;
  final ApiService _apiService;

  _PurchaseCubit(this._iapService, this._apiService)
      : super(const _PurchaseState());

  void reset() => emit(const _PurchaseState());

  Future<void> purchase(ChatDurationPackageModel package, {required String chatRoomId}) async {
    final productId = package.appleProductId;
    if (productId.isEmpty) {
      emit(state.copyWith(
        status: _PurchaseStatus.error,
        error: 'معرف المنتج غير متوفر',
      ));
      return;
    }

    emit(state.copyWith(status: _PurchaseStatus.purchasing));
    unawaited(_iapService.init());

    final platform = Platform.isIOS ? 'ios' : 'android';

    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.initiatePurchase,
        data: {
          'productId': productId,
          'platform': platform,
          // 'packageId': package.id,
          if (chatRoomId.isNotEmpty) 'chatRoomId': chatRoomId,
        },
      );

      if (response['success'] != true) {
        emit(state.copyWith(
          status: _PurchaseStatus.error,
          error: response['message']?.toString() ?? 'فشل بدء عملية الشراء',
        ));
        return;
      }

      final pendingId = response['data']?['pendingId'] as String? ?? '';
      await _iapService.buyProduct(productId, uniqueNumber: pendingId);

      emit(state.copyWith(status: _PurchaseStatus.success));
    } catch (e) {
      final err = IAPErrorHandler.handle(e);
      emit(state.copyWith(
        status: err.isCanceled ? _PurchaseStatus.canceled : _PurchaseStatus.error,
        error: err.isCanceled ? null : err.message,
      ));
    }
  }
}

// ─── Public entry point ───────────────────────────────────────────────────────

void showRematchPurchaseSheet(
  BuildContext context, {
  required String userName,
  required String userImage,
  required String chatRoomId,
  required VoidCallback onSuccess,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ChatDurationPackagesCubit>()..fetchPackages(),
        ),
        BlocProvider(
          create: (_) => _PurchaseCubit(getIt<IAPService>(), getIt<ApiService>()),
        ),
      ],
      child: _RematchSheet(
        userName: userName,
        userImage: userImage,
        chatRoomId: chatRoomId,
        onSuccess: onSuccess,
      ),
    ),
  );
}

// ─── Sheet widget ─────────────────────────────────────────────────────────────

class _RematchSheet extends StatefulWidget {
  final String userName;
  final String userImage;
  final String chatRoomId;
  final VoidCallback onSuccess;

  const _RematchSheet({
    required this.userName,
    required this.userImage,
    required this.chatRoomId,
    required this.onSuccess,
  });

  @override
  State<_RematchSheet> createState() => _RematchSheetState();
}

class _RematchSheetState extends State<_RematchSheet> {
  int _selectedIndex = 0;

  void _onPay(BuildContext context, List<ChatDurationPackageModel> packages) {
    if (packages.isEmpty) return;
    final idx = _selectedIndex.clamp(0, packages.length - 1);
    context.read<_PurchaseCubit>().purchase(packages[idx], chatRoomId: widget.chatRoomId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<_PurchaseCubit, _PurchaseState>(
      listener: (context, state) {
        if (state.status == _PurchaseStatus.success) {
          Navigator.pop(context);
          widget.onSuccess();
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: 'تمت إعادة التوافق بنجاح',
              isSuccess: true,
            ),
          );
        } else if (state.status == _PurchaseStatus.error &&
            state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: state.error!, isError: true),
          );
          context.read<_PurchaseCubit>().reset();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: BlocBuilder<ChatDurationPackagesCubit, ChatDurationPackagesState>(
          builder: (context, pkgState) {
            final packages = pkgState.status == CubitStates.success
                ? pkgState.packages
                : <ChatDurationPackageModel>[];
            final isLoading = pkgState.status == CubitStates.loading;

            return BlocBuilder<_PurchaseCubit, _PurchaseState>(
              builder: (context, purchaseState) {
                final isPurchasing =
                    purchaseState.status == _PurchaseStatus.purchasing;

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

                    // Avatar
                    CircleAvatar(
                      radius: 36.r,
                      backgroundImage: widget.userImage.isNotEmpty
                          ? NetworkImage(widget.userImage)
                          : null,
                      backgroundColor: AppColors.secondary100,
                      child: widget.userImage.isEmpty
                          ? Icon(Icons.person,
                              color: AppColors.secondary400, size: 32.w)
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
                      'اختر مدة تمديد التوافق مع هذا الشخص',
                      style: Styles.textStyle14
                          .copyWith(color: AppColors.secondary400),
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
                              child: _buildPackageCard(e.key, e.value),
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

  Widget _buildPackageCard(int index, ChatDurationPackageModel pkg) {
    final isSelected = _selectedIndex == index;

    final daysLabel = pkg.durationInDays == 1
        ? 'يوم واحد'
        : pkg.durationInDays == 2
            ? 'يومان'
            : '${pkg.durationInDays} أيام';

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary50 : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color:
                  isSelected ? AppColors.primary300 : AppColors.secondary100,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(
                daysLabel,
                style: Styles.textStyle16SemiBold.copyWith(
                  color: AppColors.kscandryTextColor,
                ),
              ),
              const Spacer(),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${pkg.price.toStringAsFixed(0)} ${pkg.currency}',
                  style: Styles.textStyle14
                      .copyWith(color: AppColors.secondary400),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary400
                        : AppColors.secondary300,
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
      ),
    );
  }
}
