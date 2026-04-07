import 'package:tayseer/features/user/my_space/presentation/manager/booking/booking_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/booking/booking_state.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/booking/offering_card.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/booking/privacy_guidelines_bottom_sheet.dart';
import 'package:tayseer/my_import.dart';

class ChooseSessionBody extends StatefulWidget {
  final String title;
  final String advisorId;

  const ChooseSessionBody({
    super.key,
    required this.title,
    required this.advisorId,
  });

  @override
  State<ChooseSessionBody> createState() => _ChooseSessionBodyState();
}

class _ChooseSessionBodyState extends State<ChooseSessionBody> {
  int? selectedOfferingIndex;

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: SafeArea(
        child: Column(
          children: [
            // ─── المحتوى ───
            Expanded(
              child: BlocConsumer<BookingCubit, BookingState>(
                listener: (context, state) {
                  if (state.getOfferingsState == CubitStates.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBar(
                        context,
                        isError: true,
                        text: state.errorMessage ?? '',
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return CustomScrollView(
                    slivers: [
                      // ═══ 1. App Bar (ثابت دائماً) ═══
                      SliverAppBar(
                        pinned: true,
                        floating: false,
                        elevation: 0,
                        scrolledUnderElevation: 0,
                        backgroundColor: Colors.transparent,
                        centerTitle: true,
                        title: Text(
                          widget.title.isNotEmpty
                              ? widget.title
                              : context.tr('choose_what_suits_you'),
                          style: Styles.textStyle20Bold.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(
                              Icons.error_outline,
                              size: 25,
                              color: AppColors.kscandryTextColor,
                            ),
                            onPressed: () =>
                                PrivacyGuidelinesBottomSheet.show(context),
                          ),
                        ],
                        leading: IconButton(
                          icon: Icon(
                            isArabic ? Icons.arrow_back : Icons.arrow_forward,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ),

                      // ═══ 2. العنوان الفرعي (ثابت دائماً) ═══
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Gap(context.responsiveHeight(8)),
                              Text(
                                context.tr('choose_suitable_session_hint'),
                                textAlign: TextAlign.center,
                                style: Styles.textStyle12.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              Gap(context.responsiveHeight(20)),
                            ],
                          ),
                        ),
                      ),

                      // ═══ 3. المحتوى حسب الحالة ═══
                      ..._buildContentSlivers(context, state),

                      // ═══ 4. مسافة تحت ═══
                      SliverToBoxAdapter(
                        child: Gap(context.responsiveHeight(24)),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ─── زر الاختيار (ثابت تحت) ───
            BlocBuilder<BookingCubit, BookingState>(
              builder: (context, state) {
                final isValid =
                    selectedOfferingIndex != null &&
                    state.getOfferingsState == CubitStates.success;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 25.0,
                  ),
                  child: CustomBotton(
                    width: double.infinity,
                    title: context.tr('choose'),
                    useGradient: isValid,
                    backGroundcolor: AppColors.kgreyColor,
                    onPressed: isValid
                        ? () {
                            final selected =
                                state.offerings[selectedOfferingIndex!];

                            debugPrint('✅ Selected: ${selected.name}');
                            debugPrint('✅ Type: ${selected.type}');
                            debugPrint('✅ Duration: ${selected.duration}');
                            debugPrint(
                              '✅ Price: ${selected.priceWithCurrency}',
                            );
                            debugPrint('✅ AdvisorId: ${widget.advisorId}');

                            context.pushNamed(
                              AppRouter.kUserRescheduleView,
                              arguments: {
                                // 'title': context.tr('book_consultation'),
                                'advisorId': widget.advisorId,
                                'selectedOffering': selected,
                                'duration': selected.duration.toString(),
                              },
                            );
                          }
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════
  // ★ بناء المحتوى حسب الحالة (يرجع List<Widget> من Slivers)
  // ════════════════════════════════════════
  List<Widget> _buildContentSlivers(BuildContext context, BookingState state) {
    // ★ لودينج → Shimmer
    if (state.getOfferingsState == CubitStates.loading) {
      return [const OfferingsShimmerList(count: 3)];
    }

    // ★ خطأ
    if (state.getOfferingsState == CubitStates.failure) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildErrorWidget(context, state.errorMessage),
        ),
      ];
    }

    // ★ نجاح - مفيش عروض
    if (state.getOfferingsState == CubitStates.success &&
        state.offerings.isEmpty) {
      return [SliverToBoxAdapter(child: _buildEmptyOfferings(context))];
    }

    // ★ نجاح - فيه عروض
    if (state.getOfferingsState == CubitStates.success &&
        state.offerings.isNotEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: state.offerings.length,
            separatorBuilder: (_, __) => Gap(context.responsiveHeight(16)),
            itemBuilder: (context, index) {
              final offering = state.offerings[index];
              final isSelected = selectedOfferingIndex == index;

              return OfferingCard(
                offering: offering,
                isSelected: isSelected,
                onSelect: () {
                  setState(() {
                    selectedOfferingIndex = index;
                  });
                },
              );
            },
          ),
        ),
      ];
    }

    return [const SliverToBoxAdapter(child: SizedBox.shrink())];
  }

  // ════════════════════════════════════════
  // ★ حالة فارغة
  // ════════════════════════════════════════
  Widget _buildEmptyOfferings(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 80.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(AssetsData.kEmptyEventsImage, width: 150.w, height: 150.h),
          Gap(context.responsiveHeight(16)),
          Text(
            context.tr('no_offerings_available'),
            style: Styles.textStyle14.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  // ★ حالة الخطأ
  // ════════════════════════════════════════
  Widget _buildErrorWidget(BuildContext context, String? message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade50,
              ),
              child: Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red.shade300,
              ),
            ),
            Gap(context.responsiveHeight(20)),
            Text(
              message ?? context.tr('error_occurred'),
              style: Styles.textStyle14.copyWith(color: Colors.red.shade400),
              textAlign: TextAlign.center,
            ),
            Gap(context.responsiveHeight(20)),
            CustomBotton(
              title: context.tr('retry'),
              useGradient: true,
              onPressed: () {
                context.read<BookingCubit>().getOfferings(widget.advisorId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
