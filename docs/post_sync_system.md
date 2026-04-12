# نظام مزامنة البوستات (Post Sync System)

## المشكلة اللي كانت موجودة

كل screen في الـ app كان عنده نسخته الخاصة من البوستات. لو عملت like على بوست في الـ Home، البوست نفسه في الـ Profile أو Search مش كان بيتحدث. كل cubit كان يشتغل بشكل منفصل.

---

## الحل: PostEventBus

عملنا نظام broadcast بسيط — أي action ناجح على أي بوست في أي مكان في الـ app بيبعت event، وكل الـ cubits التانية بتستمع وتطبق التغيير على نفسها لو البوست موجود عندهم.

---

## الملفات الجديدة

### `lib/core/utils/post_event_bus.dart`
الـ Bus نفسه — singleton stream بيستقبل ويوزع الـ events.

```dart
PostEventBus.instance.fire(PostEvent(...)); // بعت event
PostEventBus.instance.onPostEvent;          // استمع للـ events
```

### `lib/core/utils/post_event_listener_mixin.dart`
Mixin جاهز لأي cubit عنده `List<PostModel>`. بيضيف الاستماع والـ fire تلقائياً.

---

## أنواع الـ Events (PostEventType)

| Event | الوصف |
|-------|-------|
| `reacted` | اليوزر عمل like/reaction أو شاله |
| `shared` | اليوزر عمل share/repost أو شاله |
| `saved` | اليوزر حفظ البوست أو شال الحفظ |
| `deleted` | البوست اتحذف |
| `archived` | البوست اتأرشف |
| `hidden` | البوست اتخفى |
| `blocked` | اليوزر اتحظر (البوست يظهر كـ blocked وباقي بوستاته تتحذف) |
| `pollVoted` | اليوزر صوّت في poll |
| `commented` | اليوزر علّق (لتحديث isCommented/isAnonymous) |
| `commentCountUpdated` | عدد الكومنتات اتغير بـ delta |
| `commentCountSynced` | عدد الكومنتات اتزامن من الـ backend |
| `edited` | البوست اتعدّل |

---

## الـ Cubits المشاركة

| Cubit | يبعت Events | يستمع للـ Events |
|-------|-------------|-----------------|
| `HomeCubit` | ✅ كل الـ actions | ✅ من الـ cubits التانية |
| `ProfileCubit` | ✅ كل الـ actions | ✅ من الـ cubits التانية |
| `SearchCubit` | ✅ كل الـ actions | ✅ من الـ cubits التانية |
| `SavedPostsCubit` | ✅ كل الـ actions المتاحة | ✅ من الـ cubits التانية |
| `ArchivedPostsCubit` | ✅ كل الـ actions المتاحة | ✅ من الـ cubits التانية |
| `ReelsCubit` | ✅ react, share, save, edit | ✅ من الـ cubits التانية |
| `UserAdvisorProfileCubit` | ✅ كل الـ actions | ✅ من الـ cubits التانية |
| `UserPublicProfileCubit` | ✅ كل الـ actions | ✅ من الـ cubits التانية |

---

## الـ Flow خطوة بخطوة

### مثال: اليوزر عمل Like على بوست في الـ Search

```
1. اليوزر يضغط Like في SearchCubit
       ↓
2. SearchCubit يعمل Optimistic Update على نفسه (فوراً)
       ↓
3. SearchCubit يبعت API call للـ server
       ↓
4. لو نجح: SearchCubit يبعت PostEvent(type: reacted, sourceId: 'SearchCubit', ...)
       ↓
5. PostEventBus يوزع الـ event على كل المستمعين
       ↓
6. كل cubit تاني يستقبل الـ event:
   - لو sourceId == cubitsourceId → يتجاهله (عشان SearchCubit مش يطبق على نفسه مرتين)
   - لو البوست موجود في الـ list → يطبق التغيير
       ↓
7. HomeCubit, ProfileCubit, SavedPostsCubit, etc. كلهم يتحدثوا تلقائياً
```

### مثال: اليوزر حذف بوست من الـ Profile

```
1. ProfileCubit يشيل البوست من الـ list (Optimistic)
2. ProfileCubit يبعت API call
3. لو نجح: يبعت PostEvent(type: deleted, sourceId: 'ProfileCubit', postId: '...')
4. HomeCubit يستقبل الـ event → يشيل البوست من كل الـ categories
5. SearchCubit يستقبل الـ event → يشيله من posts tab و all tab
6. SavedPostsCubit يستقبل الـ event → يشيله من الـ saved list
7. كل screen بيعرض البوست ده بيتحدث فوراً
```

---

## كيف تضيف Cubit جديد للنظام

### لو الـ Cubit عنده `List<PostModel>` بسيطة:

```dart
class MyCubit extends Cubit<MyState>
    with PostEventListenerMixin<MyState> {

  MyCubit() : super(const MyState()) {
    subscribeToPostEvents(); // ابدأ الاستماع
  }

  @override
  List<PostModel> getPostList() => state.posts;

  @override
  void applyUpdatedPosts(List<PostModel> posts) =>
      emit(state.copyWith(posts: posts));

  @override
  Future<void> close() {
    cancelPostEventSubscription();
    return super.close();
  }

  // لما تعمل action ناجح، ابعت event:
  void reactToPost({required String postId, ReactionType? reactionType}) {
    // ... logic ...
    firePostEvent(PostEvent(
      type: PostEventType.reacted,
      postId: postId,
      reactionType: reactionType,
      likesCount: newLikesCount,
      topReactions: newTopReactions,
    ));
  }
}
```

### لو الـ Cubit عنده structure مختلفة (زي SearchCubit):

```dart
// اعمل StreamSubscription يدوي في الـ constructor
_postEventSub = PostEventBus.instance.onPostEvent.listen((event) {
  if (isClosed) return;
  if (event.sourceId == 'MyCubit') return; // تجاهل events نفسك
  _applyPostEvent(event);
});

// وفي close():
_postEventSub?.cancel();

// وابعت events بـ sourceId:
PostEventBus.instance.fire(PostEvent(
  sourceId: 'MyCubit',
  type: PostEventType.reacted,
  postId: postId,
  // ...
));
```

---

## نقطة مهمة: منع الـ Infinite Loop

كل cubit بيبعت الـ event بـ `sourceId` خاص بيه. لما يستقبل event، لو الـ `sourceId` بتاعه هو نفسه اللي بعت → يتجاهله. ده بيمنع إن الـ cubit يطبق نفس التغيير مرتين.

```
SearchCubit يبعت event بـ sourceId: 'SearchCubit'
    ↓
HomeCubit يستقبل → sourceId != 'HomeCubit' → يطبق ✅
SearchCubit يستقبل → sourceId == 'SearchCubit' → يتجاهل ✅
```

---

## ملاحظات

- الـ Optimistic Update بيتعمل في الـ cubit اللي عمل الـ action مباشرة (قبل الـ API).
- الـ event بيتبعت بس لما الـ API ينجح (مش في حالة الـ rollback).
- لو الـ API فشل، الـ cubit اللي عمل الـ action بيعمل rollback على نفسه بس، والـ cubits التانية مش محتاجة تعمل حاجة لأنها ما اتحدثتش أصلاً.
- الـ ReelsCubit بيستمع لكل الـ events بس بيبعت بس: react, share, save, edit (لأنه مش بيعمل delete/archive/hide/block من الـ UI).
