import 'package:flutter/material.dart';

class YearPickerDialog extends StatefulWidget {
  final int initialYear;

  const YearPickerDialog({super.key, required this.initialYear});

  @override
  State<YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<YearPickerDialog> {
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختر سنة التخرج'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: YearPicker(
          firstDate: DateTime(1950),
          lastDate: DateTime(DateTime.now().year),
          initialDate: DateTime(selectedYear),
          selectedDate: DateTime(selectedYear),
          onChanged: (DateTime dateTime) {
            setState(() {
              selectedYear = dateTime.year;
            });
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selectedYear),
          child: const Text('تأكيد'),
        ),
      ],
    );
  }
}
