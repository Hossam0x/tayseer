import 'dart:async';
import 'dart:developer';
import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/core/functions/set_advisor_status.dart';
import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/shared/home/data_source/posts_local_datasource.dart';
import 'package:tayseer/features/shared/home/model/image_and_name_model.dart';
import 'package:tayseer/features/shared/home/model/best_advisor_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/home/view_model/home_event_bus.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/features/user/my_space/data/model/session_start_model.dart';
import 'package:tayseer/core/utils/profile_event_bus.dart';
import 'package:tayseer/core/utils/post_event_bus.dart';
import 'package:tayseer/core/utils/notification_event_bus.dart';
import '../../../../my_import.dart';
import '../reposiotry/home_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository homeRepository;
  final ConnectivityCubit connectivityCubit;
  final PostsLocalDatasource localDatasource;
  static const int _pageSize = 5;

  // تتبع حالة الاتصال للتحكم في التصفح
  bool _isPaginationEnabled = true;
  StreamSubscription? _connectivitySubscription;
  late StreamSubscription<ProfileUpdateEvent> _profileSubscription;
  late StreamSubscription<PostEvent> _postEventSubscription;
  late StreamSubscription<PushNotificationReceivedEvent> _pushNotifSubscription;

  HomeCubit(
    this.homeRepository, {
    required this.connectivityCubit,
    required this.localDatasource,
  }) : super(const HomeState()) {
    _loadCachedUserData();
    _listenToConnectivity();
    _listenToProfileUpdates();
    _listenToPostEvents();
    _listenToPushNotifications();
  }

  void _listenToPushNotifications() {
    _pushNotifSubscription = NotificationEventBus
        .instance
        .onNotificationReceived
        .listen((_) {
          if (isClosed) return;
          fetchNameAndImage();
        });
  }

  void _listenToPostEvents() {
    _postEventSubscription = PostEventBus.instance.onPostEvent.listen((event) {
      if (isClosed) return;
      // تجاهل الـ events اللي HomeCubit نفسه بعتها
      if (event.sourceId == 'HomeCubit') return;
      _applyPostEvent(event);
    });
  }

  void _applyPostEvent(PostEvent event) {
    final postId = event.postId;
    // لو البوست مش موجود عندنا، مفيش حاجة نعملها
    if (_findPost(postId) == null) {
      // للـ deleted/archived/hidden/blocked: مش محتاجين البوست موجود
      if (event.type != PostEventType.deleted &&
          event.type != PostEventType.archived &&
          event.type != PostEventType.hidden &&
          event.type != PostEventType.blocked)
        return;
    }

    switch (event.type) {
      case PostEventType.reacted:
        emit(
          state.updatePostInAllCategories(
            postId,
            (p) => p.copyWith(
              likesCount: event.likesCount ?? p.likesCount,
              topReactions: event.topReactions ?? p.topReactions,
              myReaction: event.reactionType,
              clearMyReaction: event.reactionType == null,
            ),
          ),
        );
        break;

      case PostEventType.shared:
        emit(
          state.updatePostInAllCategories(
            postId,
            (p) => p.copyWith(
              sharesCount: event.sharesCount ?? p.sharesCount,
              isRepostedByMe: event.isRepostedByMe ?? p.isRepostedByMe,
            ),
          ),
        );
        break;

      case PostEventType.saved:
        emit(
          state.updatePostInAllCategories(
            postId,
            (p) => p.copyWith(isSaved: event.isSaved ?? p.isSaved),
          ),
        );
        break;

      case PostEventType.deleted:
        final newMap = <String?, CategoryPostsData>{};
        for (final entry in state.categoryPostsMap.entries) {
          newMap[entry.key] = entry.value.copyWith(
            posts: entry.value.posts.where((p) => p.postId != postId).toList(),
          );
        }
        emit(state.copyWith(categoryPostsMap: newMap));
        break;

      case PostEventType.archived:
        final newMap2 = <String?, CategoryPostsData>{};
        for (final entry in state.categoryPostsMap.entries) {
          newMap2[entry.key] = entry.value.copyWith(
            posts: entry.value.posts.where((p) => p.postId != postId).toList(),
          );
        }
        emit(state.copyWith(categoryPostsMap: newMap2));
        break;

      case PostEventType.hidden:
        emit(
          state.updatePostInAllCategories(
            postId,
            (p) => p.copyWith(isHidden: true),
          ),
        );
        break;

      case PostEventType.blocked:
        if (event.advisorId == null) break;
        final newMap3 = <String?, CategoryPostsData>{};
        for (final entry in state.categoryPostsMap.entries) {
          final updatedPosts = <PostModel>[];
          for (final p in entry.value.posts) {
            if (p.postId == postId) {
              updatedPosts.add(p.copyWith(isBlocked: true));
            } else if (p.advisorId == event.advisorId) {
              continue;
            } else {
              updatedPosts.add(p);
            }
          }
          newMap3[entry.key] = entry.value.copyWith(posts: updatedPosts);
        }
        emit(state.copyWith(categoryPostsMap: newMap3));
        break;

      case PostEventType.pollVoted:
        if (event.pollModel == null) break;
        emit(
          state.updatePostInAllCategories(
            postId,
            (p) => p.copyWith(pollModel: event.pollModel),
          ),
        );
        break;

      case PostEventType.commentCountUpdated:
        if (event.commentCountDelta == null) break;
        emit(
          state.updatePostInAllCategories(postId, (p) {
            final newCount = (p.commentsCount + event.commentCountDelta!).clamp(
              0,
              999999,
            );
            return p.copyWith(
              commentsCount: newCount,
              isCommented: event.isCommented ?? p.isCommented,
              isAnonymous: event.isAnonymous ?? p.isAnonymous,
            );
          }),
        );
        break;

      case PostEventType.commentCountSynced:
        if (event.commentCountTotal == null) break;
        emit(
          state.updatePostInAllCategories(
            postId,
            (p) => p.copyWith(commentsCount: event.commentCountTotal),
          ),
        );
        break;

      case PostEventType.commented:
        emit(
          state.updatePostInAllCategories(
            postId,
            (p) => p.copyWith(
              isCommented: true,
              isAnonymous: event.isAnonymous ?? p.isAnonymous,
            ),
          ),
        );
        break;

      case PostEventType.edited:
        if (event.updatedPost == null) break;
        emit(
          state.updatePostInAllCategories(postId, (_) => event.updatedPost!),
        );
        break;

      case PostEventType.unarchived:
        if (event.unarchivedPost == null) break;
        // أضيف البوست في أول كل category لو مش موجود فيها
        final uPost = event.unarchivedPost!;
        final newMap = <String?, CategoryPostsData>{};
        for (final entry in state.categoryPostsMap.entries) {
          final alreadyExists = entry.value.posts.any(
            (p) => p.postId == postId,
          );
          if (alreadyExists) {
            newMap[entry.key] = entry.value;
          } else {
            newMap[entry.key] = entry.value.copyWith(
              posts: [uPost, ...entry.value.posts],
            );
          }
        }
        emit(state.copyWith(categoryPostsMap: newMap));
        break;
    }
  }

  void _listenToProfileUpdates() {
    _profileSubscription = ProfileEventBus.instance.onProfileUpdated.listen((
      event,
    ) {
      if (isClosed) return;

      debugPrint('🏠 HomeCubit: profile update received → ${event.image}');

      // 1. تحديث الكاش المحلي
      CachNetwork.setData(key: kMyProfileImage, value: event.image);
      CachNetwork.setData(key: kMyProfileName, value: event.name);

      // 2. تحديث بيانات اليوزر في الهيدر
      final newData = ImageAndNameModel(
        image: event.image,
        name: event.name,
        notifications: state.homeInfo?.notifications ?? 0,
        approvalKey: state.homeInfo?.approvalKey ?? '',
      );

      var newState = state.copyWith(
        homeInfo: newData,
        fetchNameAndImageState: CubitStates.success,
      );

      // 3. تحديث صور اليوزر في البوستات الخاصة به (لو كان مستشار)
      final myId = kCurrentUserData?.id;
      if (myId != null) {
        final updatedMap = Map<String?, CategoryPostsData>.from(
          state.categoryPostsMap,
        );
        bool anyChanged = false;

        updatedMap.forEach((catId, data) {
          final postIndex = data.posts.indexWhere((p) => p.advisorId == myId);
          if (postIndex != -1) {
            final updatedPosts = data.posts.map((p) {
              if (p.advisorId == myId) {
                return p.copyWith(name: event.name, avatar: event.image);
              }
              return p;
            }).toList();
            updatedMap[catId] = data.copyWith(posts: updatedPosts);
            anyChanged = true;
          }
        });

        if (anyChanged) {
          newState = newState.copyWith(categoryPostsMap: updatedMap);
        }
      }

      emit(newState);
    });
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _profileSubscription.cancel();
    _postEventSubscription.cancel();
    _pushNotifSubscription.cancel();
    socketHelper.offAllForListener('HomeCubit_sessionStarted'); // ← أضف ده
    return super.close();
  }

  /// الاستماع لتغييرات الاتصال
  void _listenToConnectivity() {
    final isCurrentlyOnline = connectivityCubit.isOnline;
    _isPaginationEnabled = isCurrentlyOnline;

    // ✅ مزامنة حالة الاتصال الأولية — لو التطبيق اتفتح أوفلاين
    // Stream الـ ConnectivityCubit بيبعت التغييرات بس، مش الحالة الحالية
    if (!isCurrentlyOnline) {
      emit(state.copyWith(isOffline: true));
    }

    _connectivitySubscription = connectivityCubit.stream.listen((connState) {
      final wasOffline = state.isOffline;
      final isNowOnline = connState.isConnected;
      final isNowOffline = !connState.isConnected;

      // تحديث علم التصفح
      _isPaginationEnabled = isNowOnline;

      // تحديث حالة الاتصال في الـ state
      emit(state.copyWith(isOffline: isNowOffline));

      // لو رجع الاتصال بعد ما كان أوفلاين → استأنف التصفح + جلب البيانات
      if (wasOffline && isNowOnline) {
        _onReconnected();
      }
    });
  }

  /// عند استعادة الاتصال — جلب الكاتيجوريز + استكمال التصفح
  void _onReconnected() {
    // 1. جلب الكاتيجوريز لو فاشلين أو فاضيين أو لسه ما اتحملوش
    if (state.categoriesState == CubitStates.failure ||
        state.categoriesState == CubitStates.initial ||
        state.categories.isEmpty) {
      fetchCategories();
    }

    // 2. لو كان بيعرض كاش → ابدأ من أول صفحة سيرفر (مش مكمل علي اللوكال)
    if (state.isShowingCachedData) {
      final categoryId = state.selectedCategoryId;
      // فتح الـ hasMoreServer عشان الـ loadMore يشتغل من السيرفر
      emit(
        state
            .updateCategoryPosts(
              categoryId,
              (data) => data.copyWith(hasMoreServer: true),
            )
            .copyWith(isShowingCachedData: false),
      );
      // جلب الصفحة التالية تلقائياً — microtask لضمان تحديث الـ state قبل القراءة
      Future.microtask(() {
        if (!isClosed) loadMorePosts();
      });
      return;
    }

    // 3. لو البوستات فاشلة أو فاضية (فتح أوفلاين بدون كاش) → جلب من الأول
    final postsState = state.currentCategoryPosts.state;
    if (postsState == CubitStates.failure ||
        (postsState != CubitStates.loading && state.posts.isEmpty)) {
      _fetchPostsForCategory(state.selectedCategoryId);
      return;
    }

    // 4. لو النت فصل وسط السيشن والباجنيشن اتوقف → استكمل تلقائياً
    final currentData = state.currentCategoryPosts;
    if (currentData.hasMore && !currentData.isLoadingMore) {
      Future.microtask(() {
        if (!isClosed) loadMorePosts();
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 INITIALIZATION & REFRESH
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحميل بيانات اليوزر من الكاش عند البداية
  void _loadCachedUserData() {
    // الجيست بياناته في كاش مختلف (kGuestName / kGuestImage)
    if (isGuest) {
      final cachedImage = CachNetwork.getStringData(key: kGuestImage);
      final cachedName = CachNetwork.getStringData(key: kGuestName);
      if (cachedImage.isNotEmpty || cachedName.isNotEmpty) {
        emit(
          state.copyWith(
            homeInfo: ImageAndNameModel(
              image: cachedImage,
              name: cachedName,
              notifications: state.homeInfo?.notifications ?? 0,
            ),
            fetchNameAndImageState: CubitStates.success,
          ),
        );
      }
      return;
    }

    final cachedImage = CachNetwork.getStringData(key: kMyProfileImage);
    final cachedName = CachNetwork.getStringData(key: kMyProfileName);

    if (cachedImage.isNotEmpty || cachedName.isNotEmpty) {
      emit(
        state.copyWith(
          homeInfo: ImageAndNameModel(
            image: cachedImage,
            name: cachedName,
            notifications: state.homeInfo?.notifications ?? 0,

            approvalKey: state.homeInfo?.approvalKey ?? '',
          ),
          fetchNameAndImageState: CubitStates.success,
        ),
      );
    }
  }

  /// تحديث بيانات اليوزر من الكاش (للاستخدام بعد تحديث البيانات)
  void refreshUserInfoFromCache() {
    final cachedImage = CachNetwork.getStringData(key: kMyProfileImage);
    final cachedName = CachNetwork.getStringData(key: kMyProfileName);

    if (cachedImage.isNotEmpty || cachedName.isNotEmpty) {
      final newData = ImageAndNameModel(
        image: cachedImage,
        name: cachedName,
        notifications: state.homeInfo?.notifications ?? 0,
      );

      // تحديث فقط لو البيانات اتغيرت
      if (_isUserInfoChanged(newData)) {
        emit(
          state.copyWith(
            homeInfo: newData,
            fetchNameAndImageState: CubitStates.success,
          ),
        );
      }
    }
  }

  /// ريفريش كامل للصفحة - يعيد كل شيء للقيم الأولية ويحمل من جديد
  Future<void> refreshHome() async {
    // لو أوفلاين → لا تحدث، ابقي على البيانات الحالية
    if (connectivityCubit.isOffline) return;

    // إعادة تعيين كل شيء للقيم الأولية (مع الحفاظ على بيانات اليوزر المخزنة)
    emit(state.reset());

    // تحميل كل البيانات من جديد بالتوازي
    await Future.wait([
      fetchNameAndImage(),
      fetchCategories(),
      _fetchPostsForCategory(null),
      if (isUser) fetchBestAdvisors(),
      if (isUser) fetchSimilarUsers(),
      if (isUser) fetchPastMatches(),
    ]);
  }

  /// تحميل البيانات الأولية للهوم
  Future<void> initHome() async {
    await Future.wait([
      fetchNameAndImage(),
      fetchCategories(),
      _fetchPostsForCategory(null),
      if (isUser) fetchBestAdvisors(),
      if (isUser) fetchSimilarUsers(),
      if (isUser) fetchPastMatches(),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👤 USER INFO
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchNameAndImage() async {
    if (state.homeInfo == null) {
      emit(state.copyWith(fetchNameAndImageState: CubitStates.loading));
    }

    final result = await homeRepository.fetchNameAndImage();

    result.fold(
      (failure) {
        if (state.homeInfo == null) {
          emit(state.copyWith(fetchNameAndImageState: CubitStates.failure));
        }
      },
      (data) {
        // حفظ في الكاش — الجيست بياناته في كاش منفصل فمنحفظش بيانات الجيست في كاش اليوزر العادي
        if (!isGuest) {
          CachNetwork.setData(key: kMyProfileImage, value: data.image);
          CachNetwork.setData(key: kMyProfileName, value: data.name);
        }

        if (isAdvisor) {
          setAdvisorStatus(data.approvalKey);
        }
        // تحديث الـ State فقط لو البيانات اتغيرت
        if (_isUserInfoChanged(data)) {
          emit(
            state.copyWith(
              fetchNameAndImageState: CubitStates.success,
              homeInfo: data,
              currentAdvisorStatus: advisorStatus,
            ),
          );
        } else if (isAdvisor && state.currentAdvisorStatus != advisorStatus) {
          emit(state.copyWith(currentAdvisorStatus: advisorStatus));
        }
      },
    );
  }

  bool _isUserInfoChanged(ImageAndNameModel newData) {
    return state.homeInfo?.image != newData.image ||
        state.homeInfo?.name != newData.name ||
        state.homeInfo?.notifications != newData.notifications;
  }

  /// تحديث عدد الإشعارات محلياً بدون API call
  void updateNotificationsCount(int count) {
    final current = state.homeInfo;
    if (current == null) return;
    if (current.notifications == count) return;
    emit(
      state.copyWith(
        homeInfo: ImageAndNameModel(
          image: current.image,
          name: current.name,
          notifications: count,
          approvalKey: current.approvalKey,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📦 Best Sections Fetching
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchBestAdvisors({int page = 1}) async {
    if (page == 1) {
      emit(state.copyWith(bestAdvisorsState: CubitStates.loading));
    } else {
      emit(state.copyWith(bestAdvisorsIsLoadingMore: true));
    }

    final result = await homeRepository.fetchBestAdvisors(page: page);

    result.fold(
      (failure) => emit(
        state.copyWith(
          bestAdvisorsState: page == 1
              ? CubitStates.failure
              : state.bestAdvisorsState,
          bestAdvisorsErrorMessage: failure.message,
          bestAdvisorsIsLoadingMore: false,
        ),
      ),
      (response) {
        final newAdvisors = response.data?.advisors ?? [];
        final allAdvisors = page == 1
            ? newAdvisors
            : [...state.bestAdvisors, ...newAdvisors];

        print(
          '📊 Best Advisors - Page: $page, New: ${newAdvisors.length}, Total: ${allAdvisors.length}',
        );

        emit(
          state.copyWith(
            bestAdvisorsState: CubitStates.success,
            bestAdvisors: allAdvisors,
            bestAdvisorsPagination: response.data?.pagination,
            bestAdvisorsIsLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> loadMoreBestAdvisors() async {
    if (state.bestAdvisorsIsLoadingMore || state.bestAdvisorsPagination == null)
      return;

    final currentPage = state.bestAdvisorsPagination!.currentPage;
    final totalPages = state.bestAdvisorsPagination!.totalPages;

    if (currentPage >= totalPages) return;

    await fetchBestAdvisors(page: currentPage + 1);
  }

  void toggleFollowBestAdvisor({required String advisorId}) {
    // Find current follow state
    final advisorIndex = state.bestAdvisors.indexWhere(
      (a) => a.id == advisorId,
    );
    if (advisorIndex == -1) return;

    final currentAdvisor = state.bestAdvisors[advisorIndex];
    final isCurrentlyFollowing = currentAdvisor.isFollowing ?? false;
    final isAdding = !isCurrentlyFollowing;

    // Optimistic update
    final updatedAdvisors = List<BestAdvisorModel>.from(state.bestAdvisors);
    updatedAdvisors[advisorIndex] = currentAdvisor.copyWith(
      isFollowing: isAdding,
    );

    emit(state.copyWith(bestAdvisors: updatedAdvisors));

    // API Call with rollback on failure
    homeRepository.followAdvisor(advisorId: advisorId, isAdding: isAdding).then(
      (result) {
        result.fold(
          (failure) {
            // Rollback
            final rollbackAdvisors = List<BestAdvisorModel>.from(
              state.bestAdvisors,
            );
            rollbackAdvisors[advisorIndex] = currentAdvisor.copyWith(
              isFollowing: isCurrentlyFollowing,
            );
            if (!isClosed) emit(state.copyWith(bestAdvisors: rollbackAdvisors));
          },
          (_) {}, // success — optimistic update already applied
        );
      },
    );
  }

  Future<void> fetchSimilarUsers({int page = 1}) async {
    if (page == 1) {
      emit(state.copyWith(similarUsersState: CubitStates.loading));
    } else {
      emit(state.copyWith(similarUsersIsLoadingMore: true));
    }

    final result = await homeRepository.fetchSimilarUsers(page: page);

    result.fold(
      (failure) => emit(
        state.copyWith(
          similarUsersState: page == 1
              ? CubitStates.failure
              : state.similarUsersState,
          similarUsersErrorMessage: failure.message,
          similarUsersIsLoadingMore: false,
        ),
      ),
      (response) {
        final newUsers = response.data?.users ?? [];
        final allUsers = page == 1
            ? newUsers
            : [...state.similarUsers, ...newUsers];

        emit(
          state.copyWith(
            similarUsersState: CubitStates.success,
            similarUsers: allUsers,
            similarUsersPagination: response.data?.pagination,
            similarUsersIsLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> loadMoreSimilarUsers() async {
    if (state.similarUsersIsLoadingMore || state.similarUsersPagination == null)
      return;

    final currentPage = state.similarUsersPagination!.currentPage;
    final totalPages = state.similarUsersPagination!.totalPages;

    if (currentPage >= totalPages) return;

    await fetchSimilarUsers(page: currentPage + 1);
  }

  Future<void> fetchPastMatches({int page = 1}) async {
    if (page == 1) {
      emit(state.copyWith(pastMatchesState: CubitStates.loading));
    } else {
      emit(state.copyWith(pastMatchesIsLoadingMore: true));
    }

    final result = await homeRepository.fetchPastMatches(page: page);

    result.fold(
      (failure) => emit(
        state.copyWith(
          pastMatchesState: page == 1
              ? CubitStates.failure
              : state.pastMatchesState,
          pastMatchesErrorMessage: failure.message,
          pastMatchesIsLoadingMore: false,
        ),
      ),
      (response) {
        final newMatches = response.data?.data ?? [];
        final allMatches = page == 1
            ? newMatches
            : [...state.pastMatches, ...newMatches];

        emit(
          state.copyWith(
            pastMatchesState: CubitStates.success,
            pastMatches: allMatches,
            pastMatchesPagination: response.data?.pagination,
            pastMatchesIsLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> loadMorePastMatches() async {
    if (state.pastMatchesIsLoadingMore || state.pastMatchesPagination == null)
      return;

    final currentPage = state.pastMatchesPagination!.currentPage;
    final totalPages = state.pastMatchesPagination!.totalPages;

    if (currentPage >= totalPages) return;

    await fetchPastMatches(page: currentPage + 1);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📂 CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchCategories({bool loadMore = false}) async {
    if (loadMore) {
      await _loadMoreCategories();
    } else {
      await _fetchInitialCategories();
    }
  }

  Future<void> _fetchInitialCategories() async {
    emit(
      state.copyWith(
        categoriesState: CubitStates.loading,
        categories: [],
        categoriesCurrentPage: 1,
        categoriesHasMore: true,
      ),
    );

    final result = await homeRepository.fetchAllCategories(1);

    result.fold(
      (failure) => emit(
        state.copyWith(
          categoriesState: CubitStates.failure,
          categoriesErrorMessage: failure.message,
        ),
      ),
      (response) {
        final cats = response.data?.categories ?? [];
        final serverPageSize = response.data?.pagination?.pageSize ?? _pageSize;
        emit(
          state.copyWith(
            categoriesState: CubitStates.success,
            categories: cats,
            categoriesCurrentPage: 1,
            categoriesHasMore: cats.length >= serverPageSize,
          ),
        );
      },
    );
  }

  Future<void> _loadMoreCategories() async {
    if (state.categoriesIsLoadingMore || !state.categoriesHasMore) return;

    emit(state.copyWith(categoriesIsLoadingMore: true));

    final nextPage = state.categoriesCurrentPage + 1;
    final result = await homeRepository.fetchAllCategories(nextPage);

    result.fold(
      (failure) => emit(
        state.copyWith(
          categoriesIsLoadingMore: false,
          categoriesErrorMessage: failure.message,
        ),
      ),
      (response) {
        final newCats = response.data?.categories ?? [];
        final serverPageSize = response.data?.pagination?.pageSize ?? _pageSize;
        emit(
          state.copyWith(
            categories: [...state.categories, ...newCats],
            categoriesCurrentPage: nextPage,
            categoriesHasMore: newCats.length >= serverPageSize,
            categoriesIsLoadingMore: false,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📝 POSTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// تغيير الكاتيجوري المختارة وتحميل البوستات
  Future<void> selectCategory(String? categoryId) async {
    // لو نفس الكاتيجوري، لا تفعل شيء
    if (categoryId == state.selectedCategoryId) return;

    // تغيير الكاتيجوري المختارة
    emit(
      state.copyWith(
        selectedCategoryId: categoryId,
        resetSelectedCategory: categoryId == null,
      ),
    );

    // لو البيانات موجودة ومحملة، لا تحمل من جديد
    final categoryData = state.categoryPostsMap[categoryId];
    if (categoryData != null && categoryData.isLoaded) return;

    // تحميل البوستات للكاتيجوري الجديدة
    await _fetchPostsForCategory(categoryId);
  }

  /// تحميل المزيد من البوستات للكاتيجوري الحالية
  Future<void> loadMorePosts() async {
    // ⚠️ حارس الاتصال — السماح بالباجنيشن أوفلاين لو بيعرض كاش
    if (!_isPaginationEnabled && !state.isShowingCachedData) return;

    final categoryId = state.selectedCategoryId;
    final currentData = state.currentCategoryPosts;

    if (currentData.isLoadingMore || !currentData.hasMore) return;

    // تحديد المصدر ورقم الصفحة حسب حالة الاتصال
    final bool isLoadingFromLocal = !_isPaginationEnabled;
    final nextPage = isLoadingFromLocal
        ? currentData.currentLocalPage + 1
        : currentData.currentServerPage + 1;

    // لو المصدر الحالي خلص صفحاته
    if (isLoadingFromLocal && !currentData.hasMoreLocal) return;
    if (!isLoadingFromLocal && !currentData.hasMoreServer) return;

    // تحديث حالة الـ loading more
    emit(
      state.updateCategoryPosts(
        categoryId,
        (data) => data.copyWith(isLoadingMore: true),
      ),
    );

    final result = await homeRepository.fetchPosts(
      page: nextPage,
      categoryId: categoryId,
      nextCursor: isLoadingFromLocal ? null : currentData.nextCursor,
    );

    result.fold(
      (failure) {
        // السيرفر فشل وفيه لوكال متبقي → كمّل من اللوكال
        if (!isLoadingFromLocal && currentData.hasMoreLocal) {
          emit(
            state.updateCategoryPosts(
              categoryId,
              (data) => data.copyWith(isLoadingMore: false),
            ),
          );
          _loadMoreFromLocal(categoryId);
          return;
        }

        // مفيش لوكال متبقي → عرض حالة فشل السيرفر
        emit(
          state.updateCategoryPosts(
            categoryId,
            (data) => data.copyWith(
              isLoadingMore: false,
              loadMoreServerFailed: !isLoadingFromLocal,
              hasMoreLocal: isLoadingFromLocal ? false : data.hasMoreLocal,
              errorMessage: failure.message,
            ),
          ),
        );
      },
      (response) {
        final isFromCache = response.message == 'from_cache';
        final allPosts = [...currentData.posts, ...response.posts];
        final hasMorePages = response.posts.length >= _pageSize;

        emit(
          state
              .updateCategoryPosts(
                categoryId,
                (data) => data.copyWith(
                  posts: allPosts,
                  currentLocalPage: isFromCache
                      ? nextPage
                      : data.currentLocalPage,
                  currentServerPage: isFromCache
                      ? data.currentServerPage
                      : nextPage,
                  hasMoreLocal: isFromCache ? hasMorePages : data.hasMoreLocal,
                  hasMoreServer: isFromCache
                      ? data.hasMoreServer
                      : hasMorePages,
                  isLoadingMore: false,
                  loadMoreServerFailed: false,
                  nextCursor: isFromCache
                      ? data.nextCursor
                      : response.nextCursor,
                ),
              )
              .copyWith(
                isShowingCachedData: isFromCache
                    ? true
                    : state.isShowingCachedData,
              ),
        );

        // ✅ حفظ تراكمي في الكاش بعد كل صفحة أونلاين ناجحة (All category فقط)
        if (!isFromCache && categoryId == null) {
          localDatasource
              .cachePosts(
                allPosts,
                nextCursor: response.nextCursor,
                page: nextPage,
              )
              .catchError((_) {});
        }
      },
    );
  }

  /// فولباك للوكال لما السيرفر يفشل
  Future<void> _loadMoreFromLocal(String? categoryId) async {
    final currentData = state.currentCategoryPosts;
    final nextLocalPage = currentData.currentLocalPage + 1;

    emit(
      state.updateCategoryPosts(
        categoryId,
        (data) => data.copyWith(isLoadingMore: true),
      ),
    );

    final result = await homeRepository.fetchPosts(
      page: nextLocalPage,
      categoryId: categoryId,
    );

    result.fold(
      (failure) {
        // اللوكال كمان فشل (خلص) → عرض حالة فشل السيرفر
        emit(
          state.updateCategoryPosts(
            categoryId,
            (data) => data.copyWith(
              isLoadingMore: false,
              hasMoreLocal: false,
              loadMoreServerFailed: true,
              errorMessage: failure.message,
            ),
          ),
        );
      },
      (response) {
        final isFromCache = response.message == 'from_cache';
        final allPosts = [...currentData.posts, ...response.posts];
        final hasMorePages = response.posts.length >= _pageSize;

        if (!isFromCache) {
          // لو رجع أونلاين فجأة — بيانات سيرفر
          emit(
            state.updateCategoryPosts(
              categoryId,
              (data) => data.copyWith(
                posts: allPosts,
                currentServerPage: nextLocalPage,
                hasMoreServer: hasMorePages,
                isLoadingMore: false,
                loadMoreServerFailed: false,
                nextCursor: response.nextCursor,
              ),
            ),
          );
          return;
        }

        emit(
          state
              .updateCategoryPosts(
                categoryId,
                (data) => data.copyWith(
                  posts: allPosts,
                  currentLocalPage: nextLocalPage,
                  hasMoreLocal: hasMorePages,
                  isLoadingMore: false,
                ),
              )
              .copyWith(isShowingCachedData: true),
        );
      },
    );
  }

  /// إعادة محاولة تحميل المزيد من السيرفر (يستدعيها الـ UI)
  Future<void> retryLoadMore() async {
    final categoryId = state.selectedCategoryId;
    emit(
      state.updateCategoryPosts(
        categoryId,
        (data) => data.copyWith(loadMoreServerFailed: false),
      ),
    );
    await loadMorePosts();
  }

  /// تحميل البوستات لكاتيجوري معينة (داخلي)
  Future<void> _fetchPostsForCategory(String? categoryId) async {
    // تحديث حالة الـ loading
    emit(
      state.updateCategoryPosts(
        categoryId,
        (data) => data.copyWith(
          state: CubitStates.loading,
          posts: [],
          currentLocalPage: 0,
          currentServerPage: 0,
          hasMoreLocal: true,
          hasMoreServer: true,
          nextCursor: null,
        ),
      ),
    );

    final result = await homeRepository.fetchPosts(
      page: 1,
      categoryId: categoryId,
    );

    result.fold(
      (failure) => emit(
        state.updateCategoryPosts(
          categoryId,
          (data) => data.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
          ),
        ),
      ),
      (response) {
        // هل البيانات جاية من الكاش؟
        final isFromCache = response.message == 'from_cache';
        final hasMorePages = response.posts.length >= _pageSize;

        emit(
          state
              .updateCategoryPosts(
                categoryId,
                (data) => data.copyWith(
                  state: CubitStates.success,
                  posts: _deduplicatePosts(response.posts),
                  currentLocalPage: isFromCache
                      ? (response.pagination.currentPage)
                      : 0,
                  currentServerPage: isFromCache ? 0 : 1,
                  hasMoreLocal: isFromCache ? hasMorePages : true,
                  hasMoreServer: isFromCache ? true : hasMorePages,
                  nextCursor: response.nextCursor,
                ),
              )
              .copyWith(isShowingCachedData: isFromCache),
        );
      },
    );
  }

  /// تعيين بوست ابتدائي (للاستخدام عند فتح بوست من مكان آخر)
  void setInitialPost(PostModel post) {
    emit(
      state.updateCategoryPosts(
        state.selectedCategoryId,
        (data) => data.copyWith(posts: [post], state: CubitStates.success),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ❤️ REACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  void reactToPost({required String postId, ReactionType? reactionType}) {
    final post = _findPost(postId);
    if (post == null) return;

    // لا تغيير لو نفس الريأكشن
    if (post.myReaction == reactionType && reactionType != null) return;
    if (post.myReaction == null && reactionType == null) return;

    final isRemoving = reactionType == null;
    final oldReaction = post.myReaction;

    // حساب العدد الجديد
    int newLikesCount = post.likesCount;
    if (isRemoving) {
      newLikesCount = (post.likesCount - 1).clamp(0, post.likesCount);
    } else if (oldReaction == null) {
      newLikesCount = post.likesCount + 1;
    }

    // حساب التوب ريأكشنز
    final newTopReactions = calculateTopReactions(
      currentTopReactions: post.topReactions,
      oldReaction: oldReaction,
      newReaction: reactionType,
      newLikesCount: newLikesCount,
    );

    // Optimistic Update في كل الكاتيجوريز
    emit(
      state.updatePostInAllCategories(
        postId,
        (p) => p.copyWith(
          likesCount: newLikesCount,
          topReactions: newTopReactions,
          myReaction: reactionType,
          clearMyReaction: isRemoving,
        ),
      ),
    );

    // API Call مع Rollback لو فشل
    homeRepository
        .reactToPost(
          postId: postId,
          reactionType: reactionType,
          isRemove: isRemoving,
        )
        .then((result) {
          result.fold(
            (failure) {
              log('>>>>>>>>>>>>>>>>> React To Post Failed: ${failure.message}');
              // Rollback في كل الكاتيجوريز
              emit(
                state.updatePostInAllCategories(
                  postId,
                  (p) => p.copyWith(
                    likesCount: post.likesCount,
                    topReactions: post.topReactions,
                    myReaction: post.myReaction,
                    clearMyReaction: post.myReaction == null,
                  ),
                ),
              );
            },
            (_) {
              log('>>>>>>>>>>>>>>>>> React To Post Success');
              _syncPostToCacheById(postId);
              PostEventBus.instance.fire(
                PostEvent(
                  sourceId: 'HomeCubit',
                  type: PostEventType.reacted,
                  postId: postId,
                  reactionType: reactionType,
                  likesCount: newLikesCount,
                  topReactions: newTopReactions,
                ),
              );
            },
          );
        });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 SHARE POST
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> toggleSharePost({required String postId}) async {
    // Reset حالة الشير
    emit(state.copyWith(shareActionState: CubitStates.initial));

    final post = _findPost(postId);
    if (post == null) return;

    final isRemoving = post.isRepostedByMe;
    final newSharesCount = isRemoving
        ? (post.sharesCount - 1).clamp(0, post.sharesCount)
        : post.sharesCount + 1;

    // Optimistic Update في كل الكاتيجوريز
    emit(
      state.updatePostInAllCategories(
        postId,
        (p) => p.copyWith(
          sharesCount: newSharesCount,
          isRepostedByMe: !p.isRepostedByMe,
        ),
      ),
    );

    // API Call
    final result = await homeRepository.sharePost(
      postId: postId,
      action: isRemoving ? "remove" : "add",
    );

    result.fold(
      (failure) {
        log('>>>>>>>>>>>>>>>>>Share Post Failed: ${failure.message}');
        // Rollback في كل الكاتيجوريز
        emit(
          state.updatePostInAllCategories(
            postId,
            (p) => p.copyWith(
              sharesCount: post.sharesCount,
              isRepostedByMe: post.isRepostedByMe,
            ),
          ),
        );
        emit(
          state.copyWith(
            shareActionState: CubitStates.failure,
            shareMessage: failure.message,
          ),
        );
      },
      (message) {
        log('>>>>>>>>>>>>>>>>>Share Post Success: $message');
        _syncPostToCacheById(postId);
        PostEventBus.instance.fire(
          PostEvent(
            sourceId: 'HomeCubit',
            type: PostEventType.shared,
            postId: postId,
            isRepostedByMe: !isRemoving,
            sharesCount: newSharesCount,
          ),
        );
        emit(
          state.copyWith(
            shareActionState: CubitStates.success,
            shareMessage: message,
            isShareAdded: !isRemoving,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📤 SHARE POST TO STORY
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> sharePostToStory({required String postId}) async {
    emit(state.copyWith(shareToStoryState: CubitStates.loading));

    final result = await homeRepository.sharePostToStory(postId: postId);

    result.fold(
      (failure) {
        log('>>>>>>>>>>>>>>>>>Share To Story Failed: ${failure.message}');
        emit(
          state.copyWith(
            shareToStoryState: CubitStates.failure,
            shareToStoryMessage: failure.message,
          ),
        );
      },
      (message) {
        log('>>>>>>>>>>>>>>>>>Share To Story Success: $message');
        emit(
          state.copyWith(
            shareToStoryState: CubitStates.success,
            shareToStoryMessage: message,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💾 SAVE POST
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> toggleSavePost({required String postId}) async {
    // 1. العثور على البوست
    final post = _findPost(postId);
    if (post == null) return;

    // تحديد الحالة الحالية والإجراء المطلوب
    final isCurrentlySaved = post.isSaved;
    final isRemove = isCurrentlySaved;

    // 2. Optimistic Update (تحديث الواجهة فوراً)
    // ⚠️ بنصفر الـ saveActionState هنا عشان نجهز لاستقبال النتيجة
    emit(
      state
          .updatePostInAllCategories(
            postId,
            (p) => p.copyWith(isSaved: !isCurrentlySaved),
          )
          .copyWith(saveActionState: CubitStates.initial),
    );

    // 3. استدعاء السيرفر
    final result = await homeRepository.savedPost(
      postId: postId,
      isRemove: isRemove,
    );

    // 4. التعامل مع النتيجة
    result.fold(
      (failure) {
        log('>>>>>>>>>>>>>>>>> Save Post Failed: ${failure.message}');

        // Rollback: في حالة الفشل نرجع الحالة زي ما كانت
        // ⚠️ ونبعت حالة Failure عشان التوست الأحمر يظهر
        emit(
          state
              .updatePostInAllCategories(
                postId,
                (p) => p.copyWith(isSaved: isCurrentlySaved),
              )
              .copyWith(
                saveActionState: CubitStates.failure,
                saveMessage: failure.message,
              ),
        );
      },
      (message) {
        log('>>>>>>>>>>>>>>>>>Save Post Success: $message');
        _syncPostToCacheById(postId);
        PostEventBus.instance.fire(
          PostEvent(
            sourceId: 'HomeCubit',
            type: PostEventType.saved,
            postId: postId,
            isSaved: !isCurrentlySaved,
          ),
        );
        AudioService.instance.playSaveSound(isSaved: !isCurrentlySaved);
        // النجاح: الـ UI متحدث بالفعل (Optimistic)، بس محتاجين نبعت Success عشان التوست الأخضر
        emit(
          state.copyWith(
            saveActionState: CubitStates.success,
            saveMessage: message,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🗑 DELETE POST
  // ═══════════════════════════════════════════════════════════════════════════
  void deletePost({required String postId}) {
    final post = _findPost(postId);
    if (post == null) return;

    // ✅ حفظ البيانات الأصلية للـ Rollback
    final originalIndex = state.posts.indexWhere((p) => p.postId == postId);
    final originalCategoryId = state.selectedCategoryId;

    // 1. Optimistic Update
    final updatedPosts = state.posts.where((p) => p.postId != postId).toList();
    emit(
      state
          .updateCategoryPosts(
            state.selectedCategoryId,
            (data) => data.copyWith(posts: updatedPosts),
          )
          .copyWith(deletePostActionState: CubitStates.initial),
    );

    // 2. Server Request
    homeRepository.deletePost(postId: postId).then((result) {
      result.fold(
        (failure) {
          log('>>>>>>>>>>>>>>>>> Delete Post Failed: ${failure.message}');

          // ✅ Rollback باستخدام الـ Helper Method
          emit(
            state.insertPostInCategory(
              categoryId: originalCategoryId,
              post: post,
              index: originalIndex,
            ),
          );

          emit(
            state.copyWith(
              deletePostActionState: CubitStates.failure,
              deletePostMessage: failure.message,
            ),
          );
        },
        (message) {
          log('>>>>>>>>>>>>>>>>> Delete Post Success: $message');
          localDatasource.removePost(postId).catchError((_) {});
          PostEventBus.instance.fire(
            PostEvent(
              sourceId: 'HomeCubit',
              type: PostEventType.deleted,
              postId: postId,
            ),
          );
          AudioService.instance.playDeleteSound();
          emit(
            state.copyWith(
              deletePostActionState: CubitStates.success,
              deletePostMessage: message,
            ),
          );
        },
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  Archive POST
  // ═══════════════════════════════════════════════════════════════════════════
  void archivePost({required String postId}) {
    final post = _findPost(postId);
    if (post == null) return;

    // ✅ حفظ البيانات الأصلية للـ Rollback
    final originalIndex = state.posts.indexWhere((p) => p.postId == postId);
    final originalCategoryId = state.selectedCategoryId;

    // 1. Optimistic Update
    final updatedPosts = state.posts.where((p) => p.postId != postId).toList();
    emit(
      state
          .updateCategoryPosts(
            state.selectedCategoryId,
            (data) => data.copyWith(posts: updatedPosts),
          )
          .copyWith(archivePostActionState: CubitStates.initial),
    );

    // 2. Server Request
    homeRepository.archivePost(postId: postId).then((result) {
      result.fold(
        (failure) {
          log('>>>>>>>>>>>>>>>>> Archive Post Failed: ${failure.message}');

          // ✅ Rollback باستخدام الـ Helper Method
          emit(
            state.insertPostInCategory(
              categoryId: originalCategoryId,
              post: post,
              index: originalIndex,
            ),
          );

          emit(
            state.copyWith(
              archivePostActionState: CubitStates.failure,
              archivePostMessage: failure.message,
            ),
          );
        },
        (message) {
          log('>>>>>>>>>>>>>>>>> Archive Post Success: $message');
          localDatasource.removePost(postId).catchError((_) {});
          PostEventBus.instance.fire(
            PostEvent(
              sourceId: 'HomeCubit',
              type: PostEventType.archived,
              postId: postId,
            ),
          );
          AudioService.instance.playArchiveSound();
          emit(
            state.copyWith(
              archivePostActionState: CubitStates.success,
              archivePostMessage: message,
            ),
          );
        },
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✏️ UPDATE EDITED POST (بعد تعديل بوست من صفحة التعديل)
  // ═══════════════════════════════════════════════════════════════════════════
  void updateEditedPost(PostModel updatedPost) {
    emit(
      state.updatePostInAllCategories(updatedPost.postId, (_) => updatedPost),
    );
    PostEventBus.instance.fire(
      PostEvent(
        sourceId: 'HomeCubit',
        type: PostEventType.edited,
        postId: updatedPost.postId,
        updatedPost: updatedPost,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👁️ TOGGLE HIDE POST
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> toggleHidePost({required String postId}) async {
    // 1. جيب البوست الحالي
    final post = _findPost(postId);
    if (post == null) return;

    // 2. اعكس الحالة
    final newHideState = !post.isHidden;

    // 3. Loading State
    emit(state.copyWith(hidePostActionState: CubitStates.loading));

    // 4. Server Request
    final result = await homeRepository.hidePost(
      postId: postId,
      isHide: newHideState,
    );

    result.fold(
      (failure) {
        log('>>>>>>>>>>>>>>>>> Hide Post Failed: ${failure.message}');

        emit(
          state.copyWith(
            hidePostActionState: CubitStates.failure,
            hidePostMessage: failure.message,
          ),
        );
      },
      (message) {
        log('>>>>>>>>>>>>>>>>> Hide Post Success: $message');

        // ✅ نجاح: حدث الـ UI
        emit(
          state
              .updatePostInAllCategories(
                postId,
                (p) => p.copyWith(isHidden: newHideState),
              )
              .copyWith(
                hidePostActionState: CubitStates.success,
                hidePostMessage: message,
              ),
        );
        localDatasource.removePost(postId).catchError((_) {});
        PostEventBus.instance.fire(
          PostEvent(
            sourceId: 'HomeCubit',
            type: PostEventType.hidden,
            postId: postId,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚫 BLOCK USER
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> blockUser({
    required String visiblePostId,
    required String advisorId,
  }) async {
    // 1. Loading State
    emit(state.copyWith(blockUserActionState: CubitStates.loading));

    // 2. Server Request
    final result = await homeRepository.blockUser(userId: advisorId);

    result.fold(
      (failure) {
        log('>>>>>>>>>>>>>>>>> Block User Failed: ${failure.message}');

        // ❌ فشل: اعرض رسالة خطأ بس
        emit(
          state.copyWith(
            blockUserActionState: CubitStates.failure,
            blockUserMessage: failure.message,
          ),
        );
      },
      (message) {
        log('>>>>>>>>>>>>>>>>> Block User Success: $message');

        // ✅ نجاح: حدث الـ State
        final newMap = <String?, CategoryPostsData>{};

        for (final entry in state.categoryPostsMap.entries) {
          final categoryId = entry.key;
          final categoryData = entry.value;

          final updatedPosts = <PostModel>[];

          for (final post in categoryData.posts) {
            if (post.postId == visiblePostId) {
              // ✅ البوست الأصلي: isBlocked = true
              updatedPosts.add(post.copyWith(isBlocked: true));
            } else if (post.advisorId == advisorId) {
              // ❌ باقي بوستاته: احذفها
              continue;
            } else {
              // ✅ بوستات ناس تانية: خليها
              updatedPosts.add(post);
            }
          }

          newMap[categoryId] = categoryData.copyWith(posts: updatedPosts);
        }

        emit(
          state.copyWith(
            categoryPostsMap: newMap,
            blockUserActionState: CubitStates.success,
            blockUserMessage: message,
          ),
        );
        AudioService.instance.playBlockSound();
        // ✅ مزامنة الكاش: حدث البوست الظاهر + احذف باقي بوستات اليوزر المحظور
        _syncPostToCacheById(visiblePostId);
        for (final post in state.posts) {
          if (post.advisorId == advisorId && post.postId != visiblePostId) {
            localDatasource.removePost(post.postId).catchError((_) {});
          }
        }
        PostEventBus.instance.fire(
          PostEvent(
            sourceId: 'HomeCubit',
            type: PostEventType.blocked,
            postId: visiblePostId,
            advisorId: advisorId,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👥 FOLLOW ADVISOR
  // ═══════════════════════════════════════════════════════════════════════════

  void toggleFollowAdvisor({required String advisorId}) {
    // Find current follow state from any post by this advisor
    final currentPost = state.posts.firstWhere(
      (p) => p.advisorId == advisorId,
      orElse: () => state.categoryPostsMap.values
          .expand((d) => d.posts)
          .firstWhere(
            (p) => p.advisorId == advisorId,
            orElse: () => state.posts.first,
          ),
    );
    final isCurrentlyFollowing = currentPost.isFollowing;
    final isAdding = !isCurrentlyFollowing;

    // Optimistic update across all categories
    final newMap = <String?, CategoryPostsData>{};
    for (final entry in state.categoryPostsMap.entries) {
      newMap[entry.key] = entry.value.copyWith(
        posts: entry.value.posts.map((post) {
          if (post.advisorId == advisorId) {
            return post.copyWith(isFollowing: isAdding);
          }
          return post;
        }).toList(),
      );
    }
    emit(state.copyWith(categoryPostsMap: newMap));

    // API Call with rollback on failure
    homeRepository.followAdvisor(advisorId: advisorId, isAdding: isAdding).then(
      (result) {
        result.fold(
          (failure) {
            // Rollback
            final rollbackMap = <String?, CategoryPostsData>{};
            for (final entry in state.categoryPostsMap.entries) {
              rollbackMap[entry.key] = entry.value.copyWith(
                posts: entry.value.posts.map((post) {
                  if (post.advisorId == advisorId) {
                    return post.copyWith(isFollowing: isCurrentlyFollowing);
                  }
                  return post;
                }).toList(),
              );
            }
            if (!isClosed) emit(state.copyWith(categoryPostsMap: rollbackMap));
          },
          (_) {}, // success — optimistic update already applied
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // �️ POLL VOTE
  // ═══════════════════════════════════════════════════════════════════════════

  void voteInPoll({required String postId, required String choiceText}) {
    final post = _findPost(postId);
    if (post == null || post.pollModel == null) return;

    final oldPoll = post.pollModel!;
    final choices = oldPoll.pollChoices;

    // البحث عن الاختيار اللي اليوزر ضغط عليه
    final tappedIndex = choices.indexWhere((c) => c.choice == choiceText);
    if (tappedIndex == -1) return;

    final tappedChoice = choices[tappedIndex];

    // البحث عن الاختيار اللي كان مختاره قبل كده (لو في)
    final previouslySelectedIndex = choices.indexWhere((c) => c.isSelected);
    final hadPreviousVote = previouslySelectedIndex != -1;

    // لو ضغط على نفس الاختيار المحدد => حذف التصويت (toggle)
    final isRemovingVote = tappedChoice.isSelected;

    // حساب الـ totalVotes الجديد
    int newTotalVotes = oldPoll.totalPollVotes;
    if (isRemovingVote) {
      // بيشيل التصويت
      newTotalVotes = (newTotalVotes - 1).clamp(0, newTotalVotes);
    } else if (!hadPreviousVote) {
      // أول مرة يصوت
      newTotalVotes = newTotalVotes + 1;
    }
    // لو كان مختار حاجة قبل كده وغيّرها => العدد الكلي ما يتغيرش

    // صورة اليوزر الحالي
    final myAvatar = kCurrentUserData?.image ?? '';

    // بناء الاختيارات الجديدة
    final newChoices = <PollChoice>[];
    for (int i = 0; i < choices.length; i++) {
      final choice = choices[i];

      if (isRemovingVote) {
        // بيشيل التصويت: شيل الـ selected و الصورة من الاختيار ده بس
        if (i == tappedIndex) {
          final newVotes = (choice.votes - 1).clamp(0, choice.votes);
          final newVoters = List<String>.from(choice.votersAvatars)
            ..remove(myAvatar);
          newChoices.add(
            choice.copyWith(
              isSelected: false,
              votes: newVotes,
              votersAvatars: newVoters,
            ),
          );
        } else {
          newChoices.add(choice);
        }
      } else {
        // بيصوت (جديد أو بيغير اختياره)
        if (i == tappedIndex) {
          // الاختيار الجديد: زود الأصوات و selected = true و ضيف الصورة
          final newVotes = choice.votes + 1;
          final newVoters = List<String>.from(choice.votersAvatars);
          if (myAvatar.isNotEmpty && !newVoters.contains(myAvatar)) {
            newVoters.insert(0, myAvatar);
          }
          newChoices.add(
            choice.copyWith(
              isSelected: true,
              votes: newVotes,
              votersAvatars: newVoters,
            ),
          );
        } else if (hadPreviousVote && i == previouslySelectedIndex) {
          // الاختيار القديم: نقص الأصوات و selected = false و شيل الصورة
          final newVotes = (choice.votes - 1).clamp(0, choice.votes);
          final newVoters = List<String>.from(choice.votersAvatars)
            ..remove(myAvatar);
          newChoices.add(
            choice.copyWith(
              isSelected: false,
              votes: newVotes,
              votersAvatars: newVoters,
            ),
          );
        } else {
          newChoices.add(choice);
        }
      }
    }

    // إعادة حساب النسب لكل الاختيارات بعد التعديل
    final updatedChoices = newChoices.map((c) {
      final pct = newTotalVotes > 0
          ? ((c.votes / newTotalVotes) * 100).round()
          : 0;
      return c.copyWith(percentage: pct);
    }).toList();

    final newPoll = oldPoll.copyWith(
      pollChoices: updatedChoices,
      totalPollVotes: newTotalVotes,
    );

    // Optimistic Update في كل الكاتيجوريز
    emit(
      state
          .updatePostInAllCategories(
            postId,
            (p) => p.copyWith(pollModel: newPoll),
          )
          .copyWith(pollVoteActionState: CubitStates.initial),
    );

    // حساب الـ choiceIndex للريكوست (index as string)
    final choiceIndex = tappedIndex.toString();

    // API Call
    homeRepository.voteInPoll(postId: postId, choiceIndex: choiceIndex).then((
      result,
    ) {
      result.fold(
        (failure) {
          log('>>>>>>>>>>>>>>>>> Vote In Poll Failed: ${failure.message}');
          // Rollback: رجّع الـ Poll القديم
          emit(
            state
                .updatePostInAllCategories(
                  postId,
                  (p) => p.copyWith(pollModel: oldPoll),
                )
                .copyWith(
                  pollVoteActionState: CubitStates.failure,
                  pollVoteMessage: failure.message,
                ),
          );
        },
        (_) {
          log('>>>>>>>>>>>>>>>>> Vote In Poll Success');
          AudioService.instance.playVoteSound();
          _syncPostToCacheById(postId);
          PostEventBus.instance.fire(
            PostEvent(
              sourceId: 'HomeCubit',
              type: PostEventType.pollVoted,
              postId: postId,
              pollModel: newPoll,
            ),
          );
        },
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // �🔧 HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  PostModel? _findPost(String postId) {
    return state.postsMap[postId];
  }

  /// حقن بوست في الكاتيجوري الحالية إذا لم يكن موجودًا
  /// (يُستخدم عند الدخول للبوست من الإشعارات)
  void injectPost(PostModel post) {
    if (_findPost(post.postId) != null) return;
    emit(
      state.updateCategoryPosts(
        state.selectedCategoryId,
        (data) => data.copyWith(posts: [post, ...data.posts]),
      ),
    );
  }

  /// إزالة البوستات المكررة بالـ postId
  List<PostModel> _deduplicatePosts(List<PostModel> posts) {
    final seen = <String>{};
    return posts.where((p) => seen.add(p.postId)).toList();
  }

  /// مزامنة بوست محدد مع الكاش بعد تفاعل ناجح
  void _syncPostToCacheById(String postId) {
    final post = _findPost(postId);
    if (post != null) {
      localDatasource.updateSinglePost(postId, post).catchError((_) {});
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 MARK POST AS COMMENTED ✅ MODIFIED — شلنا زيادة العدد
  // ═══════════════════════════════════════════════════════════
  void markPostAsCommented({
    required String postId,
    required bool isAnonymous,
  }) {
    emit(
      state.updatePostInAllCategories(
        postId,
        (p) => p.copyWith(isCommented: true, isAnonymous: isAnonymous),
      ),
    );
    _syncPostToCacheById(postId);
    PostEventBus.instance.fire(
      PostEvent(
        sourceId: 'HomeCubit',
        type: PostEventType.commented,
        postId: postId,
        isAnonymous: isAnonymous,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💬 UPDATE COMMENT COUNT BY DELTA ✅ NEW
  // ═══════════════════════════════════════════════════════════════════════════
  void updateCommentCountByDelta({
    required String postId,
    required int countDelta,
    bool? isCommented,
    bool? isAnonymous,
  }) {
    if (countDelta == 0 && isCommented == null && isAnonymous == null) return;

    emit(
      state.updatePostInAllCategories(postId, (p) {
        final newCount = (p.commentsCount + countDelta).clamp(0, 999999);
        return p.copyWith(
          commentsCount: newCount,
          isCommented: isCommented ?? p.isCommented,
          isAnonymous: isAnonymous ?? p.isAnonymous,
        );
      }),
    );

    _syncPostToCacheById(postId);
    PostEventBus.instance.fire(
      PostEvent(
        sourceId: 'HomeCubit',
        type: PostEventType.commentCountUpdated,
        postId: postId,
        commentCountDelta: countDelta,
        isCommented: isCommented,
        isAnonymous: isAnonymous,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 SYNC COMMENT COUNT FROM BACKEND ✅ NEW
  // ═══════════════════════════════════════════════════════════════════════════
  void syncCommentCountFromBackend({
    required String postId,
    required int totalCount,
  }) {
    emit(
      state.updatePostInAllCategories(postId, (p) {
        return p.copyWith(commentsCount: totalCount);
      }),
    );

    _syncPostToCacheById(postId);
    PostEventBus.instance.fire(
      PostEvent(
        sourceId: 'HomeCubit',
        type: PostEventType.commentCountSynced,
        postId: postId,
        commentCountTotal: totalCount,
      ),
    );
  }

  final tayseerSocketHelper socketHelper = getIt.get<tayseerSocketHelper>();

  // ✅ markPostAsRead — يبعت event للـ socket لما البوست يبقى مرئي
  void markPostAsRead(String postId) {
    if (!socketHelper.isConnected) return;
    log('📤 [HomeCubit] markPostAsRead: $postId');
    socketHelper.send('markPostAsRead', {'postId': postId}, null);
  }

  // ✅ جديد
  void sessionStart() {
    log('📡 Setting up Session Start Listener');
    socketHelper.listenWithId('sessionStarted', 'HomeCubit_sessionStarted', (
      data,
    ) {
      log('📡 Session Started Event Received: $data');
      if (isClosed) return;
      final response = SessionStartModel.fromJson(data);
      emit(state.copyWith(sessionStartModel: response));
      HomeEventBus.instance.notifysessionstart(response);
      Future.delayed(Duration(milliseconds: 100), () {
        if (!isClosed) emit(state.copyWith(sessionStartModel: null));
      });
    });
  }
}
