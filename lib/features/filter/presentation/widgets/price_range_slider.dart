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
        return LayoutBuilder(
          builder: (context, constraints) {
            const double thumbRadius = 12;

            double trackWidth = constraints.maxWidth - (thumbRadius * 2);

            double startValue = state.priceRange.start;
            double endValue = state.priceRange.end;

            double startPos = thumbRadius + (startValue / 100) * trackWidth;

            double endPos = thumbRadius + (endValue / 100) * trackWidth;

            /// عكس الحساب في حالة RTL
            if (isArabic) {
              startPos = constraints.maxWidth - startPos;
              endPos = constraints.maxWidth - endPos;
            }

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
                      Positioned(
                        left: startPos,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, 0),
                          child: _buildValueLabel(
                            startValue.round().toString(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: endPos,
                        child: FractionalTranslation(
                          translation: const Offset(-0.5, 0),
                          child: _buildValueLabel(endValue.round().toString()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
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
