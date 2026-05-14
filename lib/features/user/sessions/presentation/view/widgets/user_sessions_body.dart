import 'package:tayseer/core/enum/session_card_style.dart';
import 'package:tayseer/core/widgets/error_state_widget.dart';
import 'package:tayseer/features/advisor/session/presentation/view/widget/session_card.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/session_history/empty_session_widget.dart';
import 'package:tayseer/features/user/sessions/data/models/user_session_model.dart';
import 'package:tayseer/features/user/sessions/presentation/cubit/user_sessions_cubit.dart';
import 'package:tayseer/features/user/sessions/presentation/cubit/user_sessions_state.dart';
import 'package:tayseer/features/user/sessions/presentation/view/widgets/user_sessions_filter_bar.dart';
import 'package:tayseer/my_import.dart';

class UserSessionsBody extends StatefulWidget {
  const UserSessionsBody({super.key});

  @override
  State<UserSessionsBody> createState() => _UserSessionsBodyState();
}

class _UserSessionsBodyState extends State<UserSessionsBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<UserSessionsCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdvisorBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildAppBar(context),
            const UserSessionsFilterBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: const Color(0xFF2D2D2D),
                size: 20.sp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: Text(
                  context.tr('my_sessions'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ),
            // زر مسح الفلاتر
            BlocBuilder<UserSessionsCubit, UserSessionsState>(
              buildWhen: (p, c) =>
                  p.selectedStatus != c.selectedStatus ||
                  p.selectedPaymentStatus != c.selectedPaymentStatus,
              builder: (context, state) {
                final hasFilters =
                    state.selectedStatus != null ||
                    state.selectedPaymentStatus != null;
                if (!hasFilters) return SizedBox(width: 48.w);
                return IconButton(
                  icon: Icon(
                    Icons.filter_alt_off_rounded,
                    color: AppColors.kprimaryColor,
                    size: 22.sp,
                  ),
                  onPressed: () =>
                      context.read<UserSessionsCubit>().clearFilters(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<UserSessionsCubit, UserSessionsState>(
      buildWhen: (p, c) =>
          p.fetchState != c.fetchState ||
          p.sessions != c.sessions ||
          p.loadMoreState != c.loadMoreState,
      builder: (context, state) {
        if (state.fetchState == CubitStates.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.fetchState == CubitStates.failure) {
          return ErrorStateWidget(
            errorMessage: state.errorMessage,
            onRetry: () => context.read<UserSessionsCubit>().fetchSessions(),
          );
        }

        if (state.fetchState == CubitStates.success && state.sessions.isEmpty) {
          return EmptySessionsState(
            title: context.tr('no_sessions'),
            subtitle: context.tr('no_sessions_subtitle'),
            showAnimation: true,
            isCompact: false,
          );
        }

        if (state.fetchState == CubitStates.success) {
          return RefreshIndicator(
            onRefresh: () =>
                context.read<UserSessionsCubit>().fetchSessions(refresh: true),
            color: AppColors.kprimaryColor,
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
              itemCount: state.sessions.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.sessions.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                return _SessionCard(session: state.sessions[index]);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session Card Item
// ─────────────────────────────────────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final UserSessionModel session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final isPending = session.paymentStatus == 'pending';
    final isCancelled = session.sessionStatus == 'cancelled';
    final isNow = session.isNow;

    SessionCardStyle style;
    if (isNow) {
      style = SessionCardStyle.active;
    } else if (isCancelled || isPending) {
      style = SessionCardStyle.white;
    } else {
      style = SessionCardStyle.outlined;
    }

    final date = _formatDate(session.date);
    final timeRange = '${session.timeRange.from} - ${session.timeRange.to}';

    return Stack(
      children: [
        SessionCard(
          style: style,
          name: session.advisor.name,
          handle: session.advisor.userName,
          imageUrl: session.advisor.image,
          sessiondate: date,
          timeRange: timeRange,
          isBlur: false,
          isNow: isNow && !isCancelled && !isPending,
          buttonText: _getButtonText(context, session),
          onTapDetails: () {
            Navigator.pushNamed(
              context,
              AppRouter.incommingsessiondetails,
              arguments: session.sessionId,
            );
          },
          onTapJoin: isNow && !isCancelled && !isPending
              ? () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.incommingsessiondetails,
                    arguments: session.sessionId,
                  );
                }
              : null,
        ),
        // شارة حالة الدفع للجلسات المعلقة
        if (isPending && !isCancelled)
          Positioned(
            top: 12.h,
            left: 24.w,
            child: _StatusBadge(
              label: context.tr('payment_pending'),
              color: const Color(0xFFF59E0B),
            ),
          ),
        if (isCancelled)
          Positioned(
            top: 12.h,
            left: 24.w,
            child: _StatusBadge(
              label: context.tr('cancelled'),
              color: Colors.red.shade400,
            ),
          ),
      ],
    );
  }

  String _getButtonText(BuildContext context, UserSessionModel session) {
    if (session.isNow &&
        session.sessionStatus != 'cancelled' &&
        session.paymentStatus != 'pending') {
      return context.tr('join');
    }
    return context.tr('details');
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final days = [
        'الأحد',
        'الإثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
      ];
      final months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];
      return '${days[date.weekday % 7]}، ${date.day} ${months[date.month - 1]}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
