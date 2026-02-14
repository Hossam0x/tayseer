import 'dart:developer';

import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/shared/home/model/Image_and_name_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/home/view_model/home_event_bus.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/features/user/my_space/data/model/session_start_model.dart';
import '../../../../my_import.dart';
import '../reposiotry/home_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository homeRepository;
  static const int _pageSize = 5;

  HomeCubit(this.homeRepository) : super(const HomeState()) {
    _loadCachedUserData();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 INITIALIZATION & REFRESH
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحميل بيانات اليوزر من الكاش عند البداية
  void _loadCachedUserData() {
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
        // حفظ في الكاش
        CachNetwork.setData(key: kMyProfileImage, value: data.image);
        CachNetwork.setData(key: kMyProfileName, value: data.name);

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
    final categoryId = state.selectedCategoryId;
    final currentData = state.currentCategoryPosts;

    if (currentData.isLoadingMore || !currentData.hasMore) return;

    // تحديث حالة الـ loading more
    emit(
      state.updateCategoryPosts(
        categoryId,
        (data) => data.copyWith(isLoadingMore: true),
      ),
    );

    final nextPage = currentData.currentPage + 1;
    final result = await homeRepository.fetchPosts(
      page: nextPage,
      categoryId: categoryId,
    );

    result.fold(
      (failure) => emit(
        state.updateCategoryPosts(
          categoryId,
          (data) => data.copyWith(
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        ),
      ),
      (newPosts) => emit(
        state.updateCategoryPosts(
          categoryId,
          (data) => data.copyWith(
            posts: [...data.posts, ...newPosts],
            currentPage: nextPage,
            hasMore: newPosts.length >= _pageSize,
            isLoadingMore: false,
          ),
        ),
      ),
    );
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
          currentPage: 1,
          hasMore: true,
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
      (postsList) => emit(
        state.updateCategoryPosts(
          categoryId,
          (data) => data.copyWith(
            state: CubitStates.success,
            posts: postsList,
            currentPage: 1,
            hasMore: postsList.length >= _pageSize,
          ),
        ),
      ),
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

    // التحديث في كل الكاتيجوريز
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

    // API Call (Fire and forget)
    homeRepository.reactToPost(
      postId: postId,
      reactionType: reactionType,
      isRemove: isRemoving,
    );
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

  void toggleHidePost({required String postId}) {
    // 1. جيب البوست الحالي
    final post = _findPost(postId);
    if (post == null) return;

    // 2. اعكس الحالة
    final newHideState = !post.isHidden;

    // 3. Update UI فوراً
    emit(
      state.updatePostInAllCategories(
        postId,
        (p) => p.copyWith(isHidden: newHideState),
      ),
    );

    // 4. بعت للسيرفر في الـ Background
    homeRepository.hidePost(postId: postId, isHide: newHideState);
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
}
