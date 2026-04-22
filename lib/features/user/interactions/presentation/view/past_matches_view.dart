import 'dart:async';
import 'package:tayseer/features/user/interactions/data/Model/history_response_model.dart';
import 'package:tayseer/features/user/interactions/data/repos/interactions_repository.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/rematch_purchase_sheet.dart';
import 'package:tayseer/my_import.dart';

class PastMatchesView extends StatefulWidget {
  const PastMatchesView({super.key});

  @override
  State<PastMatchesView> createState() => _PastMatchesViewState();
}

class _PastMatchesViewState extends State<PastMatchesView> {
  late Future<PastMatchesResponse> _pastMatchesFuture;

  @override
  void initState() {
    super.initState();
    _pastMatchesFuture = _loadPastMatches();
  }

  Future<PastMatchesResponse> _loadPastMatches() async {
    final result = await getIt<InteractionsRepository>().fetchPastMatches(
      page: 1,
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (response) => response,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AdvisorBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.r),
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.secondary800,
                            size: 24.w,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'التوافقات السابقة',
                            style: Styles.textStyle22Bold,
                            textAlign: TextAlign.center,
                          ),
                          Gap(4.h),
                          Text(
                            'تظهر التوافقات منتهية هنا ويبقى امامك فرصة حتي تعيد الارسال مره أخرى',
                            style: Styles.textStyle14.copyWith(
                              color: AppColors.secondary600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 40.w),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<PastMatchesResponse>(
                  future: _pastMatchesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'حدث خطأ أثناء تحميل التوافقات السابقة',
                                style: Styles.textStyle16.copyWith(
                                  color: AppColors.secondary800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Gap(16.h),
                              CustomBotton(
                                title: 'أعد المحاولة',
                                onPressed: () {
                                  setState(() {
                                    _pastMatchesFuture = _loadPastMatches();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final items = snapshot.data?.items ?? [];
                    if (items.isEmpty) {
                      return _EmptyState(
                        message: 'لا توجد توافقات سابقة حتى الآن.',
                      );
                    }

                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 12.h,
                        ),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: AppColors.kWhiteColor.withOpacity(0.96),
                              borderRadius: BorderRadius.circular(18.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Re-match button (left side in RTL)
                                OutlinedButton(
                                  onPressed: () {
                                    showRematchPurchaseSheet(
                                      context,
                                      userName: item.name.isNotEmpty
                                          ? item.name
                                          : 'مستخدم سابق',
                                      userImage: item.image,
                                      onSuccess: () {
                                        setState(() {
                                          _pastMatchesFuture =
                                              _loadPastMatches();
                                        });
                                      },
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary400,
                                    side: BorderSide(
                                      color: AppColors.primary400,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 8.h,
                                    ),
                                  ),
                                  child: Text(
                                    'اعادة التوافق',
                                    style: Styles.textStyle12.copyWith(
                                      color: AppColors.primary400,
                                    ),
                                  ),
                                ),
                                Gap(12.w),
                                // Name + reason (center)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        item.name.isNotEmpty
                                            ? item.name
                                            : 'مستخدم سابق',
                                        style: Styles.textStyle16SemiBold,
                                        textAlign: TextAlign.end,
                                      ),
                                      Gap(4.h),
                                      Text(
                                        item.reason,
                                        style: Styles.textStyle12.copyWith(
                                          color: AppColors.secondary600,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ],
                                  ),
                                ),
                                Gap(12.w),
                                // Avatar (right side in RTL)
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary300,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 28.r,
                                    backgroundImage: item.image.isNotEmpty
                                        ? NetworkImage(item.image)
                                        : null,
                                    backgroundColor: AppColors.secondary100,
                                    child: item.image.isEmpty
                                        ? Icon(
                                            Icons.person,
                                            color: AppColors.secondary400,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ); // close Directionality
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(AssetsData.noSessionHistoryIcon, width: 268.w),
            SizedBox(height: 24.h),
            Text(
              message,
              style: Styles.textStyle16.copyWith(color: AppColors.secondary400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
