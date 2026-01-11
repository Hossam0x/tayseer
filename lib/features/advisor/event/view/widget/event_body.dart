import 'package:tayseer/core/widgets/custom_content_switcher.dart';
import 'package:tayseer/features/advisor/event/view/widget/all_events_content.dart';
import 'package:tayseer/features/advisor/event/view/widget/custom_sliver_app_bar.dart';
import 'package:tayseer/features/advisor/event/view/widget/my_events_content.dart';
import 'package:tayseer/features/advisor/event/view_model/events_cubit.dart';
import 'package:tayseer/my_import.dart';

class EventBody extends StatefulWidget {
  const EventBody({super.key});

  @override
  State<EventBody> createState() => _EventBodyState();
}

class _EventBodyState extends State<EventBody> {
  int selectedIndex = 0;
  @override
  initState() {
    super.initState();
    // Preload both event lists
    final eventsCubit = context.read<EventsCubit>();
    eventsCubit.getAdvisorEvents();
    eventsCubit.getAllEvents();
  }

  @override
  Widget build(BuildContext context) {
    final options = [context.tr('my_event'), context.tr('all_events')];

    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        CustomSliverAppBarEvent(title: context.tr('event_title')),

        SliverToBoxAdapter(
          child: ContentSwitcher(
            options: options,
            onOptionSelected: (selectedOption) {
              final newIndex = options.indexOf(selectedOption);
              if (newIndex != -1) setState(() => selectedIndex = newIndex);
            },
          ),
        ),

        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              final slideAnim = Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slideAnim, child: child),
              );
            },
            child: selectedIndex == 0
                ? MyEventsContent(
                    key: const ValueKey('my'),
                    eventsCubit: context.read<EventsCubit>(),
                  )
                : AllEventsContent(key: const ValueKey('all')),
          ),
        ),
      ],
    );
  }
}
