import 'dart:async';
import 'dart:developer';
import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/shared/home/data_source/posts_local_datasource.dart';
import 'package:tayseer/features/shared/home/model/Image_and_name_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/home/view_model/home_event_bus.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/features/user/my_space/data/model/session_start_model.dart';
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

  HomeCubit(
    this.homeRepository, {
    required this.connectivityCubit,
    required this.localDatasource,
  }) : super(const HomeState()) {
    _loadCachedUserData();
    _listenToConnectivity();
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
              notifications: 0,
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
            notifications: 0,
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
    ]);
  }

  /// تحميل البيانات الأولية للهوم
  Future<void> initHome() async {
    await Future.wait([
      fetchNameAndImage(),
      fetchCategories(),
      _fetchPostsForCategory(null),
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

        // تحديث الـ State فقط لو البيانات اتغيرت
        if (_isUserInfoChanged(data)) {
          emit(
            state.copyWith(
              fetchNameAndImageState: CubitStates.success,
              homeInfo: data,
            ),
          );
        }
      },
    );
  }

  bool _isUserInfoChanged(ImageAndNameModel newData) {
    return state.homeInfo?.image != newData.image ||
        state.homeInfo?.name != newData.name ||
        state.homeInfo?.notifications != newData.notifications;
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
        final allPosts = _deduplicatePosts([
          ...currentData.posts,
          ...response.posts,
        ]);
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
        final allPosts = _deduplicatePosts([
          ...currentData.posts,
          ...response.posts,
        ]);
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
        log('>>>>>>>>>>>>>>>>> Save Post Success: $message');
        _syncPostToCacheById(postId);

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

        // ✅ مزامنة الكاش: حدث البوست الظاهر + احذف باقي بوستات اليوزر المحظور
        _syncPostToCacheById(visiblePostId);
        for (final post in state.posts) {
          if (post.advisorId == advisorId && post.postId != visiblePostId) {
            localDatasource.removePost(post.postId).catchError((_) {});
          }
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👥 FOLLOW ADVISOR
  // ═══════════════════════════════════════════════════════════════════════════

  void toggleFollowAdvisor({required String advisorId}) {
    final currentPosts = state.posts;
    final updatedPosts = currentPosts.map((post) {
      if (post.advisorId == advisorId) {
        return post.copyWith(isFollowing: !post.isFollowing);
      }
      return post;
    }).toList();

    emit(
      state.updateCategoryPosts(
        state.selectedCategoryId,
        (data) => data.copyWith(posts: updatedPosts),
      ),
    );

    // TODO: API Call
    // homeRepository.toggleFollowAdvisor(advisorId: advisorId);
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
          _syncPostToCacheById(postId);
        },
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // �🔧 HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  PostModel? _findPost(String postId) {
    final posts = state.posts;
    final index = posts.indexWhere((p) => p.postId == postId);
    return index != -1 ? posts[index] : null;
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
  // 📌 MARK POST AS COMMENTED
  // ═══════════════════════════════════════════════════════════
  void markPostAsCommented({
    required String postId,
    required bool isAnonymous,
  }) {
    emit(
      state.updatePostInAllCategories(
        postId,
        (p) => p.copyWith(
          isCommented: true,
          isAnonymous: isAnonymous,
          commentsCount: p.commentsCount + 1,
        ),
      ),
    );
    _syncPostToCacheById(postId);
  }

  final tayseerSocketHelper socketHelper = getIt.get<tayseerSocketHelper>();

  void sessionStart() {
    log('📡 Setting up Session Start Listener');
    socketHelper.listen('sessionStarted', (data) {
      log('📡 Session Started Event Received: $data');

      final response = SessionStartModel.fromJson(data);

      emit(state.copyWith(sessionStartModel: response));
      HomeEventBus.instance.notifysessionstart(response);

      Future.delayed(Duration(milliseconds: 100), () {
        emit(state.copyWith(sessionStartModel: null));
      });
    });
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
