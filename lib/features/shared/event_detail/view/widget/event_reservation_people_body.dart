import 'package:tayseer/features/shared/event_detail/model/event_people_model.dart';
import 'package:tayseer/features/shared/event_detail/view/widget/person_cardItem.dart';
import 'package:tayseer/features/shared/event_detail/view_model/event_detail_cubit.dart';
import 'package:tayseer/features/shared/event_detail/view_model/event_detail_state.dart';
import 'package:tayseer/my_import.dart';

class EventReservationPeopleBody extends StatefulWidget {
  const EventReservationPeopleBody({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventReservationPeopleBody> createState() =>
      _EventReservationPeopleBodyState();
}

class _EventReservationPeopleBodyState
    extends State<EventReservationPeopleBody> {
  @override
  void initState() {
    super.initState();
    context.read<EventDetailCubit>().fetchEventPeople(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: BlocBuilder<EventDetailCubit, EventDetailState>(
        buildWhen: (previous, current) =>
            previous.eventPeopleStatus != current.eventPeopleStatus,
        builder: (context, state) {
          return CustomScrollView(
            physics: state.eventPeopleStatus == CubitStates.loading
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            slivers: [
              const CustomSliverAppBar(),

              SliverToBoxAdapter(child: Gap(context.responsiveHeight(20))),

              ..._buildContentSlivers(context, state),

              SliverToBoxAdapter(child: Gap(context.responsiveHeight(20))),
            ],
          );
        },
      ),
    );
  }

  /// بيرجع الـ Slivers المناسبة حسب الحالة
  List<Widget> _buildContentSlivers(
    BuildContext context,
    EventDetailState state,
  ) {
    // ⏳ حالة التحميل
    if (state.eventPeopleStatus == CubitStates.loading) {
      return [_buildShimmerGrid(context)];
    }

    // ❌ حالة الخطأ
    if (state.eventPeopleStatus == CubitStates.failure) {
      return [
        _buildErrorSliver(
          context,
          state.errorMessage ?? context.tr('something_went_wrong'),
        ),
      ];
    }

    // ✅ حالة النجاح
    if (state.eventPeopleStatus == CubitStates.success) {
      final people = state.eventPeople;

      // 📭 لو الليستة فاضية
      if (people.isEmpty) {
        return [_buildEmptySliver(context)];
      }

      // 📋 عرض البيانات
      return [_buildPeopleGrid(context, people)];
    }

    // الحالة الابتدائية
    return [const SliverToBoxAdapter(child: SizedBox.shrink())];
  }

  // ═══════════════════════════════════════════════════════
  // 📋 Grid البيانات الحقيقية
  // ═══════════════════════════════════════════════════════
  Widget _buildPeopleGrid(BuildContext context, List<EventPeopleModel> people) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(16)),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: context.responsiveHeight(16),
          crossAxisSpacing: context.responsiveWidth(16),
          childAspectRatio: 0.65,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final person = people[index];
          return PersonCardItem(
            name: person.name,
            imageUrl: person.image,
            email: person.email,
            phone: person.phone,
            country: person.country,
            numberOfTickets: person.numberOfTicketsUserReserved,
          );
        }, childCount: people.length),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ⏳ Shimmer Grid
  // ═══════════════════════════════════════════════════════
  Widget _buildShimmerGrid(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(16)),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: context.responsiveHeight(16),
          crossAxisSpacing: context.responsiveWidth(16),
          childAspectRatio: 0.65,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const PersonCardItemShimmer(),
          childCount: 6,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // 📭 حالة الليستة الفاضية
  // ═══════════════════════════════════════════════════════
  Widget _buildEmptySliver(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false, // ⚡ عشان يتمركز في المنتصف
      child: Padding(
        padding: EdgeInsets.all(context.responsiveWidth(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(
              AssetsData.emptyBoxImage,
              width: context.responsiveWidth(150),
              height: context.responsiveWidth(150),
            ),
            Gap(context.responsiveHeight(16)),
            Text(
              context.tr('no_attendees_yet'),
              style: Styles.textStyle16Bold.copyWith(
                color: AppColors.kgreyColor,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(context.responsiveHeight(8)),
            Text(
              context.tr('no_attendees_description'),
              style: Styles.textStyle12.copyWith(
                color: AppColors.kgreyColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ❌ حالة الخطأ
  // ═══════════════════════════════════════════════════════
  Widget _buildErrorSliver(BuildContext context, String message) {
    return SliverFillRemaining(
      hasScrollBody: false, // ⚡ عشان يتمركز في المنتصف
      child: Padding(
        padding: EdgeInsets.all(context.responsiveWidth(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Colors.redAccent.withOpacity(0.5),
            ),
            Gap(context.responsiveHeight(16)),
            Text(
              message,
              style: Styles.textStyle14Bold.copyWith(
                color: AppColors.kgreyColor,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(context.responsiveHeight(16)),
            ElevatedButton.icon(
              onPressed: () {
                context.read<EventDetailCubit>().fetchEventPeople(
                  widget.eventId,
                );
              },
              icon: const Icon(Icons.refresh),
              label: Text(context.tr('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kprimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(24),
                  vertical: context.responsiveHeight(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 📌 الـ SliverAppBar
// ═══════════════════════════════════════════════════════════
class CustomSliverAppBar extends StatelessWidget {
  const CustomSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      centerTitle: true,
      title: Text(
        context.tr('detils_attendees'),
        style: Styles.textStyle18Bold.copyWith(color: Colors.black87),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => context.pop(),
      ),
    );
  }
}
