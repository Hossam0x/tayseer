import 'package:tayseer/features/user/my_space/presentation/view/My_Space_Consultatioin_Content.dart';
import 'package:tayseer/features/user/my_space/presentation/view/My_Space_Marriage.dart';
import 'package:tayseer/my_import.dart';

class ConsultationStandalonePage extends StatelessWidget {
  const ConsultationStandalonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdvisorBackground(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 16.h),
          child: Column(
            children: [
              Text(context.tr("Consulting"), style: Styles.textStyle20Bold),
              SizedBox(height: 24.h),
              const Expanded(
                child: MySpaceConsultationContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}