import 'package:tayseer/features/user/my_tickets_event/view_model/my_ticket_cubit.dart';
import 'package:tayseer/features/user/my_tickets_event/view_model/my_ticket_state.dart';
import 'package:tayseer/my_import.dart';

class TicketDetailsBody extends StatefulWidget {
  const TicketDetailsBody({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<TicketDetailsBody> createState() => _TicketDetailsBodyState();
}

class _TicketDetailsBodyState extends State<TicketDetailsBody> {
  @override
  void initState() {
    super.initState();
    context.read<MyTicketCubit>().getReservationDetails(widget.ticketId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyTicketCubit, MyTicketState>(
      builder: (context, state) {
        /// 🔄 LOADING
        if (state.reservationDetailsState == CubitStates.loading) {
          return const TicketDetailsShimmer();
        }

        /// ❌ FAILURE
        if (state.reservationDetailsState == CubitStates.failure) {
          return CustomBackground(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      state.errorMessage ?? context.tr('error_occurred'),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        /// ✅ SUCCESS
        final details = state.reservationDetails;

        return CustomBackground(
          child: CustomScrollView(
            slivers: [
              /// AppBar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),

              /// QR
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: context.responsiveHeight(20)),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: context.responsiveHeight(200),
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: context.responsiveHeight(30)),
                  ],
                ),
              ),

              /// Session Details
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(16),
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildSectionCard(
                    context: context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            style: Styles.textStyle16SemiBold.copyWith(
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: context.tr('session_title_ticket'),
                              ),
                              TextSpan(
                                text: details?.title ?? "",
                                style: Styles.textStyle16SemiBold.copyWith(
                                  color: AppColors.kscandryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          details?.location ?? "",
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.person_outline,
                          details?.advisorName ?? "",
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          details?.date.toString() ?? "",
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Price Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: context.responsiveWidth(20),
                    top: context.responsiveHeight(24),
                    bottom: context.responsiveHeight(10),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      context.tr('price_di'),
                      style: Styles.textStyle16SemiBold.copyWith(
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ),

              /// Price Card
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(16),
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildSectionCard(
                    context: context,
                    child: Column(
                      children: [
                        _buildPriceRow(
                          context.tr('ticket_price'),
                          "${details?.price ?? 0} ${context.tr('sar')}",
                        ),
                        _buildPriceRow(
                          context.tr('fees'),
                          "${details?.tax ?? 0} ${context.tr('sar')}",
                        ),
                        _buildPriceRow(
                          context.tr('tax'),
                          "${0} ${context.tr('sar')}",
                        ),
                        _buildPriceRow(
                          context.tr('discount'),
                          "-${details?.discount ?? 0} ${context.tr('sar')}",
                        ),
                        const Divider(thickness: 0.3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('total'),
                              style: Styles.textStyle16SemiBold,
                            ),
                            Text(
                              "${details?.total ?? 0} ${context.tr('sar')}",
                              style: Styles.textStyle18Bold.copyWith(
                                color: const Color(0xFFD65A73),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Payment
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: context.responsiveWidth(20),
                    top: context.responsiveHeight(24),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      context.tr('payment_method'),
                      style: Styles.textStyle16SemiBold.copyWith(
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(16),
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildSectionCard(
                    context: context,
                    child: Text(
                      context.tr('payment_method'),
                      style: Styles.textStyle14SemiBold,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(height: context.responsiveHeight(40)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.responsiveWidth(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Styles.textStyle12.copyWith(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String title, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Styles.textStyle16.copyWith(color: AppColors.kgreyColor),
          ),
          Text(
            price,
            style: Styles.textStyle16.copyWith(color: AppColors.kgreyColor),
          ),
        ],
      ),
    );
  }
}

class TicketDetailsShimmer extends StatelessWidget {
  const TicketDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: CustomScrollView(
        slivers: [
          const SliverAppBar(backgroundColor: Colors.transparent, elevation: 0),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const ShimmerBox(width: 200, height: 200),
                const SizedBox(height: 30),
              ],
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(child: _ShimmerSection()),
          ),
        ],
      ),
    );
  }
}

class _ShimmerSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ShimmerBox(width: 200, height: 18),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 14),
          SizedBox(height: 8),
          ShimmerBox(width: double.infinity, height: 14),
          SizedBox(height: 8),
          ShimmerBox(width: 180, height: 14),
        ],
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerBox({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
