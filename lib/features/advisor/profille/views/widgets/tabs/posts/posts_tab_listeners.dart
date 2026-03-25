import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_state.dart';

/// Mixin that provides all BlocListener conditions and handlers for PostsTab
mixin PostsTabListeners {
  bool shouldListenToShare(ProfileState prev, ProfileState curr) =>
      prev.shareActionState != curr.shareActionState &&
      curr.shareActionState != CubitStates.initial;

  bool shouldListenToSave(ProfileState prev, ProfileState curr) =>
      prev.saveActionState != curr.saveActionState &&
      curr.saveActionState != CubitStates.initial;

  bool shouldListenToDelete(ProfileState prev, ProfileState curr) =>
      prev.deletePostActionState != curr.deletePostActionState &&
      curr.deletePostActionState != CubitStates.initial;

  bool shouldListenToBlock(ProfileState prev, ProfileState curr) =>
      prev.blockUserActionState != curr.blockUserActionState &&
      curr.blockUserActionState != CubitStates.initial;

  bool shouldListenToArchive(ProfileState prev, ProfileState curr) =>
      prev.archivePostActionState != curr.archivePostActionState &&
      curr.archivePostActionState != CubitStates.initial;

  void handleShareFeedback(BuildContext context, ProfileState state) {
    final message = state.shareMessage;
    switch (state.shareActionState) {
      case CubitStates.success:
        state.isShareAdded == true
            ? AppToast.success(context, message ?? context.tr('shared_success'))
            : AppToast.info(context, message ?? context.tr('unshared_success'));
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? context.tr('shared_error'));
        break;
      default:
        break;
    }
  }

  void handleSaveFeedback(BuildContext context, ProfileState state) {
    final message = state.saveMessage;
    switch (state.saveActionState) {
      case CubitStates.success:
        AppToast.success(context, message ?? context.tr('operation_success'));
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? context.tr('save_error'));
        break;
      default:
        break;
    }
  }

  void handleDeleteFeedback(BuildContext context, ProfileState state) {
    final message = state.deletePostMessage;
    switch (state.deletePostActionState) {
      case CubitStates.success:
        AppToast.success(context, message ?? context.tr('delete_success'));
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? context.tr('delete_error'));
        break;
      default:
        break;
    }
  }

  void handleArchiveFeedback(BuildContext context, ProfileState state) {
    final message = state.archivePostMessage;
    switch (state.archivePostActionState) {
      case CubitStates.success:
        AppToast.success(context, message ?? context.tr('archive_success'));
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? context.tr('archive_error'));
        break;
      default:
        break;
    }
  }

  void handleBlockFeedback(BuildContext context, ProfileState state) {
    switch (state.blockUserActionState) {
      case CubitStates.loading:
        CustomloadingApp.show(context);
        break;
      case CubitStates.success:
        CustomloadingApp.hide(context);
        AppToast.success(
          context,
          state.blockUserMessage ?? context.tr('blocked_successfully'),
        );
        break;
      case CubitStates.failure:
        CustomloadingApp.hide(context);
        AppToast.error(
          context,
          state.blockUserMessage ?? context.tr('failed_to_block'),
        );
        break;
      default:
        break;
    }
  }
}
