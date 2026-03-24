import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/blocked_users_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/blocked_users/blocked_users_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/blocked_users/blocked_users_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/blocked_users/blocked_users_list.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/blocked_users/blocked_users_skeleton.dart';
import 'package:tayseer/my_import.dart';

class BlockedUsersView extends StatefulWidget {
  const BlockedUsersView({super.key});

  @override
  State<BlockedUsersView> createState() => _BlockedUsersViewState();
}

class _BlockedUsersViewState extends State<BlockedUsersView> {
  late final BlockedUsersCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlockedUsersCubit(getIt<BlockedUsersRepository>());
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
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
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 15.h,
                      ),
                      child: SimpleAppBar(title: context.tr('blocks')),
                    ),
                    Expanded(
                      child: BlocListener<BlockedUsersCubit, BlockedUsersState>(
                        listener: (context, state) {
                          if (state is BlockedUsersLoaded) {
                            if (state.actionError != null) {
                              AppToast.error(
                                context,
                                state.isActionKey
                                    ? context.tr(state.actionError!)
                                    : state.actionError!,
                              );
                              context.read<BlockedUsersCubit>().clearMessages();
                            } else if (state.actionSuccess != null) {
                              AppToast.success(
                                context,
                                state.isActionKey
                                    ? context.tr(state.actionSuccess!)
                                    : state.actionSuccess!,
                              );
                              context.read<BlockedUsersCubit>().clearMessages();
                            }
                          }
                        },
                        child:
                            BlocBuilder<BlockedUsersCubit, BlockedUsersState>(
                              builder: (context, state) {
                                if (state is BlockedUsersLoading) {
                                  return const BlockedUsersSkeleton();
                                }
                                if (state is BlockedUsersError) {
                                  return CustomErrorView(
                                    verticalPadding: 100,
                                    message: state.message,
                                    onRetry: () => context
                                        .read<BlockedUsersCubit>()
                                        .refresh(),
                                  );
                                }
                                if (state is BlockedUsersLoaded) {
                                  return BlockedUsersList(
                                    blockedUsers: state.blockedUsers,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
