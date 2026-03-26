import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/story_visibility/story_visibility_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/story_visibility/story_visibility_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/hide_story/hide_story_confirm_dialog.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/hide_story/hide_story_skeleton.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/hide_story/hide_story_user_item.dart';
import 'package:tayseer/my_import.dart';

class HideStoryFromView extends StatefulWidget {
  const HideStoryFromView({super.key});

  @override
  State<HideStoryFromView> createState() => _HideStoryFromViewState();
}

class _HideStoryFromViewState extends State<HideStoryFromView> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    setState(() => _hasText = _searchController.text.isNotEmpty);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StoryVisibilityCubit>(
      create: (_) => getIt<StoryVisibilityCubit>(),
      child: BlocConsumer<StoryVisibilityCubit, StoryVisibilityState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            showSafeSnackBar(
              context: context,
              text: context.tr(state.errorMessage!),
              isError: true,
            );
            context.read<StoryVisibilityCubit>().clearError();
          }
          if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            showSafeSnackBar(
              context: context,
              text: context.tr(state.successMessage!),
              isSuccess: true,
            );
            context.read<StoryVisibilityCubit>().clearSuccess();
          }
        },
        builder: (context, state) {
          final cubit = context.read<StoryVisibilityCubit>();
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    child: SimpleAppBar(
                      title: context.tr('hide_story_from'),
                      icon: Icons.close,
                    ),
                  ),
                  _SearchField(
                    controller: _searchController,
                    hasText: _hasText,
                    isLoading: state.isLoading,
                    onChanged: (value) => cubit.updateSearchQuery(value),
                    onClear: () {
                      _searchController.clear();
                      cubit.updateSearchQuery('');
                    },
                  ),
                  Gap(16.h),
                  if (state.state == CubitStates.success &&
                      state.users.isNotEmpty)
                    _SelectAllButton(state: state, cubit: cubit),
                  Gap(8.h),
                  Expanded(child: _buildUsersList(context, state, cubit)),
                  if (state.hasSelections)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.w,
                        vertical: 16.h,
                      ),
                      child: CustomBotton(
                        title: state.isUnrestricting
                            ? context.tr('unrestricting')
                            : '${context.tr('unrestricting_for')} ${state.selectedUsers.length} ${context.tr('user')}',
                        onPressed: state.isUnrestricting
                            ? null
                            : () => showDialog(
                                context: context,
                                builder: (_) => HideStoryConfirmDialog(
                                  cubit: cubit,
                                  state: state,
                                ),
                              ),
                        useGradient: true,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsersList(
    BuildContext context,
    StoryVisibilityState state,
    StoryVisibilityCubit cubit,
  ) {
    if (state.state == CubitStates.loading) return const HideStorySkeleton();

    if (state.state == CubitStates.failure) {
      return CustomErrorView(
        message: state.errorMessage ?? context.tr('error_loading_users'),
        onRetry: () => cubit.loadRestrictedUsers(),
      );
    }

    if (state.state == CubitStates.success && state.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(AssetsData.icNoContentSeach),
            Gap(16.h),
            Text(
              state.searchQuery.isEmpty
                  ? context.tr('no_hidden_users')
                  : context.tr('no_results_for_search'),
              style: Styles.textStyle16.copyWith(color: Colors.grey.shade600),
            ),
            Gap(50.h),
            if (state.searchQuery.isNotEmpty)
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  cubit.updateSearchQuery('');
                },
                child: Text(context.tr('clear_search')),
              ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      itemCount: state.users.length,
      separatorBuilder: (_, __) =>
          Divider(color: Colors.grey.shade100, height: 1),
      itemBuilder: (context, index) {
        final user = state.users[index];
        return HideStoryUserItem(
          key: ValueKey(user.userId),
          user: user,
          onTap: () => cubit.toggleUserSelection(user.userId),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hasText,
    required this.isLoading,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: TextField(
        controller: controller,
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: context.tr('search_by_name'),
          hintStyle: Styles.textStyle16.copyWith(color: AppColors.gray2),
          prefixIcon: Icon(Icons.search, color: AppColors.gray2, size: 20.sp),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40.w,
            minHeight: 20.h,
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 20.h),
          suffixIcon: isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary300,
                    ),
                  ),
                )
              : hasText
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.gray2, size: 20.sp),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}

class _SelectAllButton extends StatelessWidget {
  final StoryVisibilityState state;
  final StoryVisibilityCubit cubit;

  const _SelectAllButton({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => cubit.selectAllUsers(),
            child: Text(
              state.hasSelections &&
                      state.selectedUsers.length == state.users.length
                  ? context.tr('unselect_all')
                  : context.tr('select_all'),
              style: Styles.textStyle14.copyWith(
                color: AppColors.primary400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
