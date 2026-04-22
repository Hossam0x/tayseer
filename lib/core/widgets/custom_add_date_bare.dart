import 'package:intl/intl.dart';

import '../../my_import.dart';

class CustomAddDateBare extends StatefulWidget {
  const CustomAddDateBare({super.key});

  @override
  State<CustomAddDateBare> createState() => _CustomAddDateBareState();
}

class _CustomAddDateBareState extends State<CustomAddDateBare> {
  DateTime _selectedDate = DateTime.now();

  // Generate a list of dates: 15 days back + today + 15 days ahead
  late final List<DateTime> _dates = List.generate(
    31,
    (i) => DateTime.now()
        .subtract(const Duration(days: 15))
        .add(Duration(days: i)),
  );

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d MMMM y', 'ar').format(now);
    final double itemWidth = context.width * 0.19;
    final double itemHeight = context.height * 0.1;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formattedDate, style: Styles.textStyle12),
          const SizedBox(height: 5),
          Text(
            'اليوم',
            style: Styles.textStyle18.copyWith(color: Colors.green),
          ),
          SizedBox(
            height: itemHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              reverse: true, // RTL feel for Arabic
              itemCount: _dates.length,
              itemBuilder: (context, index) {
                final date = _dates[index];
                final isSelected = DateUtils.isSameDay(date, _selectedDate);
                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: itemWidth,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.ksecondaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE', 'ar').format(date),
                          style: Styles.textStyle18.copyWith(
                            fontSize: 14,
                            color: isSelected ? AppColors.kprimaryColor : null,
                          ),
                        ),
                        Text(
                          DateFormat('d', 'ar').format(date),
                          style: Styles.textStyle18.copyWith(
                            fontSize: 16,
                            color: isSelected ? AppColors.kprimaryColor : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
