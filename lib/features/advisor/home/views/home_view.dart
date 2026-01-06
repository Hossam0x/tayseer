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
    return BlocListener<ALayoutCubit, ALayoutState>(
      listenWhen:
          (previous, current) =>
              previous.scrollToTopTrigger != current.scrollToTopTrigger,
      listener: (context, state) {
        // لما يتغير الـ scrollToTopTrigger نعمل scroll لفوق
        _homeViewBodyKey.currentState?.scrollToTop();
      },
      child: Scaffold(
        body: AdvisorBackground(
          child: HomeViewBody(key: _homeViewBodyKey, onScroll: widget.onScroll),
        ),
      ),
    );
  }
}
