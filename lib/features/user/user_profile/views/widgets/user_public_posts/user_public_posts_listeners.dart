import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_state.dart';
import 'package:tayseer/my_import.dart';

void handleShareState(BuildContext context, UserPublicProfileState state) {
  final message = state.shareMessage;
  switch (state.shareActionState) {
    case CubitStates.success:
      // Play success sound for share action
      AudioService.instance.playSuccessSound();
      showSafeSnackBar(
        context: context,
        text: state.isShareAdded == true
            ? (message ?? context.tr('shared_success'))
            : (message ?? context.tr('unshared_success')),
        isSuccess: true,
        duration: const Duration(milliseconds: 1500),
      );
      break;
    case CubitStates.failure:
      // Play error sound for failed share
      AudioService.instance.playErrorSound();
      showSafeSnackBar(
        context: context,
        text: message ?? context.tr('shared_error'),
        isError: true,
      );
      break;
    default:
      break;
  }
}

void handleSaveState(BuildContext context, UserPublicProfileState state) {
  if (state.saveActionState == CubitStates.success) {
    // Play save success sound
    AudioService.instance.playSaveSound(isSaved: true);
    showSafeSnackBar(
      context: context,
      text: state.saveMessage ?? context.tr('saved_success'),
      isSuccess: true,
    );
  } else if (state.saveActionState == CubitStates.failure) {
    // Play error sound for failed save
    AudioService.instance.playErrorSound();
    showSafeSnackBar(
      context: context,
      text: state.saveMessage ?? context.tr('save_error'),
      isError: true,
    );
  }
}

void handleDeleteState(BuildContext context, UserPublicProfileState state) {
  if (state.deletePostActionState == CubitStates.success) {
    // Play delete success sound
    AudioService.instance.playDeleteSound();
    showSafeSnackBar(
      context: context,
      text: state.deletePostMessage ?? context.tr('delete_success'),
      isSuccess: true,
    );
  } else if (state.deletePostActionState == CubitStates.failure) {
    // Play error sound for failed delete
    AudioService.instance.playErrorSound();
    showSafeSnackBar(
      context: context,
      text: state.deletePostMessage ?? context.tr('delete_error'),
      isError: true,
    );
  }
}

void handleArchiveState(BuildContext context, UserPublicProfileState state) {
  if (state.archivePostActionState == CubitStates.success) {
    // Play archive success sound
    AudioService.instance.playArchiveSound();
    showSafeSnackBar(
      context: context,
      text: state.archivePostMessage ?? context.tr('archive_success'),
      isSuccess: true,
    );
  } else if (state.archivePostActionState == CubitStates.failure) {
    // Play error sound for failed archive
    AudioService.instance.playErrorSound();
    showSafeSnackBar(
      context: context,
      text: state.archivePostMessage ?? context.tr('archive_error'),
      isError: true,
    );
  }
}

void handleBlockUserState(BuildContext context, UserPublicProfileState state) {
  if (state.blockUserActionState == CubitStates.success) {
    // Play block success sound
    AudioService.instance.playBlockSound();
    AppToast.success(
      context,
      state.blockUserMessage ?? context.tr('blocked_successfully'),
    );
  } else if (state.blockUserActionState == CubitStates.failure) {
    // Play error sound for failed block
    AudioService.instance.playErrorSound();
    AppToast.error(
      context,
      state.blockUserMessage ?? context.tr('failed_to_block'),
    );
  }
}

void handlePollVoteState(BuildContext context, UserPublicProfileState state) {
  showSafeSnackBar(
    context: context,
    text: state.pollVoteMessage ?? context.tr('poll_vote_error'),
    isError: true,
  );
}
