import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_event_bus.dart';
import 'package:tayseer/my_import.dart';

class StoriesCubit extends Cubit<StoriesState> {
  final StoriesRepository storiesRepository;
  final int pageSize = 10;
  
  StreamSubscription? _myStoriesSub;
  StreamSubscription? _uploadSub;

  StoriesCubit(this.storiesRepository) : super(const StoriesState()) {
    // ── Listen to EventBus to sync myStories and uploadProgress ──
    _myStoriesSub = StoriesEventBus.instance.onMyStoriesUpdated.listen((myStories) {
      if (state.myStories != myStories) {
        emit(state.copyWith(myStories: myStories));
        if (myStories != null) {
          _syncMyStoriesIntoMainList(myStories);
        }
      }
    });

    _uploadSub = StoriesEventBus.instance.onUploadProgress.listen((event) {
      if (state.createStoryState != event.state || state.uploadProgress != event.progress) {
        emit(state.copyWith(createStoryState: event.state, uploadProgress: event.progress));
      }
    });
  }

  @override
  Future<void> close() {
    _myStoriesSub?.cancel();
    _uploadSub?.cancel();
    return super.close();
  }

  Future<void> fetchStories({
    bool loadMore = false,
    String? advisorId,
    bool? isSpecial,
    bool isSilent = false,
    required BuildContext context,
  }) async {
    final effectiveAdvisorId = advisorId ?? state.advisorId;
    final effectiveIsSpecial = isSpecial ?? state.isSpecial;

    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await storiesRepository.fetchStories(
        page: nextPage,
        limit: pageSize,
        advisorId: effectiveAdvisorId,
        isSpecial: effectiveIsSpecial,
        context: context,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              isLoadingMore: false,
              storiesMessage: failure.message,
            ),
          );
        },
        (newStories) {
          final updatedList = [...state.storiesList, ...newStories];
          emit(
            state.copyWith(
              storiesList: updatedList,
              currentPage: nextPage,
              hasMore: newStories.length >= pageSize,
              isLoadingMore: false,
              advisorId: effectiveAdvisorId,
              isSpecial: effectiveIsSpecial,
            ),
          );
        },
      );
    } else {
      if (!isSilent) {
        emit(
          state.copyWith(
            storiesState: CubitStates.loading,
            currentPage: 1,
            hasMore: true,
            advisorId: advisorId,
            isSpecial: isSpecial,
          ),
        );
      }
      final result = await storiesRepository.fetchStories(
        page: 1,
        limit: pageSize,
        advisorId: effectiveAdvisorId,
        isSpecial: effectiveIsSpecial,
        context: context,
      );
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              storiesState: CubitStates.failure,
              storiesMessage: failure.message,
            ),
          );
        },
        (storiesList) {
          emit(
            state.copyWith(
              storiesState: CubitStates.success,
              storiesList: storiesList,
              currentPage: 1,
              hasMore: storiesList.length >= pageSize,
              advisorId: effectiveAdvisorId,
              isSpecial: effectiveIsSpecial,
            ),
          );
        },
      );
    }
  }

  /// Silent fetch that doesn't require a [BuildContext].
  /// Used after adding a story when the original context is already popped.
  Future<void> fetchStoriesSilent() async {
    final effectiveAdvisorId = state.advisorId;
    final effectiveIsSpecial = state.isSpecial;

    final result = await storiesRepository.fetchStoriesSilent(
      page: 1,
      limit: pageSize,
      advisorId: effectiveAdvisorId,
      isSpecial: effectiveIsSpecial,
    );

    result.fold(
      (failure) {
        debugPrint('Silent story fetch failed: ${failure.message}');
      },
      (storiesList) {
        emit(
          state.copyWith(
            storiesState: CubitStates.success,
            storiesList: storiesList,
            currentPage: 1,
            hasMore: storiesList.length >= pageSize,
            advisorId: effectiveAdvisorId,
            isSpecial: effectiveIsSpecial,
          ),
        );
      },
    );
    // Also refresh my own stories silently
    await fetchMyStories(isSilent: true);
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH MY STORIES  (GET /stories/my-stories)
  // ═══════════════════════════════════════════════════════════
  /// Fetches only the current advisor's own stories.
  /// Call this on profile load and after opening a story to refresh
  /// view counts and likers without affecting the main stories list.
  Future<void> fetchMyStories({bool isSilent = false}) async {
    if (!isSilent) {
      emit(state.copyWith(myStoriesState: CubitStates.loading));
    }

    final result = await storiesRepository.fetchMyStories();

    result.fold(
      (failure) {
        debugPrint('fetchMyStories failed: ${failure.message}');
        emit(
          state.copyWith(
            myStoriesState: CubitStates.failure,
            myStoriesMessage: failure.message,
          ),
        );
      },
      (myStories) {
        emit(
          state.copyWith(
            myStoriesState: CubitStates.success,
            myStories: myStories,
          ),
        );

        // ⭐ Keep the main storiesList in sync locally:
        if (myStories != null) {
          _syncMyStoriesIntoMainList(myStories);
        }

        // ⭐ Broadcast the update to all other StoriesCubit instances
        StoriesEventBus.instance.updateMyStories(myStories);
      },
    );
  }

  void _syncMyStoriesIntoMainList(UserStoriesModel myStories) {
    if (state.isSpecial == true) return;

    final myUserId = myStories.userId;
    if (myUserId.isEmpty) return;

    final currentList = state.storiesList;
    final myIndex = currentList.indexWhere((us) => us.userId == myUserId);

    if (myIndex == -1) return; // advisor not in the public list — fine

    final updatedList = List<UserStoriesModel>.from(currentList);
    updatedList[myIndex] = myStories;
    emit(state.copyWith(storiesList: updatedList));
  }

  void markStoryAsViewed({required String storyId, required String userId}) {
    final myUserId = kCurrentUserData?.id;
    final isMine = myUserId != null && userId == myUserId;

    // ── Update main storiesList ────────────────────────────────────────────
    final currentList = state.storiesList;
    final userStoryIndex = currentList.indexWhere(
      (userStory) => userStory.userId == userId,
    );

    List<UserStoriesModel>? updatedList;

    if (userStoryIndex != -1) {
      final userStory = currentList[userStoryIndex];
      final storyIndex = userStory.stories.indexWhere((s) => s.id == storyId);

      if (storyIndex != -1) {
        final story = userStory.stories[storyIndex];
        final List<StoryModel> updatedStories = List.from(userStory.stories);
        if (!story.isViewedByMe) {
          updatedStories[storyIndex] = story.copyWith(
            isViewedByMe: true,
            viewsCount: story.viewsCount == 0 ? 1 : story.viewsCount,
          );
        }
        final bool allViewedLocally =
            updatedStories.every((s) => s.isViewedByMe);
        final updatedUserStory = userStory.copyWith(
          stories: updatedStories,
          allViewed: allViewedLocally,
          isViewedByMe: true,
        );
        updatedList = List.from(currentList);
        updatedList[userStoryIndex] = updatedUserStory;
      }
    }

    // ── Also update myStories if this story is mine ────────────────────────
    UserStoriesModel? updatedMyStories = state.myStories;
    if (isMine && updatedMyStories != null) {
      final myStoryIndex =
          updatedMyStories.stories.indexWhere((s) => s.id == storyId);
      if (myStoryIndex != -1) {
        final story = updatedMyStories.stories[myStoryIndex];
        final updatedStories = List<StoryModel>.from(updatedMyStories.stories);
        if (!story.isViewedByMe) {
          updatedStories[myStoryIndex] = story.copyWith(
            isViewedByMe: true,
            viewsCount: story.viewsCount == 0 ? 1 : story.viewsCount,
          );
        }
        final allViewed = updatedStories.every((s) => s.isViewedByMe);
        updatedMyStories = updatedMyStories.copyWith(
          stories: updatedStories,
          allViewed: allViewed,
        );
      }
    }

    emit(
      state.copyWith(
        storiesList: updatedList ?? state.storiesList,
        myStories: updatedMyStories ?? state.myStories,
      ),
    );

    // ⭐ Call API only if NOT already viewed by me (check pre-update state)
    StoryModel? originalStory;
    final originalUserStory =
        currentList.where((us) => us.userId == userId).firstOrNull;
    if (originalUserStory != null) {
      originalStory = originalUserStory.stories
          .where((s) => s.id == storyId)
          .firstOrNull;
    }
    originalStory ??= state.myStories?.stories
        .where((s) => s.id == storyId)
        .firstOrNull;

    if (originalStory != null && !originalStory.isViewedByMe) {
      storiesRepository.markStoryAsViewed(storyId: storyId);
    }
  }

  void likeStory({required String storyId, required String userId}) {
    final myUserId = kCurrentUserData?.id;
    final isMine = myUserId != null && userId == myUserId;

    // ── Update main storiesList ────────────────────────────────────────────
    List<UserStoriesModel>? updatedList;
    final userStoryIndex = state.storiesList.indexWhere(
      (userStory) => userStory.userId == userId,
    );
    if (userStoryIndex != -1) {
      final userStory = state.storiesList[userStoryIndex];
      final storyIndex = userStory.stories.indexWhere((s) => s.id == storyId);
      if (storyIndex != -1) {
        final story = userStory.stories[storyIndex];
        final updatedStories = List<StoryModel>.from(userStory.stories);
        updatedStories[storyIndex] = story.copyWith(
          isLiked: !story.isLiked,
          likesCount:
              story.isLiked ? story.likesCount - 1 : story.likesCount + 1,
        );
        final updatedUserStory = userStory.copyWith(stories: updatedStories);
        updatedList = List<UserStoriesModel>.from(state.storiesList);
        updatedList[userStoryIndex] = updatedUserStory;
      }
    }

    // ── Also update myStories if this story is mine ────────────────────────
    UserStoriesModel? updatedMyStories;
    if (isMine && state.myStories != null) {
      final myStories = state.myStories!;
      final myStoryIndex =
          myStories.stories.indexWhere((s) => s.id == storyId);
      if (myStoryIndex != -1) {
        final story = myStories.stories[myStoryIndex];
        final updatedStories = List<StoryModel>.from(myStories.stories);
        updatedStories[myStoryIndex] = story.copyWith(
          isLiked: !story.isLiked,
          likesCount:
              story.isLiked ? story.likesCount - 1 : story.likesCount + 1,
        );
        updatedMyStories = myStories.copyWith(stories: updatedStories);
      }
    }

    emit(
      state.copyWith(
        storiesList: updatedList ?? state.storiesList,
        myStories: updatedMyStories ?? state.myStories,
      ),
    );
    storiesRepository.likeStory(storyId: storyId);
  }

  Future<void> deleteStory({
    required BuildContext context,
    required String storyId,
    required String userId,
  }) async {
    final result = await storiesRepository.deleteStory(storyId: storyId);

    result.fold(
      (failure) {
        emit(state.copyWith(storiesMessage: failure.message));
        if (context.mounted) {
          AppToast.error(context, failure.message);
        }
      },
      (_) {
        final userStoryIndex = state.storiesList.indexWhere(
          (us) => us.userId == userId,
        );
        if (userStoryIndex == -1) return;

        final userStory = state.storiesList[userStoryIndex];
        final updatedStories = userStory.stories
            .where((s) => s.id != storyId)
            .toList();

        final updatedList = List<UserStoriesModel>.from(state.storiesList);
        if (updatedStories.isEmpty) {
          updatedList.removeAt(userStoryIndex);
        } else {
          updatedList[userStoryIndex] = userStory.copyWith(
            stories: updatedStories,
            storiesCount: updatedStories.length,
          );
        }

        emit(state.copyWith(storiesList: updatedList));
        if (context.mounted) {
          AppToast.success(context, context.tr('story_deleted_success'));
        }
      },
    );
  }

  Future<void> toggleArchiveStory({
    required BuildContext context,
    required String storyId,
    required String userId,
    required bool isArchive,
  }) async {
    final result = await storiesRepository.toggleArchiveStory(
      storyId: storyId,
      isArchive: isArchive,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(storiesMessage: failure.message));
        if (context.mounted) {
          AppToast.error(context, failure.message);
        }
      },
      (_) {
        if (isArchive) {
          final userStoryIndex = state.storiesList.indexWhere(
            (us) => us.userId == userId,
          );
          if (userStoryIndex == -1) return;

          final userStory = state.storiesList[userStoryIndex];
          final updatedStories = userStory.stories
              .where((s) => s.id != storyId)
              .toList();

          final updatedList = List<UserStoriesModel>.from(state.storiesList);
          if (updatedStories.isEmpty) {
            updatedList.removeAt(userStoryIndex);
          } else {
            updatedList[userStoryIndex] = userStory.copyWith(
              stories: updatedStories,
              storiesCount: updatedStories.length,
            );
          }
          emit(state.copyWith(storiesList: updatedList));
          if (context.mounted) {
            AppToast.success(context, context.tr('story_archived_success'));
          }
        }
      },
    );
  }

  Future<Either<Failure, void>> hideStory({
    required BuildContext context,
    required String storyId,
    required String userId,
  }) async {
    final result = await storiesRepository.hideStory(storyId: storyId);

    return result.fold(
      (failure) {
        emit(state.copyWith(storiesMessage: failure.message));
        if (context.mounted) {
          AppToast.error(context, failure.message);
        }
        return Left(failure);
      },
      (_) {
        final userStoryIndex = state.storiesList.indexWhere(
          (us) => us.userId == userId,
        );
        if (userStoryIndex != -1) {
          final userStory = state.storiesList[userStoryIndex];
          final updatedStories = userStory.stories
              .where((s) => s.id != storyId)
              .toList();

          final updatedList = List<UserStoriesModel>.from(state.storiesList);
          if (updatedStories.isEmpty) {
            updatedList.removeAt(userStoryIndex);
          } else {
            updatedList[userStoryIndex] = userStory.copyWith(
              stories: updatedStories,
              storiesCount: updatedStories.length,
            );
          }
          emit(state.copyWith(storiesList: updatedList));
        }
        if (context.mounted) {
          AppToast.success(context, context.tr('story_hidden_success'));
        }
        return const Right(null);
      },
    );
  }

  Future<void> makeStorySpecial({
    required BuildContext context,
    required String storyId,
    required String userId,
  }) async {
    final result = await storiesRepository.makeStorySpecial(storyId: storyId);

    result.fold(
      (failure) {
        emit(state.copyWith(storiesMessage: failure.message));
        if (context.mounted) {
          AppToast.error(context, failure.message);
        }
      },
      (_) {
        final userStoryIndex = state.storiesList.indexWhere(
          (us) => us.userId == userId,
        );
        if (userStoryIndex == -1) return;

        final userStory = state.storiesList[userStoryIndex];
        final storyIndex = userStory.stories.indexWhere((s) => s.id == storyId);
        if (storyIndex == -1) return;

        final updatedStories = List<StoryModel>.from(userStory.stories);
        updatedStories[storyIndex] = updatedStories[storyIndex].copyWith(
          isSpecial: true,
        );

        final List<UserStoriesModel> updatedList = List.from(state.storiesList);
        updatedList[userStoryIndex] = userStory.copyWith(
          stories: updatedStories,
        );

        emit(state.copyWith(storiesList: updatedList));
        if (context.mounted) {
          AppToast.success(context, context.tr('story_special_success'));
        }
      },
    );
  }

  Future<void> createStory({
    String? content,
    List<File>? images,
    List<XFile>? videos,
    double? videoDuration,
    BuildContext? context,
  }) async {
    emit(
      state.copyWith(
        createStoryState: CubitStates.loading,
        uploadProgress: 0.0,
      ),
    );
    StoriesEventBus.instance.updateUploadProgress(CubitStates.loading, 0.0);

    final result = await storiesRepository.createStories(
      content: content,
      images: images,
      videos: videos,
      videoDuration: videoDuration,
      onSendProgress: (sent, total) {
        if (total > 0) {
          final progress = sent / total;
          if ((progress - state.uploadProgress).abs() > 0.01 ||
              progress == 1.0) {
            emit(
              state.copyWith(
                uploadProgress: progress,
                createStoryState: CubitStates.loading,
              ),
            );
            StoriesEventBus.instance.updateUploadProgress(CubitStates.loading, progress);
          }
        }
      },
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            createStoryState: CubitStates.failure,
            createStoryMessage: failure.message,
          ),
        );
        StoriesEventBus.instance.updateUploadProgress(CubitStates.failure, 0.0);
        if (context != null && context.mounted) {
          AppToast.error(context, failure.message);
        }
      },
      (createdStory) {
        emit(state.copyWith(createStoryState: CubitStates.success));
        StoriesEventBus.instance.updateUploadProgress(CubitStates.success, 1.0);

        // ── Optimistically add the new story to state ──────────────────────
        final myUserId = kCurrentUserData?.id;
        if (myUserId != null) {
          if (state.isSpecial != true) {
            // Update main storiesList
            final currentList = List<UserStoriesModel>.from(state.storiesList);
            final myStoryIndex = currentList.indexWhere(
              (userStory) => userStory.userId == myUserId,
            );
            if (myStoryIndex != -1) {
              final myUserStory = currentList[myStoryIndex];
              final updatedStories = [createdStory, ...myUserStory.stories];
              currentList[myStoryIndex] = myUserStory.copyWith(
                stories: updatedStories,
                storiesCount: updatedStories.length,
              );
            } else {
              final newUserStory = UserStoriesModel(
                userId: myUserId,
                name: kCurrentUserData?.name ?? '',
                image: kCurrentUserData?.image ?? '',
                isFollowed: false,
                isViewedByMe: false,
                allViewed: false,
                storiesCount: 1,
                stories: [createdStory],
              );
              currentList.insert(0, newUserStory);
            }
            emit(state.copyWith(storiesList: currentList));
          }

          // ── Also update myStories optimistically ──────────────────────────
          final currentMyStories = state.myStories;
          if (currentMyStories != null) {
            final updatedMyStories = currentMyStories.copyWith(
              stories: [createdStory, ...currentMyStories.stories],
              storiesCount: currentMyStories.storiesCount + 1,
            );
            emit(state.copyWith(myStories: updatedMyStories));
            StoriesEventBus.instance.updateMyStories(updatedMyStories);
          } else {
            final newMyStories = UserStoriesModel(
              userId: myUserId,
              name: kCurrentUserData?.name ?? '',
              image: kCurrentUserData?.image ?? '',
              isFollowed: false,
              isViewedByMe: false,
              allViewed: false,
              storiesCount: 1,
              stories: [createdStory],
            );
            emit(state.copyWith(myStories: newMyStories));
            StoriesEventBus.instance.updateMyStories(newMyStories);
          }
        }

        // ── Re-fetch my stories in the background to get accurate data ──────
        fetchMyStories(isSilent: true);

        if (context != null && context.mounted) {
          AppToast.success(context, context.tr('story_created_success'));
        }
      },
    );
  }
}
