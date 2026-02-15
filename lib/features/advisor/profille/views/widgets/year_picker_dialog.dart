import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/year_picker_cubit.dart';

class YearPickerDialog extends StatelessWidget {
  final int initialYear;

  const YearPickerDialog({super.key, required this.initialYear});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => YearPickerCubit(initialYear),
      child: Builder(
        builder: (context) {
          return AlertDialog(
            title: const Text('اختر سنة التخرج'),
            content: SizedBox(
              width: 300,
              height: 300,
              child: BlocBuilder<YearPickerCubit, int>(
                builder: (context, selectedYear) {
                  return YearPicker(
                    firstDate: DateTime(1950),
                    lastDate: DateTime(DateTime.now().year),
                    initialDate: DateTime(selectedYear),
                    selectedDate: DateTime(selectedYear),
                    onChanged: (DateTime dateTime) {
                      context.read<YearPickerCubit>().selectYear(dateTime.year);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              BlocBuilder<YearPickerCubit, int>(
                builder: (context, selectedYear) {
                  return TextButton(
                    onPressed: () => Navigator.pop(context, selectedYear),
                    child: const Text('تأكيد'),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
