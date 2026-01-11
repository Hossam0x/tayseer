import 'package:tayseer/core/widgets/custom_content_switcher.dart';
import 'package:tayseer/features/advisor/session/view/widget/custom_sliver_app_bar_session.dart';
import 'package:tayseer/my_import.dart';

class SessionViewBody extends StatefulWidget {
  const SessionViewBody({super.key});

  @override
  State<SessionViewBody> createState() => _SessionViewBodyState();
}

class _SessionViewBodyState extends State<SessionViewBody> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final options = [context.tr('conversations'), context.tr('session')];

    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        CustomSliverAppBarSession(title: context.tr('session')),
        SliverToBoxAdapter(
          child: ContentSwitcher(
            options: options,
            onOptionSelected: (selectedOption) {
              final newIndex = options.indexOf(selectedOption);
              if (newIndex != -1) setState(() => selectedIndex = newIndex);
            },
          ),
        ),
      ],
    );
  }
}
