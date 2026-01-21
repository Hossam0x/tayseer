import 'package:fl_chart/fl_chart.dart';
import 'package:tayseer/my_import.dart';

class AnalyticsChart extends StatelessWidget {
  const AnalyticsChart({super.key});

  // Colors
  final Color _pinkColor = const Color(0xFFF08095);
  final Color _burgundyColor = const Color(0xFF7D1C2E);
  final Color _lightBlueColor = const Color(0xFF4DB6F6);
  final Color _darkBlueColor = const Color(0xFF0D5EAF);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160.h,
      child: BarChart(
        BarChartData(
          maxY: 32,
          minY: 0,

          /// Grid
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 8,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.shade400, strokeWidth: 1.w),
            getDrawingVerticalLine: (value) =>
                FlLine(color: Colors.grey.shade400, strokeWidth: 1.w),
          ),

          /// Border
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade400, width: 1.w),
          ),

          /// Tooltip
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.blueGrey,
            ),
          ),

          /// Titles
          titlesData: FlTitlesData(
            show: true,

            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            /// Y Axis
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 8,
                reservedSize: 30.w,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.blackColor,
                    ),
                  );
                },
              ),
            ),

            /// X Axis
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40.h,
                getTitlesWidget: (value, meta) {
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'المشاهدات';
                      break;
                    case 1:
                      text = 'الزيارات';
                      break;
                    case 2:
                      text = 'متابعين جدد';
                      break;
                    case 3:
                      text = 'التفاعلات';
                      break;
                    default:
                      text = '';
                  }

                  return SideTitleWidget(
                    meta: meta,
                    space: 8.h,
                    child: Text(
                      text,
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.blackColor,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          /// Bars
          barGroups: [
            _makeGroupData(0, 28, 19, 15, 25),
            _makeGroupData(1, 17, 7, 13, 1),
            _makeGroupData(2, 12, 14, 3, 29),
            _makeGroupData(3, 12, 16, 5, 18),
          ],
        ),
      ),
    );
  }

  /// Group of bars
  BarChartGroupData _makeGroupData(
    int x,
    double pinkVal,
    double burgundyVal,
    double lightBlueVal,
    double darkBlueVal,
  ) {
    final double barWidth = 12.w;

    return BarChartGroupData(
      x: x,
      barsSpace: 2.w,
      barRods: [
        _makeRod(pinkVal, _pinkColor, barWidth),
        _makeRod(burgundyVal, _burgundyColor, barWidth),
        _makeRod(lightBlueVal, _lightBlueColor, barWidth),
        _makeRod(darkBlueVal, _darkBlueColor, barWidth),
      ],
    );
  }

  BarChartRodData _makeRod(double y, Color color, double width) {
    return BarChartRodData(
      toY: y,
      color: color,
      width: width,
      borderRadius: BorderRadius.zero,
    );
  }
}
