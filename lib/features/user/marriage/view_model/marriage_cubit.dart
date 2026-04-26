import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/animation.dart';
import 'package:tayseer/features/user/interactions/data/Model/interaction_usermodel%20.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_event_bus.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_state.dart';
import 'package:tayseer/features/user/marriage/repositories/marriage_repository.dart';
import 'package:tayseer/my_import.dart';

class MarriageCubit extends Cubit<MarriageState> {
  MarriageCubit({
    MarriageRepository? repository,
    this.seedPersonId,
    this.seedIsFavorite = false,
    this.interactionUser,
  }) : _repo = repository ?? getIt<MarriageRepository>(),
       super(
         MarriageState(
           favoritedIds: {
             if ((seedPersonId?.isNotEmpty ?? false) && seedIsFavorite)
               seedPersonId!,
             if (interactionUser != null && interactionUser.isFavorite)
               interactionUser.userId,
           },
         ),
       ) {
    _filterSubscription = MarriageEventBus.instance.onFilterApplied.listen(
      (filters) => fetchMarriageProfile(filters: filters),
    );
    _switchToMarriageTabSub = MarriageEventBus.instance.onSwitchToMarriageTab
        .listen((_) => setMarriageTab(true));
  }

  final MarriageRepository _repo;
  late final StreamSubscription<Map<String, dynamic>> _filterSubscription;
  StreamSubscription? _switchToMarriageTabSub;

  final String? seedPersonId;
  final bool seedIsFavorite;
  final InteractionUserModel? interactionUser;

  // ═══ Animation ═══
  AnimationController? _cardController;
  CurvedAnimation? _cardAnimation;

