import 'package:intl/intl.dart';

import '../../my_import.dart';

class CustomAddDateBare extends StatefulWidget {
  const CustomAddDateBare({super.key});

  @override
  State<CustomAddDateBare> createState() => _CustomAddDateBareState();
}

class _CustomAddDateBareState extends State<CustomAddDateBare> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d MMMM y', 'ar').format(now);
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
          DatePicker(
            DateTime.now(),
            width: context.width * 0.19,
            height: context.height * 0.1,

            initialSelectedDate: _selectedDate,
            dayTextStyle: Styles.textStyle18.copyWith(fontSize: 14),
            monthTextStyle: const TextStyle(fontSize: 0),
            dateTextStyle: Styles.textStyle18.copyWith(fontSize: 16),
            selectionColor: AppColors.ksecondaryColor,
            selectedTextColor: AppColors.kprimaryColor,
            locale: 'ar',
            onDateChange: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
        ],
      ),
    );
  }
}
