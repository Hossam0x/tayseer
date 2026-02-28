import '../../../../my_import.dart';
import 'widgets/home_view_body.dart';

class HomeView extends StatefulWidget {
  final Function(bool isScrollingDown)? onScroll;

  const HomeView({super.key, this.onScroll});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<HomeViewBodyState> _homeViewBodyKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LayoutCubit, LayoutState>(
          listenWhen: (previous, current) =>
              previous.scrollToTopTrigger != current.scrollToTopTrigger &&
              previous.refreshHomeTrigger == current.refreshHomeTrigger &&
              current.currentIndex == 0,
          listener: (context, state) {
            // لما يتغير الـ scrollToTopTrigger بس نعمل scroll لفوق
            _homeViewBodyKey.currentState?.scrollToTop();
          },
        ),
        BlocListener<LayoutCubit, LayoutState>(
          listenWhen: (previous, current) =>
              previous.refreshHomeTrigger != current.refreshHomeTrigger,
          listener: (context, state) {
            // لما يتغير الـ refreshHomeTrigger نعمل scroll لفوق + ريفريش
            _homeViewBodyKey.currentState?.scrollToTopAndRefresh();
          },
        ),
      ],
      child: Scaffold(
        body: AdvisorBackground(
          child: HomeViewBody(key: _homeViewBodyKey, onScroll: widget.onScroll),
        ),
      ),
    );
  }
}
