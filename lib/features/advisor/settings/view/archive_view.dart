import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/chats_tab_view.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/posts_tab_view.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/stories_tab_view.dart';
import 'package:tayseer/my_import.dart';

class ArchiveView extends StatelessWidget {
  const ArchiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ArchivedChatsCubit>(
          create: (_) => getIt<ArchivedChatsCubit>(),
        ),
        BlocProvider<ArchivedPostsCubit>(
          create: (_) => getIt<ArchivedPostsCubit>(),
        ),
        BlocProvider<ArchivedStoriesCubit>(
          create: (_) => getIt<ArchivedStoriesCubit>(),
        ),
      ],
      child: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Scaffold(
          body: AdvisorBackground(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 100.h,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AssetsData.homeBarBackgroundImage),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      // Header with Back Button
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 15.h,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Text(
                              'الأرشيف',
                              style: Styles.textStyle24Meduim.copyWith(
                                color: AppColors.secondary700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Three-Tab Bar Container (Matches your Packages style)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          padding: EdgeInsets.all(2.5.w),
                          decoration: BoxDecoration(
                            color: AppColors.tabsBack,
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(color: AppColors.primary100),
                          ),
                          child: TabBar(
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            indicator: BoxDecoration(
                              color: AppColors.primary300,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            labelColor: AppColors.secondary950,
                            unselectedLabelColor: AppColors.blackColor,
                            labelStyle: Styles.textStyle14SemiBold,
                            tabs: const [
                              Tab(text: 'المحادثات'),
                              Tab(text: 'المنشورات'),
                              Tab(text: 'القصص'),
                            ],
                          ),
                        ),
                      ),

                      const Expanded(
                        child: TabBarView(
                          children: [
                            ChatsTabView(),
                            PostsTabView(),
                            StoriesTabView(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
