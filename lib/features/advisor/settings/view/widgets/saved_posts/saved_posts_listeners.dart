import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts/saved_posts_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts/saved_posts_state.dart';
import 'package:tayseer/my_import.dart';

List<BlocListenerCondition<SavedPostsState>> get savedPostsListeners => [];

/// Returns all BlocListeners needed for SavedPostsView feedback.
List<BlocListener<SavedPostsCubit, SavedPostsState>> buildSavedPostsListeners(
  BuildContext context,
) => [
  BlocListener<SavedPostsCubit, SavedPostsState>(
    listenWhen: (p, c) =>
        p.status != c.status && c.status == CubitStates.failure,
    listener: (context, state) {
      if (state.errorMessage != null) {
        AppToast.error(context, state.errorMessage!);
      }
    },
  ),
  BlocListener<SavedPostsCubit, SavedPostsState>(
    listenWhen: (p, c) =>
        p.shareActionState != c.shareActionState &&
        c.shareActionState != CubitStates.initial,
    listener: (context, state) {
      if (state.shareActionState == CubitStates.success) {
        AppToast.success(
          context,
          state.isShareAdded == true
              ? (state.shareMessage ?? context.tr('shared_success'))
              : (state.shareMessage ?? context.tr('unshared_success')),
        );
      } else if (state.shareActionState == CubitStates.failure) {
        AppToast.error(
          context,
          state.shareMessage ?? context.tr('shared_error'),
        );
      }
    },
  ),
  BlocListener<SavedPostsCubit, SavedPostsState>(
    listenWhen: (p, c) =>
        p.saveActionState != c.saveActionState &&
        c.saveActionState != CubitStates.initial,
    listener: (context, state) {
      if (state.saveActionState == CubitStates.success) {
        AppToast.success(
          context,
          state.saveMessage ?? context.tr('saved_success'),
        );
      } else if (state.saveActionState == CubitStates.failure) {
        AppToast.error(context, state.saveMessage ?? context.tr('save_error'));
      }
    },
  ),
  BlocListener<SavedPostsCubit, SavedPostsState>(
    listenWhen: (p, c) =>
        p.deletePostActionState != c.deletePostActionState &&
        c.deletePostActionState != CubitStates.initial,
    listener: (context, state) {
      if (state.deletePostActionState == CubitStates.success) {
        AppToast.success(
          context,
          state.deletePostMessage ?? context.tr('delete_success'),
        );
      } else if (state.deletePostActionState == CubitStates.failure) {
        AppToast.error(
          context,
          state.deletePostMessage ?? context.tr('delete_error'),
        );
      }
    },
  ),
  BlocListener<SavedPostsCubit, SavedPostsState>(
    listenWhen: (p, c) =>
        p.archivePostActionState != c.archivePostActionState &&
        c.archivePostActionState != CubitStates.initial,
    listener: (context, state) {
      if (state.archivePostActionState == CubitStates.success) {
        AppToast.success(
          context,
          state.archivePostMessage ?? context.tr('archive_success'),
        );
      } else if (state.archivePostActionState == CubitStates.failure) {
        AppToast.error(
          context,
          state.archivePostMessage ?? context.tr('archive_error'),
        );
      }
    },
  ),
  BlocListener<SavedPostsCubit, SavedPostsState>(
    listenWhen: (p, c) =>
        p.blockUserActionState != c.blockUserActionState &&
        c.blockUserActionState != CubitStates.initial,
    listener: (context, state) {
      if (state.blockUserActionState == CubitStates.success) {
        AppToast.success(
          context,
          state.blockUserMessage ?? context.tr('blocked_successfully'),
        );
      } else if (state.blockUserActionState == CubitStates.failure) {
        AppToast.error(
          context,
          state.blockUserMessage ?? context.tr('failed_to_block'),
        );
      }
    },
  ),
];
