import 'package:fl_chart/fl_chart.dart';
import 'package:tayseer/my_import.dart';

class AnalyticsChart extends StatelessWidget {
  const AnalyticsChart({super.key});

  // Define the colors exactly as seen in the image
  final Color _pinkColor = const Color(0xFFF08095);
  final Color _burgundyColor = const Color(0xFF7D1C2E);
  final Color _lightBlueColor = const Color(0xFF4DB6F6);
  final Color _darkBlueColor = const Color(0xFF0D5EAF);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 139,
      // The image has a subtle gradient background (Pinkish left -> Bluish right)
      child: BarChart(
        BarChartData(
          // Define Axis ranges
          maxY: 32,
          minY: 0,

          // Grid styling (vertical and horizontal lines)
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 8, // Ticks: 0, 8, 16, 24, 32
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey.shade400, strokeWidth: 1),
            getDrawingVerticalLine: (value) =>
                FlLine(color: Colors.grey.shade400, strokeWidth: 1),
          ),

          // Border styling (Box around the chart)
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade400),
          ),

          // Tooltip configuration (optional)
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.blueGrey,
            ),
          ),

          // Axis Titles configuration
          titlesData: FlTitlesData(
            show: true,
            // Hide Top and Right titles
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            // Y-Axis (Left)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 8,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.blackColor,
                    ),
                    textAlign: TextAlign.left,
                  );
                },
              ),
            ),

            // X-Axis (Bottom - Arabic Labels)
            // X-Axis (Bottom - Arabic Labels)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'المشاهدات'; // Views
                      break;
                    case 1:
                      text = 'الزيارات'; // Visits
                      break;
                    case 2:
                      text = 'متابعين جدد'; // New Followers
                      break;
                    case 3:
                      text = 'التفاعلات'; // Interactions
                      break;
                    default:
                      text = '';
                  }
                  return SideTitleWidget(
                    meta:
                        meta, // <--- CHANGED: Pass 'meta' directly instead of 'axisSide'
                    space: 8,
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

          // The Data Bars
          barGroups: [
            _makeGroupData(0, 28, 19, 15, 25), // Data for Views
            _makeGroupData(1, 17, 7, 13, 1), // Data for Visits
            _makeGroupData(2, 12, 14, 3, 29), // Data for New Followers
            _makeGroupData(3, 12, 16, 5, 18), // Data for Interactions
          ],
        ),
      ),
    );
  }

  // Helper function to create a group of 4 bars
  BarChartGroupData _makeGroupData(
    int x,
    double pinkVal,
    double burgundyVal,
    double lightBlueVal,
    double darkBlueVal,
  ) {
    const double width = 12; // Width of individual bars

    return BarChartGroupData(
      x: x,
      barsSpace: 2, // Space between bars within the same group
      barRods: [
        _makeRod(pinkVal, _pinkColor, width),
        _makeRod(burgundyVal, _burgundyColor, width),
        _makeRod(lightBlueVal, _lightBlueColor, width),
        _makeRod(darkBlueVal, _darkBlueColor, width),
      ],
    );
  }

  BarChartRodData _makeRod(double y, Color color, double width) {
    return BarChartRodData(
      toY: y,
      color: color,
      width: width,
      borderRadius: BorderRadius.zero, // Square edges like the image
    );
  }
}
