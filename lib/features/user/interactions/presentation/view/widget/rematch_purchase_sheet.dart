import 'dart:developer';
import 'dart:io';

import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/features/user/interactions/data/model/chat_duration_package_model.dart';
import 'package:tayseer/features/user/interactions/view_model/chat_duration_packages_cubit.dart';
import 'package:tayseer/my_import.dart';

// ─── Purchase state ──────────────────────────────────────────────────────────

enum _PurchaseStatus { initial, purchasing, success, canceled, error }

class _PurchaseState {
  final _PurchaseStatus status;
  final String? error;

  const _PurchaseState({this.status = _PurchaseStatus.initial, this.error});

  _PurchaseState copyWith({_PurchaseStatus? status, String? error}) =>
      _PurchaseState(status: status ?? this.status, error: error);
}

class _PurchaseCubit extends Cubit<_PurchaseState> {
  final IAPService _iapService;
  final ApiService _apiService;

  _PurchaseCubit(this._iapService, this._apiService)
    : super(const _PurchaseState());

  void reset() => emit(const _PurchaseState());

  Future<void> purchase(
    ChatDurationPackageModel package, {
    required String chatRoomId,
  }) async {
    final productId = package.appleProductId;
    if (productId.isEmpty) {
      emit(
        state.copyWith(
          status: _PurchaseStatus.error,
          error: 'معرف المنتج غير متوفر',
        ),
      );
      return;
    }

    emit(state.copyWith(status: _PurchaseStatus.purchasing));

    try {
      await _iapService.init();
    } catch (e) {
      log('[RematchPurchase] ❌ IAP init failed: $e');
      emit(
        state.copyWith(
          status: _PurchaseStatus.error,
          error: 'store_unavailable',
        ),
      );
      return;
    }

    try {
      // قراءة الـ uuid من الكاش — نفس الطريقة المستخدمة في باقات الاشتراك
      final uuid = CachNetwork.getStringData(key: kUuid);

      log('[RematchPurchase] ════════════════════════════════════════');
      log('[RematchPurchase] 🛒 PURCHASE FLOW START');
      log('[RematchPurchase]   productId  : $productId');
      log('[RematchPurchase]   chatRoomId : $chatRoomId');
      log(
        '[RematchPurchase]   uuid       : ${uuid.isNotEmpty ? uuid : "⚠️ EMPTY"}',
      );
      log('[RematchPurchase] ════════════════════════════════════════');

      if (uuid.isEmpty) {
        emit(
          state.copyWith(
            status: _PurchaseStatus.error,
            error: 'purchase_user_data_missing',
          ),
        );
        return;
      }

      // 1️⃣ أول حاجة: نبعت للباك-إند عشان يسجل الـ purchase intent ونجيب الـ pendingId
      log('[RematchPurchase] 📤 Calling /iap/initiate-purchase...');
      Map<String, dynamic> initiateResponse;
      try {
        initiateResponse = await _apiService.post(
          endPoint: '/iap/initiate-purchase',
          data: {
            'productId': productId,
            'platform': Platform.isIOS ? 'ios' : 'android',
            'chatRoomId': chatRoomId,
          },
        );
      } catch (e) {
        log('[RematchPurchase] ❌ Backend call failed: $e');
        emit(
          state.copyWith(
            status: _PurchaseStatus.error,
            error: 'فشل تسجيل عملية الشراء',
          ),
        );
        return;
      }

      if (initiateResponse['success'] != true) {
        log(
          '[RematchPurchase] ❌ initiate-purchase error: ${initiateResponse['message']}',
        );
        emit(
          state.copyWith(
            status: _PurchaseStatus.error,
            error: 'فشل تسجيل عملية الشراء',
          ),
        );
        return;
      }

      final pendingId = initiateResponse['data']?['pendingId'] as String? ?? '';
      if (pendingId.isEmpty) {
        log('[RematchPurchase] ❌ pendingId is empty');
        emit(
          state.copyWith(
            status: _PurchaseStatus.error,
            error: 'فشل تسجيل عملية الشراء',
          ),
        );
        return;
      }

      log('[RematchPurchase] ✅ pendingId: $pendingId');
      log('[RematchPurchase] 📲 appAccountToken → Apple: $pendingId');

      // 2️⃣ بعد كده نبدأ الشراء من Apple بالـ pendingId كـ appAccountToken
      // نستخدم native SK2 channel عشان appAccountToken يتبعت صح في الـ webhook
      await _iapService.buyConsumableNative(
        productId: productId,
        appAccountToken: pendingId,
      );

      emit(state.copyWith(status: _PurchaseStatus.success));
    } catch (e) {
      final err = IAPErrorHandler.handle(e);
      emit(
        state.copyWith(
          status: err.isCanceled
              ? _PurchaseStatus.canceled
              : _PurchaseStatus.error,
          error: err.isCanceled ? null : err.messageKey,
        ),
      );
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
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ChatDurationPackagesCubit>()..fetchPackages(),
        ),
        BlocProvider(
          create: (_) =>
              _PurchaseCubit(getIt<IAPService>(), getIt<ApiService>()),
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
  int _closeCountdown = 5;
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    // countdown عشان المستخدم ميقفلش الـ sheet بالغلط
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_closeCountdown > 0) {
        setState(() => _closeCountdown--);
        return true;
      }
      setState(() => _canClose = true);
      return false;
    });
  }

  void _onPay(BuildContext context, List<ChatDurationPackageModel> packages) {
    if (packages.isEmpty) return;
    final idx = _selectedIndex.clamp(0, packages.length - 1);
    context.read<_PurchaseCubit>().purchase(
      packages[idx],
      chatRoomId: widget.chatRoomId,
    );
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
              text: context.tr('purchase_success'),
              isSuccess: true,
            ),
          );
        } else if (state.status == _PurchaseStatus.canceled) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: context.tr('purchase_cancelled')),
          );
          context.read<_PurchaseCubit>().reset();
        } else if (state.status == _PurchaseStatus.error &&
            state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr(state.error!),
              isError: true,
            ),
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
        child:
            BlocBuilder<ChatDurationPackagesCubit, ChatDurationPackagesState>(
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
                        // Handle + زرار الإغلاق
                        Row(
                          children: [
                            SizedBox(
                              width: 36.w,
                              height: 36.w,
                              child:
                                  _canClose &&
                                      purchaseState.status !=
                                          _PurchaseStatus.purchasing
                                  ? GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 18.w,
                                          color: AppColors.secondary600,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _canClose ? '' : '$_closeCountdown',
                                          style: Styles.textStyle14.copyWith(
                                            color: AppColors.secondary600,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: Center(
                                child: Container(
                                  width: 40.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary200,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 36.w),
                          ],
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
                              ? Icon(
                                  Icons.person,
                                  color: AppColors.secondary400,
                                  size: 32.w,
                                )
                              : null,
                        ),
                        SizedBox(height: 12.h),

                        Text(
                          context
                              .tr('rematch_with')
                              .replaceFirst('{name}', widget.userName),
                          style: Styles.textStyle20Meduim.copyWith(
                            color: AppColors.kscandryTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          context.tr('rematch_description'),
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.secondary400,
                          ),
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
                          title: isPurchasing
                              ? ''
                              : context.tr('rematch_button'),
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
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    String daysLabel;
    if (isArabic) {
      daysLabel = pkg.durationInDays == 1
          ? 'يوم واحد'
          : pkg.durationInDays == 2
          ? 'يومان'
          : '${pkg.durationInDays} أيام';
    } else {
      daysLabel = pkg.durationInDays == 1
          ? '1 Day'
          : pkg.durationInDays == 2
          ? '2 Days'
          : '${pkg.durationInDays} Days';
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              margin: EdgeInsets.symmetric(vertical: 4.w),
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary50 : Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary300
                      : AppColors.secondary100,
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
                  Text(
                    '${pkg.price.toStringAsFixed(0)} ${pkg.currency}',
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondary400,
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
            if ((pkg.savePercentage ?? 0) > 0)
              Positioned(
                top: -6.h,
                right: isArabic ? 0 : null,
                left: isArabic ? null : 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFEB7A91),
                        Color.fromRGBO(245, 192, 3, 1),
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEB7A91).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    context
                        .tr('save_percent')
                        .replaceAll('{percent}', '${pkg.savePercentage}'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