  void initAnimation(TickerProvider vsync) {
    if (_cardController != null) return;
    _cardController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 180), // ✅ كانت 350
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController!,
      curve: Curves.easeOutCubic,
    );
    _cardController!.addListener(_onAnimationTick);
  }

  void _onAnimationTick() {
    final newProgress = _cardAnimation?.value ?? 0;
    if ((state.swipeProgress - newProgress).abs() > 0.005) {
      emit(state.copyWith(swipeProgress: newProgress));
    }
  }

  void emitSwipeLikeDislikeAnimation({required double direction}) {
    if (state.isAnimating) return; // ✅ امنع أي call تاني لحد ما الأول يخلص

    emit(
      state.copyWith(
        swipeDirection: direction,
        isAnimating: true,
        swipeProgress: 1,
      ),
    );

    Future.delayed(const Duration(milliseconds: 250), () {
      // ✅ كانت 300
      if (isClosed) return;
      emit(
        state.copyWith(swipeDirection: 0, swipeProgress: 0, isAnimating: false),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // FETCH
  // ═══════════════════════════════════════════════════════════════
  Future<void> fetchMarriageProfile({
    Map<String, dynamic>? filters,
    String? seedFavoriteId,
  }) async {
    emit(
      state.copyWith(
        marriageProfileState: CubitStates.loading,
        errorMessage: null,
        activeFilters: filters ?? state.activeFilters,
      ),
    );

    final results = await Future.wait([
      _repo.getMarriageProfile("1", filters: state.activeFilters),
      _repo.getFavoriteIds(),
    ]);

    final profileResult = results[0] as Either<Failure, UsersMarriageResponse>;
    final favoritesResult = results[1] as Either<Failure, List<String>>;

    final fetchedFavoriteIds = favoritesResult.fold(
      (_) => <String>{},
      (ids) => ids.toSet(),
    );

    profileResult.fold(
      (failure) {
        if (isClosed) return;

        if (interactionUser != null) {
          _emitFromInteractionUser(
            fetchedFavoriteIds: fetchedFavoriteIds,
            seedFavoriteId: seedFavoriteId,
          );
        } else if (seedPersonId != null && seedPersonId!.isNotEmpty) {
          final placeholder = UserItem(
            user: User(id: seedPersonId),
            answers: null,
            isPartialData: true,
          );
          emit(
            state.copyWith(
              marriageProfileState: CubitStates.loading,
              currentIndex: 0,
              allUsers: [placeholder],
              currentPage: 1,
              totalPages: 1,
              favoritedIds: {...state.favoritedIds, ...fetchedFavoriteIds},
            ),
          );
          fetchSpecificProfile(seedPersonId!);
        } else {
          emit(
            state.copyWith(
              marriageProfileState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (profile) {
        if (isClosed) return;

        final favoritesFromUsers = (profile.data?.users ?? [])
            .where((item) => item.user?.isFavorite == true)
            .map((item) => item.user?.id ?? '')
            .where((id) => id.isNotEmpty)
            .toSet();

        final mergedFavorites = {
          ...state.favoritedIds,
          ...fetchedFavoriteIds,
          ...favoritesFromUsers,
          if (seedFavoriteId != null && seedFavoriteId.isNotEmpty)
            seedFavoriteId,
          if (seedPersonId != null &&
              seedIsFavorite &&
              seedPersonId!.isNotEmpty)
            seedPersonId!,
          if (interactionUser != null && interactionUser!.isFavorite)
            interactionUser!.userId,
        };

        final serverUsers = profile.data?.users ?? [];
        List<UserItem> finalUsers = serverUsers;

        if (seedPersonId != null) {
          final found = serverUsers.any((u) => u.user?.id == seedPersonId);
          if (!found) {
            if (interactionUser != null) {
              final seededItem = _buildUserItemFromInteraction(
                interactionUser!,
              );
              finalUsers = [seededItem, ...serverUsers];
            } else {
              final placeholder = UserItem(
                user: User(id: seedPersonId),
                answers: null,
                isPartialData: true,
              );
              finalUsers = [placeholder, ...serverUsers];
            }
          }
        }

        final firstIsPartial =
            finalUsers.isNotEmpty && finalUsers.first.isPartialData;

        emit(
          state.copyWith(
            marriageProfileState: firstIsPartial
                ? CubitStates.loading
                : CubitStates.success,
            profile: profile,
            currentIndex: 0,
            allUsers: finalUsers,
            currentPage: profile.data?.pagination?.currentPage ?? 1,
            totalPages: profile.data?.pagination?.totalPages ?? 1,
            favoritedIds: mergedFavorites,
            regardsLeft: profile.data?.regardsLeft,
            likesLeft: profile.data?.likesLeft,
            // ✅ اقرأ requiresSubscription من users-for-marry مباشرة
            requiresSubscription: profile.data?.requiresSubscription ?? false,
          ),
        );

        // ✅ Sync regardsLeft to InteractionsCubit
        try {
          final interactionsCubit = getIt<InteractionsCubit>();
          interactionsCubit.updateLimits(
            regardsLeft: profile.data?.regardsLeft,
          );
        } catch (_) {}

        if (seedPersonId != null) {
          final hasPartial = finalUsers.any(
            (u) => u.user?.id == seedPersonId && u.isPartialData,
          );
          if (hasPartial) {
            fetchSpecificProfile(seedPersonId!);
          }
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FETCH ONLY SPECIFIC PROFILE
  // ═══════════════════════════════════════════════════════════════
  Future<void> fetchOnlySpecificProfile(String targetPersonId) async {
    final existing = state.allUsers.firstWhere(
      (u) => u.user?.id == targetPersonId && !u.isPartialData,
      orElse: () => UserItem(user: User(id: ''), answers: null),
    );
    if (existing.user?.id == targetPersonId) return;

    emit(
      state.copyWith(
        marriageProfileState: CubitStates.loading,
        allUsers: [
          UserItem(
            user: User(id: targetPersonId),
            answers: null,
            isPartialData: true,
          ),
        ],
        currentIndex: 0,
      ),
    );

    final result = await _repo.getProfileById(targetPersonId);

    result.fold(
      (failure) {
        if (isClosed) return;
        emit(
          state.copyWith(
            marriageProfileState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (userItem) {
        if (isClosed) return;
        emit(
          state.copyWith(
            allUsers: [userItem],
            currentIndex: 0,
            marriageProfileState: CubitStates.success,
          ),
        );
        fetchNotificationCount();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FETCH SPECIFIC PROFILE
  // ═══════════════════════════════════════════════════════════════
  Future<void> fetchSpecificProfile(String targetPersonId) async {
    final alreadyHasFullData = state.allUsers.any(
      (u) =>
          u.user?.id == targetPersonId && u.answers != null && !u.isPartialData,
    );
    if (alreadyHasFullData) return;

    if (interactionUser == null || interactionUser!.userId != targetPersonId) {
      _ensurePlaceholderExists(targetPersonId);
    }

    if (state.marriageProfileState != CubitStates.loading) {
      emit(state.copyWith(marriageProfileState: CubitStates.loading));
    }

    final result = await _repo.getProfileById(targetPersonId);

    result.fold((_) => _fetchSpecificProfileFallback(targetPersonId), (
      userItem,
    ) {
      if (isClosed) return;
      final updatedUsers = <UserItem>[
        userItem,
        ...state.allUsers.where((u) => u.user?.id != targetPersonId),
      ];
      emit(
        state.copyWith(
          allUsers: updatedUsers,
          currentIndex: 0,
          marriageProfileState: CubitStates.success,
        ),
      );
      fetchNotificationCount();
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // FETCH NOTIFICATION COUNT
  // ═══════════════════════════════════════════════════════════════
  Future<void> fetchNotificationCount() async {
    final result = await _repo.getInteractionNotificationCount();
    result.fold(
      (failure) => print('❌ fetchNotificationCount failed: ${failure.message}'),
      (model) {
        emit(
          state.copyWith(
            interactionsNotificationCount: model.total,
            likesNotificationCount: model.likes,
            favoritesNotificationCount: model.favorites,
            regardsNotificationCount: model.regards,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SYNC NOTIFICATION COUNT FROM INTERACTIONS CUBIT
  // ═══════════════════════════════════════════════════════════════
  void syncNotificationCountFromInteractions(
    int total,
    int likes,
    int favorites,
    int regards,
  ) {
    if (isClosed) return;
    emit(
      state.copyWith(
        interactionsNotificationCount: total,
        likesNotificationCount: likes,
        favoritesNotificationCount: favorites,
        regardsNotificationCount: regards,
      ),
    );
  }

  Future<void> fetchAndSyncNotificationCount() async {
    final interactionsCubit = getIt<InteractionsCubit>();
    await interactionsCubit.fetchAndSyncNotificationCount();
    if (isClosed) return;
    final interactionsState = interactionsCubit.state;
    syncNotificationCountFromInteractions(
      interactionsState.totalNotificationCount,
      interactionsState.likesNotificationCount,
      interactionsState.favoritesNotificationCount,
      interactionsState.regardsNotificationCount,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // USER INTERACTION
  // ═══════════════════════════════════════════════════════════════
  Future<void> userInteraction({
    required String personId,
    required String interactionType,
    bool countView = false,
  }) async {
    // ✅ لو requiresSubscription = true في الـ state، اعرض sheet الاشتراك مباشرة
    if (state.requiresSubscription) {
      emit(state.copyWith(
        userInteractionState: CubitStates.failure,
        requiresSubscription: true,
        showActionSnackbar: false,
      ));
      return;
    }

    final result = await _repo.userInteraction(
      personId: personId,
      interactionType: interactionType,
      countView: countView,
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        final data = failure is ServerFailure ? failure.data : null;
        final likesLeft = data?['likesLeft'] as int?;
        final regardsLeft = data?['regardsLeft'] as int?;
        final requiresSubscription = data?['requiresSubscription'] as bool? ?? false;
        emit(
          state.copyWith(
            userInteractionState: CubitStates.failure,
            errorMessage: failure.message,
            showActionSnackbar: false,
            likesLeft: likesLeft,
            regardsLeft: regardsLeft,
            requiresSubscription: requiresSubscription,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            userInteractionState: CubitStates.success,
            showActionSnackbar: false,
          ),
        );
        fetchNotificationCount();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SEND REGARD
  // ═══════════════════════════════════════════════════════════════
  Future<void> sendRegard({
    required String personId,
    bool countView = false,
  }) async {
    // ✅ لو requiresSubscription = true في الـ state، اعرض sheet الاشتراك مباشرة
    if (state.requiresSubscription) {
      emit(state.copyWith(
        sendRegardState: CubitStates.failure,
        requiresSubscription: true,
        showActionSnackbar: true,
      ));
      return;
    }
    // ✅ لو regardsLeft = 0 في الـ state، ارجع failure مباشرة
    if (state.regardsLeft == 0) {
      emit(
        state.copyWith(
          sendRegardState: CubitStates.failure,
          errorMessage: null,
          showActionSnackbar: true,
          regardsLeft: 0,
        ),
      );
      return;
    }

    final result = await _repo.sendRegard(
      personId: personId,
      countView: countView,
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        final data = failure is ServerFailure ? failure.data : null;
        final likesLeft = data?['likesLeft'] as int?;
        final regardsLeftFromData = data?['regardsLeft'] as int?;
        final regardsLeft = regardsLeftFromData ??
            (failure.message?.toLowerCase().contains('no regards') == true ? 0 : null);
        final requiresSubscription = data?['requiresSubscription'] as bool? ?? false;
        emit(
          state.copyWith(
            sendRegardState: CubitStates.failure,
            errorMessage: failure.message,
            showActionSnackbar: true,
            likesLeft: likesLeft,
            regardsLeft: regardsLeft,
            requiresSubscription: requiresSubscription,
          ),
        );
      },
      (regardsLeft) {
        emit(
          state.copyWith(
            sendRegardState: CubitStates.success,
            showActionSnackbar: true,
            regardsLeft: regardsLeft,
          ),
        );
        fetchNotificationCount();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SEND REGARD TEXT
  // ═══════════════════════════════════════════════════════════════
  Future<void> sendRegardText({
    required String personId,
    required String text,
    bool countView = false,
  }) async {
    // ✅ لو requiresSubscription = true في الـ state، اعرض sheet الاشتراك مباشرة
    if (state.requiresSubscription) {
      emit(state.copyWith(
        sendRegardTextState: CubitStates.failure,
        requiresSubscription: true,
        showActionSnackbar: true,
      ));
      return;
    }
    // ✅ لو regardsLeft = 0 في الـ state، ارجع failure مباشرة بدون API call
    if (state.regardsLeft == 0) {
      emit(
        state.copyWith(
          sendRegardTextState: CubitStates.failure,
          errorMessage: null,
          showActionSnackbar: true,
          regardsLeft: 0,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        sendRegardTextState: CubitStates.initial,
        errorMessage: null,
        showActionSnackbar: false,
      ),
    );

    final result = await _repo.sendRegard(
      personId: personId,
      text: text,
      countView: countView,
    );

    result.fold(
      (failure) {
        final data = failure is ServerFailure ? failure.data : null;
        final regardsLeftFromData = data?['regardsLeft'] as int?;
        final regardsLeft = regardsLeftFromData ??
            (failure.message?.toLowerCase().contains('no regards') == true ? 0 : null);
        final requiresSubscription = data?['requiresSubscription'] as bool? ?? false;
        emit(
          state.copyWith(
            sendRegardTextState: CubitStates.failure,
            errorMessage: failure.message,
            showActionSnackbar: true,
            regardsLeft: regardsLeft,
            requiresSubscription: requiresSubscription,
          ),
        );
      },
      (regardsLeft) => emit(
        state.copyWith(
          sendRegardTextState: CubitStates.success,
          showActionSnackbar: true,
          regardsLeft: regardsLeft,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ENSURE PLACEHOLDER EXISTS
  // ═══════════════════════════════════════════════════════════════
  void _ensurePlaceholderExists(String targetPersonId) {
    final exists = state.allUsers.any((u) => u.user?.id == targetPersonId);
    if (exists) return;

    final placeholder = UserItem(
      user: User(id: targetPersonId),
      answers: null,
      isPartialData: true,
    );

    emit(
      state.copyWith(
        allUsers: [
          placeholder,
          ...state.allUsers.where((u) => u.user?.id != targetPersonId),
        ],
        currentIndex: 0,
        marriageProfileState: CubitStates.loading,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FETCH SPECIFIC PROFILE FALLBACK
  // ═══════════════════════════════════════════════════════════════
  Future<void> _fetchSpecificProfileFallback(String targetPersonId) async {
    if (isClosed) return;

    final resultWithFilter = await _repo.getMarriageProfile(
      "1",
      filters: {'user_id': targetPersonId},
    );

    final foundInFilter = resultWithFilter.fold((_) => false, (profile) {
      if (isClosed) return false;
      final users = profile.data?.users ?? [];
      try {
        final specificUser = users.firstWhere(
          (u) => u.user?.id == targetPersonId,
        );
        final updatedUsers = <UserItem>[
          specificUser,
          ...state.allUsers.where((u) => u.user?.id != targetPersonId),
        ];
        emit(
          state.copyWith(
            allUsers: updatedUsers,
            currentIndex: 0,
            marriageProfileState: CubitStates.success,
          ),
        );
        return true;
      } catch (_) {
        return false;
      }
    });

    if (foundInFilter) return;

    final resultNoFilter = await _repo.getMarriageProfile("1", filters: {});

    resultNoFilter.fold(
      (_) {
        if (isClosed) return;
        emit(
          state.copyWith(
            marriageProfileState: CubitStates.failure,
            errorMessage: 'Failed to load profile',
          ),
        );
      },
      (profile) {
        if (isClosed) return;
        final users = profile.data?.users ?? [];
        try {
          final specificUser = users.firstWhere(
            (u) => u.user?.id == targetPersonId,
          );
          final updatedUsers = <UserItem>[
            specificUser,
            ...state.allUsers.where((u) => u.user?.id != targetPersonId),
          ];
          emit(
            state.copyWith(
              allUsers: updatedUsers,
              currentIndex: 0,
              marriageProfileState: CubitStates.success,
            ),
          );
        } catch (_) {
          if (!isClosed) {
            emit(
              state.copyWith(
                marriageProfileState: CubitStates.failure,
                errorMessage: 'Profile not found',
              ),
            );
          }
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD USER ITEM FROM INTERACTION
  // ═══════════════════════════════════════════════════════════════
  UserItem _buildUserItemFromInteraction(InteractionUserModel item) {
    final hasImage = item.image.isNotEmpty;
    final hasJob = item.job.isNotEmpty;

    return UserItem(
      isPartialData: true,
      user: User(
        id: item.userId,
        name: item.name,
        image: hasImage ? item.image : null,
        country: item.country,
        isFavorite: item.isFavorite,
        isVerified: item.isverified,
        imageBlur: item.isImageBlurred,
        age: item.age,
        about: UserAbout(job: hasJob ? item.job : null),
      ),
      answers: Answers(
        aboutMe: AboutMe(
          age: item.age > 0 ? item.age.toString() : null,
          country: item.country.isNotEmpty ? item.country : null,
        ),
        professionalLife: hasJob ? ProfessionalLife(job: item.job) : null,
        userMedia: hasImage ? UserMedia(image: [item.image]) : null,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // EMIT FROM INTERACTION USER
  // ═══════════════════════════════════════════════════════════════
  void _emitFromInteractionUser({
    required Set<String> fetchedFavoriteIds,
    String? seedFavoriteId,
  }) {
    if (isClosed) return;
    final item = interactionUser!;
    final seededItem = _buildUserItemFromInteraction(item);

    final mergedFavorites = {
      ...state.favoritedIds,
      ...fetchedFavoriteIds,
      if (item.isFavorite || seedIsFavorite) item.userId,
      if (seedFavoriteId != null && seedFavoriteId.isNotEmpty) seedFavoriteId,
    };

    emit(
      state.copyWith(
        marriageProfileState: CubitStates.loading,
        currentIndex: 0,
        allUsers: [seededItem],
        currentPage: 1,
        totalPages: 1,
        favoritedIds: mergedFavorites,
      ),
    );

    fetchSpecificProfile(item.userId);
  }

  // ═══════════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════════
  Future<void> refreshProfile() async {
    emit(state.copyWith(userHistory: []));
    await fetchMarriageProfile(filters: state.activeFilters);
  }

  // ═══════════════════════════════════════════════════════════════
  // CLEAR FILTERS AND REFRESH
  // ═══════════════════════════════════════════════════════════════
  Future<void> clearFiltersAndRefresh() async {
    emit(state.copyWith(activeFilters: {}, userHistory: []));
    await fetchMarriageProfile(filters: {});
  }

  // ═══════════════════════════════════════════════════════════════
  // REFRESH SILENTLY
  // ═══════════════════════════════════════════════════════════════
  Future<void> refreshProfileSilently() async {
    final results = await Future.wait([
      _repo.getMarriageProfile("1", filters: state.activeFilters),
      _repo.getFavoriteIds(),
    ]);

    final profileResult = results[0] as Either<Failure, UsersMarriageResponse>;
    final favoritesResult = results[1] as Either<Failure, List<String>>;

    final fetchedFavoriteIds = favoritesResult.fold(
      (_) => <String>{},
      (ids) => ids.toSet(),
    );

    profileResult.fold((_) {}, (profile) {
      if (isClosed) return;
      final mergedFavorites = {...state.favoritedIds, ...fetchedFavoriteIds};
      emit(
        state.copyWith(
          marriageProfileState: CubitStates.success,
          profile: profile,
          currentIndex: 0,
          allUsers: profile.data?.users ?? [],
          userHistory: [],
          currentPage: profile.data?.pagination?.currentPage ?? 1,
          totalPages: profile.data?.pagination?.totalPages ?? 1,
          favoritedIds: mergedFavorites,
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // LOAD MORE
  // ═══════════════════════════════════════════════════════════════
  Future<void> loadMoreUsers() async {
    if (state.isLoadingMore) return;
    if (state.currentPage >= state.totalPages) return;

    emit(state.copyWith(isLoadingMore: true));

    final result = await _repo.getMarriageProfile(
      (state.currentPage + 1).toString(),
      filters: state.activeFilters,
    );

    result.fold((_) => emit(state.copyWith(isLoadingMore: false)), (profile) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingMore: false,
          allUsers: [...state.allUsers, ...profile.data?.users ?? []],
          currentPage:
              profile.data?.pagination?.currentPage ?? state.currentPage,
          totalPages: profile.data?.pagination?.totalPages ?? state.totalPages,
          favoritedIds: state.favoritedIds,
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // SWIPE LIKE
  // ═══════════════════════════════════════════════════════════════
  Future<void> swipeLike({
    required String personId,
    required int usersLength,
    required bool hasSinglePerson,
  }) async {
    if (state.isAnimating || _cardController == null) return;
    emit(state.copyWith(swipeDirection: 1, isAnimating: true));
    await userInteraction(
      personId: personId,
      interactionType: 'like',
      countView: !hasSinglePerson,
    );
    // ✅ لو فشل بسبب likesLeft = 0 → ارجع بدون ما تشيل اليوزر
    if (state.userInteractionState == CubitStates.failure &&
        state.likesLeft == 0) {
      emit(state.copyWith(
        swipeDirection: 0,
        swipeProgress: 0,
        isAnimating: false,
      ));
      return;
    }
    await _cardController!.forward(from: 0);
    _onSwipeComplete(personId: personId, hasSinglePerson: hasSinglePerson);
  }

  // ═══════════════════════════════════════════════════════════════
  // SWIPE DISLIKE
  // ═══════════════════════════════════════════════════════════════
  Future<void> swipeDislike({
    required String personId,
    required int usersLength,
    required bool hasSinglePerson,
  }) async {
    if (state.isAnimating || _cardController == null) return;
    emit(state.copyWith(swipeDirection: -1, isAnimating: true));
    userInteraction(
      personId: personId,
      interactionType: 'dislike',
      countView: !hasSinglePerson,
    );
    await _cardController!.forward(from: 0);
    _onSwipeComplete(personId: personId, hasSinglePerson: hasSinglePerson);
  }

  // ═══════════════════════════════════════════════════════════════
  // ON SWIPE COMPLETE
  // ═══════════════════════════════════════════════════════════════
  void _onSwipeComplete({
    required String personId,
    required bool hasSinglePerson,
  }) {
    _cardController!.value = 0;

    if (!hasSinglePerson) {
      final removedUser = state.allUsers.firstWhere(
        (u) => u.user?.id == personId,
        orElse: () => UserItem(user: User(id: personId), answers: null),
      );
      final updatedHistory = [...state.userHistory, removedUser];

      final updatedUsers = state.allUsers
          .where((u) => u.user?.id != personId)
          .toList();
      final newLength = updatedUsers.length;

      if (newLength <= 5) loadMoreUsers();

      int newIndex = state.currentIndex;
      if (newIndex >= newLength) {
        newIndex = newLength > 0 ? newLength - 1 : 0;
      }

      emit(
        state.copyWith(
          allUsers: updatedUsers,
          userHistory: updatedHistory,
          currentIndex: newIndex,
          swipeDirection: 0,
          swipeProgress: 0,
          isAnimating: false,
          isScrollingDown: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          swipeDirection: 0,
          swipeProgress: 0,
          isAnimating: false,
          isScrollingDown: false,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // HISTORY
  // ═══════════════════════════════════════════════════════════════
  void hideHistoryView() => emit(state.copyWith(showHistory: false));

  void setHistoryFilter(String filter) =>
      emit(state.copyWith(selectedHistoryFilter: filter));

  // ═══════════════════════════════════════════════════════════════
  // SCROLL
  // ═══════════════════════════════════════════════════════════════
  void setScrollingDown(bool isDown) {
    if (state.isScrollingDown == isDown) return;
    emit(state.copyWith(isScrollingDown: isDown));
  }

  // ═══════════════════════════════════════════════════════════════
  // TABS
  // ═══════════════════════════════════════════════════════════════
  void setMarriageTab(bool isMarriage) {
    if (state.isMarriageTab == isMarriage) return;
    if (state.showHistory) {
      emit(state.copyWith(showHistory: false, isMarriageTab: isMarriage));
    } else {
      emit(state.copyWith(isMarriageTab: isMarriage));
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // BLOCK USER
  // ═══════════════════════════════════════════════════════════════
  Future<void> blockUser({required String personId}) async {
    _repo.blockUser(personId: personId);
    if (isClosed) return;

    final updatedUsers = state.allUsers
        .where((u) => u.user?.id != personId)
        .toList();

    final newLength = updatedUsers.length;
    int newIndex = state.currentIndex;
    if (newIndex >= newLength) {
      newIndex = newLength > 0 ? newLength - 1 : 0;
    }

    emit(
      state.copyWith(
        allUsers: updatedUsers,
        currentIndex: newIndex,
        isScrollingDown: false,
        blockActionState: CubitStates.success,
        showActionSnackbar: true,
      ),
    );

    if (newLength <= 5) loadMoreUsers();
    if (newLength == 0) refreshProfileSilently();
  }

  // ═══════════════════════════════════════════════════════════════
  // TOGGLE FAVORITE
  // ═══════════════════════════════════════════════════════════════
  Future<void> toggleLocalFavorite(
    String userId, {
    bool removeFromList = false,
    bool countView = false,
  }) async {
    final isCurrentlyFavorited = state.favoritedIds.contains(userId);
    final updatedFavorites = Set<String>.from(state.favoritedIds);

    if (isCurrentlyFavorited) {
      updatedFavorites.remove(userId);
    } else {
      updatedFavorites.add(userId);
    }

    if (removeFromList) {
      final removedUser = state.allUsers.firstWhere(
        (u) => u.user?.id == userId,
        orElse: () => UserItem(user: User(id: userId), answers: null),
      );
      final updatedHistory = [...state.userHistory, removedUser];

      final updatedUsers = state.allUsers
          .where((u) => u.user?.id != userId)
          .toList();
      final newLength = updatedUsers.length;
      int newIndex = state.currentIndex;
      if (newIndex >= newLength) {
        newIndex = newLength > 0 ? newLength - 1 : 0;
      }
      emit(
        state.copyWith(
          favoritedIds: updatedFavorites,
          allUsers: updatedUsers,
          userHistory: updatedHistory,
          currentIndex: newIndex,
          isScrollingDown: false,
        ),
      );
      if (newLength <= 5) loadMoreUsers();
    } else {
      emit(state.copyWith(favoritedIds: updatedFavorites));
    }

    final result = await _repo.toggleFavorite(
      userId: userId,
      isAdd: !isCurrentlyFavorited,
      countView: countView,
    );

    result.fold(
      (failure) {
        if (isClosed) return;
        final revertFavorites = Set<String>.from(state.favoritedIds);
        if (isCurrentlyFavorited) {
          revertFavorites.add(userId);
        } else {
          revertFavorites.remove(userId);
        }
        emit(state.copyWith(favoritedIds: revertFavorites));
      },
      (_) {
        fetchNotificationCount();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CLAMP INDEX
  // ═══════════════════════════════════════════════════════════════
  void clampCurrentIndex({required int usersLength}) {
    if (usersLength <= 0) return;
    if (state.currentIndex >= usersLength) {
      emit(state.copyWith(currentIndex: usersLength - 1));
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // UPDATE LIMITS
  // ═══════════════════════════════════════════════════════════════
  void updateLimits({int? likesLeft, int? regardsLeft}) {
    if (isClosed) return;
    emit(state.copyWith(likesLeft: likesLeft, regardsLeft: regardsLeft));
  }

  // ═══════════════════════════════════════════════════════════════
  // GO BACK TO PREVIOUS USER
  // ═══════════════════════════════════════════════════════════════
  void goBackToPreviousUser() {
    if (state.userHistory.isEmpty) return;

    final previousUser = state.userHistory.last;
    final updatedHistory = state.userHistory.sublist(
      0,
      state.userHistory.length - 1,
    );

    emit(
      state.copyWith(
        allUsers: [previousUser, ...state.allUsers],
        userHistory: updatedHistory,
        currentIndex: 0,
        isScrollingDown: false,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RESET STATE
  // ═══════════════════════════════════════════════════════════════
  void resetState() {
    emit(
      state.copyWith(
        userInteractionState: CubitStates.initial,
        sendRegardState: CubitStates.initial,
        sendRegardTextState: CubitStates.initial,
        blockActionState: CubitStates.initial,
        blockMessage: null,
        errorMessage: null,
        showActionSnackbar: false,
        requiresSubscription: false, // ✅ reset بعد ما نعرض الـ sheet
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SHOW HISTORY VIEW
  // ═══════════════════════════════════════════════════════════════
  Future<void> showHistoryView() async {
    final likesToSubtract = state.likesNotificationCount;

    emit(
      state.copyWith(
        showHistory: true,
        selectedHistoryFilter: "liked_you",
        likesNotificationCount: 0,
        interactionsNotificationCount:
            (state.interactionsNotificationCount - likesToSubtract).clamp(
              0,
              999,
            ),
      ),
    );

    await _repo.resetLikesNotificationCount();
  }

  // ═══════════════════════════════════════════════════════════════
  // RESET NOTIFICATION FOR FILTER
  // ═══════════════════════════════════════════════════════════════
  Future<void> resetNotificationForFilter(String filter) async {
    switch (filter) {
      case 'liked_you':
        final toSubtract = state.likesNotificationCount;
        if (toSubtract == 0) return;
        emit(
          state.copyWith(
            likesNotificationCount: 0,
            interactionsNotificationCount:
                (state.interactionsNotificationCount - toSubtract).clamp(
                  0,
                  999,
                ),
          ),
        );
        await _repo.resetLikesNotificationCount();
        break;

      case 'favorites':
        final toSubtract = state.favoritesNotificationCount;
        if (toSubtract == 0) return;
        emit(
          state.copyWith(
            favoritesNotificationCount: 0,
            interactionsNotificationCount:
                (state.interactionsNotificationCount - toSubtract).clamp(
                  0,
                  999,
                ),
          ),
        );
        await _repo.resetFavoritesNotificationCount();
        break;

      case 'sent_compliment':
        final toSubtract = state.regardsNotificationCount;
        if (toSubtract == 0) return;
        emit(
          state.copyWith(
            regardsNotificationCount: 0,
            interactionsNotificationCount:
                (state.interactionsNotificationCount - toSubtract).clamp(
                  0,
                  999,
                ),
          ),
        );
        await _repo.resetRegardsNotificationCount();
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // DISPOSE
  // ═══════════════════════════════════════════════════════════════
  @override
  Future<void> close() {
    _filterSubscription.cancel();
    _switchToMarriageTabSub?.cancel();
    _cardController?.removeListener(_onAnimationTick);
    _cardController?.dispose();
    return super.close();
  }
}
