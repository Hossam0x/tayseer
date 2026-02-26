import 'package:tayseer/features/shared/reports/presentation/view/widgets/reports_view_body.dart';
import 'package:tayseer/my_import.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CustomBackground(child: ReportsViewBody()));
  }
}
