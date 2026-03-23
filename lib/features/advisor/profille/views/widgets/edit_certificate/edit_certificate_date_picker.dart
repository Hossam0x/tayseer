import 'package:tayseer/features/advisor/profille/views/cubit/certificates/edit_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/edit_certificate_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:intl/intl.dart';

class EditCertificateDatePicker extends StatelessWidget {
  const EditCertificateDatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditCertificateCubit, EditCertificateState>(
      buildWhen: (previous, current) => previous.date != current.date,
      builder: (context, state) {
        final cubit = context.read<EditCertificateCubit>();
        return GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: state.date ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.kprimaryColor,
                      onPrimary: Colors.white,
                      onSurface: AppColors.secondary800,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) cubit.updateDate(picked);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.kWhiteColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.primary100),
            ),
            child: Row(
              children: [
                AppImage(AssetsData.calenderIcon, width: 22.h),
                SizedBox(
                  width: 30,
                  height: 20,
                  child: VerticalDivider(color: AppColors.primary100, thickness: 2),
                ),
                Expanded(
                  child: Text(
                    state.date != null
                        ? DateFormat('yyyy/MM/dd').format(state.date!)
                        : context.tr('choose_date'),
                    style: Styles.textStyle14.copyWith(
                      color: state.date == null
                          ? AppColors.primary200
                          : AppColors.secondary800,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
