import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/widgets/custom_content_switcher.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/shared/event/view/widget/all_events_content.dart';
import 'package:tayseer/features/shared/event/view/widget/my_events_content.dart';
import 'package:tayseer/features/shared/event/view_model/events_cubit.dart';
import 'package:tayseer/my_import.dart';

class EventBody extends StatefulWidget {
  const EventBody({super.key});

  @override
  State<EventBody> createState() => _EventBodyState();
}

class _EventBodyState extends State<EventBody> {
  int selectedIndex = 0;

  // 👇 هنا بنحدد هل المستخدم عادي ولا مستشار
  bool get _isUser => selectedUserType == UserTypeEnum.user;

  @override
  initState() {
    super.initState();
    final eventsCubit = context.read<EventsCubit>();

    if (_isUser) {
      // ✅ لو يوزر عادي → نجيب كل الأحداث بس
      eventsCubit.getAllEvents();
    } else {
      // ✅ لو مستشار → نجيب الاتنين
      eventsCubit.getAdvisorEvents();
      eventsCubit.getAllEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = [context.tr('my_event'), context.tr('all_events')];

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 105.h,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AssetsData.homeBarBackgroundImage),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16.h,
                left: 20.w,
                right: 20.w,
              ),
              child: SimpleAppBar(
                isLargeTitle: true,
                title: context.tr('event_title'),
                isUserTicket: _isUser,
              ),
            ),

            // ✅ الـ ContentSwitcher يظهر بس لو مستشار
            if (!_isUser)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: ContentSwitcher(
                  options: options,
                  onOptionSelected: (selectedOption) {
                    final newIndex = options.indexOf(selectedOption);
                    if (newIndex != -1)
                      setState(() => selectedIndex = newIndex);
                  },
                ),
              ),

            // ✅ المحتوى
            Expanded(
              child: _isUser
                  // 👇 لو يوزر عادي → AllEventsContent مباشرة بدون AnimatedSwitcher
                  ? const AllEventsContent(key: ValueKey('all'))
                  // 👇 لو مستشار → التبديل بين MyEvents و AllEvents
                  : AnimatedSwitcher(
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
                          child: SlideTransition(
                            position: slideAnim,
                            child: child,
                          ),
                        );
                      },
                      child: selectedIndex == 0
                          ? MyEventsContent(
                              key: const ValueKey('my'),
                              eventsCubit: context.read<EventsCubit>(),
                            )
                          : const AllEventsContent(key: ValueKey('all')),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
