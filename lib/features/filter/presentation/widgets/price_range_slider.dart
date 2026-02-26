import '../../../../my_import.dart';
import '../cubit/advisor_filter_cubit.dart';
import '../cubit/advisor_filter_state.dart';

class PriceRangeSlider extends StatelessWidget {
  const PriceRangeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvisorFilterCubit, AdvisorFilterState>(
      buildWhen: (previous, current) =>
          previous.priceRange != current.priceRange,
      builder: (context, state) {
        return Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                const double thumbRadius = 12.0;
                double trackWidth = constraints.maxWidth - (thumbRadius * 2);

                double startPos =
                    thumbRadius + (state.priceRange.start / 100) * trackWidth;
                double endPos =
                    thumbRadius + (state.priceRange.end / 100) * trackWidth;

                return Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        rangeThumbShape: const RoundRangeSliderThumbShape(
                          enabledThumbRadius: thumbRadius,
                          elevation: 3,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 20,
                        ),
                        activeTrackColor: AppColors.kprimaryColor,
                        inactiveTrackColor: AppColors.primary100,
                        thumbColor: Colors.white,
                        trackHeight: 4.h,
                      ),
                      child: RangeSlider(
                        values: state.priceRange,
                        min: 0,
                        max: 100,
                        onChanged: (values) {
                          context.read<AdvisorFilterCubit>().updatePriceRange(
                            values,
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 35.h,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          PositionedDirectional(
                            start: startPos,
                            child: FractionalTranslation(
                              translation: const Offset(0.4, 0),
                              child: _buildValueLabel(
                                state.priceRange.start.round().toString(),
                              ),
                            ),
                          ),
                          PositionedDirectional(
                            start: endPos,
                            child: FractionalTranslation(
                              translation: const Offset(0.4, 0),
                              child: _buildValueLabel(
                                state.priceRange.end.round().toString(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildValueLabel(String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.secondary100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        value,
        style: Styles.textStyle12SemiBold.copyWith(
          color: AppColors.kprimaryColor,
        ),
      ),
    );
  }
}
