import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_event_bus.dart';
import 'package:tayseer/core/utils/profile_event_bus.dart';
import 'package:tayseer/my_import.dart';

class StoriesCubit extends Cubit<StoriesState> {
  final StoriesRepository storiesRepository;
  final int pageSize = 10;

  StreamSubscription? _myStoriesSub;
  StreamSubscription? _uploadSub;
  late StreamSubscription<ProfileUpdateEvent> _profileSub;

  StoriesCubit(this.storiesRepository) : super(const StoriesState()) {
    // ── Listen to EventBus to sync myStories and uploadProgress ──
    _myStoriesSub = StoriesEventBus.instance.onMyStoriesUpdated.listen((
      myStories,
    ) {
      if (state.myStories != myStories) {
        emit(state.copyWith(myStories: myStories));
        if (myStories != null) {
          _syncMyStoriesIntoMainList(myStories);
        }
      }
    });

    _uploadSub = StoriesEventBus.instance.onUploadProgress.listen((event) {
      if (state.createStoryState != event.state ||
          state.uploadProgress != event.progress) {
        emit(
          state.copyWith(
            createStoryState: event.state,
            uploadProgress: event.progress,
          ),
        );
      }
    });

    _listenToProfileUpdates();
  }

  void _listenToProfileUpdates() {
    _profileSub = ProfileEventBus.instance.onProfileUpdated.listen((event) {
      final myId = kCurrentUserData?.id;

      // 1. Update myStories
      if (state.myStories != null) {
        final updatedMyStories = state.myStories!.copyWith(
          name: event.name,
          image: event.image,
        );
        emit(state.copyWith(myStories: updatedMyStories));
        _syncMyStoriesIntoMainList(updatedMyStories);
      }

      // 2. Update in storiesList (Home Feed)
      final currentList = state.storiesList;
      final myIndexInList = currentList.indexWhere((us) => us.userId == myId);
      if (myIndexInList != -1) {
        final updatedList = List<UserStoriesModel>.from(currentList);
        updatedList[myIndexInList] = updatedList[myIndexInList].copyWith(
          name: event.name,
          image: event.image,
        );
        emit(state.copyWith(storiesList: updatedList));
      }

      // 3. Update in mySpecialStories (My Profile)
      final currentMySpecialList = state.mySpecialStories;
      final myIndexInMySpecial = currentMySpecialList.indexWhere(
        (us) => us.userId == myId,
      );
      if (myIndexInMySpecial != -1) {
        final updatedList = List<UserStoriesModel>.from(currentMySpecialList);
        updatedList[myIndexInMySpecial] = updatedList[myIndexInMySpecial]
            .copyWith(name: event.name, image: event.image);
        emit(state.copyWith(mySpecialStories: updatedList));
      }

      // 4. Update in advisorSpecialStories (Other Advisor Profile)
      final currentAdvisorSpecialList = state.advisorSpecialStories;
      final myIndexInAdvisorSpecial = currentAdvisorSpecialList.indexWhere(
        (us) => us.userId == myId,
      );
      if (myIndexInAdvisorSpecial != -1) {
        final updatedList = List<UserStoriesModel>.from(
          currentAdvisorSpecialList,
        );
        updatedList[myIndexInAdvisorSpecial] =
            updatedList[myIndexInAdvisorSpecial].copyWith(
              name: event.name,
              image: event.image,
            );
        emit(state.copyWith(advisorSpecialStories: updatedList));
      }
    });
  }

  @override
  Future<void> close() {
    _myStoriesSub?.cancel();
    _uploadSub?.cancel();
    _profileSub.cancel();
    return super.close();
  }

