import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/animation.dart';
import 'package:tayseer/features/user/interactions/data/Model/interaction_usermodel%20.dart';
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
       super(const MarriageState()) {
    // ✅ استمع لأحداث الـ EventBus
    _filterSubscription = MarriageEventBus.instance.onFilterApplied.listen(
      (filters) => fetchMarriageProfile(filters: filters),
    );

    // ✅ استمع للتحويل لتاب الزواج — هنا في الـ constructor مش في دالة منفصلة
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
      duration: const Duration(milliseconds: 350),
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

  // ═══════════════════════════════════════════════════════════
  // FETCH
  // ═══════════════════════════════════════════════════════════
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
          // ✅ جاي من interactions — نبني من interactionUser مباشرة
          _emitFromInteractionUser(
            fetchedFavoriteIds: fetchedFavoriteIds,
            seedFavoriteId: seedFavoriteId,
          );
        } else if (seedPersonId != null && seedPersonId!.isNotEmpty) {
          // ✅ جاي من deeplink أو نفس الـ gender — نعمل placeholder ونجيب البيانات
          final placeholder = UserItem(
            user: User(id: seedPersonId),
            answers: null,
          );
          emit(
            state.copyWith(
              marriageProfileState: CubitStates.success,
              currentIndex: 0,
              allUsers: [placeholder],
              currentPage: 1,
              totalPages: 1,
              favoritedIds: fetchedFavoriteIds,
            ),
          );
          // ✅ اجيب البيانات الحقيقية بعدها
          fetchSpecificProfile(seedPersonId!);
        } else {
          // ✅ مفيش seed — عرض الـ error
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
        };

        final serverUsers = profile.data?.users ?? [];
        List<UserItem> finalUsers = serverUsers;

        // ✅ لو في seedPersonId ومش موجود في النتايج
        if (seedPersonId != null) {
          final found = serverUsers.any((u) => u.user?.id == seedPersonId);
          if (!found) {
            if (interactionUser != null) {
              // ✅ عندنا interactionUser — نبني منه
              final seededItem = _buildUserItemFromInteraction(
                interactionUser!,
              );
              finalUsers = [seededItem, ...serverUsers];
            } else {
              // ✅ مفيش interactionUser — نحط placeholder بـ seedPersonId
              final placeholder = UserItem(
                user: User(id: seedPersonId),
                answers: null,
              );
              finalUsers = [placeholder, ...serverUsers];
            }
          }
        }

        emit(
          state.copyWith(
            marriageProfileState: CubitStates.success,
            profile: profile,
            currentIndex: 0,
            allUsers: finalUsers,
            currentPage: profile.data?.pagination?.currentPage ?? 1,
            totalPages: profile.data?.pagination?.totalPages ?? 1,
            favoritedIds: mergedFavorites,
          ),
        );

        // ✅ لو في placeholder (answers == null) — اجيب البيانات الحقيقية
        if (seedPersonId != null) {
          final hasPlaceholder = finalUsers.any(
            (u) => u.user?.id == seedPersonId && u.answers == null,
          );
          if (hasPlaceholder) {
            fetchSpecificProfile(seedPersonId!);
          }
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FETCH SPECIFIC PROFILE — المدخل الرئيسي
  // ═══════════════════════════════════════════════════════════════
  Future<void> fetchSpecificProfile(String targetPersonId) async {
    final alreadyHasData = state.allUsers.any(
      (u) => u.user?.id == targetPersonId && u.answers != null,
    );
    if (alreadyHasData) return;

    // ✅ لو جاي من interactionUser — ابني منه مباشرة
    if (interactionUser != null && interactionUser!.userId == targetPersonId) {
      final builtItem = _buildUserItemFromInteraction(interactionUser!);
      final updatedUsers = <UserItem>[
        builtItem,
        ...state.allUsers.where((u) => u.user?.id != targetPersonId),
      ];
      emit(state.copyWith(allUsers: updatedUsers, currentIndex: 0));
      return;
    }

    // ✅ تأكد من وجود placeholder
    _ensurePlaceholderExists(targetPersonId);

    // ✅ استخدم الـ endpoint المخصص
    final result = await _repo.getProfileById(targetPersonId);

    result.fold(
      (_) {
        // ✅ فشل — جرب الـ fallback القديم
        _fetchSpecificProfileFallback(targetPersonId);
      },
      (userItem) {
        if (isClosed) return;
        final updatedUsers = <UserItem>[
          userItem,
          ...state.allUsers.where((u) => u.user?.id != targetPersonId),
        ];
        emit(state.copyWith(allUsers: updatedUsers, currentIndex: 0));
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ENSURE PLACEHOLDER EXISTS
  // ═══════════════════════════════════════════════════════════════
  void _ensurePlaceholderExists(String targetPersonId) {
    final exists = state.allUsers.any((u) => u.user?.id == targetPersonId);
    if (exists) return;

    final placeholder = UserItem(user: User(id: targetPersonId), answers: null);

    emit(
      state.copyWith(
        allUsers: [
          placeholder,
          ...state.allUsers.where((u) => u.user?.id != targetPersonId),
        ],
        currentIndex: 0,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FETCH SPECIFIC PROFILE FALLBACK
  // ═══════════════════════════════════════════════════════════════
  Future<void> _fetchSpecificProfileFallback(String targetPersonId) async {
    if (isClosed) return;

    // ✅ جرب بـ user_id filter أولاً
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
        emit(state.copyWith(allUsers: updatedUsers, currentIndex: 0));
        return true;
      } catch (_) {
        return false;
      }
    });

    if (foundInFilter) return;

    // ✅ مش موجود بالـ filter — جرب بدون filter
    final resultNoFilter = await _repo.getMarriageProfile("1", filters: {});

    resultNoFilter.fold(
      (_) {
        // ✅ فشل — placeholder يفضل
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
          emit(state.copyWith(allUsers: updatedUsers, currentIndex: 0));
        } catch (_) {
          // ✅ مش موجود — السيرفر بيفلتره بسبب التفاعل
          // الـ UI يفضل بالـ placeholder
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BUILD USER ITEM FROM INTERACTION — بيبني UserItem كامل مع Answers
  // ═══════════════════════════════════════════════════════════
  UserItem _buildUserItemFromInteraction(InteractionUserModel item) {
    // ✅ تأكد إن الـ image مش فاضية
    final hasImage = item.image.isNotEmpty;
    final hasJob = item.job.isNotEmpty;

    return UserItem(
      user: User(
        id: item.userId,
        name: item.name,
        // ✅ لو image فاضية ابعت null مش string فاضية
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
          // ✅ لو age = 0 ابعت null
          age: item.age > 0 ? item.age.toString() : null,
          country: item.country.isNotEmpty ? item.country : null,
        ),
        professionalLife: hasJob ? ProfessionalLife(job: item.job) : null,
        // ✅ بس لو image حقيقية موجودة
        userMedia: hasImage ? UserMedia(image: [item.image]) : null,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // EMIT FROM INTERACTION USER
  // ═══════════════════════════════════════════════════════════
  void _emitFromInteractionUser({
    required Set<String> fetchedFavoriteIds,
    String? seedFavoriteId,
  }) {
    if (isClosed) return;
    final item = interactionUser!;

    // ✅ بنبني بـ answers مش null
    final seededItem = _buildUserItemFromInteraction(item);

    final mergedFavorites = {
      ...state.favoritedIds,
      ...fetchedFavoriteIds,
      if (item.isFavorite) item.userId,
      if (seedFavoriteId != null && seedFavoriteId.isNotEmpty) seedFavoriteId,
    };

    emit(
      state.copyWith(
        marriageProfileState: CubitStates.success,
        currentIndex: 0,
        allUsers: [seededItem],
        currentPage: 1,
        totalPages: 1,
        favoritedIds: mergedFavorites,
      ),
    );

    // ✅ مش محتاج fetchSpecificProfile — عنده بيانات كافية للعرض
  }

  // ═══════════════════════════════════════════════════════════
  // REFRESH
  // ═══════════════════════════════════════════════════════════
  Future<void> refreshProfile() async {
    await fetchMarriageProfile(filters: state.activeFilters);
  }

  // ═══════════════════════════════════════════════════════════
  // REFRESH SILENTLY
  // ═══════════════════════════════════════════════════════════
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
          currentPage: profile.data?.pagination?.currentPage ?? 1,
          totalPages: profile.data?.pagination?.totalPages ?? 1,
          favoritedIds: mergedFavorites,
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════
  // LOAD MORE
  // ═══════════════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════════════════
  // SWIPE LIKE
  // ═══════════════════════════════════════════════════════════
  Future<void> swipeLike({
    required String personId,
    required int usersLength,
    required bool hasSinglePerson,
  }) async {
    if (state.isAnimating || _cardController == null) return;
    emit(state.copyWith(swipeDirection: 1, isAnimating: true));
    userInteraction(personId: personId, interactionType: 'like');
    await _cardController!.forward(from: 0);
    _onSwipeComplete(personId: personId, hasSinglePerson: hasSinglePerson);
  }

  // ═══════════════════════════════════════════════════════════
  // SWIPE DISLIKE
  // ═══════════════════════════════════════════════════════════
  Future<void> swipeDislike({
    required String personId,
    required int usersLength,
    required bool hasSinglePerson,
  }) async {
    if (state.isAnimating || _cardController == null) return;
    emit(state.copyWith(swipeDirection: -1, isAnimating: true));
    userInteraction(personId: personId, interactionType: 'dislike');
    await _cardController!.forward(from: 0);
    _onSwipeComplete(personId: personId, hasSinglePerson: hasSinglePerson);
  }

  // ═══════════════════════════════════════════════════════════
  // ON SWIPE COMPLETE
  // ═══════════════════════════════════════════════════════════
  void _onSwipeComplete({
    required String personId,
    required bool hasSinglePerson,
  }) {
    _cardController!.value = 0;

    if (!hasSinglePerson) {
      final updatedUsers = state.allUsers
          .where((u) => u.user?.id != personId)
          .toList();
      final newLength = updatedUsers.length;

      if (newLength <= 3) loadMoreUsers();

      int newIndex = state.currentIndex;
      if (newIndex >= newLength) {
        newIndex = newLength > 0 ? newLength - 1 : 0;
      }

      emit(
        state.copyWith(
          allUsers: updatedUsers,
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

  // ═══════════════════════════════════════════════════════════
  // HISTORY
  // ═══════════════════════════════════════════════════════════
  void showHistoryView() => emit(
    state.copyWith(showHistory: true, selectedHistoryFilter: "liked_you"),
  );
  void hideHistoryView() => emit(state.copyWith(showHistory: false));
  void setHistoryFilter(String filter) =>
      emit(state.copyWith(selectedHistoryFilter: filter));

  // ═══════════════════════════════════════════════════════════
  // SCROLL
  // ═══════════════════════════════════════════════════════════
  void setScrollingDown(bool isDown) {
    if (state.isScrollingDown == isDown) return;
    emit(state.copyWith(isScrollingDown: isDown));
  }

  // ═══════════════════════════════════════════════════════════
  // TABS
  // ═══════════════════════════════════════════════════════════
  void setMarriageTab(bool isMarriage) {
    if (state.isMarriageTab == isMarriage) return;
    if (state.showHistory) {
      emit(state.copyWith(showHistory: false, isMarriageTab: isMarriage));
    } else {
      emit(state.copyWith(isMarriageTab: isMarriage));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // USER INTERACTION
  // ═══════════════════════════════════════════════════════════
  Future<void> userInteraction({
    required String personId,
    required String interactionType,
  }) async {
    final result = await _repo.userInteraction(
      personId: personId,
      interactionType: interactionType,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          userInteractionState: CubitStates.failure,
          errorMessage: failure.message,
          showActionSnackbar: false,
        ),
      ),
      (_) => emit(
        state.copyWith(
          userInteractionState: CubitStates.success,
          showActionSnackbar: false,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // REGARD
  // ═══════════════════════════════════════════════════════════
  Future<void> sendRegard({required String personId}) async {
    final result = await _repo.sendRegard(personId: personId);

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          sendRegardState: CubitStates.failure,
          errorMessage: failure.message,
          showActionSnackbar: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          sendRegardState: CubitStates.success,
          showActionSnackbar: true,
        ),
      ),
    );
  }

  Future<void> sendRegardText({
    required String personId,
    required String text,
  }) async {
    emit(
      state.copyWith(
        sendRegardTextState: CubitStates.initial,
        errorMessage: null,
        showActionSnackbar: false,
      ),
    );

    final result = await _repo.sendRegard(personId: personId, text: text);

    result.fold(
      (failure) => emit(
        state.copyWith(
          sendRegardTextState: CubitStates.failure,
          errorMessage: failure.message,
          showActionSnackbar: true,
        ),
      ),
      (_) => emit(
        state.copyWith(
          sendRegardTextState: CubitStates.success,
          showActionSnackbar: true,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BLOCK USER
  // ═══════════════════════════════════════════════════════════
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
      ),
    );

    if (newLength <= 3) loadMoreUsers();
    if (newLength == 0) refreshProfileSilently();
  }

  // ═══════════════════════════════════════════════════════════
  // TOGGLE FAVORITE
  // ═══════════════════════════════════════════════════════════
  Future<void> toggleLocalFavorite(
    String userId, {
    bool removeFromList = false,
  }) async {
    final isCurrentlyFavorited = state.favoritedIds.contains(userId);
    final updatedFavorites = Set<String>.from(state.favoritedIds);

    if (isCurrentlyFavorited) {
      updatedFavorites.remove(userId);
    } else {
      updatedFavorites.add(userId);
    }

    if (removeFromList) {
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
          currentIndex: newIndex,
          isScrollingDown: false,
        ),
      );
      if (newLength <= 3) loadMoreUsers();
    } else {
      emit(state.copyWith(favoritedIds: updatedFavorites));
    }

    final result = await _repo.toggleFavorite(
      userId: userId,
      isAdd: !isCurrentlyFavorited,
    );

    result.fold((failure) {
      if (isClosed) return;
      final revertFavorites = Set<String>.from(state.favoritedIds);
      if (isCurrentlyFavorited) {
        revertFavorites.add(userId);
      } else {
        revertFavorites.remove(userId);
      }
      emit(state.copyWith(favoritedIds: revertFavorites));
    }, (_) {});
  }

  // ═══════════════════════════════════════════════════════════
  // CLAMP INDEX
  // ═══════════════════════════════════════════════════════════
  void clampCurrentIndex({required int usersLength}) {
    if (usersLength <= 0) return;
    if (state.currentIndex >= usersLength) {
      emit(state.copyWith(currentIndex: usersLength - 1));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // RESET STATE
  // ═══════════════════════════════════════════════════════════
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
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DISPOSE
  // ═══════════════════════════════════════════════════════════
  @override
  Future<void> close() {
    _filterSubscription.cancel();
    _switchToMarriageTabSub?.cancel();
    _cardController?.removeListener(_onAnimationTick);
    _cardController?.dispose();
    return super.close();
  }
}
