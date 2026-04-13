import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/saved_posts_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts/saved_posts_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/saved_posts/saved_posts_body.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/my_import.dart';

class SavedPostsView extends StatelessWidget {
  const SavedPostsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SavedPostsCubit(
        getIt<SavedPostsRepository>(),
        getIt<HomeRepository>(),
      ),
      child: const _SavedPostsScaffold(),
    );
  }
}

class _SavedPostsScaffold extends StatelessWidget {
  const _SavedPostsScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
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
                Gap(30.h),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 15.h,
                  ),
                  child: SimpleAppBar(title: context.tr('saved_posts')),
                ),
                const Expanded(child: SavedPostsBody()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