  Future<void> fetchStories({
    bool loadMore = false,
    String? advisorId,
    bool? isSpecial,
    bool isSilent = false,
    required BuildContext context,
  }) async {
    final bool effectiveIsSpecial =
        isSpecial ?? (loadMore ? state.isSpecial : false);
    final String? effectiveAdvisorId = loadMore
        ? (advisorId ?? state.advisorId)
        : advisorId;

    // Determine target state fields based on whether it's My Profile or Advisor Profile
    final bool isMySpecialProfile =
        effectiveIsSpecial && effectiveAdvisorId == null;
    final bool isOtherAdvisorProfile =
        effectiveIsSpecial && effectiveAdvisorId != null;

    if (loadMore) {
      final bool isLoading = isMySpecialProfile
          ? state.mySpecialIsLoadingMore
          : (isOtherAdvisorProfile
                ? state.advisorSpecialIsLoadingMore
                : state.isLoadingMore);

      final bool hasMore = isMySpecialProfile
          ? state.mySpecialHasMore
          : (isOtherAdvisorProfile
                ? state.advisorSpecialHasMore
                : state.hasMore);

      if (isLoading || !hasMore) return;

      if (isMySpecialProfile) {
        emit(state.copyWith(mySpecialIsLoadingMore: true));
      } else if (isOtherAdvisorProfile) {
        emit(state.copyWith(advisorSpecialIsLoadingMore: true));
      } else {
        emit(state.copyWith(isLoadingMore: true));
      }

      final int nextPage =
          (isMySpecialProfile
              ? state.mySpecialCurrentPage
              : (isOtherAdvisorProfile
                    ? state.advisorSpecialCurrentPage
                    : state.currentPage)) +
          1;

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
              mySpecialIsLoadingMore: false,
              advisorSpecialIsLoadingMore: false,
              storiesMessage: failure.message,
            ),
          );
        },
        (newStories) {
          if (isMySpecialProfile) {
            emit(
              state.copyWith(
                mySpecialStories: [...state.mySpecialStories, ...newStories],
                mySpecialCurrentPage: nextPage,
                mySpecialHasMore: newStories.length >= pageSize,
                mySpecialIsLoadingMore: false,
                isSpecial: true,
                advisorId: null,
              ),
            );
          } else if (isOtherAdvisorProfile) {
            emit(
              state.copyWith(
                advisorSpecialStories: [
                  ...state.advisorSpecialStories,
                  ...newStories,
                ],
                advisorSpecialCurrentPage: nextPage,
                advisorSpecialHasMore: newStories.length >= pageSize,
                advisorSpecialIsLoadingMore: false,
                isSpecial: true,
                advisorId: effectiveAdvisorId,
                activeAdvisorId: effectiveAdvisorId,
              ),
            );
          } else {
            emit(
              state.copyWith(
                storiesList: [...state.storiesList, ...newStories],
                currentPage: nextPage,
                hasMore: newStories.length >= pageSize,
                isLoadingMore: false,
                isSpecial: false,
                advisorId: effectiveAdvisorId,
              ),
            );
          }
        },
      );
    } else {
      // ── FRESH FETCH ──
      if (!isSilent) {
        if (isMySpecialProfile) {
          emit(
            state.copyWith(
              mySpecialStoriesState: CubitStates.loading,
              mySpecialCurrentPage: 1,
              mySpecialHasMore: true,
              mySpecialStories: const [],
              isSpecial: true,
              advisorId: null,
            ),
          );
        } else if (isOtherAdvisorProfile) {
          emit(
            state.copyWith(
              advisorSpecialStoriesState: CubitStates.loading,
              advisorSpecialCurrentPage: 1,
              advisorSpecialHasMore: true,
              advisorSpecialStories: const [],
              isSpecial: true,
              advisorId: effectiveAdvisorId,
              activeAdvisorId: effectiveAdvisorId,
            ),
          );
        } else {
          emit(
            state.copyWith(
              storiesState: CubitStates.loading,
              currentPage: 1,
              hasMore: true,
              storiesList: const [],
              isSpecial: false,
              advisorId: effectiveAdvisorId,
            ),
          );
        }
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
          if (isMySpecialProfile) {
            emit(
              state.copyWith(
                mySpecialStoriesState: CubitStates.failure,
                storiesMessage: failure.message,
                isSpecial: true,
                advisorId: null,
              ),
            );
          } else if (isOtherAdvisorProfile) {
            emit(
              state.copyWith(
                advisorSpecialStoriesState: CubitStates.failure,
                storiesMessage: failure.message,
                isSpecial: true,
                advisorId: effectiveAdvisorId,
                activeAdvisorId: effectiveAdvisorId,
              ),
            );
          } else {
            emit(
              state.copyWith(
                storiesState: CubitStates.failure,
                storiesMessage: failure.message,
                isSpecial: false,
                advisorId: effectiveAdvisorId,
              ),
            );
          }
        },
        (storiesFetched) {
          if (isMySpecialProfile) {
            emit(
              state.copyWith(
                mySpecialStoriesState: CubitStates.success,
                mySpecialStories: storiesFetched,
                mySpecialCurrentPage: 1,
                mySpecialHasMore: storiesFetched.length >= pageSize,
                isSpecial: true,
                advisorId: null,
              ),
            );
          } else if (isOtherAdvisorProfile) {
            emit(
              state.copyWith(
                advisorSpecialStoriesState: CubitStates.success,
                advisorSpecialStories: storiesFetched,
                advisorSpecialCurrentPage: 1,
                advisorSpecialHasMore: storiesFetched.length >= pageSize,
                isSpecial: true,
                advisorId: effectiveAdvisorId,
                activeAdvisorId: effectiveAdvisorId,
              ),
            );
          } else {
            emit(
              state.copyWith(
                storiesState: CubitStates.success,
                storiesList: storiesFetched,
                currentPage: 1,
                hasMore: storiesFetched.length >= pageSize,
                isSpecial: false,
                advisorId: effectiveAdvisorId,
              ),
            );
          }
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
      (storiesFetched) {
        final bool isMySpecialProfile =
            effectiveIsSpecial && effectiveAdvisorId == null;
        final bool isOtherAdvisorProfile =
            effectiveIsSpecial && effectiveAdvisorId != null;

        if (isMySpecialProfile) {
          emit(
            state.copyWith(
              mySpecialStoriesState: CubitStates.success,
              mySpecialStories: storiesFetched,
              mySpecialCurrentPage: 1,
              mySpecialHasMore: storiesFetched.length >= pageSize,
            ),
          );
        } else if (isOtherAdvisorProfile) {
          emit(
            state.copyWith(
              advisorSpecialStoriesState: CubitStates.success,
              advisorSpecialStories: storiesFetched,
              advisorSpecialCurrentPage: 1,
              advisorSpecialHasMore: storiesFetched.length >= pageSize,
              activeAdvisorId: effectiveAdvisorId,
            ),
          );
        } else {
          emit(
            state.copyWith(
              storiesState: CubitStates.success,
              storiesList: storiesFetched,
              currentPage: 1,
              hasMore: storiesFetched.length >= pageSize,
            ),
          );
        }
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

  void _syncMyStoriesIntoMainList(UserStoriesModel myUserStories) {
    final myUserId = myUserStories.userId;
    if (myUserId.isEmpty) return;

    // 1. Sync into Home List only
    // NOTE: mySpecialStories and advisorSpecialStories are independently fetched
    // via fetchStories(isSpecial: true) and must NOT be polluted by the advisor's
    // own story ring data.
    final currentList = state.storiesList;
    final myIndex = currentList.indexWhere((us) => us.userId == myUserId);
    List<UserStoriesModel>? updatedHomeList;

    if (myIndex != -1) {
      updatedHomeList = List<UserStoriesModel>.from(currentList);
      updatedHomeList[myIndex] = myUserStories;
    }

    if (updatedHomeList != null) {
      emit(state.copyWith(storiesList: updatedHomeList));
    }
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
        final bool allViewedLocally = updatedStories.every(
          (s) => s.isViewedByMe,
        );
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
      final myStoryIndex = updatedMyStories.stories.indexWhere(
        (s) => s.id == storyId,
      );
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

    // ── 3. Update mySpecialStories (My Profile) ───────────────────────────
    List<UserStoriesModel>? updatedMySpecialList;
    final mySpecialIndex = state.mySpecialStories.indexWhere(
      (us) => us.userId == userId,
    );
    if (mySpecialIndex != -1) {
      final userStory = state.mySpecialStories[mySpecialIndex];
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
        final allViewed = updatedStories.every((s) => s.isViewedByMe);
        updatedMySpecialList = List.from(state.mySpecialStories);
        updatedMySpecialList[mySpecialIndex] = userStory.copyWith(
          stories: updatedStories,
          allViewed: allViewed,
          isViewedByMe: true,
        );
      }
    }

    // ── 4. Update advisorSpecialStories (Other Advisor Profile) ────────────
    List<UserStoriesModel>? updatedAdvisorSpecialList;
    final advisorSpecialIndex = state.advisorSpecialStories.indexWhere(
      (us) => us.userId == userId,
    );
    if (advisorSpecialIndex != -1) {
      final userStory = state.advisorSpecialStories[advisorSpecialIndex];
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
        final allViewed = updatedStories.every((s) => s.isViewedByMe);
        updatedAdvisorSpecialList = List.from(state.advisorSpecialStories);
        updatedAdvisorSpecialList[advisorSpecialIndex] = userStory.copyWith(
          stories: updatedStories,
          allViewed: allViewed,
          isViewedByMe: true,
        );
      }
    }

    emit(
      state.copyWith(
        storiesList: updatedList ?? state.storiesList,
        mySpecialStories: updatedMySpecialList ?? state.mySpecialStories,
        advisorSpecialStories:
            updatedAdvisorSpecialList ?? state.advisorSpecialStories,
        myStories: updatedMyStories ?? state.myStories,
      ),
    );

    // ⭐ Call API only if NOT already viewed by me (check pre-update state)
    StoryModel? originalStory;
    final originalUserStory = currentList
        .where((us) => us.userId == userId)
        .firstOrNull;
    if (originalUserStory != null) {
      originalStory = originalUserStory.stories
          .where((s) => s.id == storyId)
          .firstOrNull;
    }
    originalStory ??= state.mySpecialStories
        .where((us) => us.userId == userId)
        .firstOrNull
        ?.stories
        .where((s) => s.id == storyId)
        .firstOrNull;
    originalStory ??= state.advisorSpecialStories
        .where((us) => us.userId == userId)
        .firstOrNull
        ?.stories
        .where((s) => s.id == storyId)
        .firstOrNull;
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
          likesCount: story.isLiked
              ? story.likesCount - 1
              : story.likesCount + 1,
        );
        final updatedUserStory = userStory.copyWith(stories: updatedStories);
        updatedList = List<UserStoriesModel>.from(state.storiesList);
        updatedList[userStoryIndex] = updatedUserStory;
      }
    }

    // ── 3. Update mySpecialStories (My Profile) ───────────────────────────
    List<UserStoriesModel>? updatedMySpecialList;
    final mySpecialIndex = state.mySpecialStories.indexWhere(
      (us) => us.userId == userId,
    );
    if (mySpecialIndex != -1) {
      final userStory = state.mySpecialStories[mySpecialIndex];
      final storyIndex = userStory.stories.indexWhere((s) => s.id == storyId);
      if (storyIndex != -1) {
        final story = userStory.stories[storyIndex];
        final updatedStories = List<StoryModel>.from(userStory.stories);
        updatedStories[storyIndex] = story.copyWith(
          isLiked: !story.isLiked,
          likesCount: story.isLiked
              ? story.likesCount - 1
              : story.likesCount + 1,
        );
        updatedMySpecialList = List.from(state.mySpecialStories);
        updatedMySpecialList[mySpecialIndex] = userStory.copyWith(
          stories: updatedStories,
        );
      }
    }

    // ── 4. Update advisorSpecialStories (Other Advisor Profile) ────────────
    List<UserStoriesModel>? updatedAdvisorSpecialList;
    final advisorSpecialIndex = state.advisorSpecialStories.indexWhere(
      (us) => us.userId == userId,
    );
    if (advisorSpecialIndex != -1) {
      final userStory = state.advisorSpecialStories[advisorSpecialIndex];
      final storyIndex = userStory.stories.indexWhere((s) => s.id == storyId);
      if (storyIndex != -1) {
        final story = userStory.stories[storyIndex];
        final updatedStories = List<StoryModel>.from(userStory.stories);
        updatedStories[storyIndex] = story.copyWith(
          isLiked: !story.isLiked,
          likesCount: story.isLiked
              ? story.likesCount - 1
              : story.likesCount + 1,
        );
        updatedAdvisorSpecialList = List.from(state.advisorSpecialStories);
        updatedAdvisorSpecialList[advisorSpecialIndex] = userStory.copyWith(
          stories: updatedStories,
        );
      }
    }

    // ── 5. Update myStories (for self-story ring) ─────────────────────────
    UserStoriesModel? updatedMyStories = state.myStories;
    if (isMine && updatedMyStories != null) {
      final storyIndex = updatedMyStories.stories.indexWhere(
        (s) => s.id == storyId,
      );
      if (storyIndex != -1) {
        final story = updatedMyStories.stories[storyIndex];
        final updatedStories = List<StoryModel>.from(updatedMyStories.stories);
        updatedStories[storyIndex] = story.copyWith(
          isLiked: !story.isLiked,
          likesCount: story.isLiked
              ? story.likesCount - 1
              : story.likesCount + 1,
        );
        updatedMyStories = updatedMyStories.copyWith(stories: updatedStories);
      }
    }

    emit(
      state.copyWith(
        storiesList: updatedList ?? state.storiesList,
        mySpecialStories: updatedMySpecialList ?? state.mySpecialStories,
        advisorSpecialStories:
            updatedAdvisorSpecialList ?? state.advisorSpecialStories,
        myStories: updatedMyStories,
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
        // 1. Update storiesList (Home)
        final userStoryIndex = state.storiesList.indexWhere(
          (us) => us.userId == userId,
        );
        List<UserStoriesModel>? updatedList;
        if (userStoryIndex != -1) {
          final userStory = state.storiesList[userStoryIndex];
          final updatedStories = userStory.stories
              .where((s) => s.id != storyId)
              .toList();
          updatedList = List<UserStoriesModel>.from(state.storiesList);
          if (updatedStories.isEmpty) {
            updatedList.removeAt(userStoryIndex);
          } else {
            updatedList[userStoryIndex] = userStory.copyWith(
              stories: updatedStories,
              storiesCount: updatedStories.length,
            );
          }
        }

        // 2. Update mySpecialStories (My Profile)
        final mySpecialIndex = state.mySpecialStories.indexWhere(
          (us) => us.userId == userId,
        );
        List<UserStoriesModel>? updatedMySpecialList;
        if (mySpecialIndex != -1) {
          final userStory = state.mySpecialStories[mySpecialIndex];
          final updatedStories = userStory.stories
              .where((s) => s.id != storyId)
              .toList();
          updatedMySpecialList = List<UserStoriesModel>.from(
            state.mySpecialStories,
          );
          if (updatedStories.isEmpty) {
            updatedMySpecialList.removeAt(mySpecialIndex);
          } else {
            updatedMySpecialList[mySpecialIndex] = userStory.copyWith(
              stories: updatedStories,
              storiesCount: updatedStories.length,
            );
          }
        }

        // 3. Update advisorSpecialStories (Other Advisor Profile)
        final advisorSpecialIndex = state.advisorSpecialStories.indexWhere(
          (us) => us.userId == userId,
        );
        List<UserStoriesModel>? updatedAdvisorSpecialList;
        if (advisorSpecialIndex != -1) {
          final userStory = state.advisorSpecialStories[advisorSpecialIndex];
          final updatedStories = userStory.stories
              .where((s) => s.id != storyId)
              .toList();
          updatedAdvisorSpecialList = List<UserStoriesModel>.from(
            state.advisorSpecialStories,
          );
          if (updatedStories.isEmpty) {
            updatedAdvisorSpecialList.removeAt(advisorSpecialIndex);
          } else {
            updatedAdvisorSpecialList[advisorSpecialIndex] = userStory.copyWith(
              stories: updatedStories,
              storiesCount: updatedStories.length,
            );
          }
        }

        emit(
          state.copyWith(
            storiesList: updatedList ?? state.storiesList,
            mySpecialStories: updatedMySpecialList ?? state.mySpecialStories,
            advisorSpecialStories:
                updatedAdvisorSpecialList ?? state.advisorSpecialStories,
          ),
        );

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
          // 1. Update storiesList (Home)
          final userStoryIndex = state.storiesList.indexWhere(
            (us) => us.userId == userId,
          );
          List<UserStoriesModel>? updatedList;
          if (userStoryIndex != -1) {
            final userStory = state.storiesList[userStoryIndex];
            final updatedStories = userStory.stories
                .where((s) => s.id != storyId)
                .toList();
            updatedList = List<UserStoriesModel>.from(state.storiesList);
            if (updatedStories.isEmpty) {
              updatedList.removeAt(userStoryIndex);
            } else {
              updatedList[userStoryIndex] = userStory.copyWith(
                stories: updatedStories,
                storiesCount: updatedStories.length,
              );
            }
          }

          // 2. Update mySpecialStories (My Profile)
          final mySpecialIndex = state.mySpecialStories.indexWhere(
            (us) => us.userId == userId,
          );
          List<UserStoriesModel>? updatedMySpecialList;
          if (mySpecialIndex != -1) {
            final userStory = state.mySpecialStories[mySpecialIndex];
            final updatedStories = userStory.stories
                .where((s) => s.id != storyId)
                .toList();
            updatedMySpecialList = List<UserStoriesModel>.from(
              state.mySpecialStories,
            );
            if (updatedStories.isEmpty) {
              updatedMySpecialList.removeAt(mySpecialIndex);
            } else {
              updatedMySpecialList[mySpecialIndex] = userStory.copyWith(
                stories: updatedStories,
                storiesCount: updatedStories.length,
              );
            }
          }

          // 3. Update advisorSpecialStories (Other Advisor Profile)
          final advisorSpecialIndex = state.advisorSpecialStories.indexWhere(
            (us) => us.userId == userId,
          );
          List<UserStoriesModel>? updatedAdvisorSpecialList;
          if (advisorSpecialIndex != -1) {
            final userStory = state.advisorSpecialStories[advisorSpecialIndex];
            final updatedStories = userStory.stories
                .where((s) => s.id != storyId)
                .toList();
            updatedAdvisorSpecialList = List<UserStoriesModel>.from(
              state.advisorSpecialStories,
            );
            if (updatedStories.isEmpty) {
              updatedAdvisorSpecialList.removeAt(advisorSpecialIndex);
            } else {
              updatedAdvisorSpecialList[advisorSpecialIndex] = userStory
                  .copyWith(
                    stories: updatedStories,
                    storiesCount: updatedStories.length,
                  );
            }
          }

          emit(
            state.copyWith(
              storiesList: updatedList ?? state.storiesList,
              mySpecialStories: updatedMySpecialList ?? state.mySpecialStories,
              advisorSpecialStories:
                  updatedAdvisorSpecialList ?? state.advisorSpecialStories,
            ),
          );

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
        // 1. Update storiesList (Home)
        final userStoryIndex = state.storiesList.indexWhere(
          (us) => us.userId == userId,
        );
        List<UserStoriesModel>? updatedList;
        if (userStoryIndex != -1) {
          final userStory = state.storiesList[userStoryIndex];
          final updatedStories = userStory.stories
              .where((s) => s.id != storyId)
              .toList();
          updatedList = List<UserStoriesModel>.from(state.storiesList);
          if (updatedStories.isEmpty) {
            updatedList.removeAt(userStoryIndex);
          } else {
            updatedList[userStoryIndex] = userStory.copyWith(
              stories: updatedStories,
              storiesCount: updatedStories.length,
            );
          }
        }

        // 2. Update mySpecialStories (My Profile)
        final mySpecialIndex = state.mySpecialStories.indexWhere(
          (us) => us.userId == userId,
        );
        List<UserStoriesModel>? updatedMySpecialList;
        if (mySpecialIndex != -1) {
          final userStory = state.mySpecialStories[mySpecialIndex];
          final updatedStories = userStory.stories
              .where((s) => s.id != storyId)
              .toList();
          updatedMySpecialList = List<UserStoriesModel>.from(
            state.mySpecialStories,
          );
          if (updatedStories.isEmpty) {
            updatedMySpecialList.removeAt(mySpecialIndex);
          } else {
            updatedMySpecialList[mySpecialIndex] = userStory.copyWith(
              stories: updatedStories,
              storiesCount: updatedStories.length,
            );
          }
        }

        // 3. Update advisorSpecialStories (Other Advisor Profile)
        final advisorSpecialIndex = state.advisorSpecialStories.indexWhere(
          (us) => us.userId == userId,
        );
        List<UserStoriesModel>? updatedAdvisorSpecialList;
        if (advisorSpecialIndex != -1) {
          final userStory = state.advisorSpecialStories[advisorSpecialIndex];
          final updatedStories = userStory.stories
              .where((s) => s.id != storyId)
              .toList();
          updatedAdvisorSpecialList = List<UserStoriesModel>.from(
            state.advisorSpecialStories,
          );
          if (updatedStories.isEmpty) {
            updatedAdvisorSpecialList.removeAt(advisorSpecialIndex);
          } else {
            updatedAdvisorSpecialList[advisorSpecialIndex] = userStory.copyWith(
              stories: updatedStories,
              storiesCount: updatedStories.length,
            );
          }
        }

        emit(
          state.copyWith(
            storiesList: updatedList ?? state.storiesList,
            mySpecialStories: updatedMySpecialList ?? state.mySpecialStories,
            advisorSpecialStories:
                updatedAdvisorSpecialList ?? state.advisorSpecialStories,
          ),
        );

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
        // 1. Update storiesList (Home)
        final userStoryIndex = state.storiesList.indexWhere(
          (us) => us.userId == userId,
        );
        List<UserStoriesModel>? updatedList;
        if (userStoryIndex != -1) {
          final userStory = state.storiesList[userStoryIndex];
          final storyIndex = userStory.stories.indexWhere(
            (s) => s.id == storyId,
          );
          if (storyIndex != -1) {
            final updatedStories = List<StoryModel>.from(userStory.stories);
            updatedStories[storyIndex] = updatedStories[storyIndex].copyWith(
              isSpecial: true,
            );
            updatedList = List<UserStoriesModel>.from(state.storiesList);
            updatedList[userStoryIndex] = userStory.copyWith(
              stories: updatedStories,
            );
          }
        }

        // 2. Update mySpecialStories (My Profile)
        // Find the story from storiesList to add it to mySpecialStories
        StoryModel? theStory;
        if (updatedList != null) {
          theStory = updatedList
              .where((us) => us.userId == userId)
              .firstOrNull
              ?.stories
              .where((s) => s.id == storyId)
              .firstOrNull;
        }
        theStory ??= state.storiesList
            .where((us) => us.userId == userId)
            .firstOrNull
            ?.stories
            .where((s) => s.id == storyId)
            .firstOrNull;

        final mySpecialIndex = state.mySpecialStories.indexWhere(
          (us) => us.userId == userId,
        );
        List<UserStoriesModel>? updatedMySpecialList;
        if (mySpecialIndex != -1) {
          // User already in special list — update or add the story
          final userStory = state.mySpecialStories[mySpecialIndex];
          final storyIndex = userStory.stories.indexWhere(
            (s) => s.id == storyId,
          );
          updatedMySpecialList = List<UserStoriesModel>.from(
            state.mySpecialStories,
          );
          if (storyIndex != -1) {
            final updatedStories = List<StoryModel>.from(userStory.stories);
            updatedStories[storyIndex] = updatedStories[storyIndex].copyWith(
              isSpecial: true,
            );
            updatedMySpecialList[mySpecialIndex] = userStory.copyWith(
              stories: updatedStories,
              storiesCount: updatedStories.length,
            );
          } else if (theStory != null) {
            // Story not yet in special list — prepend it
            final updatedStories = [
              theStory.copyWith(isSpecial: true),
              ...userStory.stories,
            ];
            updatedMySpecialList[mySpecialIndex] = userStory.copyWith(
              stories: updatedStories,
              storiesCount: updatedStories.length,
            );
          }
        } else if (theStory != null) {
          // User not in special list at all — create a new entry
          final sourceUser = state.storiesList
              .where((us) => us.userId == userId)
              .firstOrNull;
          final newUserStory = UserStoriesModel(
            userId: userId,
            name: sourceUser?.name ?? kCurrentUserData?.name ?? '',
            image: sourceUser?.image ?? kCurrentUserData?.image ?? '',
            isFollowed: false,
            isViewedByMe: false,
            allViewed: false,
            storiesCount: 1,
            stories: [theStory.copyWith(isSpecial: true)],
          );
          updatedMySpecialList = [newUserStory, ...state.mySpecialStories];
        }

        // 3. Update advisorSpecialStories (Other Advisor Profile)
        final advisorSpecialIndex = state.advisorSpecialStories.indexWhere(
          (us) => us.userId == userId,
        );
        List<UserStoriesModel>? updatedAdvisorSpecialList;
        if (advisorSpecialIndex != -1) {
          final userStory = state.advisorSpecialStories[advisorSpecialIndex];
          final storyIndex = userStory.stories.indexWhere(
            (s) => s.id == storyId,
          );
          if (storyIndex != -1) {
            final updatedStories = List<StoryModel>.from(userStory.stories);
            updatedStories[storyIndex] = updatedStories[storyIndex].copyWith(
              isSpecial: true,
            );
            updatedAdvisorSpecialList = List<UserStoriesModel>.from(
              state.advisorSpecialStories,
            );
            updatedAdvisorSpecialList[advisorSpecialIndex] = userStory.copyWith(
              stories: updatedStories,
            );
          }
        }

        emit(
          state.copyWith(
            storiesList: updatedList ?? state.storiesList,
            mySpecialStories: updatedMySpecialList ?? state.mySpecialStories,
            advisorSpecialStories:
                updatedAdvisorSpecialList ?? state.advisorSpecialStories,
          ),
        );

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
            StoriesEventBus.instance.updateUploadProgress(
              CubitStates.loading,
              progress,
            );
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
          // 1. Update main storiesList
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

          // mySpecialStories and advisorSpecialStories are NOT updated here.
          // A newly created story is NOT special by default — it only appears
          // in the special section after the user explicitly marks it as special.

          emit(state.copyWith(storiesList: currentList));

          // 4. Also update myStories optimistically
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
