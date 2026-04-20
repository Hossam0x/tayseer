// features/advisor/layout/views/a_layout_view.dart
import 'package:flutter/foundation.dart';
import 'package:tayseer/features/user/layout/view/widgets/user_layout_view_body.dart';
import 'package:tayseer/my_import.dart';

class UserLayoutView extends StatelessWidget {
  const UserLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => LayoutCubit(),
        child: const UserLayOutViewBody(),
      ),
      // زر اختبار الأصوات - مؤقت للتطوير
      // floatingActionButton: kDebugMode
      //     ? FloatingActionButton(
      //         onPressed: () {
      //           Navigator.pushNamed(context, AppRouter.kAudioTestView);
      //         },
      //         backgroundColor: Colors.orange,
      //         child: const Icon(Icons.volume_up, color: Colors.white),
      //       )
      //     : null,
    );
  }
}
