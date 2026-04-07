import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_cubit.dart';
import 'package:tayseer/my_import.dart';

class SummaryEmptyState extends StatelessWidget {
  const SummaryEmptyState({super.key, required this.cubit});

  final UpdateOfferingsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.pink.shade100, width: 2),
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: Colors.pink.shade200,
              size: 48,
            ),
          ),
          Gap(16.h),
          Text(
            context.tr('no_sessions_added_yet'),
            style: Styles.textStyle16.copyWith(
              color: AppColors.kprimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(24.h),
          CustomBotton(
            width: context.width * .65,
            title: '+ ${context.tr('add_another_country')}',
            useGradient: true,
            onPressed: () => cubit.goToAddAnotherCountry(),
          ),
        ],
      ),
    );
  }
}
