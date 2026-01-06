import 'package:tayseer/core/widgets/custom_content_switcher.dart';
import 'package:tayseer/features/advisor/event/view/widget/custom_sliver_app_bar.dart';
import 'package:tayseer/features/advisor/event/view/widget/empty_event_section.dart';
import 'package:tayseer/my_import.dart';

class EventBody extends StatefulWidget {
  const EventBody({super.key});

  @override
  State<EventBody> createState() => _EventBodyState();
}

class _EventBodyState extends State<EventBody> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final options = [context.tr('my_event'), context.tr('all_events')];

    return CustomScrollView(
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
            duration: const Duration(milliseconds: 350),
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
                ? _EventsContent(
                    key: const ValueKey('my'),
                    title: context.tr('my_events'),
                  )
                : _EventsContent(
                    key: const ValueKey('all'),
                    title: context.tr('all_events'),
                  ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomBotton(
              useGradient: true,
              title: context.tr('creat_event'),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class _EventsContent extends StatelessWidget {
  const _EventsContent({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: context.responsiveHeight(20),
        bottom: context.responsiveHeight(20),
      ),
      child: Column(
        children: [
          Text(title, style: Styles.textStyle18Bold),
          Gap(context.responsiveHeight(3)),

          // Placeholder content (keeps the same look as EmptyEventSection)
          AppImage(
            AssetsData.kEmptyEventImage,
            height: context.height * 0.3,
            fit: BoxFit.contain,
          ),
          Gap(context.responsiveHeight(5)),
          Text(
            context.tr('no_events_title'),
            textAlign: TextAlign.center,
            style: Styles.textStyle16.copyWith(color: AppColors.kgreyColor),
          ),
        ],
      ),
    );
  }
}
