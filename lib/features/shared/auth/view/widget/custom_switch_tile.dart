import 'package:intl/intl.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';

class CustomSwitchTile extends StatelessWidget {
  final String dayKey;
  final String title;

  const CustomSwitchTile({
    super.key,
    required this.dayKey,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();
        final isEnabled = state.isDayEnabled(dayKey);
        final range = state.availableDays[dayKey];

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              /// Switch Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: Styles.textStyle18),

                  Switch(
                    value: isEnabled,
                    onChanged: (_) => cubit.toggleDay(dayKey),
                    activeTrackColor: AppColors.kprimaryColor,
                    inactiveTrackColor: HexColor('b3b3b3'),
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.white,
                    trackOutlineColor: WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    trackOutlineWidth: WidgetStatePropertyAll(0),
                  ),
                ],
              ),

              /// Animated Fields
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                child: isEnabled && range != null
                    ? Column(
                        children: [
                          SizedBox(height: context.responsiveHeight(5)),
                          TimeRangeFields(
                            from: range.from,
                            to: range.to,
                            onFromTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: range.from,
                              );
                              if (time != null) {
                                cubit.updateFromTime(dayKey, time);
                              }
                            },
                            onToTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: range.to,
                              );
                              if (time != null) {
                                cubit.updateToTime(dayKey, time);
                              }
                            },
                          ),
                        ],
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TimeRangeFields extends StatelessWidget {
  final TimeOfDay from;
  final TimeOfDay to;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;

  const TimeRangeFields({
    super.key,
    required this.from,
    required this.to,
    required this.onFromTap,
    required this.onToTap,
  });

  String _format(TimeOfDay time) {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a', 'ar').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            Text(context.tr('from'), style: Styles.textStyle16),
            TimeField(value: _format(from), onTap: onFromTap),
          ],
        ),
        Row(
          children: [
            Text(context.tr('to'), style: Styles.textStyle16),

            TimeField(value: _format(to), onTap: onToTap),
          ],
        ),
      ],
    );
  }
}

class TimeField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const TimeField({super.key, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(20),
          vertical: context.responsiveHeight(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: HexColor('fcffff'),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 2,
            color: HexColor('eb7a91').withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.access_time,
              size: 18,
              color: HexColor('eb7a91').withOpacity(0.5),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 1.5,
              height: context.height * 0.04,
              color: Colors.grey.withOpacity(0.3),
            ),
            Text(
              value,
              style: Styles.textStyle14.copyWith(
                color: HexColor('eb7a91').withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
