import 'package:fl_chart/fl_chart.dart';
import 'package:tayseer/features/advisor/profille/data/models/analytics_model.dart';
import 'package:tayseer/features/advisor/profille/data/models/weekly_day.dart';
import 'package:tayseer/my_import.dart';

class AnalyticsChart extends StatelessWidget {
  final List<ChartData> chartData;

  const AnalyticsChart({super.key, required this.chartData});

  // Colors for weeks
  final Color _week1Color = const Color(0xFFF08095); // Week 1
  final Color _week2Color = const Color(0xFF7D1C2E); // Week 2
  final Color _week3Color = const Color(0xFF4DB6F6); // Week 3
  final Color _week4Color = const Color(0xFF0D5EAF); // Week 4

  @override
  Widget build(BuildContext context) {
    // تجميع البيانات على 4 أسابيع لكل فئة
    final weeklyData = _calculateWeeklyData();

    return Column(
      children: [
        Gap(40.h),
        // Legend for weeks
        // _buildWeekLegend(),
        Gap(8.h),

        SizedBox(
          height: 160.h,
          child: BarChart(
            BarChartData(
              maxY: _calculateMaxValue(weeklyData),
              minY: 0,

              /// Grid
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: _calculateMaxValue(weeklyData) / 4,
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
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  // tooltipBgColor: Colors.blueGrey.withOpacity(0.9),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    String category;
                    String week;
                    double value;

                    switch (groupIndex) {
                      case 0:
                        category = 'المشاهدات';
                        break;
                      case 1:
                        category = 'الزيارات';
                        break;
                      case 2:
                        category = 'متابعين جدد';
                        break;
                      case 3:
                        category = 'التفاعلات';
                        break;
                      default:
                        category = '';
                    }

                    switch (rodIndex) {
                      case 0:
                        week = 'الأسبوع 1';
                        value = _getWeekValue(weeklyData, groupIndex, 0);
                        break;
                      case 1:
                        week = 'الأسبوع 2';
                        value = _getWeekValue(weeklyData, groupIndex, 1);
                        break;
                      case 2:
                        week = 'الأسبوع 3';
                        value = _getWeekValue(weeklyData, groupIndex, 2);
                        break;
                      case 3:
                        week = 'الأسبوع 4';
                        value = _getWeekValue(weeklyData, groupIndex, 3);
                        break;
                      default:
                        week = '';
                        value = 0;
                    }

                    return BarTooltipItem(
                      '$category\n$week: ${value.toInt()}',
                      TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
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
                    interval: _calculateMaxValue(weeklyData) / 4,
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

              /// Bars - 4 مجموعات (فئات) مع 4 أعمدة لكل مجموعة (أسابيع)
              barGroups: [
                // المشاهدات - 4 أعمدة (أسابيع)
                _makeGroupData(
                  0,
                  _getWeekValue(weeklyData, 0, 0), // Week 1
                  _getWeekValue(weeklyData, 0, 1), // Week 2
                  _getWeekValue(weeklyData, 0, 2), // Week 3
                  _getWeekValue(weeklyData, 0, 3), // Week 4
                ),
                // الزيارات - 4 أعمدة (أسابيع)
                _makeGroupData(
                  1,
                  _getWeekValue(weeklyData, 1, 0), // Week 1
                  _getWeekValue(weeklyData, 1, 1), // Week 2
                  _getWeekValue(weeklyData, 1, 2), // Week 3
                  _getWeekValue(weeklyData, 1, 3), // Week 4
                ),
                // متابعين جدد - 4 أعمدة (أسابيع)
                _makeGroupData(
                  2,
                  _getWeekValue(weeklyData, 2, 0), // Week 1
                  _getWeekValue(weeklyData, 2, 1), // Week 2
                  _getWeekValue(weeklyData, 2, 2), // Week 3
                  _getWeekValue(weeklyData, 2, 3), // Week 4
                ),
                // التفاعلات - 4 أعمدة (أسابيع)
                _makeGroupData(
                  3,
                  _getWeekValue(weeklyData, 3, 0), // Week 1
                  _getWeekValue(weeklyData, 3, 1), // Week 2
                  _getWeekValue(weeklyData, 3, 2), // Week 3
                  _getWeekValue(weeklyData, 3, 3), // Week 4
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// بناء Legend للأسابيع
  // Widget _buildWeekLegend() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       _buildLegendItem(_week1Color, 'الأسبوع 1'),
  //       _buildLegendItem(_week2Color, 'الأسبوع 2'),
  //       _buildLegendItem(_week3Color, 'الأسبوع 3'),
  //       _buildLegendItem(_week4Color, 'الأسبوع 4'),
  //     ],
  //   );
  // }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        Gap(4.w),
        Text(
          text,
          style: Styles.textStyle12.copyWith(color: AppColors.blackColor),
        ),
      ],
    );
  }

  /// نموذج بيانات الأسبوع لكل فئة

  /// تجميع البيانات على 4 أسابيع لكل فئة
  List<CategoryWeeklyData> _calculateWeeklyData() {
    // إذا لم توجد بيانات، نرجع بيانات صفرية
    if (chartData.isEmpty) {
      return List.generate(
        4,
        (_) => CategoryWeeklyData(weeksData: [0, 0, 0, 0]),
      );
    }

    // ترتيب البيانات من الأقدم للأحدث
    final sortedData = List<ChartData>.from(chartData)
      ..sort((a, b) => a.date.compareTo(b.date));

    // حساب تواريخ الأسابيع الأربعة
    final now = DateTime.now();
    final week4Start = now.subtract(const Duration(days: 7));
    final week3Start = now.subtract(const Duration(days: 14));
    final week2Start = now.subtract(const Duration(days: 21));
    final week1Start = now.subtract(const Duration(days: 28));

    // تجميع البيانات لكل فئة لكل أسبوع
    final List<CategoryWeeklyData> result = [];

    // فئات البيانات: views, visits, followers, interactions
    for (int category = 0; category < 4; category++) {
      List<int> weekValues = [0, 0, 0, 0];

      for (final data in sortedData) {
        final date = data.date;
        int value;

        // تحديد قيمة الفئة
        switch (category) {
          case 0: // المشاهدات
            value = data.views;
            break;
          case 1: // الزيارات
            value = data.visits;
            break;
          case 2: // متابعين جدد
            value = data.followers;
            break;
          case 3: // التفاعلات
            value = data.interactions;
            break;
          default:
            value = 0;
        }

        // تحديد الأسبوع المناسب
        if (date.isAfter(week4Start) && date.isBefore(now)) {
          // الأسبوع 4 (الأحدث)
          weekValues[3] += value;
        } else if (date.isAfter(week3Start) && date.isBefore(week4Start)) {
          // الأسبوع 3
          weekValues[2] += value;
        } else if (date.isAfter(week2Start) && date.isBefore(week3Start)) {
          // الأسبوع 2
          weekValues[1] += value;
        } else if (date.isAfter(week1Start) && date.isBefore(week2Start)) {
          // الأسبوع 1 (الأقدم)
          weekValues[0] += value;
        }
      }

      result.add(CategoryWeeklyData(weeksData: weekValues));
    }

    return result;
  }

  /// الحصول على قيمة أسبوع محدد لفئة محددة
  double _getWeekValue(
    List<CategoryWeeklyData> data,
    int categoryIndex,
    int weekIndex,
  ) {
    if (data.length <= categoryIndex ||
        data[categoryIndex].weeksData.length <= weekIndex) {
      return 0;
    }

    return data[categoryIndex].weeksData[weekIndex].toDouble();
  }

  /// حساب القيمة القصوى للرسم البياني
  double _calculateMaxValue(List<CategoryWeeklyData> data) {
    double max = 0;

    for (var category in data) {
      for (var value in category.weeksData) {
        if (value > max) {
          max = value.toDouble();
        }
      }
    }

    // إضافة هامش 20% للقيمة القصوى
    return max == 0 ? 10 : max * 1;
  }

  /// Group of bars (4 أعمدة لكل فئة تمثل الأسابيع)
  BarChartGroupData _makeGroupData(
    int categoryIndex,
    double week1Val,
    double week2Val,
    double week3Val,
    double week4Val,
  ) {
    final double barWidth = 15.w;

    return BarChartGroupData(
      x: categoryIndex,
      barsSpace: 3.w,
      barRods: [
        _makeRod(week1Val, _week1Color, barWidth),
        _makeRod(week2Val, _week2Color, barWidth),
        _makeRod(week3Val, _week3Color, barWidth),
        _makeRod(week4Val, _week4Color, barWidth),
      ],
    );
  }

  BarChartRodData _makeRod(double y, Color color, double width) {
    return BarChartRodData(
      toY: y,
      color: color,
      width: width,
      borderRadius: BorderRadius.circular(0.r),
    );
  }
}
